import 'package:flutter/material.dart';
import 'package:qit/pages/animated_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          BackgroundAnimation(),
          Center(
            child: FractionallySizedBox(
              heightFactor: 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeButton(
                    child: Text(
                      "CREATE ROOM",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  HomeButton(
                    child: Text(
                      "JOIN ROOM",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  final Widget child;

  const HomeButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.5),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(120),
        // side: const BorderSide(
        //   color: Colors.black,
        //   width: 5.0,
        // ),
      ),
      child: child,
    );
  }
}
