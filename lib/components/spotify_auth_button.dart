import 'package:flutter/material.dart';
import 'package:qit/pages/spotify_auth_webview_page.dart';

class SpotifyAuthButton extends StatelessWidget {
  final String? url;
  final double fontSize;
  final bool error;

  const SpotifyAuthButton(
      {super.key,
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SpotifyAuthWebViewPage(
              url: url!,
            ),
          ),
        ); // Use the fetched URL
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
