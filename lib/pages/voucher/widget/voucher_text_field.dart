import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcplus/themes/palette/palette.dart';
import 'package:pcplus/themes/text_decor.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.initialValue,
    this.validator,
    this.maxLines,
    this.minLines,
    this.keyboardType,
    this.onChanged,
    this.inputFormatters,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextDecor.robo16,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Palette.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}