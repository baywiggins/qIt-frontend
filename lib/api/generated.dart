// GENERATED from OpenAPI. Run tool/generate_api.py; do not edit.
// Contract SHA256: d92309ec6adc2012b9da476f83edc877d200259d9eb09ac3dd78261fb17125d1
typedef RequestFn =
    Future<dynamic> Function(
      String method,
      String path, {
      Map<String, dynamic>? body,
      Map<String, String>? query,
    });

class Room {
  final String id;
  final String code;
  final String name;
  final int threshold;
  final bool paused;
  final String status;
  final int revision;
  final String createdAt;
  final String expiresAt;
  const Room({
    required this.id,
    required this.code,
    required this.name,
    required this.threshold,
    required this.paused,
    required this.status,
    required this.revision,
    required this.createdAt,
    required this.expiresAt,
  });
  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: (json['id'] as String? ?? ''),
    code: (json['code'] as String? ?? ''),
    name: (json['name'] as String? ?? ''),
    threshold: (json['threshold'] as num?)?.toInt() ?? 0,
    paused: (json['paused'] as bool? ?? false),
    status: (json['status'] as String? ?? ''),
    revision: (json['revision'] as num?)?.toInt() ?? 0,
    createdAt: (json['created_at'] as String? ?? ''),
    expiresAt: (json['expires_at'] as String? ?? ''),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'threshold': threshold,
    'paused': paused,
    'status': status,
    'revision': revision,
    'created_at': createdAt,
    'expires_at': expiresAt,
  };
}

class Member {
  final String id;
  final String nickname;
  final bool blocked;
  const Member({
    required this.id,
    required this.nickname,
    required this.blocked,
  });
  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: (json['id'] as String? ?? ''),
    nickname: (json['nickname'] as String? ?? ''),
    blocked: (json['blocked'] as bool? ?? false),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'blocked': blocked,
  };
}

class Track {
  final String id;
  final String uri;
  final String name;
  final String artists;
  final String imageUrl;
  final String spotifyUrl;
  final int durationMs;
  final bool explicit;
  final bool playable;
  const Track({
    required this.id,
    required this.uri,
    required this.name,
    required this.artists,
    required this.imageUrl,
    required this.spotifyUrl,
    required this.durationMs,
    required this.explicit,
    required this.playable,
  });
  factory Track.fromJson(Map<String, dynamic> json) => Track(
    id: (json['id'] as String? ?? ''),
    uri: (json['uri'] as String? ?? ''),
    name: (json['name'] as String? ?? ''),
    artists: (json['artists'] as String? ?? ''),
    imageUrl: (json['image_url'] as String? ?? ''),
    spotifyUrl: (json['spotify_url'] as String? ?? ''),
    durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
    explicit: (json['explicit'] as bool? ?? false),
    playable: (json['playable'] as bool? ?? false),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'uri': uri,
    'name': name,
    'artists': artists,
    'image_url': imageUrl,
    'spotify_url': spotifyUrl,
    'duration_ms': durationMs,
    'explicit': explicit,
    'playable': playable,
  };
}

typedef DeliveryStatus = String;

class Suggestion {
  final String id;
  final Track track;
  final String? memberId;
  final String nickname;
  final String status;
  final int votes;
  final bool myVote;
  final String createdAt;
  final DeliveryStatus deliveryStatus;
  final String deliveryReason;
  const Suggestion({
    required this.id,
    required this.track,
    this.memberId,
    required this.nickname,
    required this.status,
    required this.votes,
    required this.myVote,
    required this.createdAt,
    required this.deliveryStatus,
    required this.deliveryReason,
  });
  factory Suggestion.fromJson(Map<String, dynamic> json) => Suggestion(
    id: (json['id'] as String? ?? ''),
    track: Track.fromJson(json['track'] as Map<String, dynamic>),
    memberId: json['member_id'] == null
        ? null
        : (json['member_id'] as String? ?? ''),
    nickname: (json['nickname'] as String? ?? ''),
    status: (json['status'] as String? ?? ''),
    votes: (json['votes'] as num?)?.toInt() ?? 0,
    myVote: (json['my_vote'] as bool? ?? false),
    createdAt: (json['created_at'] as String? ?? ''),
    deliveryStatus: (json['delivery_status'] as String? ?? ''),
    deliveryReason: (json['delivery_reason'] as String? ?? ''),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'track': track.toJson(),
    if (memberId != null) 'member_id': memberId,
    'nickname': nickname,
    'status': status,
    'votes': votes,
    'my_vote': myVote,
    'created_at': createdAt,
    'delivery_status': deliveryStatus,
    'delivery_reason': deliveryReason,
  };
}

class PlaybackDevice {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final bool isRestricted;
  final bool supportsVolume;
  final int? volumePercent;
  const PlaybackDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.isActive,
    required this.isRestricted,
    required this.supportsVolume,
    this.volumePercent,
  });
  factory PlaybackDevice.fromJson(Map<String, dynamic> json) => PlaybackDevice(
    id: (json['id'] as String? ?? ''),
    name: (json['name'] as String? ?? ''),
    type: (json['type'] as String? ?? ''),
    isActive: (json['is_active'] as bool? ?? false),
    isRestricted: (json['is_restricted'] as bool? ?? false),
    supportsVolume: (json['supports_volume'] as bool? ?? false),
    volumePercent: json['volume_percent'] == null
        ? null
        : (json['volume_percent'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'is_active': isActive,
    'is_restricted': isRestricted,
    'supports_volume': supportsVolume,
    if (volumePercent != null) 'volume_percent': volumePercent,
  };
}

class PlaybackCommand {
  final String action;
  final int? positionMs;
  final int? volumePercent;
  final String? deviceId;
  const PlaybackCommand({
    required this.action,
    this.positionMs,
    this.volumePercent,
    this.deviceId,
  });
  factory PlaybackCommand.fromJson(Map<String, dynamic> json) =>
      PlaybackCommand(
        action: (json['action'] as String? ?? ''),
        positionMs: json['position_ms'] == null
            ? null
            : (json['position_ms'] as num?)?.toInt() ?? 0,
        volumePercent: json['volume_percent'] == null
            ? null
            : (json['volume_percent'] as num?)?.toInt() ?? 0,
        deviceId: json['device_id'] == null
            ? null
            : (json['device_id'] as String? ?? ''),
      );
  Map<String, dynamic> toJson() => {
    'action': action,
    if (positionMs != null) 'position_ms': positionMs,
    if (volumePercent != null) 'volume_percent': volumePercent,
    if (deviceId != null) 'device_id': deviceId,
  };
}

class PlaybackSnapshot {
  final Track? current;
  final List<Track> queue;
  final String? fetchedAt;
  final String? queueFetchedAt;
  final int? progressMs;
  final bool isPlaying;
  final PlaybackDevice? device;
  final List<String> disallowed;
  final String status;
  final String message;
  const PlaybackSnapshot({
    this.current,
    required this.queue,
    this.fetchedAt,
    this.queueFetchedAt,
    this.progressMs,
    required this.isPlaying,
    this.device,
    required this.disallowed,
    required this.status,
    required this.message,
  });
  factory PlaybackSnapshot.fromJson(Map<String, dynamic> json) =>
      PlaybackSnapshot(
        current: json['current'] == null
            ? null
            : Track.fromJson(json['current'] as Map<String, dynamic>),
        queue: ((json['queue'] as List?) ?? [])
            .map((v) => Track.fromJson(v as Map<String, dynamic>))
            .toList(),
        fetchedAt: json['fetched_at'] == null
            ? null
            : (json['fetched_at'] as String? ?? ''),
        queueFetchedAt: json['queue_fetched_at'] == null
            ? null
            : (json['queue_fetched_at'] as String? ?? ''),
        progressMs: json['progress_ms'] == null
            ? null
            : (json['progress_ms'] as num?)?.toInt() ?? 0,
        isPlaying: (json['is_playing'] as bool? ?? false),
        device: json['device'] == null
            ? null
            : PlaybackDevice.fromJson(json['device'] as Map<String, dynamic>),
        disallowed: ((json['disallowed'] as List?) ?? [])
            .map((v) => (v as String? ?? ''))
            .toList(),
        status: (json['status'] as String? ?? ''),
        message: (json['message'] as String? ?? ''),
      );
  Map<String, dynamic> toJson() => {
    if (current != null) 'current': current?.toJson(),
    'queue': queue.map((v) => v.toJson()).toList(),
    if (fetchedAt != null) 'fetched_at': fetchedAt,
    if (queueFetchedAt != null) 'queue_fetched_at': queueFetchedAt,
    if (progressMs != null) 'progress_ms': progressMs,
    'is_playing': isPlaying,
    if (device != null) 'device': device?.toJson(),
    'disallowed': disallowed.map((v) => v).toList(),
    'status': status,
    'message': message,
  };
}

class Snapshot {
  final Room room;
  final Member? member;
  final bool isHost;
  final List<Member> members;
  final List<Suggestion> suggestions;
  final PlaybackSnapshot playback;
  const Snapshot({
    required this.room,
    this.member,
    required this.isHost,
    required this.members,
    required this.suggestions,
    required this.playback,
  });
  factory Snapshot.fromJson(Map<String, dynamic> json) => Snapshot(
    room: Room.fromJson(json['room'] as Map<String, dynamic>),
    member: json['member'] == null
        ? null
        : Member.fromJson(json['member'] as Map<String, dynamic>),
    isHost: (json['is_host'] as bool? ?? false),
    members: ((json['members'] as List?) ?? [])
        .map((v) => Member.fromJson(v as Map<String, dynamic>))
        .toList(),
    suggestions: ((json['suggestions'] as List?) ?? [])
        .map((v) => Suggestion.fromJson(v as Map<String, dynamic>))
        .toList(),
    playback: PlaybackSnapshot.fromJson(
      json['playback'] as Map<String, dynamic>,
    ),
  );
  Map<String, dynamic> toJson() => {
    'room': room.toJson(),
    if (member != null) 'member': member?.toJson(),
    'is_host': isHost,
    'members': members.map((v) => v.toJson()).toList(),
    'suggestions': suggestions.map((v) => v.toJson()).toList(),
    'playback': playback.toJson(),
  };
}

class RoomEvent {
  final String type;
  final int revision;
  final Snapshot? snapshot;
  const RoomEvent({required this.type, required this.revision, this.snapshot});
  factory RoomEvent.fromJson(Map<String, dynamic> json) => RoomEvent(
    type: (json['type'] as String? ?? ''),
    revision: (json['revision'] as num?)?.toInt() ?? 0,
    snapshot: json['snapshot'] == null
        ? null
        : Snapshot.fromJson(json['snapshot'] as Map<String, dynamic>),
  );
  Map<String, dynamic> toJson() => {
    'type': type,
    'revision': revision,
    if (snapshot != null) 'snapshot': snapshot?.toJson(),
  };
}

class Host {
  final String id;
  final bool spotifyConnected;
  final String spotifyAccountId;
  final bool demo;
  const Host({
    required this.id,
    required this.spotifyConnected,
    required this.spotifyAccountId,
    required this.demo,
  });
  factory Host.fromJson(Map<String, dynamic> json) => Host(
    id: (json['id'] as String? ?? ''),
    spotifyConnected: (json['spotify_connected'] as bool? ?? false),
    spotifyAccountId: (json['spotify_account_id'] as String? ?? ''),
    demo: (json['demo'] as bool? ?? false),
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'spotify_connected': spotifyConnected,
    'spotify_account_id': spotifyAccountId,
    'demo': demo,
  };
}

class Ack {
  final bool ok;
  const Ack({required this.ok});
  factory Ack.fromJson(Map<String, dynamic> json) =>
      Ack(ok: (json['ok'] as bool? ?? false));
  Map<String, dynamic> toJson() => {'ok': ok};
}

class APIError {
  final String code;
  final String message;
  final int retryAfter;
  const APIError({
    required this.code,
    required this.message,
    this.retryAfter = 0,
  });
  factory APIError.fromJson(Map<String, dynamic> json) => APIError(
    code: (json['code'] as String? ?? ''),
    message: (json['message'] as String? ?? ''),
    retryAfter: (json['retry_after'] as num?)?.toInt() ?? 0,
  );
  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'retry_after': retryAfter,
  };
}

class ErrorResponse {
  final APIError error;
  const ErrorResponse({required this.error});
  factory ErrorResponse.fromJson(Map<String, dynamic> json) => ErrorResponse(
    error: APIError.fromJson(json['error'] as Map<String, dynamic>),
  );
  Map<String, dynamic> toJson() => {'error': error.toJson()};
}

class CreateRoomRequest {
  final String name;
  final int threshold;
  const CreateRoomRequest({required this.name, this.threshold = 3});
  factory CreateRoomRequest.fromJson(Map<String, dynamic> json) =>
      CreateRoomRequest(
        name: (json['name'] as String? ?? ''),
        threshold: (json['threshold'] as num?)?.toInt() ?? 3,
      );
  Map<String, dynamic> toJson() => {'name': name, 'threshold': threshold};
}

class JoinRequest {
  final String nickname;
  final bool native;
  const JoinRequest({this.nickname = "", this.native = false});
  factory JoinRequest.fromJson(Map<String, dynamic> json) => JoinRequest(
    nickname: (json['nickname'] as String? ?? ''),
    native: (json['native'] as bool? ?? false),
  );
  Map<String, dynamic> toJson() => {'nickname': nickname, 'native': native};
}

class JoinResponse {
  final Member member;
  final String? guestToken;
  const JoinResponse({required this.member, this.guestToken});
  factory JoinResponse.fromJson(Map<String, dynamic> json) => JoinResponse(
    member: Member.fromJson(json['member'] as Map<String, dynamic>),
    guestToken: json['guest_token'] == null
        ? null
        : (json['guest_token'] as String? ?? ''),
  );
  Map<String, dynamic> toJson() => {
    'member': member.toJson(),
    if (guestToken != null) 'guest_token': guestToken,
  };
}

class SettingsRequest {
  final String? name;
  final int? threshold;
  final bool? paused;
  const SettingsRequest({this.name, this.threshold, this.paused});
  factory SettingsRequest.fromJson(Map<String, dynamic> json) =>
      SettingsRequest(
        name: json['name'] == null ? null : (json['name'] as String? ?? ''),
        threshold: json['threshold'] == null
            ? null
            : (json['threshold'] as num?)?.toInt() ?? 0,
        paused: json['paused'] == null
            ? null
            : (json['paused'] as bool? ?? false),
      );
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (threshold != null) 'threshold': threshold,
    if (paused != null) 'paused': paused,
  };
}

class NicknameRequest {
  final String nickname;
  const NicknameRequest({required this.nickname});
  factory NicknameRequest.fromJson(Map<String, dynamic> json) =>
      NicknameRequest(nickname: (json['nickname'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'nickname': nickname};
}

class SuggestionRequest {
  final String trackId;
  const SuggestionRequest({required this.trackId});
  factory SuggestionRequest.fromJson(Map<String, dynamic> json) =>
      SuggestionRequest(trackId: (json['track_id'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'track_id': trackId};
}

class SuggestionResponse {
  final String id;
  const SuggestionResponse({required this.id});
  factory SuggestionResponse.fromJson(Map<String, dynamic> json) =>
      SuggestionResponse(id: (json['id'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'id': id};
}

class ModerationRequest {
  final String action;
  const ModerationRequest({required this.action});
  factory ModerationRequest.fromJson(Map<String, dynamic> json) =>
      ModerationRequest(action: (json['action'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'action': action};
}

class ResolutionRequest {
  final String action;
  const ResolutionRequest({required this.action});
  factory ResolutionRequest.fromJson(Map<String, dynamic> json) =>
      ResolutionRequest(action: (json['action'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'action': action};
}

class TicketResponse {
  final String ticket;
  const TicketResponse({required this.ticket});
  factory TicketResponse.fromJson(Map<String, dynamic> json) =>
      TicketResponse(ticket: (json['ticket'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'ticket': ticket};
}

class ConnectResponse {
  final String url;
  const ConnectResponse({required this.url});
  factory ConnectResponse.fromJson(Map<String, dynamic> json) =>
      ConnectResponse(url: (json['url'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'url': url};
}

class DevLoginResponse {
  final String accessToken;
  const DevLoginResponse({required this.accessToken});
  factory DevLoginResponse.fromJson(Map<String, dynamic> json) =>
      DevLoginResponse(accessToken: (json['access_token'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'access_token': accessToken};
}

class SpotifyLoginRequest {
  final String code;
  final String verifier;
  const SpotifyLoginRequest({required this.code, required this.verifier});
  factory SpotifyLoginRequest.fromJson(Map<String, dynamic> json) =>
      SpotifyLoginRequest(
        code: (json['code'] as String? ?? ''),
        verifier: (json['verifier'] as String? ?? ''),
      );
  Map<String, dynamic> toJson() => {'code': code, 'verifier': verifier};
}

class ManagedSession {
  final String refreshToken;
  const ManagedSession({required this.refreshToken});
  factory ManagedSession.fromJson(Map<String, dynamic> json) =>
      ManagedSession(refreshToken: (json['refresh_token'] as String? ?? ''));
  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

class QitApi {
  final RequestFn request;
  const QitApi(this.request);
  Future<DevLoginResponse> devLogin() async {
    final value = await request('POST', '/dev/login');
    return DevLoginResponse.fromJson(value as Map<String, dynamic>);
  }

  Future<ManagedSession> exchangeSpotifyLogin({
    required SpotifyLoginRequest body,
  }) async {
    final value = await request(
      'POST',
      '/auth/spotify/exchange',
      body: body.toJson(),
    );
    return ManagedSession.fromJson(value as Map<String, dynamic>);
  }

  Future<Host> getHost() async {
    final value = await request('GET', '/me');
    return Host.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> deleteAccount() async {
    final value = await request('DELETE', '/me');
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<ConnectResponse> connectSpotify() async {
    final value = await request('POST', '/spotify/connect');
    return ConnectResponse.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> disconnectSpotify() async {
    final value = await request('DELETE', '/spotify/connection');
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<List<Room>> listRooms() async {
    final value = await request('GET', '/rooms');
    return ((value as List?) ?? [])
        .map((v) => Room.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<Room> createRoom({required CreateRoomRequest body}) async {
    final value = await request('POST', '/rooms', body: body.toJson());
    return Room.fromJson(value as Map<String, dynamic>);
  }

  Future<JoinResponse> joinRoom({
    required String code,
    required JoinRequest body,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/join',
      body: body.toJson(),
    );
    return JoinResponse.fromJson(value as Map<String, dynamic>);
  }

  Future<Snapshot> getSnapshot({required String code}) async {
    final value = await request(
      'GET',
      '/rooms/${Uri.encodeComponent(code)}/snapshot',
    );
    return Snapshot.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> updateSettings({
    required String code,
    required SettingsRequest body,
  }) async {
    final value = await request(
      'PATCH',
      '/rooms/${Uri.encodeComponent(code)}/settings',
      body: body.toJson(),
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> closeRoom({required String code}) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/close',
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> renameMember({
    required String code,
    required NicknameRequest body,
  }) async {
    final value = await request(
      'PATCH',
      '/rooms/${Uri.encodeComponent(code)}/membership',
      body: body.toJson(),
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> blockMember({
    required String code,
    required String member,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/members/${Uri.encodeComponent(member)}/block',
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<List<PlaybackDevice>> getPlaybackDevices({
    required String code,
  }) async {
    final value = await request(
      'GET',
      '/rooms/${Uri.encodeComponent(code)}/playback/devices',
    );
    return ((value as List?) ?? [])
        .map((v) => PlaybackDevice.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<Ack> controlPlayback({
    required String code,
    required PlaybackCommand body,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/playback/control',
      body: body.toJson(),
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<List<Track>> searchTracks({
    required String code,
    required String q,
  }) async {
    final value = await request(
      'GET',
      '/rooms/${Uri.encodeComponent(code)}/tracks',
      query: {'q': q},
    );
    return ((value as List?) ?? [])
        .map((v) => Track.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  Future<SuggestionResponse> suggestTrack({
    required String code,
    required SuggestionRequest body,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/suggestions',
      body: body.toJson(),
    );
    return SuggestionResponse.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> addVote({
    required String code,
    required String suggestion,
  }) async {
    final value = await request(
      'PUT',
      '/rooms/${Uri.encodeComponent(code)}/suggestions/${Uri.encodeComponent(suggestion)}/vote',
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> removeVote({
    required String code,
    required String suggestion,
  }) async {
    final value = await request(
      'DELETE',
      '/rooms/${Uri.encodeComponent(code)}/suggestions/${Uri.encodeComponent(suggestion)}/vote',
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> moderateSuggestion({
    required String code,
    required String suggestion,
    required ModerationRequest body,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/suggestions/${Uri.encodeComponent(suggestion)}/moderate',
      body: body.toJson(),
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<Ack> resolveDelivery({
    required String code,
    required String suggestion,
    required ResolutionRequest body,
  }) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/suggestions/${Uri.encodeComponent(suggestion)}/resolve',
      body: body.toJson(),
    );
    return Ack.fromJson(value as Map<String, dynamic>);
  }

  Future<TicketResponse> getEventTicket({required String code}) async {
    final value = await request(
      'POST',
      '/rooms/${Uri.encodeComponent(code)}/event-ticket',
    );
    return TicketResponse.fromJson(value as Map<String, dynamic>);
  }
}
