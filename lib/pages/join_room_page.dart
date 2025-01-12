import 'package:flutter/material.dart';

class JoinRoomPage extends StatelessWidget {
  const JoinRoomPage({super.key});
  // Make sure to add a creation of a session ID when a user joins the room
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      ),
      body: Container(
        color: const Color.fromARGB(255, 248, 248, 248),
      ),
    );
  }
}
