import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final bool isObscure;
  final TextEditingController controller;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.hint,
    this.isObscure = false,
    required this.controller,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF3F63F4)),
          ),
        ),
      ),
    );
  }
}
