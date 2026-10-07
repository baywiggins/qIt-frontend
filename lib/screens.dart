import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api/generated.dart';
import 'config.dart';
import 'providers.dart';
import 'ui.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});
  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final code = TextEditingController();
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  void join() {
    final value = code.text.trim().toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(value)) {
      showMessage(context, 'Enter the eight-character room code.');
      return;
    }
    context.go('/r/$value');
  }

  @override
  Widget build(BuildContext context) => PageShell(
    actions: [
      TextButton(
        onPressed: () => context.go('/host'),
        child: const Text('Host a room'),
      ),
    ],
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StatusPill('YOUR PEOPLE. YOUR SOUNDTRACK.'),
          const SizedBox(height: 24),
          const Text(
            'Good music.\nA group decision.',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              height: 1.08,
              letterSpacing: -1.8,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Request a song. Rally your friends.\nLet the room decide what plays next.',
            style: TextStyle(color: muted, fontSize: 18, height: 1.6),
          ),
          const SizedBox(height: 36),
          LayoutBuilder(
            builder: (context, c) {
              final joinPanel = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find your room',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Scan the host’s QR code or enter the code below.\nNo account. No app required.',
                      style: TextStyle(color: muted, height: 1.6),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      key: const Key('room-code'),
                      controller: code,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 8,
                      decoration: const InputDecoration(
                        labelText: 'Room code',
                        hintText: 'e.g. MANGO123',
                        counterText: '',
                      ),
                      onSubmitted: (_) => join(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('join-room'),
                        onPressed: join,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Join the room'),
                      ),
                    ),
                  ],
                ),
              );
              const demo = Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.graphic_eq_rounded, color: accent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'THE ROOM IS IN CONTROL',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _PreviewSong('Midnight City', 'M83', '3 / 3', true),
                    SizedBox(height: 18),
                    _PreviewSong('Electric Feel', 'MGMT', '2 / 3', false),
                    SizedBox(height: 18),
                    _PreviewSong(
                      'Sweet Disposition',
                      'The Temper Trap',
                      '1 / 3',
                      false,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'A little democracy for the dance floor.',
                      style: TextStyle(color: muted, height: 1.5),
                    ),
                  ],
                ),
              );
              return c.maxWidth > 760
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: joinPanel),
                        const SizedBox(width: 24),
                        const Expanded(child: demo),
                      ],
                    )
                  : Column(
                      children: [joinPanel, const SizedBox(height: 24), demo],
                    );
            },
          ),
          const SizedBox(height: 36),
          const Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _Step('01', 'Request something good'),
              _Step('02', 'Vote it up'),
              _Step('03', 'Hear it on Spotify'),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Icon(Icons.headphones_rounded, color: muted, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: () => context.go('/host'),
                  child: const Text('On music duty? Start a room →'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _Step extends StatelessWidget {
  final String number, title;
  const _Step(this.number, this.title);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        number,
        style: const TextStyle(color: accent, fontWeight: FontWeight.w700),
      ),
      const SizedBox(width: 10),
      Text(title, style: const TextStyle(color: muted, fontSize: 12)),
    ],
  );
}

class _PreviewSong extends StatelessWidget {
  final String title, artist, votes;
  final bool approved;
  const _PreviewSong(this.title, this.artist, this.votes, this.approved);
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.music_note_rounded, color: accent),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(artist, style: const TextStyle(fontSize: 12, color: muted)),
          ],
        ),
      ),
      StatusPill(
        approved ? 'Queued ✓' : votes,
        color: approved ? const Color(0xFF85D6B2) : accent,
      ),
    ],
  );
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool busy = false;
  Future<void> submit() async {
    setState(() => busy = true);
    try {
      final url = await ref.read(sessionProvider).spotifyLoginUrl();
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_self',
      )) {
        throw 'Could not open Spotify sign-in. Try again.';
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageShell(
    width: 500,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.headphones_rounded, color: accent, size: 40),
          const SizedBox(height: 20),
          const Text(
            'Your Spotify.\nEveryone’s soundtrack.',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in with Spotify and come straight back here. Create a room, queue songs, and control the music from qIt.',
            style: TextStyle(color: muted, height: 1.6),
          ),
          const SizedBox(height: 28),
          if (!Config.demo)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : submit,
                icon: const Icon(Icons.login_rounded),
                label: Text(
                  busy ? 'Opening Spotify…' : 'Continue with Spotify',
                ),
              ),
            ),
          if (Config.demo)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => runAction(context, () async {
                        final api = ref.read(apiProvider);
                        final result = await api.devLogin();
                        ref.read(sessionProvider).useDemo(result.accessToken);
                        await api.connectSpotify();
                        if (context.mounted) context.go('/host');
                      }),
                icon: const Icon(Icons.science_outlined),
                label: const Text('Explore as demo host'),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Guests never need an account. Hosts need Spotify Premium and an available Spotify Connect device.',
            style: TextStyle(color: muted, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    ),
  );
}

class SpotifyCallbackPage extends ConsumerStatefulWidget {
  final Uri uri;
  const SpotifyCallbackPage({super.key, required this.uri});
  @override
  ConsumerState<SpotifyCallbackPage> createState() => _SpotifyCallbackState();
}

class _SpotifyCallbackState extends ConsumerState<SpotifyCallbackPage> {
  Object? error;
  @override
  void initState() {
    super.initState();
    finish();
  }

  Future<void> finish() async {
    try {
      await ref
          .read(sessionProvider)
          .completeSpotifyLogin(widget.uri, ref.read(apiProvider));
      if (mounted) context.go('/host');
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  Widget build(BuildContext context) => PageShell(
    width: 500,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (error == null) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Finishing Spotify sign-in…'),
            ] else ...[
              Text('$error', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to sign-in'),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class HostPage extends ConsumerStatefulWidget {
  const HostPage({super.key});
  @override
  ConsumerState<HostPage> createState() => _HostPageState();
}

class _HostPageState extends ConsumerState<HostPage>
    with WidgetsBindingObserver {
  Host? host;
  List<Room> rooms = [];
  Object? error;
  bool loading = true, busy = false;
  final name = TextEditingController(text: 'Friday night'),
      threshold = TextEditingController(text: '3');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    name.dispose();
    threshold.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final api = ref.read(apiProvider);
      final h = await api.getHost();
      final r = await api.listRooms();
      if (mounted) {
        setState(() {
          host = h;
          rooms = r;
          error = null;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e;
          loading = false;
        });
      }
    }
  }

  Future<void> connect() async {
    setState(() => busy = true);
    try {
      if (Config.demo) {
        await ref.read(apiProvider).connectSpotify();
        await load();
      } else {
        await launchUrl(
          await ref.read(sessionProvider).spotifyLoginUrl(),
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_self',
        );
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> create() async {
    final count = int.tryParse(threshold.text);
    if (count == null || count < 1 || count > 1000) {
      showMessage(context, 'Choose between 1 and 1000 votes.');
      return;
    }
    setState(() => busy = true);
    try {
      final room = await ref
          .read(apiProvider)
          .createRoom(
            body: CreateRoomRequest(name: name.text, threshold: count),
          );
      if (mounted) context.go('/r/${room.code}');
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = rooms.where((r) => r.status == 'open').toList();
    return PageShell(
      width: 760,
      actions: [
        IconButton(
          tooltip: 'Account settings',
          onPressed: () => context.go('/account'),
          icon: const Icon(Icons.person_outline),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            const Text(
              'Set the room’s rhythm.',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'You handle the music. Your friends handle the requests.',
              style: TextStyle(color: muted, height: 1.6),
            ),
            const SizedBox(height: 28),
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (error != null) ...[
              Text('$error'),
              TextButton(onPressed: load, child: const Text('Try again')),
            ] else ...[
              Panel(
                child: Row(
                  children: [
                    const Icon(
                      Icons.headphones_rounded,
                      color: accent,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            host!.spotifyConnected
                                ? 'Spotify is connected'
                                : 'Connect your Spotify',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Playback and device controls are inside your room.',
                            style: TextStyle(
                              color: muted,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: busy ? null : connect,
                      child: Text(
                        host!.spotifyConnected ? 'Reconnect' : 'Connect',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (active.isNotEmpty)
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StatusPill('YOUR ROOM IS LIVE'),
                      const SizedBox(height: 16),
                      Text(
                        active.first.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${active.first.code} · ${active.first.threshold} votes to queue',
                        style: const TextStyle(color: muted),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.go('/r/${active.first.code}'),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Enter your room'),
                      ),
                    ],
                  ),
                )
              else
                Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start something good',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: name,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Room name',
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: threshold,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Votes needed',
                          helperText:
                              'Each request starts with one vote from its submitter.',
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: host!.spotifyConnected && !busy
                              ? create
                              : null,
                          icon: const Icon(Icons.add),
                          label: Text(busy ? 'Creating…' : 'Create room'),
                        ),
                      ),
                    ],
                  ),
                ),
              if (rooms.any((r) => r.status == 'closed')) ...[
                const SizedBox(height: 28),
                const Text(
                  'Past rooms',
                  style: TextStyle(color: muted, fontWeight: FontWeight.w700),
                ),
                ...rooms
                    .where((r) => r.status == 'closed')
                    .take(10)
                    .map(
                      (r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.name),
                        subtitle: Text(r.code),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/r/${r.code}'),
                      ),
                    ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PageShell(
    width: 600,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Your account',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 28),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Spotify connection',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Disconnecting ends your active room. Songs already in Spotify’s queue stay there.',
                style: TextStyle(color: muted, height: 1.5),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => runAction(context, () async {
                  if (!await confirm(
                    context,
                    'Disconnect Spotify?',
                    'Your active room will end.',
                    action: 'Disconnect',
                  )) {
                    return;
                  }
                  await ref.read(apiProvider).disconnectSpotify();
                  if (context.mounted) {
                    showMessage(context, 'Spotify disconnected.');
                  }
                }),
                child: const Text('Disconnect Spotify'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => runAction(context, () async {
            await ref.read(sessionProvider).signOut();
            if (context.mounted) context.go('/');
          }),
          child: const Text('Sign out'),
        ),
        const SizedBox(height: 40),
        TextButton(
          onPressed: () => runAction(context, () async {
            if (!await confirm(
              context,
              'Delete your qIt account?',
              'This permanently removes your rooms and guest activity, disconnects Spotify, and deletes your login. Songs already in Spotify are unaffected.',
              action: 'Delete account',
            )) {
              return;
            }
            await ref.read(apiProvider).deleteAccount();
            await ref.read(sessionProvider).signOut();
            if (context.mounted) context.go('/');
          }),
          child: const Text(
            'Delete account',
            style: TextStyle(color: Color(0xFFFFAAA0)),
          ),
        ),
      ],
    ),
  );
}
