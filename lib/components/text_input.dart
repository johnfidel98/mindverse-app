import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/models.dart' as aw;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindverse/components/button.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/chat.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class MVTextInput extends StatefulWidget {
  final String hintText;
  final String? validationMsg;
  final bool? obscureText;
  final bool? showLabel;
  final double labelFontSize;
  final TextEditingController controller;
  final Icon? prefixIcon;
  final Widget? suffixWidget;
  final EdgeInsets? padding;
  final TextInputType? inputType;
  final OutlineInputBorder? activeBorder;
  final Function? validator;
  final Function? onChanged;
  final Function? onTappedOutside;
  final Function? onTapped;
  final int? maxLines;
  final double? txtHeight;
  final double? paddingV;

  const MVTextInput({
    Key? key,
    required this.hintText,
    this.obscureText,
    required this.controller,
    this.prefixIcon,
    this.padding,
    this.labelFontSize = 16,
    this.validationMsg = "Invalid input detected!",
    this.inputType,
    this.activeBorder,
    this.validator,
    this.onChanged,
    this.onTappedOutside,
    this.onTapped,
    this.suffixWidget,
    this.maxLines = 1,
    this.showLabel = true,
    this.txtHeight = 1.8,
    this.paddingV = 1,
  }) : super(key: key);

  @override
  State<MVTextInput> createState() => _MVTextInputState();
}

class _MVTextInputState extends State<MVTextInput> {
  bool showPassword = false;

  void togglePassword() {
    setState(() {
      showPassword = !showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(defaultBorderRadius),
      borderSide: const BorderSide(
        color: htSolid3,
      ),
    );
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: TextFormField(
        maxLines: widget.maxLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: widget.onChanged != null
            ? (input) async => widget.onChanged!(input)
            : null,
        validator: widget.validator != null
            ? (input) => widget.validator!(input) ? null : widget.validationMsg
            : null,
        onTap: () => widget.onTapped != null ? widget.onTapped!() : null,
        onTapOutside: (event) => releaseFocus(
          context: context,
          onTappedOutside: widget.onTappedOutside,
        ),
        controller: widget.controller,
        keyboardType: widget.inputType ?? TextInputType.text,
        obscureText: widget.hintText.contains('Password')
            ? !showPassword
            : widget.obscureText ?? false,
        style: GoogleFonts.overpass(
            textStyle: TextStyle(
                fontSize: widget.labelFontSize, height: widget.txtHeight)),
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          label: widget.showLabel!
              ? Text(widget.hintText,
                  style: TextStyle(height: widget.txtHeight))
              : null,
          labelStyle: TextStyle(height: widget.txtHeight),
          //floatingLabelStyle: const TextStyle(color: Colors.black87),
          errorStyle: const TextStyle(fontSize: 14.0, height: 1.0),
          hintText: widget.hintText,
          hintStyle: GoogleFonts.overpass(
              textStyle: TextStyle(
                  fontSize: widget.labelFontSize, height: widget.txtHeight)),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.hintText.contains('Password')
              ? IconButton(
                  onPressed: togglePassword,
                  icon: Icon(
                    showPassword ? Icons.visibility_off : Icons.visibility,
                    color: htSolid3,
                  ),
                )
              : widget.suffixWidget,
          suffixIconColor: htSolid2,
          errorMaxLines: 1,
          hintMaxLines: 1,
          helperMaxLines: 1,
          contentPadding: EdgeInsets.symmetric(
            vertical: widget.paddingV!,
            horizontal: widget.prefixIcon != null ? 0 : 15,
          ),
          enabledBorder: widget.activeBorder ?? defaultBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: const BorderSide(color: htSolid4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: const BorderSide(
              color: Colors.redAccent,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.isGroup,
    required this.entitiesId,
  });

  final bool isGroup;
  final String entitiesId;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();
  final ChatController cc = Get.find<ChatController>();

  final TextEditingController ec = TextEditingController();

  String text = '';
  bool isPosting = false;
  bool isAttaching = false;
  UserProfile profile = UserProfile(username: unknownBastard);
  List<Map> uploadedMedia = [];

  @override
  void initState() {
    super.initState();

    // listen to input events
    ec.addListener(handleInput);

    // add observer
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => postInit());
  }

  void postInit() async {
    // load my profile
    UserProfile myProfile = await sc.getProfile(uname: sc.username.value);

    setState(() {
      profile = myProfile;
    });
  }

  void handleInput() => setState(() => text = ec.text);

  void onSend() async {
    // check if message is not empty
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kindly type something... down here!")),
      );
      return;
    }
    // mark posting
    setState(() {
      isPosting = true;
    });

    // post message
    Map uploadData = {
      'text': text,
      'sourceId': sc.username.value,
      'entitiesId': widget.entitiesId,
      'toGroup': widget.isGroup,
    };

    // attach media if present
    List<String> imUp = [];
    for (Map mUp in uploadedMedia) {
      if (mUp['media'] == 'video') {
        // set video to upload
        uploadData['video'] = mUp['id'];
        break;
      } else {
        imUp.add(mUp['id']);
      }
    }
    if (imUp.isNotEmpty) {
      // set images to upload
      uploadData['images'] = imUp;
    }

    await cc.postMessage(ses: sc, data: uploadData).then((mDoc) {
      // clean message
      ec.text = '';

      // reset state
      setState(() {
        isPosting = false;
        uploadedMedia = [];
        isAttaching = false;
      });
    });
  }

  void onAttach() => setState(() => isAttaching = !isAttaching);

  _removeMedia(Map mData) async {
    // remove unwanted media
    String bkt = 'chat_images';
    if (mData['media'] == 'video') {
      bkt = 'chat_videos';
    }
    await sc.delFile(bucket: bkt, fileId: mData['id']).then((_) {
      // remove media from list & update state
      List<Map> uMedia = uploadedMedia;
      uMedia.removeWhere((Map e) => e['id'] == mData['id']);
      setState(() {
        uploadedMedia = uMedia;
      });
    });
  }

  _selectImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> ims = await picker.pickMultiImage();

    List<Map> ui = [];
    for (XFile i in ims) {
      // upload group logo
      await sc.uploadFile(
          bucket: 'chat_images',
          f: {'name': i.name, 'path': i.path}).then((aw.File file) {
        // add to temp list
        ui.add({'media': 'image', 'id': file.$id});
      });
    }

    // update state
    setState(() {
      uploadedMedia = ui;
      isAttaching = true;
    });
  }

  _selectVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? i = await picker.pickVideo(source: ImageSource.gallery);

    if (i != null) {
      // upload group logo
      await sc.uploadFile(
          bucket: 'chat_videos',
          f: {'name': i.name, 'path': i.path}).then((aw.File file) {
        // update state
        setState(() {
          uploadedMedia = [
            {
              'media': 'video',
              'id': file.$id,
              'mime': file.mimeType,
              'name': file.name,
              'size': (file.sizeOriginal / 1000000).ceil(),
            }
          ];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn,
          height: isAttaching ? 80 : 2,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey.shade200,
          child: uploadedMedia.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: uploadedMedia.length,
                  itemBuilder: (BuildContext context, int index) {
                    Map m = uploadedMedia[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 5.0),
                      child: Container(
                        child: m['media'] == 'video'
                            ? VideoPath(remove: () => _removeMedia(m), data: m)
                            : Stack(
                                children: [
                                  ImagePath(
                                    bucket: 'chat_images',
                                    imageId: m['id'],
                                    size: 70,
                                    isCircular: true,
                                  ),
                                  GestureDetector(
                                    onTap: () => _removeMedia(m),
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    );
                  },
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ConversationButton(
                      label: 'Image',
                      onPressed: _selectImage,
                      iconData: Icons.photo_library,
                    ),
                    // ConversationButton(
                    //   label: 'Video',
                    //   onPressed: _selectVideo,
                    //   middle: true,
                    //   iconData: Icons.video_library,
                    // ),
                    // ConversationButton(
                    //   label: 'Link',
                    //   onPressed: () {},
                    //   iconData: Icons.link,
                    // ),
                  ],
                ),
        ),
        TextFormField(
          maxLines: 5,
          minLines: 1,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onTapOutside: (event) => releaseFocus(context: context),
          controller: ec,
          keyboardType: TextInputType.text,
          style: GoogleFonts.overpass(
              textStyle: const TextStyle(fontSize: 18, height: 1.5)),
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            labelStyle: const TextStyle(height: 1.5),
            errorStyle: const TextStyle(fontSize: 18.0, height: 1.5),
            hintText: 'I heard a roumor! 🤫',
            hintStyle: GoogleFonts.overpass(
                textStyle: const TextStyle(fontSize: 18, height: 1.7)),
            prefixIcon: Material(
              child: IconButton(
                onPressed: _selectImage,
                icon: const Icon(
                  Icons.photo,
                  color: htSolid5,
                ),
              ),
            ),
            suffixIcon: Material(
              child: IconButton(
                onPressed: onSend,
                icon: const Icon(
                  Icons.send_rounded,
                  color: htSolid5,
                ),
              ),
            ),
            suffixIconColor: htSolid2,
            errorMaxLines: 1,
            hintMaxLines: 1,
            helperMaxLines: 1,
            contentPadding: const EdgeInsets.symmetric(vertical: 5),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: htSolid4),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: Colors.redAccent,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // remove text listener
    ec.removeListener(handleInput);

    super.dispose();
  }
}
