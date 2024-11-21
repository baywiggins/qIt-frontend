import 'package:flutter/material.dart';

class SubmitButton extends StatefulWidget {
  final Function()? onTap;
  final String buttonText;

  const SubmitButton(
      {super.key, required this.onTap, required this.buttonText});

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  double _scale = 1.0;

  void _onTap() {
    setState(() {
      _scale = 0.95;
    });
  }

  void _onTapUp() {
    setState(() {
      _scale = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTap: () {
          widget.onTap?.call();
        },
        onTapUp: (details) {
          _onTapUp();
        },
        onTapCancel: () => setState(() {
          _scale = 1;
        }),
        onTapDown: (details) => {_onTap()},
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.085,
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(50)),
          child: Center(
            child: Text(
              widget.buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
