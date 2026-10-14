import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../network/local_lan_game_service.dart';
import '../../../network/models/network_room.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';

class OnlineRoomScreen extends StatefulWidget {
  final GameController gameController;

  const OnlineRoomScreen({super.key, required this.gameController});

  @override
  State<OnlineRoomScreen> createState() => _OnlineRoomScreenState();
}

class _OnlineRoomScreenState extends State<OnlineRoomScreen> {
  final LocalLanGameService _lanService = LocalLanGameService();
  final TextEditingController _nameController = TextEditingController(text: 'Player 1');
  final TextEditingController _codeController = TextEditingController();

  bool _isHosting = false;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _lanService.addListener(_onLanUpdate);
  }

  @override
  void dispose() {
    _lanService.removeListener(_onLanUpdate);
    _lanService.disconnect();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _onLanUpdate() {
    setState(() {});
  }

  void _startHosting() async {
    final name = _nameController.text.trim().isEmpty ? 'Host' : _nameController.text.trim();
    setState(() => _isHosting = true);
    await _lanService.startHost(hostName: name);
  }

  void _joinHost() async {
    final name = _nameController.text.trim().isEmpty ? 'Guest' : _nameController.text.trim();
    final ip = _codeController.text.trim();
    if (ip.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      await _lanService.connectToHost(hostIp: ip, playerName: name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to host: $e')),
        );
      }
      setState(() => _isJoining = false);
    }
  }

  void _showFirebaseConfigInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Firebase Production & Emulator Setup'),
        content: const SingleChildScrollView(
          child: Text(
            'This build includes complete Firebase Cloud Functions & Firestore security architecture in the project repository (`functions/` and `firestore.rules`).\n\n'
            'To run against Firebase:\n'
            '1. Run `firebase emulators:start` in the project root.\n'
            '2. The emulator starts Auth on :9099, Firestore on :8080, and Functions on :5001.\n\n'
            'Offline Direct Local LAN mode is also active immediately for cross-device play without internet!',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final room = _lanService.room;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onlineRooms),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showFirebaseConfigInfo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: room == null
            ? _buildEntryMenu(context, l10n)
            : _buildLobbyView(context, l10n, room),
      ),
    );
  }

  Widget _buildEntryMenu(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nickname field
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.yourName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Host a room
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wifi_tethering_rounded, color: Colors.amberAccent, size: 28),
                      const SizedBox(width: 10),
                      Text(l10n.createRoom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Host a local match on your Wi-Fi or Hotspot. Other devices can join via Room Code or QR code.',
                    style: TextStyle(fontSize: 12.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkAccent),
                    onPressed: _isHosting ? null : _startHosting,
                    child: _isHosting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.createRoom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Join a room
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.login_rounded, color: Colors.greenAccent, size: 28),
                      const SizedBox(width: 10),
                      Text(l10n.joinRoom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: 'Enter Host IP (e.g. 192.168.1.50)',
                      prefixIcon: const Icon(Icons.qr_code_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                    onPressed: _isJoining ? null : _joinHost,
                    child: _isJoining
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.joinRoom, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView(BuildContext context, AppLocalizations l10n, NetworkRoom room) {
    final isHost = _lanService.role == LanConnectionRole.host;
    final hostIp = _lanService.hostIpAddress ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // QR Code Card for pairing
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Room Code / IP: $hostIp',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amberAccent),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    child: QrImageView(
                      data: hostIp,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Ask friends on the same Wi-Fi to scan or enter IP', style: TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Players in lobby
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.playerCount} (${room.players.length}/${room.maxPlayers})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  for (final p in room.players)
                    ListTile(
                      leading: Icon(
                        p.isHost ? Icons.military_tech_rounded : Icons.person_rounded,
                        color: p.isHost ? Colors.amberAccent : Colors.white70,
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: p.isReady ? Colors.green.withValues(alpha: 0.8) : Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.isHost ? 'Host' : (p.isReady ? l10n.ready : 'Waiting'),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          if (isHost)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(l10n.startOnlineMatch, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () {
                _lanService.hostStartGame();
              },
            ),
        ],
      ),
    );
  }
}
