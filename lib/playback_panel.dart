import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/generated.dart';
import 'providers.dart';
import 'room_controller.dart';
import 'ui.dart';

// Project the last observed progress only. Never infer a track change or a play
// event from the end of this bar. Stale and paused samples do not keep ticking.
int playbackPosition(PlaybackSnapshot p, DateTime now) {
  final duration = p.current?.durationMs ?? 0;
  if (duration <= 0 || p.progressMs == null) return 0;
  final sampled = DateTime.tryParse(p.fetchedAt ?? '');
  final age = sampled == null
      ? 0
      : now.difference(sampled).inMilliseconds.clamp(0, 45000);
  return (p.progressMs! + (p.isPlaying && p.status == 'ready' ? age : 0)).clamp(
    0,
    duration,
  );
}

String trackTime(int ms) =>
    '${ms ~/ 60000}:${((ms ~/ 1000) % 60).toString().padLeft(2, '0')}';
bool playbackFresh(PlaybackSnapshot p, DateTime now) {
  final at = DateTime.tryParse(p.fetchedAt ?? '');
  return p.status == 'ready' && at != null && now.difference(at).inSeconds < 45;
}

String playbackFreshness(PlaybackSnapshot p, DateTime now) {
  final at = DateTime.tryParse(p.fetchedAt ?? '');
  if (at == null) return 'Waiting for Spotify…';
  final seconds = now.difference(at).inSeconds.clamp(0, 86400);
  if (seconds > 45 || p.status != 'ready') {
    return 'Playback may be out of date · last synced ${seconds < 60 ? '${seconds}s' : '${seconds ~/ 60} min'} ago';
  }
  return 'Synced ${seconds < 5 ? 'just now' : '${seconds}s ago'}';
}

class PlaybackPanel extends ConsumerStatefulWidget {
  final RoomController controller;
  const PlaybackPanel({super.key, required this.controller});
  @override
  ConsumerState<PlaybackPanel> createState() => _PlaybackPanelState();
}

class _PlaybackPanelState extends ConsumerState<PlaybackPanel> {
  Timer? ticker;
  bool sending = false;
  double? seekPosition, volume;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(covariant PlaybackPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    now = DateTime.now();
  }

  @override
  void dispose() {
    ticker?.cancel();
    super.dispose();
  }

  Future<void> command(PlaybackCommand command) async {
    if (sending) return;
    setState(() => sending = true);
    try {
      await ref
          .read(apiProvider)
          .controlPlayback(code: widget.controller.code, body: command);
      // Spotify commands settle asynchronously. The worker broadcasts the next
      // observed state to everybody; controls never invent a successful skip.
      if (mounted) showMessage(context, 'Sent to Spotify. Syncing playback…');
      await Future<void>.delayed(const Duration(seconds: 2));
      await widget.controller.refresh();
    } catch (e) {
      if (mounted) showMessage(context, e);
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
          seekPosition = null;
          volume = null;
        });
      }
    }
  }

  Future<void> devices() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => DeviceSheet(
        code: widget.controller.code,
        onChoose: (device) async {
          Navigator.pop(context);
          await command(
            PlaybackCommand(action: 'transfer', deviceId: device.id),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.controller.snapshot!;
    final p = data.playback, track = p.current;
    final host = data.isHost && data.room.status == 'open';
    final fresh = playbackFresh(p, now);
    final available = fresh && p.device != null && !p.device!.isRestricted;
    final enabled = host && available && !sending;
    bool allowed(String action) => enabled && !p.disallowed.contains(action);
    final duration = track?.durationMs ?? 0,
        position = playbackPosition(p, now);
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.graphic_eq_rounded, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.isPlaying ? 'NOW PLAYING · SPOTIFY' : 'PAUSED · SPOTIFY',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (sending)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (track != null)
            TrackInfo(
              track,
              trailing: IconButton(
                tooltip: 'Open track in Spotify',
                onPressed: () => openSpotify(track),
                icon: const Icon(Icons.open_in_new, size: 18),
              ),
            )
          else
            const Text(
              'Ready for a soundtrack.',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
          if (track != null && duration > 0) ...[
            const SizedBox(height: 16),
            if (host)
              Slider(
                key: const Key('playback-seek'),
                min: 0,
                max: (duration - 1).toDouble(),
                value: (seekPosition ?? position.toDouble()).clamp(
                  0,
                  (duration - 1).toDouble(),
                ),
                label: trackTime((seekPosition ?? position.toDouble()).round()),
                semanticFormatterCallback: (value) =>
                    'Seek to ${trackTime(value.round())}',
                onChanged: allowed('seeking') && p.progressMs != null
                    ? (v) => setState(() => seekPosition = v)
                    : null,
                onChangeEnd: allowed('seeking') && p.progressMs != null
                    ? (v) => command(
                        PlaybackCommand(action: 'seek', positionMs: v.round()),
                      )
                    : null,
              )
            else
              Semantics(
                label: 'Song progress',
                value: p.progressMs == null
                    ? 'Unavailable'
                    : '${trackTime(position)} of ${trackTime(duration)}',
                child: LinearProgressIndicator(
                  value: p.progressMs == null ? 0 : position / duration,
                  minHeight: 5,
                  color: accent,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  p.progressMs == null
                      ? '—'
                      : trackTime(
                          (seekPosition ?? position.toDouble()).round(),
                        ),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                Text(
                  trackTime(duration),
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ],
          if (host) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                IconButton.outlined(
                  tooltip: 'Previous song',
                  onPressed: allowed('skipping_prev')
                      ? () => command(const PlaybackCommand(action: 'previous'))
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                IconButton.outlined(
                  tooltip: 'Replay current song',
                  onPressed: allowed('seeking') && track != null
                      ? () => command(const PlaybackCommand(action: 'replay'))
                      : null,
                  icon: const Icon(Icons.replay_rounded),
                ),
                FilledButton.icon(
                  onPressed: allowed(p.isPlaying ? 'pausing' : 'resuming')
                      ? () => command(
                          PlaybackCommand(
                            action: p.isPlaying ? 'pause' : 'play',
                          ),
                        )
                      : null,
                  icon: Icon(
                    p.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(p.isPlaying ? 'Pause' : 'Play'),
                ),
                IconButton.outlined(
                  tooltip: 'Next song',
                  onPressed: allowed('skipping_next')
                      ? () => command(const PlaybackCommand(action: 'next'))
                      : null,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
            if (p.device?.supportsVolume ?? false)
              Row(
                children: [
                  const Icon(Icons.volume_up_outlined, size: 18, color: muted),
                  Expanded(
                    child: Slider(
                      key: const Key('playback-volume'),
                      min: 0,
                      max: 100,
                      value:
                          volume ?? (p.device!.volumePercent ?? 0).toDouble(),
                      label:
                          '${(volume ?? (p.device!.volumePercent ?? 0)).round()}%',
                      semanticFormatterCallback: (v) =>
                          'Volume ${v.round()} percent',
                      onChanged: enabled
                          ? (v) => setState(() => volume = v)
                          : null,
                      onChangeEnd: enabled
                          ? (v) => command(
                              PlaybackCommand(
                                action: 'volume',
                                volumePercent: v.round(),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            TextButton.icon(
              onPressed: sending ? null : devices,
              icon: const Icon(Icons.speaker_group_outlined, size: 18),
              label: Text(
                p.device == null ? 'Choose a playback device' : p.device!.name,
              ),
            ),
            if (p.device == null)
              const Text(
                'Choose an available Spotify Connect device. If none appears, open Spotify on a device once to make it available.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
            if (p.device?.isRestricted ?? false)
              const Text(
                'Spotify restricts remote control on this device. Choose another device.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.5),
              ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              p.device == null
                  ? 'The host chooses the playback device.'
                  : 'Playing on ${p.device!.name} · controlled by the host',
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
          if (p.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                p.message,
                style: const TextStyle(
                  color: Color(0xFFFFC68A),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            playbackFreshness(p, now),
            style: const TextStyle(color: muted, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class DeviceSheet extends ConsumerStatefulWidget {
  final String code;
  final Future<void> Function(PlaybackDevice) onChoose;
  const DeviceSheet({super.key, required this.code, required this.onChoose});
  @override
  ConsumerState<DeviceSheet> createState() => _DeviceSheetState();
}

class _DeviceSheetState extends ConsumerState<DeviceSheet> {
  List<PlaybackDevice>? devices;
  Object? error;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      error = null;
      devices = null;
    });
    try {
      final values = await ref
          .read(apiProvider)
          .getPlaybackDevices(code: widget.code);
      if (mounted) setState(() => devices = values);
    } catch (e) {
      if (mounted) setState(() => error = e);
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: MediaQuery.sizeOf(context).height * .65,
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Where should the music play?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose a Spotify Connect device. Audio plays there; everyone can follow along in qIt.',
          style: TextStyle(color: muted, height: 1.5),
        ),
        const SizedBox(height: 20),
        if (devices == null && error == null)
          const Center(child: CircularProgressIndicator()),
        if (error != null) Text('$error'),
        if (devices?.isEmpty ?? false)
          const Text(
            'No devices are online. Open Spotify on your speaker, computer, or phone once, then refresh this list.',
          ),
        for (final device in devices ?? <PlaybackDevice>[])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.speaker_outlined, color: accent),
            title: Text(device.name),
            subtitle: Text(
              device.isRestricted
                  ? 'Remote control unavailable'
                  : device.isActive
                  ? 'Current device'
                  : device.type,
            ),
            trailing: device.isActive
                ? const Icon(Icons.check, color: accent)
                : const Icon(Icons.chevron_right),
            enabled: !device.isRestricted && device.id.isNotEmpty,
            onTap: () => widget.onChoose(device),
          ),
        TextButton.icon(
          onPressed: load,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh devices'),
        ),
      ],
    ),
  );
}
