import 'package:flutter/material.dart';
import 'package:qit/animations/animated_background.dart';
import 'package:qit/animations/animated_homebutton.dart';
import 'package:qit/pages/create_room_page.dart';
import 'package:qit/pages/join_room_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          BackgroundAnimation(),
          HomeButtons(),
        ],
      ),
    );
  }
}

class HomeButtons extends StatefulWidget {
  const HomeButtons({super.key});

  @override
  State<HomeButtons> createState() => _HomeButtonsState();
}

class _HomeButtonsState extends State<HomeButtons> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FractionallySizedBox(
        heightFactor: 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AnimatedHomeButton(
              buttonText: "CREATE ROOM",
              nextPage: CreateRoomPage(),
            ),
            AnimatedHomeButton(
              buttonText: "JOIN ROOM",
              nextPage: JoinRoomPage(),
            ),
          ],
        ),
      ),
    );
  }
}
