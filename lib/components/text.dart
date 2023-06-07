import 'package:any_link_preview/any_link_preview.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/models.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class TextSegment extends StatelessWidget {
  final String text;
  final String? link;
  final bool preview;
  final bool boxed;
  const TextSegment({
    Key? key,
    required this.text,
    this.preview = false,
    this.boxed = false,
    this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: boxed
          ? const Color.fromARGB(227, 226, 226, 226)
          : const Color.fromRGBO(255, 255, 255, 0.9),
      width: MediaQuery.of(context).size.width - 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 50, left: 8.0, right: 8.0, bottom: 8.0),
                child: AutoTextSizer(text: text),
              ),
            ),
          ),
          link == null || link!.isEmpty
              ? const SizedBox()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: LinkSegment(link: link),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                )
        ],
      ),
    );
  }
}

class LinkSegment extends StatelessWidget {
  const LinkSegment({
    super.key,
    required this.link,
  });

  final String? link;

  @override
  Widget build(BuildContext context) {
    return AnyLinkPreview(
      link: link!,
      displayDirection: UIDirection.uiDirectionHorizontal,
      showMultimedia: true,
      bodyMaxLines: 5,
      previewHeight: 130,
      bodyTextOverflow: TextOverflow.ellipsis,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        height: 1.3,
      ),
      bodyStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        height: 1.2,
      ),
      errorWidget: Container(
        color: Colors.grey[500],
        child: Text('Bad Link! $link'),
      ),
      cache: const Duration(days: 3),
      backgroundColor: Colors.grey[100],
      borderRadius: 0,
      removeElevation: false,
      boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.grey)],
      onTap: () =>
          launchUrl(Uri.parse(link!), mode: LaunchMode.externalApplication),
    );
  }
}

class AutoTextSizer extends StatefulWidget {
  const AutoTextSizer({
    super.key,
    required this.text,
    this.align = TextAlign.center,
    this.subFont = 0,
  });

  final String text;
  final TextAlign? align;
  final double? subFont;

  @override
  State<AutoTextSizer> createState() => _AutoTextSizerState();
}

class _AutoTextSizerState extends State<AutoTextSizer> {
  String tapped = '';

  void _handleTap(String txt) {
    // Handle the tap event here
    setState(() {
      tapped = txt;
    });
  }

  String cleanWord({required String rawWord, String char = '#'}) {
    RegExp regex;
    if (char == '#') {
      regex = RegExp(r'\B#\w+\b');
    } else {
      regex = RegExp(r'\B@\w+\b');
    }

    final Iterable<Match> matches = regex.allMatches(rawWord);

    for (Match match in matches) {
      //final String hashtag = match.group(0);
      return match.group(0)!;
    }
    return rawWord;
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> textArray = [];
    for (String word in widget.text.split(' ')) {
      if (word.startsWith('#')) {
        String cleanedWord = cleanWord(rawWord: word);
        String extra = word.replaceAll(cleanedWord, '');
        String wordOnly = cleanedWord.replaceAll('#', '');
        textArray.addAll([
          TextSpan(
            text: tapped == word ? '[ #$wordOnly ]' : wordOnly,
            recognizer: TapGestureRecognizer()..onTap = () => _handleTap(word),
            style: TextStyle(
              color: htSolid3,
              backgroundColor: tapped == word ? htTrans1 : null,
              height: 1.5,
            ),
          ),
          TextSpan(
              text: extra.isEmpty ? ' ' : '$extra ',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black45,
                height: 1.5,
              ))
        ]);
      } else if (word.startsWith('@')) {
        String cleanedWord = cleanWord(rawWord: word, char: '@');
        String extra = word.replaceAll(cleanedWord, '');
        String wordOnly = cleanedWord.replaceAll('@', '');
        textArray.addAll([
          TextSpan(
            text: tapped == word ? '< @$wordOnly >' : wordOnly,
            recognizer: TapGestureRecognizer()..onTap = () => _handleTap(word),
            style: TextStyle(
              color: Colors.teal,
              backgroundColor: tapped == word ? htTrans1 : null,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: extra.isEmpty ? ' ' : '$extra ',
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black45,
              height: 1.5,
            ),
          ),
        ]);
      } else {
        textArray.add(TextSpan(
          text: '$word ',
          style: GoogleFonts.overpass(
              textStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            color: Colors.black45,
            height: 1.5,
          )),
        ));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AutoSizeText.rich(
        TextSpan(
          children: textArray,
        ),
        style: const TextStyle(
          fontSize: 40,
          color: Color.fromARGB(255, 49, 49, 49),
          height: 1.2,
        ),
        minFontSize: 16,
        maxLines: 5,
        textAlign: widget.align ??
            (widget.text.length > 50 ? TextAlign.left : TextAlign.center),
      ),
    );
  }
}

class NamingSegment extends StatelessWidget {
  const NamingSegment({
    super.key,
    required this.owner,
    required this.size,
    this.vertical = false,
    this.height = 1.5,
    this.fontDiff = 5,
    this.rowAlignment = MainAxisAlignment.center,
    this.colAlignment = CrossAxisAlignment.start,
    this.usernameColor = Colors.black54,
  });

  final UserProfile owner;
  final double size;
  final double height;
  final double fontDiff;
  final bool vertical;
  final Color usernameColor;
  final MainAxisAlignment rowAlignment;
  final CrossAxisAlignment colAlignment;

  @override
  Widget build(BuildContext context) {
    return vertical
        ? Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: colAlignment,
            children: namingWidgets.reversed.toList(),
          )
        : Row(
            mainAxisAlignment: rowAlignment,
            children: namingWidgets,
          );
  }

  List<Widget> get namingWidgets {
    return [
      Text(
        owner.name, //'owner.name h rt r h tbhebrb erbbw',
        style: defaultTextStyle.copyWith(
          fontSize: size,
          color: htSolid4,
          height: height,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(width: 5),
      Text(
        '@${owner.username}',
        style: defaultTextStyle.copyWith(
          fontSize: size - fontDiff,
          color: usernameColor,
          height: height,
        ),
      ),
    ];
  }
}
