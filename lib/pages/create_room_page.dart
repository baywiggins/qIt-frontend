import 'package:flutter/material.dart';
import 'package:qit/animations/animated_fade_route.dart';
import 'package:qit/pages/home_page.dart';
import 'package:qit/services/api.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                if (_isPlaying) {
                  Api.pauseSpotify();
                } else {
                  Api.playSpotify();
                }
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              child: _isPlaying
                  ? Icon(
                      Icons.pause_circle_filled,
                      size: 300,
                    )
                  : Icon(
                      Icons.play_circle_filled,
                      size: 300,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
