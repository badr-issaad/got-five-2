enum RoomStatus {
  lobby,
  inGame,
  finished,
}

class RoomPlayer {
  final String id;
  final String name;
  final bool isHost;
  final bool isReady;
  final bool isConnected;
  final DateTime lastHeartbeat;

  RoomPlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.isReady = false,
    this.isConnected = true,
    DateTime? lastHeartbeat,
  }) : lastHeartbeat = lastHeartbeat ?? DateTime.now();

  RoomPlayer copyWith({
    String? id,
    String? name,
    bool? isHost,
    bool? isReady,
    bool? isConnected,
    DateTime? lastHeartbeat,
  }) {
    return RoomPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      isConnected: isConnected ?? this.isConnected,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isHost': isHost,
        'isReady': isReady,
        'isConnected': isConnected,
        'lastHeartbeat': lastHeartbeat.toIso8601String(),
      };

  factory RoomPlayer.fromJson(Map<String, dynamic> json) {
    return RoomPlayer(
      id: json['id'] as String,
      name: json['name'] as String,
      isHost: json['isHost'] as bool? ?? false,
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? true,
      lastHeartbeat: json['lastHeartbeat'] != null
          ? DateTime.parse(json['lastHeartbeat'] as String)
          : DateTime.now(),
    );
  }
}

class NetworkRoom {
  final String roomId;
  final String roomCode; // 6-character user friendly code
  final String hostId;
  final List<RoomPlayer> players;
  final int maxPlayers;
  final RoomStatus status;
  final bool fillEmptyWithBots;
  final String? activeGameId;

  NetworkRoom({
    required this.roomId,
    required this.roomCode,
    required this.hostId,
    required this.players,
    this.maxPlayers = 4,
    this.status = RoomStatus.lobby,
    this.fillEmptyWithBots = true,
    this.activeGameId,
  });

  bool get canStart =>
      players.length >= 2 && players.every((p) => p.isReady || p.isHost);

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'roomCode': roomCode,
        'hostId': hostId,
        'players': players.map((p) => p.toJson()).toList(),
        'maxPlayers': maxPlayers,
        'status': status.name,
        'fillEmptyWithBots': fillEmptyWithBots,
        'activeGameId': activeGameId,
      };

  factory NetworkRoom.fromJson(Map<String, dynamic> json) {
    return NetworkRoom(
      roomId: json['roomId'] as String,
      roomCode: json['roomCode'] as String,
      hostId: json['hostId'] as String,
      players: (json['players'] as List<dynamic>)
          .map((p) => RoomPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
      maxPlayers: json['maxPlayers'] as int? ?? 4,
      status: RoomStatus.values.firstWhere((s) => s.name == json['status']),
      fillEmptyWithBots: json['fillEmptyWithBots'] as bool? ?? true,
      activeGameId: json['activeGameId'] as String?,
    );
  }
}
