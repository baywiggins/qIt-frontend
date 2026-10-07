import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'api/generated.dart';
import 'config.dart';
import 'providers.dart';
import 'room_controller.dart';
import 'ui.dart';
import 'playback_panel.dart';

class RoomPage extends ConsumerStatefulWidget {
  final String code;
  const RoomPage({super.key, required this.code});
  @override
  ConsumerState<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends ConsumerState<RoomPage> {
  int tab = 0;
  Future<void> share(Room room) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Brand(size: 36),
              const SizedBox(height: 16),
              Text(
                room.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(
                  data: Config.roomLink(room.code),
                  size: 220,
                  backgroundColor: Colors.white,
                  semanticsLabel: 'QR code to join ${room.name}',
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(
                room.code,
                style: const TextStyle(
                  fontSize: 28,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan to join. No account needed.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: Config.roomLink(room.code)),
                  );
                  showMessage(context, 'Room link copied.');
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy invite link'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> nickname(RoomController controller) async {
    final text = TextEditingController(
      text: controller.snapshot?.member?.nickname ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('What should we call you?'),
        content: TextField(
          controller: text,
          maxLength: 40,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Your nickname'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, text.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    text.dispose();
    if (result != null && mounted) {
      await runAction(
        context,
        () => controller.act(
          () => ref
              .read(apiProvider)
              .renameMember(
                code: widget.code,
                body: NicknameRequest(nickname: result),
              ),
        ),
      );
    }
  }

  Future<void> settings(RoomController controller) async {
    final room = controller.snapshot!.room;
    final name = TextEditingController(text: room.name),
        threshold = TextEditingController(text: room.threshold.toString());
    final result = await showDialog<SettingsRequest>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Room name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: threshold,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Votes needed'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Changing the threshold immediately updates songs still being voted on.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(threshold.text);
              if (n == null || n < 1 || n > 1000) {
                showMessage(context, 'Choose between 1 and 1000 votes.');
                return;
              }
              Navigator.pop(
                context,
                SettingsRequest(name: name.text, threshold: n),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    name.dispose();
    threshold.dispose();
    if (result != null && mounted) {
      await runAction(
        context,
        () => controller.act(
          () => ref
              .read(apiProvider)
              .updateSettings(code: widget.code, body: result),
        ),
      );
    }
  }

  Future<void> guests(RoomController controller) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .7,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'People in the room',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              if (controller.snapshot!.members.isEmpty)
                const Text(
                  'Your guests will appear here.',
                  style: TextStyle(color: muted),
                ),
              ...controller.snapshot!.members.map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline, color: accent),
                  title: Text(m.nickname),
                  subtitle: m.blocked ? const Text('Blocked') : null,
                  trailing: m.blocked
                      ? null
                      : TextButton(
                          onPressed: () => runAction(context, () async {
                            if (!await confirm(
                              context,
                              'Block ${m.nickname}?',
                              'This guest session will no longer be able to view, request, or vote.',
                              action: 'Block guest',
                            )) {
                              return;
                            }
                            await controller.act(
                              () => ref
                                  .read(apiProvider)
                                  .blockMember(code: widget.code, member: m.id),
                            );
                            if (context.mounted) Navigator.pop(context);
                          }),
                          child: const Text('Block'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> moderate(
    RoomController controller,
    Suggestion s,
    String action,
  ) async {
    await runAction(context, () async {
      if (['retry', 'sent', 'cancel'].contains(action)) {
        if (!await confirm(
          context,
          action == 'retry'
              ? 'Send this song again?'
              : action == 'sent'
              ? 'Mark as sent?'
              : 'Cancel this delivery?',
          action == 'retry'
              ? 'Check the Spotify queue first. The previous attempt may already have succeeded.'
              : 'This resolves the delivery without sending a new Spotify command.',
          action: action == 'retry' ? 'Retry send' : 'Resolve',
        )) {
          return;
        }
        await controller.act(
          () => ref
              .read(apiProvider)
              .resolveDelivery(
                code: widget.code,
                suggestion: s.id,
                body: ResolutionRequest(action: action),
              ),
        );
      } else {
        await controller.act(
          () => ref
              .read(apiProvider)
              .moderateSuggestion(
                code: widget.code,
                suggestion: s.id,
                body: ModerationRequest(action: action),
              ),
        );
      }
    });
  }

  Widget suggestionCard(RoomController c, Suggestion s) {
    final data = c.snapshot!;
    final pending = s.status == 'pending';
    final uncertain = ['failed', 'needs_attention'].contains(s.deliveryStatus);
    final status = s.status == 'rejected'
        ? 'Declined by host'
        : switch (s.deliveryStatus) {
            'waiting' =>
              s.deliveryReason == 'no_active_device'
                  ? 'Waiting for the host’s device'
                  : 'Approved · waiting for Spotify',
            'sending' => 'Sending to Spotify…',
            'sent' => 'Sent to Spotify',
            'needs_attention' => 'Host attention needed',
            'failed' => 'Could not send to Spotify',
            'cancelled' => 'Delivery cancelled',
            _ => '${s.votes} / ${data.room.threshold} votes',
          };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Panel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrackInfo(
              s.track,
              subtitle: '${s.track.artists}\nRequested by ${s.nickname}',
              trailing: data.isHost && (data.room.status == 'open' || uncertain)
                  ? PopupMenuButton<String>(
                      tooltip: 'Manage ${s.track.name}',
                      onSelected: (action) => moderate(c, s, action),
                      itemBuilder: (_) => [
                        if (pending && data.room.status == 'open')
                          const PopupMenuItem(
                            value: 'approve',
                            child: Text('Approve now'),
                          ),
                        if (data.room.status == 'open' &&
                            (pending ||
                                s.deliveryStatus == 'waiting' ||
                                s.deliveryStatus == 'failed'))
                          const PopupMenuItem(
                            value: 'reject',
                            child: Text('Reject request'),
                          ),
                        if (uncertain) ...[
                          if (data.room.status == 'open')
                            const PopupMenuItem(
                              value: 'retry',
                              child: Text('Retry sending…'),
                            ),
                          const PopupMenuItem(
                            value: 'sent',
                            child: Text('Mark as already sent…'),
                          ),
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Text('Cancel delivery…'),
                          ),
                        ],
                      ],
                    )
                  : IconButton(
                      tooltip: 'Open in Spotify',
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: muted,
                      ),
                      onPressed: () => openSpotify(s.track),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: uncertain
                              ? const Color(0xFFFFC68A)
                              : pending
                              ? muted
                              : accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (pending) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (s.votes / data.room.threshold).clamp(0, 1),
                            minHeight: 4,
                            color: accent,
                            backgroundColor: const Color(0xFF29324B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (pending && !data.isHost && data.room.status == 'open') ...[
                  const SizedBox(width: 20),
                  Semantics(
                    label: s.myVote
                        ? 'Remove your vote for ${s.track.name}'
                        : 'Vote for ${s.track.name}',
                    child: OutlinedButton.icon(
                      onPressed: c.busy
                          ? null
                          : () => runAction(
                              context,
                              () => c.act(
                                () => s.myVote
                                    ? ref
                                          .read(apiProvider)
                                          .removeVote(
                                            code: widget.code,
                                            suggestion: s.id,
                                          )
                                    : ref
                                          .read(apiProvider)
                                          .addVote(
                                            code: widget.code,
                                            suggestion: s.id,
                                          ),
                              ),
                            ),
                      icon: Icon(
                        s.myVote
                            ? Icons.check_rounded
                            : Icons.arrow_upward_rounded,
                        size: 18,
                      ),
                      label: Text(s.myVote ? 'Voted' : 'Vote'),
                    ),
                  ),
                ],
              ],
            ),
            if (s.deliveryReason.isNotEmpty &&
                !['sent', 'cancelled'].contains(s.deliveryStatus)) ...[
              const SizedBox(height: 12),
              Text(
                deliveryHelp(s.deliveryReason),
                style: const TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(roomProvider(widget.code));
    final data = controller.snapshot;
    return PageShell(
      width: 880,
      actions: [
        if (data != null)
          IconButton(
            tooltip: 'Share room',
            onPressed: () => share(data.room),
            icon: const Icon(Icons.qr_code_2_rounded),
          ),
        if (data?.isHost ?? false)
          IconButton(
            tooltip: 'Host dashboard',
            onPressed: () => context.go('/host'),
            icon: const Icon(Icons.dashboard_outlined),
          ),
      ],
      child: data == null
          ? (controller.error != null
                ? ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Couldn’t join this room',
                        body: '${controller.error}',
                      ),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(roomProvider(widget.code)),
                        child: const Text('Try again'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Enter another code'),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()))
          : RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Row(
                    children: [
                      StatusPill(
                        data.room.status == 'closed'
                            ? 'ROOM ENDED'
                            : controller.live
                            ? 'LIVE ROOM'
                            : 'RECONNECTING',
                        color: data.room.status == 'closed'
                            ? muted
                            : controller.live
                            ? const Color(0xFF85D6B2)
                            : const Color(0xFFFFC68A),
                      ),
                      const Spacer(),
                      Text(
                        data.room.code,
                        style: const TextStyle(
                          color: muted,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    data.room.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data.room.threshold} votes sends a song to Spotify. Make yours count.',
                    style: const TextStyle(color: muted, height: 1.5),
                  ),
                  if (data.member != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => nickname(controller),
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: Text('You’re ${data.member!.nickname}'),
                      ),
                    ),
                  if (controller.error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        '${controller.error}',
                        style: const TextStyle(color: Color(0xFFFFC68A)),
                      ),
                    ),
                  if (data.isHost && data.room.status == 'open')
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => settings(controller),
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: const Text('Settings'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => guests(controller),
                            icon: const Icon(Icons.people_outline, size: 18),
                            label: Text('${data.members.length} guests'),
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.busy
                                ? null
                                : () => runAction(
                                    context,
                                    () => controller.act(
                                      () => ref
                                          .read(apiProvider)
                                          .updateSettings(
                                            code: widget.code,
                                            body: SettingsRequest(
                                              paused: !data.room.paused,
                                            ),
                                          ),
                                    ),
                                  ),
                            icon: Icon(
                              data.room.paused ? Icons.play_arrow : Icons.pause,
                              size: 18,
                            ),
                            label: Text(
                              data.room.paused
                                  ? 'Resume requests'
                                  : 'Pause requests',
                            ),
                          ),
                          TextButton(
                            onPressed: () => runAction(context, () async {
                              if (!await confirm(
                                context,
                                'End this room?',
                                'Guests will no longer be able to request or vote. Songs already sent to Spotify stay queued.',
                                action: 'End room',
                              )) {
                                return;
                              }
                              await controller.act(
                                () => ref
                                    .read(apiProvider)
                                    .closeRoom(code: widget.code),
                              );
                            }),
                            child: const Text(
                              'End room',
                              style: TextStyle(color: Color(0xFFFFAAA0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (data.room.status == 'closed')
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Panel(
                        child: Text(
                          'Thanks for the good music. This room has ended.',
                          style: TextStyle(color: muted),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  PlaybackPanel(controller: controller),
                  const SizedBox(height: 24),
                  if (data.room.status == 'open') ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: data.room.paused && !data.isHost
                            ? null
                            : () => showModalBottomSheet<void>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                useSafeArea: true,
                                builder: (_) => SearchSheet(
                                  code: widget.code,
                                  controller: controller,
                                ),
                              ),
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          data.isHost
                              ? 'Add to Spotify queue'
                              : data.room.paused
                              ? 'Requests are paused'
                              : 'Request a song',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'Voting (${data.suggestions.where((s) => s.status == 'pending').length})',
                        ),
                        selected: tab == 0,
                        onSelected: (_) => setState(() => tab = 0),
                      ),
                      ChoiceChip(
                        label: const Text('Up next'),
                        selected: tab == 1,
                        onSelected: (_) => setState(() => tab = 1),
                      ),
                      ChoiceChip(
                        label: const Text('Activity'),
                        selected: tab == 2,
                        onSelected: (_) => setState(() => tab = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (tab == 0) ...[
                    if (data.suggestions.every((s) => s.status != 'pending'))
                      const EmptyState(
                        icon: Icons.queue_music_rounded,
                        title: 'A blank canvas for good music',
                        body:
                            'Request the first song. Each request starts with your vote.',
                      ),
                    ...data.suggestions
                        .where((s) => s.status == 'pending')
                        .map((s) => suggestionCard(controller, s)),
                  ],
                  if (tab == 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        queueFreshness(data.playback),
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                    ...data.suggestions
                        .where(
                          (s) =>
                              s.status == 'approved' &&
                              !['sent', 'cancelled'].contains(s.deliveryStatus),
                        )
                        .map((s) => suggestionCard(controller, s)),
                    if (data.playback.queue.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'UPCOMING · SPOTIFY',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      ...data.playback.queue.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Panel(
                            padding: const EdgeInsets.all(16),
                            child: TrackInfo(
                              t,
                              trailing: IconButton(
                                tooltip: 'Open in Spotify',
                                onPressed: () => openSpotify(t),
                                icon: const Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                  color: muted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      const EmptyState(
                        icon: Icons.headphones_rounded,
                        title: 'The next great song is up to you',
                        body:
                            'Approved requests will appear here. Spotify’s queue updates about every 15 seconds.',
                      ),
                  ],
                  if (tab == 2) ...[
                    if (data.suggestions.every(
                      (s) =>
                          s.status != 'rejected' &&
                          !['sent', 'cancelled'].contains(s.deliveryStatus),
                    ))
                      const EmptyState(
                        icon: Icons.history_rounded,
                        title: 'The night is still young',
                        body:
                            'Sent songs and declined requests will appear here.',
                      ),
                    ...data.suggestions
                        .where(
                          (s) =>
                              s.status == 'rejected' ||
                              ['sent', 'cancelled'].contains(s.deliveryStatus),
                        )
                        .map((s) => suggestionCard(controller, s)),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Music plays on the host’s device. Playback controls stay with the host.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 11, height: 1.5),
                  ),
                ],
              ),
            ),
    );
  }
}

String deliveryHelp(String reason) => switch (reason) {
  'no_active_device' =>
    'Host: choose a device in the player. If none appear, open Spotify once on your speaker or computer. Delivery resumes automatically.',
  'spotify_reconnect' =>
    'Host: reconnect Spotify from your dashboard to resume delivery.',
  'spotify_forbidden' =>
    'Host: check your Spotify Premium subscription and the app’s approved-user list.',
  'spotify_rate_limited' =>
    'Spotify asked us to wait. Delivery resumes after its cooldown.',
  'spotify_quota_exceeded' =>
    'Spotify’s app quota is exhausted. The host can retry after access is restored.',
  'track_unavailable' =>
    'This song is unavailable for the host. Cancel this delivery to continue.',
  'uncertain_send' =>
    'Host: check Spotify’s queue before retrying. This song may already have been added.',
  _ =>
    'Spotify could not complete this request. The host can review and retry the delivery.',
};

class SearchSheet extends ConsumerStatefulWidget {
  final String code;
  final RoomController controller;
  const SearchSheet({super.key, required this.code, required this.controller});
  @override
  ConsumerState<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends ConsumerState<SearchSheet> {
  final query = TextEditingController();
  Timer? debounce;
  List<Track> tracks = [];
  Object? error;
  bool loading = false, adding = false;
  int generation = 0;
  @override
  void dispose() {
    query.dispose();
    debounce?.cancel();
    super.dispose();
  }

  Future<void> search() async {
    final g = ++generation;
    final text = query.text.trim();
    if (text.length < 2) {
      setState(() {
        tracks = [];
        error = null;
        loading = false;
      });
      return;
    }
    setState(() => loading = true);
    try {
      final results = await ref
          .read(apiProvider)
          .searchTracks(code: widget.code, q: text);
      if (mounted && g == generation) {
        setState(() {
          tracks = results;
          error = null;
        });
      }
    } catch (e) {
      if (mounted && g == generation) setState(() => error = e);
    } finally {
      if (mounted && g == generation) setState(() => loading = false);
    }
  }

  Future<void> add(Track track) async {
    setState(() => adding = true);
    try {
      await widget.controller.act(
        () => ref
            .read(apiProvider)
            .suggestTrack(
              code: widget.code,
              body: SuggestionRequest(trackId: track.id),
            ),
      );
      if (mounted) {
        Navigator.pop(context);
        showMessage(
          context,
          widget.controller.snapshot!.isHost
              ? 'Added to the delivery queue.'
              : 'Your request is in.',
        );
      }
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What should play next?',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('track-search'),
              controller: query,
              autofocus: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Song, artist, or Spotify track link',
              ),
              onChanged: (_) {
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 350), search);
              },
              onSubmitted: (_) => search(),
            ),
            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(),
            Expanded(
              child: error != null
                  ? Center(
                      child: Text(
                        '$error',
                        style: const TextStyle(color: muted),
                      ),
                    )
                  : tracks.isEmpty
                  ? EmptyState(
                      icon: Icons.search_rounded,
                      title: query.text.trim().length < 2
                          ? 'Find your next favorite'
                          : 'No songs found',
                      body: query.text.trim().length < 2
                          ? 'Search Spotify’s catalog, then add your pick.'
                          : 'Try another song, artist, or a Spotify track link.',
                    )
                  : ListView.separated(
                      itemCount: tracks.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final t = tracks[index];
                        final exists = widget.controller.snapshot!.suggestions
                            .any((s) => s.track.id == t.id);
                        return Panel(
                          padding: const EdgeInsets.all(14),
                          child: TrackInfo(
                            t,
                            trailing: IconButton(
                              tooltip: exists
                                  ? 'Already requested'
                                  : t.playable
                                  ? (widget.controller.snapshot!.isHost
                                        ? 'Queue ${t.name}'
                                        : 'Request ${t.name}')
                                  : 'Unavailable',
                              onPressed: adding || exists || !t.playable
                                  ? null
                                  : () => add(t),
                              icon: Icon(
                                exists
                                    ? Icons.check_rounded
                                    : Icons.add_circle_outline,
                                color: exists ? muted : accent,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Search results provided by Spotify.',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}

String queueFreshness(PlaybackSnapshot p) {
  final at = DateTime.tryParse(p.queueFetchedAt ?? '');
  if (at == null) return 'Waiting for Spotify’s upcoming queue…';
  final seconds = DateTime.now().difference(at).inSeconds.clamp(0, 86400);
  return '${seconds >= 45 ? 'Queue may be out of date · ' : ''}Queue synced ${seconds < 5
      ? 'just now'
      : seconds < 60
      ? '${seconds}s ago'
      : '${seconds ~/ 60} min ago'}';
}
