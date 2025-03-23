import 'package:flutter/material.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class ButtonProfile extends StatefulWidget {
  final String name;
  final Function onPressed;
  const ButtonProfile({super.key, required this.name, required this.onPressed});

  @override
  State<ButtonProfile> createState() => _ButtonProfileState();
}

class _ButtonProfileState extends State<ButtonProfile> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50),
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Palette.main3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onPressed: () {
        widget.onPressed();
      },
      child: Text(
        widget.name,
        style: TextDecor.profileButtonText,
      ),
    );
  }
}
