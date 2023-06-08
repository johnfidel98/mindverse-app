import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:visibility_detector/visibility_detector.dart';

var uuid = const Uuid();

class VideoSegment extends StatefulWidget {
  final String video;
  final String id;
  final Message? message;
  final bool fullScreen;
  final bool? independent;

  const VideoSegment(
      {super.key,
      required this.video,
      required this.id,
      this.fullScreen = false,
      this.message,
      this.independent = false});

  @override
  State<VideoSegment> createState() => _VideoSegmentState();
}

class _VideoSegmentState extends State<VideoSegment> {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  late StreamSubscription _listenerMuter;

  bool bufferingVideo = false;
  bool mutedVideo = true;
  bool pausedVideo = false;
  bool isDisposed = false;
  int _streamPosition = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([]);

    _controller = VideoPlayerController.network(widget.video)
      ..initialize().then((value) {
        if (widget.fullScreen) {
          for (var vid in cc.videoPosition.keys) {
            if ('fs-$vid' == widget.id) {
              // resume video
              _controller
                  .seekTo(Duration(seconds: cc.videoPosition[vid] - 2))
                  .then((_) {
                _controller.play();
              });
            }
          }
        }
      });

    if (cc.muteVideos.value) {
      _controller.setVolume(0.0);
    } else {
      _controller.setVolume(1.0);
      mutedVideo = false;
    }

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      looping: true,
      showOptions: false,
      allowMuting: false,
      allowFullScreen: false,
      showControls: false,
    );

    _listenerMuter = cc.muteVideos.listen((mute) {
      // listen to any mute event and apply changes
      if (!isDisposed) {
        if (mute && _controller.value.volume > 0.0) {
          _controller.setVolume(0.0);
        } else if (!mute && _controller.value.volume == 0.0) {
          _controller.setVolume(1.0);
        }
      }
    });

    _controller.addListener(() {
      // listen to video state events and update ui
      if (!isDisposed) {
        if (_controller.value.isBuffering && !bufferingVideo) {
          setState(() {
            bufferingVideo = true;
          });
        } else if (!_controller.value.isBuffering && bufferingVideo) {
          setState(() {
            bufferingVideo = false;
          });
        }

        if (_controller.value.isPlaying &&
            _streamPosition != _controller.value.position.inSeconds) {
          setState(() {
            _streamPosition = _controller.value.position.inSeconds;
          });
          cc.setCurrentVideoPosition(
              widget.id, _controller.value.position.inSeconds);
        }

        if ((_controller.value.volume > 0 && mutedVideo) ||
            (_controller.value.volume == 0 && !mutedVideo)) {
          setState(() {
            mutedVideo = _controller.value.volume == 0;
          });
          cc.setGlobalMute(mutedVideo);
        }
      }
    });
  }

  @override
  void dispose() {
    // dispose listeners and controllers when widget is exiting
    _listenerMuter.cancel();

    _chewieController.dispose();
    _controller.dispose();

    isDisposed = true;

    super.dispose();
  }

  void pauseVideoAction() {
    if (_controller.value.isPlaying) {
      _chewieController.pause();
      setState(() {
        pausedVideo = true;
      });
    }
  }

  void openFullScreen() => Navigator.of(context).push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'VideoViewer'),
          builder: (BuildContext context) {
            // if (widget.message != null) {
            //   return ViewerDetailPage(message: widget.message!);
            // }

            return StatusBarColorObserver(
              child: VideoSegment(
                video: widget.video,
                id: 'fs-${widget.id}',
                fullScreen: true,
                independent: true,
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      margin: const EdgeInsets.only(top: 1.3),
      child: VisibilityDetector(
        key: Key('video-${uuid.v4()}'),
        onVisibilityChanged: (visibilityInfo) {
          var visiblePercentage = visibilityInfo.visibleFraction * 100;
          if (!isDisposed) {
            if (visiblePercentage > 70) {
              if (!_controller.value.isPlaying && !pausedVideo) {
                _chewieController.play();
                setState(() {
                  pausedVideo = false;
                });
              }
            } else {
              if (_controller.value.isPlaying) _chewieController.pause();
            }
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.fullScreen
                  ? pauseVideoAction
                  : () {
                      pauseVideoAction();
                      openFullScreen();
                    },
              child: Chewie(
                controller: _chewieController,
              ),
            ),
            if (bufferingVideo || !_controller.value.isInitialized)
              Positioned(
                child: Center(
                  child: SizedBox(
                      height: 160,
                      width: 160,
                      child: CircularProgressIndicator(
                        strokeWidth: _controller.value.isInitialized ? 1 : 2,
                        color: _controller.value.isInitialized
                            ? htSolid4
                            : Colors.white,
                      )),
                ),
              ),
            if (pausedVideo ||
                bufferingVideo ||
                !_controller.value.isInitialized)
              Positioned(
                child: GestureDetector(
                  onTap: widget.fullScreen ? null : openFullScreen,
                  child: Container(
                    color: Colors.black45,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
              ),
            if (widget.independent!)
              const Positioned(
                right: 20,
                top: 50,
                child: CloseCircleButton(),
              ),
            Positioned(
              bottom: widget.fullScreen ? 0 : 37,
              left: widget.fullScreen ? 0 : 50,
              right: widget.fullScreen ? 0 : 50,
              top: widget.fullScreen ? 0 : null,
              child: Center(
                child: widget.fullScreen
                    ? GestureDetector(
                        onTap: pauseVideoAction,
                        child: SizedBox(
                          height: 120,
                          width: 120,
                          child: CircularProgressIndicator(
                            value: calcProgress,
                            strokeWidth: 0.5,
                            backgroundColor: htTrans1,
                          ),
                        ))
                    : VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        colors: const VideoProgressColors(
                          playedColor: htSolid4,
                          bufferedColor: htTrans2,
                          backgroundColor: htTrans1,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 15,
              right: 20,
              child: Material(
                color: htTrans2,
                shape: const CircleBorder(
                  side: BorderSide(width: 1, color: htSolid4),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      if (_controller.value.volume == 0.0) {
                        _controller.setVolume(1.0);
                        mutedVideo = false;
                      } else {
                        _controller.setVolume(0.0);
                        mutedVideo = true;
                      }
                    });
                    //sc.setGlobalMute(mutedVideo);
                  },
                  icon: Icon(
                    mutedVideo ? Icons.volume_mute : Icons.volume_up,
                    color: htSolid4,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: widget.fullScreen ? 0 : 15,
              right: widget.fullScreen ? 0 : null,
              left: widget.fullScreen ? 0 : 15,
              top: widget.fullScreen ? 0 : null,
              child: Center(
                child: SizedBox(
                  height: widget.fullScreen
                      ? pausedVideo ||
                              bufferingVideo ||
                              !_controller.value.isInitialized
                          ? 80
                          : 0
                      : 50,
                  width: widget.fullScreen
                      ? pausedVideo ||
                              bufferingVideo ||
                              !_controller.value.isInitialized
                          ? 80
                          : 0
                      : 50,
                  child: Material(
                    color: htTrans2,
                    shape: const CircleBorder(
                      side: BorderSide(width: 1, color: htSolid4),
                    ),
                    child: IconButton(
                      iconSize: widget.fullScreen
                          ? pausedVideo ||
                                  bufferingVideo ||
                                  !_controller.value.isInitialized
                              ? 45
                              : 0
                          : 30,
                      onPressed: () {
                        setState(() {
                          if (_controller.value.isPlaying) {
                            _controller.pause();
                            pausedVideo = true;
                          } else {
                            _controller.play();
                            pausedVideo = false;
                          }
                        });
                      },
                      icon: Icon(
                        pausedVideo ? Icons.play_arrow : Icons.pause,
                        color: htSolid4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get calcProgress {
    if (_controller.value.duration.inSeconds > 0) {
      return _streamPosition / _controller.value.duration.inSeconds;
    }

    return 0.0;
  }
}
