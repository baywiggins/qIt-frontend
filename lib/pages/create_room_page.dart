import 'package:flutter/material.dart';
import 'package:qit/animations/animated_fade_route.dart';
import 'package:qit/components/play_pause_button.dart';
import 'package:qit/pages/home_page.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, FadeRoute(child: const HomePage()));
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // PlayPauseButton(),
          ],
        ),
      ),
    );
  }
}
