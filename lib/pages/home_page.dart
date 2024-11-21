import 'package:flutter/material.dart';
import 'package:qit/animations/animated_background.dart';
import 'package:qit/animations/animated_homebutton.dart';
import 'package:qit/pages/create_room_page.dart';
import 'package:qit/pages/spotify_auth_page.dart';
import 'package:qit/pages/join_room_page.dart';
import 'package:qit/pages/login_page.dart';
import 'package:qit/services/secure_storage.dart';

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
  Future<bool> isUserAuthorized() async {
    String? isAuthorized = await SecureStorage.getItem("is_authorized");
    return isAuthorized == "true";
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: FractionallySizedBox(
          heightFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Use FutureBuilder to handle async state
              FutureBuilder<bool>(
                future: isUserAuthorized(),
                builder: (context, snapshot) {
                  // If error occurs, show an error message
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // If data is loaded, check if user is authorized
                  bool isAuthorized = snapshot.data ?? false;

                  return AnimatedHomeButton(
                    buttonText: "CREATE ROOM",
                    nextPage: isAuthorized
                        ? const CreateRoomPage()
                        : const LoginPage(),
                  );
                },
              ),
              const AnimatedHomeButton(
                buttonText: "JOIN ROOM",
                nextPage: JoinRoomPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
