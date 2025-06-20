import 'package:flutter/material.dart';
import 'package:pcplus/themes/text_decor.dart';

class AcceptButton extends StatelessWidget {
  final Function()? onPressed;
  final String name;
  const AcceptButton({super.key, this.name = 'Chấp nhận', this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 50),
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: name.isEmpty
          ? Text(
              'Từ chối',
              style: TextDecor.profileTextButton.copyWith(color: Colors.white),
            )
          : Text(
              name,
              style: TextDecor.profileTextButton.copyWith(color: Colors.white),
            ),
    );
  }
}
