import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UtilsWidget {
  static Widget circularBorderTextFormField({
    required String hint,
    TextInputType textInputType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSave,
    String? Function(String?)? validator,
    FocusNode? focusNode,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    TextEditingController? controller,
  }) {
    return TextFormField(
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32.0),
        ),
      ),
      onSaved: onSave,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      obscureText: obscureText,
    );
  }
}
