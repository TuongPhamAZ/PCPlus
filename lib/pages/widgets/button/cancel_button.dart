import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';

class CancelButton extends StatelessWidget {
  final Function()? onPressed;
  final String name;
  const CancelButton({super.key, this.name = 'HỦY', this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 50),
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: name.isEmpty
          ? Text(
              'Hủy',
              style: TextDecor.profileTextButton.copyWith(color: Colors.white),
            )
          : Text(
              name,
              style: TextDecor.profileTextButton.copyWith(color: Colors.white),
            ),
    );
  }
}
