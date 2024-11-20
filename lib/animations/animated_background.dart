import 'package:flutter/material.dart';

class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({super.key});

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorOneAnimation;
  late Animation<Color?> _colorTwoAnimation;
  late Animation<Color?> _colorThreeAnimation;

  final _colorOne = const Color.fromARGB(255, 124, 159, 255);
  final _colorTwo = const Color.fromARGB(255, 85, 201, 255);
  final _colorThree = const Color.fromRGBO(14, 103, 255, 1);

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController first
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _colorOneAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorOne, end: _colorThree),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorThree, end: _colorTwo),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorTwo, end: _colorOne),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _colorTwoAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorTwo, end: _colorOne),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorOne, end: _colorThree),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorThree, end: _colorTwo),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    _colorThreeAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorThree, end: _colorTwo),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorTwo, end: _colorOne),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: _colorOne, end: _colorThree),
          weight: 1,
        ),
      ],
    ).animate(_controller);

    // Start the animation after initializing all animations
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Always dispose of the controller to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorOneAnimation.value ?? _colorOne,
                    _colorTwoAnimation.value ?? _colorTwo,
                    _colorThreeAnimation.value ?? _colorThree,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            );
          }),
    );
  }
}
