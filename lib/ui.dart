import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api/generated.dart';
import 'config.dart';

const accent = Color(0xFF6797FF);
const surface = Color(0xFF151D30);
const muted = Color(0xFF9AAAC6);
ThemeData qitTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Raleway',
  scaffoldBackgroundColor: const Color(0xFF0A1020),
  colorScheme: ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
    surface: surface,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    scrolledUnderElevation: 0,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: const Color(0xFF091326),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF35415B)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
);

class Brand extends StatelessWidget {
  final double size;
  const Brand({super.key, this.size = 30});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'qIt',
    excludeSemantics: true,
    child: Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: 'q',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: 'It',
            style: TextStyle(color: accent),
          ),
        ],
      ),
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
      ),
    ),
  );
}

class PageShell extends StatelessWidget {
  final Widget child;
  final List<Widget> actions;
  final double width;
  const PageShell({
    super.key,
    required this.child,
    this.actions = const [],
    this.width = 1000,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: InkWell(onTap: () => context.go('/'), child: const Brand()),
      actions: [...actions, const SizedBox(width: 16)],
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (Config.demo)
            Container(
              width: double.infinity,
              color: const Color(0xFF1C2C46),
              padding: const EdgeInsets.all(8),
              child: const Text(
                'DEMO  ·  No music is sent to Spotify',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: width),
                child: child,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0xFF26314A)),
    ),
    child: child,
  );
}

class StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const StatusPill(this.text, {super.key, this.color = accent});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    ),
  );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    child: Column(
      children: [
        Icon(icon, size: 38, color: accent),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(color: muted, height: 1.6),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class AlbumArt extends StatelessWidget {
  final Track track;
  final double size;
  const AlbumArt(this.track, {super.key, this.size = 52});
  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4167C9), Color(0xFF6D4C92)],
        ),
      ),
      child: Icon(
        Icons.music_note_rounded,
        color: Colors.white70,
        size: size * .5,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: track.imageUrl.isEmpty
          ? placeholder
          : Image.network(
              track.imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stack) => placeholder,
            ),
    );
  }
}

class TrackInfo extends StatelessWidget {
  final Track track;
  final String? subtitle;
  final Widget? trailing;
  const TrackInfo(this.track, {super.key, this.subtitle, this.trailing});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      AlbumArt(track),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              track.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle ?? track.artists,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: muted, fontSize: 12, height: 1.4),
            ),
          ],
        ),
      ),
      if (trailing != null) ...[const SizedBox(width: 8), trailing!],
    ],
  );
}

void showMessage(BuildContext context, Object message) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message.toString())));
}

Future<void> runAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (e) {
    if (context.mounted) showMessage(context, e);
  }
}

Future<bool> confirm(
  BuildContext context,
  String title,
  String body, {
  String action = 'Confirm',
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
Future<void> openSpotify(Track track) async {
  final uri = Uri.tryParse(track.spotifyUrl);
  if (uri != null && uri.scheme == 'https' && uri.host == 'open.spotify.com') {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
