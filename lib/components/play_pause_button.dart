import 'package:flutter/material.dart';
import 'package:qit/services/api.dart';

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({super.key});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late Future<bool> _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = Api.spotifyController.isPlaying();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isPlaying,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Placeholder();
        } else if (!snapshot.hasData) {
          return const Placeholder();
        } else {
          bool isPlaying = snapshot.data!;
          return GestureDetector(
            onTap: () async {
              if (isPlaying) {
                await Api.spotifyController.pause();
              } else {
                await Api.spotifyController.play();
              }
              // Update the _isPlaying Future to reflect the new state
              setState(() {
                _isPlaying = Api.spotifyController.isPlaying();
              });
            },
            child: isPlaying
                ? const Icon(
                    Icons.pause_circle_filled,
                    size: 300,
                  )
                : const Icon(
                    Icons.play_circle_filled,
                    size: 300,
                  ),
          );
        }
      },
    );
  }
}
