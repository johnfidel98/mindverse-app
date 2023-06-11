import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
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
  UserProfile profile = UserProfile(username: unknownBastard);

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
    await cc.postMessage(ses: sc, data: {
      'text': text,
      'sourceId': sc.username.value,
      'entitiesId': widget.entitiesId,
      'toGroup': widget.isGroup,
    }).then((mDoc) {
      // add message to messages
      cc.addMessage(Message.fromDoc(doc: mDoc, profile: profile));

      // clean message
      ec.text = '';

      setState(() {
        isPosting = false;
      });
    });
  }

  void onAttached() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(thickness: 1, color: htSolid5, height: 1),
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
                onPressed: onAttached,
                icon: Transform.rotate(
                    angle: 40 * math.pi / 180,
                    child: const Icon(
                      Icons.attach_file,
                      color: htSolid5,
                    )),
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
