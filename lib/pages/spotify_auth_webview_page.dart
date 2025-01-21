import 'package:flutter/material.dart';
import 'package:qit/pages/create_room_page.dart';
import 'package:qit/pages/spotify_auth_page.dart';
import 'package:qit/services/api.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyAuthWebViewPage extends StatefulWidget {
  final String url;
  const SpotifyAuthWebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<SpotifyAuthWebViewPage> createState() => _SpotifyAuthWebViewPageState();
}

class _SpotifyAuthWebViewPageState extends State<SpotifyAuthWebViewPage> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int process) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _handleBackButton() async {
    bool isAuthorized = await Api.checkAndUpdateAuthStatus();
    if (isAuthorized) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const CreateRoomPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from the right
            const end = Offset.zero; // End at the current position
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SpotifyAuthPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        leading: IconButton(
          onPressed: _handleBackButton,
          icon: const Icon(
            Icons.check,
            size: 40,
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
