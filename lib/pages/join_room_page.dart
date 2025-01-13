import 'package:flutter/material.dart';
import 'package:qit/services/secure_storage.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final TextEditingController _controller = TextEditingController();

  void _onPressed() async {
    var x = await SecureStorage.getItem("user_id");
    print(_controller.text + x!);
  }

  // Make sure to add a creation of a session ID when a user joins the room
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  controller: _controller,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _onPressed();
                },
                child: Text("123"),
              ),
            ],
          ),
        ));
  }
}
