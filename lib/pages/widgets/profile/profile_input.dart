import 'package:flutter/material.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ProfileInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool? obscureText;
  final String? errorText;
  final IconData? icon;
  const ProfileInput({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.errorText,
    this.icon,
  });

  @override
  State<ProfileInput> createState() => _ProfileInputState();
}

class _ProfileInputState extends State<ProfileInput> {
  late bool isObscure;
  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText!;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      cursorColor: Palette.primaryColor,
      style: TextDecor.robo16Medi,
      obscureText: isObscure,
      decoration: InputDecoration(
        errorText: widget.errorText,
        errorStyle: TextDecor.profileHintText.copyWith(
          color: Colors.red,
        ),
        hintText: widget.hintText,
        hintStyle: TextDecor.profileHintText,
        prefixIcon: Icon(
          widget.icon,
          size: 25,
          color: widget.errorText != null ? Colors.red : Palette.hintText,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Palette.hintText,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Palette.primaryColor,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        suffixIcon: widget.obscureText!
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(
                  isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Palette.hintText,
                ),
              )
            : null,
      ),
    );
  }
}
