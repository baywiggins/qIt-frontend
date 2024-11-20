import 'package:flutter/material.dart';

class HomePageRoute extends PageRouteBuilder {
  final Widget child;
  HomePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(
                0,
                0.7,
                curve: Curves.easeOut,
              ),
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
}
