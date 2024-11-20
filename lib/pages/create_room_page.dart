import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qit/services/api.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateRoomPage extends StatelessWidget {
  const CreateRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CREATE ROOM",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: const SpotifyAuth(),
    );
  }
}

class SpotifyAuthButton extends StatelessWidget {
  final Function onPressed;
  final String? url;
  final double fontSize;
  final bool error;

  const SpotifyAuthButton(
      {super.key,
      required this.onPressed,
      required this.url,
      required this.fontSize,
      required this.error});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Center(
                child: Text(
                  "Error fetching URL, try again later",
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          );
        }
        onPressed(url); // Use the fetched URL
      },
      style: const ButtonStyle(
        shadowColor: WidgetStatePropertyAll(Colors.white),
        backgroundColor: WidgetStatePropertyAll(
          Color.fromARGB(255, 29, 185, 84),
        ),
        foregroundColor: WidgetStatePropertyAll(Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: Text(
          "Log In",
          style: TextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}

class SpotifyAuth extends StatefulWidget {
  const SpotifyAuth({super.key});

  @override
  State<SpotifyAuth> createState() => _SpotifyAuthState();
}

class _SpotifyAuthState extends State<SpotifyAuth>
    with SingleTickerProviderStateMixin {
  late Future<String> _futureURL;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  double _opacity = 0;

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      print("Could not launch the URL");
    }
  }

  void _handleApiError(String? url) {
    print("handle this");
  }

  @override
  void initState() {
    super.initState();
    _futureURL = Api().getAuthURL();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          _opacity = 1;
        });
        _controller.forward();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = MediaQuery.of(context).size.width * 0.05;

    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      child: SlideTransition(
        position: _offsetAnimation,
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Please authenticate with Spotify.",
                  style: TextStyle(
                    fontSize: fontSize,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/Primary_Logo_Black_PMS_C.svg',
                    height: MediaQuery.of(context).size.height / 7,
                  ),
                ),
              ),

              // Use FutureBuilder to handle the async URL fetch
              FutureBuilder<String>(
                future: _futureURL,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show loading indicator
                  } else if (snapshot.hasError) {
                    return SpotifyAuthButton(
                      onPressed: _handleApiError,
                      url: null,
                      fontSize: fontSize,
                      error: true,
                    ); // Handle errors
                  } else if (!snapshot.hasData) {
                    return const Text('No URL available'); // Handle no data
                  } else {
                    String url = snapshot.data!; // Get the URL from the future
                    return SpotifyAuthButton(
                      onPressed: _launchURL,
                      url: url,
                      fontSize: fontSize,
                      error: false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
