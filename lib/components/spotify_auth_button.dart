import 'package:flutter/material.dart';

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
