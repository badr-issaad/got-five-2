import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../domain/engine/game_engine.dart';
import '../domain/models/game_state.dart';
import '../domain/models/tile.dart';
import 'models/network_room.dart';

enum LanConnectionRole { host, client }

class LocalLanGameService extends ChangeNotifier {
  static const int defaultPort = 55555;

  LanConnectionRole? _role;
  ServerSocket? _server;
  final Map<String, Socket> _clientSockets = {};
  Socket? _outgoingSocket;

  GameState? _authoritativeState;
  GameState? _clientReceivedState;

  NetworkRoom? _room;
  String? _myPlayerId;
  String? _hostIpAddress;
  bool _isConnected = false;
  String? _statusMessage;

  NetworkRoom? get room => _room;
  GameState? get currentGameState =>
      _role == LanConnectionRole.host ? _authoritativeState : _clientReceivedState;
  bool get isConnected => _isConnected;
  String? get hostIpAddress => _hostIpAddress;
  String? get statusMessage => _statusMessage;
  LanConnectionRole? get role => _role;

  /// Start Host mode on local network
  Future<void> startHost({
    required String hostName,
    int port = defaultPort,
  }) async {
    _role = LanConnectionRole.host;
    _myPlayerId = 'host_${DateTime.now().millisecondsSinceEpoch}';

    // Find local Wi-Fi / LAN IP address
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLinkLocal: false,
    );
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) {
          _hostIpAddress = addr.address;
          break;
        }
      }
      if (_hostIpAddress != null) break;
    }
    _hostIpAddress ??= '127.0.0.1';

    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _isConnected = true;
    _statusMessage = 'Host running at $_hostIpAddress:$port';

    _room = NetworkRoom(
      roomId: 'lan_room_${DateTime.now().millisecondsSinceEpoch}',
      roomCode: _hostIpAddress!.split('.').last.padLeft(3, '0'),
      hostId: _myPlayerId!,
      players: [
        RoomPlayer(id: _myPlayerId!, name: hostName, isHost: true, isReady: true),
      ],
    );

    _server!.listen(_handleIncomingClient);
    notifyListeners();
  }

  void _handleIncomingClient(Socket socket) {
    String? assignedPlayerId;

    socket.listen(
      (data) {
        final message = utf8.decode(data).trim();
        for (final line in message.split('\n')) {
          if (line.isEmpty) continue;
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            final type = json['type'] as String;

            if (type == 'join') {
              final playerName = json['name'] as String;
              assignedPlayerId = 'client_${DateTime.now().millisecondsSinceEpoch}';
              _clientSockets[assignedPlayerId!] = socket;

              final updatedPlayers = [
                ..._room!.players,
                RoomPlayer(id: assignedPlayerId!, name: playerName, isReady: true),
              ];
              _room = NetworkRoom(
                roomId: _room!.roomId,
                roomCode: _room!.roomCode,
                hostId: _room!.hostId,
                players: updatedPlayers,
              );

              _sendToSocket(socket, {
                'type': 'join_ack',
                'playerId': assignedPlayerId,
                'room': _room!.toJson(),
              });
              _broadcastRoom();
            } else if (type == 'action') {
              _handleClientGameAction(json);
            }
          } catch (e) {
            debugPrint('Error parsing LAN message: $e');
          }
        }
      },
      onDone: () {
        if (assignedPlayerId != null) {
          _clientSockets.remove(assignedPlayerId);
          _room = NetworkRoom(
            roomId: _room!.roomId,
            roomCode: _room!.roomCode,
            hostId: _room!.hostId,
            players: _room!.players.where((p) => p.id != assignedPlayerId).toList(),
          );
          _broadcastRoom();
        }
      },
    );
  }

  /// Start Host's game and send sanitized views to each client
  void hostStartGame() {
    if (_role != LanConnectionRole.host || _room == null) return;

    final configs = _room!.players.map((p) => PlayerConfig(
      id: p.id,
      name: p.name,
      isAi: false,
    )).toList();

    // Fill remaining with bots up to at least 2 or 3
    if (configs.length < 2) {
      configs.add(const PlayerConfig(id: 'lan_bot_1', name: 'Bot Bravo', isAi: true));
    }

    _authoritativeState = GameEngine.createGame(playerConfigs: configs);
    _broadcastSanitizedGameStates();
    notifyListeners();
  }

  void _broadcastRoom() {
    for (final socket in _clientSockets.values) {
      _sendToSocket(socket, {'type': 'room_update', 'room': _room!.toJson()});
    }
    notifyListeners();
  }

  /// CRITICAL SECURITY: Host only sends sanitized view to each client
  void _broadcastSanitizedGameStates() {
    if (_authoritativeState == null) return;

    for (int i = 0; i < _authoritativeState!.players.length; i++) {
      final player = _authoritativeState!.players[i];
      final socket = _clientSockets[player.id];
      if (socket != null) {
        final sanitized = _authoritativeState!.sanitizedForPlayer(i);
        _sendToSocket(socket, {
          'type': 'game_update',
          'state': sanitized.toJson(),
        });
      }
    }
    notifyListeners();
  }

  void _handleClientGameAction(Map<String, dynamic> json) {
    if (_authoritativeState == null) return;
    final action = json['action'] as String;

    try {
      if (action == 'reveal') {
        final colorName = json['color'] as String;
        final color = TileColor.values.firstWhere((c) => c.name == colorName);
        _authoritativeState = GameEngine.revealTile(_authoritativeState!, color);
      } else if (action == 'sort_clue') {
        final tileNum = json['tileNumber'] as int;
        final tile = Tile.fromNumber(tileNum);
        _authoritativeState = GameEngine.askSortClue(_authoritativeState!, tile);
      } else if (action == 'compare_clue') {
        final tileNum = json['tileNumber'] as int;
        final slotIdx = json['slotIndex'] as int;
        final tile = Tile.fromNumber(tileNum);
        _authoritativeState = GameEngine.askCompareClue(_authoritativeState!, tile, slotIdx);
      } else if (action == 'declare') {
        final playerIdx = _authoritativeState!.activePlayerIndex;
        final numbers = (json['numbers'] as List<dynamic>).map((e) => e as int).toList();
        _authoritativeState = GameEngine.declareGotFive(_authoritativeState!, playerIdx, numbers);
      }

      _broadcastSanitizedGameStates();
    } catch (e) {
      debugPrint('LAN Action execution error: $e');
    }
  }

  /// Connect as Client to a Host's IP address
  Future<void> connectToHost({
    required String hostIp,
    required String playerName,
    int port = defaultPort,
  }) async {
    _role = LanConnectionRole.client;
    _outgoingSocket = await Socket.connect(hostIp, port);
    _isConnected = true;
    _statusMessage = 'Connected to $hostIp';

    _outgoingSocket!.listen((data) {
      final msg = utf8.decode(data).trim();
      for (final line in msg.split('\n')) {
        if (line.isEmpty) continue;
        try {
          final json = jsonDecode(line) as Map<String, dynamic>;
          final type = json['type'] as String;

          if (type == 'join_ack') {
            _myPlayerId = json['playerId'] as String;
            _room = NetworkRoom.fromJson(json['room'] as Map<String, dynamic>);
            notifyListeners();
          } else if (type == 'room_update') {
            _room = NetworkRoom.fromJson(json['room'] as Map<String, dynamic>);
            notifyListeners();
          } else if (type == 'game_update') {
            _clientReceivedState = GameState.fromJson(json['state'] as Map<String, dynamic>);
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing server message: $e');
        }
      }
    });

    _sendToSocket(_outgoingSocket!, {'type': 'join', 'name': playerName});
    notifyListeners();
  }

  void _sendToSocket(Socket socket, Map<String, dynamic> data) {
    final payload = '${jsonEncode(data)}\n';
    socket.write(payload);
  }

  void disconnect() {
    _server?.close();
    _server = null;
    for (final s in _clientSockets.values) {
      s.destroy();
    }
    _clientSockets.clear();
    _outgoingSocket?.destroy();
    _outgoingSocket = null;
    _isConnected = false;
    _room = null;
    _authoritativeState = null;
    _clientReceivedState = null;
    notifyListeners();
  }
}
