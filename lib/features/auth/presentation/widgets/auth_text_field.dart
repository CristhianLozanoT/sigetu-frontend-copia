import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.focusNode,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      autocorrect: autocorrect && !obscureText,
      enableSuggestions: enableSuggestions && !obscureText,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
