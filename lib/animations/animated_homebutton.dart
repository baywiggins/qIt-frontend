import 'package:flutter/material.dart';
import 'package:qit/animations/animated_fade_route.dart';

class AnimatedHomeButton extends StatefulWidget {
  final String buttonText;
  final Widget nextPage;

  const AnimatedHomeButton(
      {super.key, required this.buttonText, required this.nextPage});

  @override
  State<AnimatedHomeButton> createState() => _AnimatedHomeButtonState();
}

class _AnimatedHomeButtonState extends State<AnimatedHomeButton>
    with RouteAware {
  double _scale = 1.0;
  double _textOpacity = 0.7;
  double _outlineOpacity = 0.1;
  double _buttonOpacity = 0.3;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.95;
      _textOpacity = 1;
      _outlineOpacity = 1;
      _buttonOpacity = 0.35;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 4.0;
      _textOpacity = 0;
      _outlineOpacity = 0;
      _buttonOpacity = 1;
    });
  }

  void _resetAnimationState() {
    setState(() {
      _scale = 1.0;
      _textOpacity = 0.7;
      _outlineOpacity = 0.1;
      _buttonOpacity = 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * 0.05;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(child: widget.nextPage),
        ).then((_) => _resetAnimationState());
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => setState(() {
        _scale = 1.0;
        _textOpacity = 0.7;
        _outlineOpacity = 0.1;
        _buttonOpacity = 0.3;
      }),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding:
              const EdgeInsets.all(120), // Reduce padding to allow more space
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(248, 248, 248, _buttonOpacity),
            border: Border.all(
              color: Color.fromRGBO(24, 0, 0, _outlineOpacity),
              width: 2.0,
            ),
          ),
          child: Opacity(
            opacity: _textOpacity,
            child: FittedBox(
              fit: BoxFit.contain, // Ensures text fits and doesn't overflow
              child: Text(
                widget.buttonText,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
