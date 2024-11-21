import 'package:flutter/material.dart';

class LoginField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextNode;

  const LoginField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.nextNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction:
            nextNode == null ? TextInputAction.done : TextInputAction.next,
        onEditingComplete: () => nextNode == null
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).requestFocus(nextNode),
        decoration: InputDecoration(
          prefixText: "   ",
          hintText: hintText,
          hintFadeDuration: const Duration(milliseconds: 100),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(25))),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 3,
              ),
              borderRadius: BorderRadius.all(Radius.circular(100))),
        ),
      ),
    );
  }
}
