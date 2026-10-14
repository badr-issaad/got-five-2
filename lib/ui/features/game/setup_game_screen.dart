import 'package:flutter/material.dart';
import '../../../domain/engine/game_engine.dart';
import '../../../domain/models/player.dart';
import '../../../l10n/app_localizations.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';
import 'game_screen.dart';

class SetupGameScreen extends StatefulWidget {
  final GameController controller;

  const SetupGameScreen({super.key, required this.controller});

  @override
  State<SetupGameScreen> createState() => _SetupGameScreenState();
}

class _SetupGameScreenState extends State<SetupGameScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'Player 1');
  int _playerCount = 3; // 2, 3, or 4
  AiDifficulty _difficulty = AiDifficulty.medium;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onStartMatch() {
    final name = _nameController.text.trim().isEmpty ? 'Player 1' : _nameController.text.trim();

    final configs = <PlayerConfig>[
      PlayerConfig(id: 'human_1', name: name, isAi: false),
    ];

    final botNames = ['Bot Alpha', 'Bot Beta', 'Bot Gamma'];
    for (int i = 1; i < _playerCount; i++) {
      configs.add(PlayerConfig(
        id: 'bot_$i',
        name: botNames[i - 1],
        isAi: true,
        aiDifficulty: _difficulty,
      ));
    }

    widget.controller.startNewGame(configs);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectOpponents)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player name
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
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Player count
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.playerCount, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 2, label: Text('2 Players')),
                          ButtonSegment(value: 3, label: Text('3 Players')),
                          ButtonSegment(value: 4, label: Text('4 Players')),
                        ],
                        selected: {_playerCount},
                        onSelectionChanged: (set) => setState(() => _playerCount = set.first),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // AI Difficulty
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.aiDifficulty, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      SegmentedButton<AiDifficulty>(
                        segments: [
                          ButtonSegment(value: AiDifficulty.easy, label: Text(l10n.easy)),
                          ButtonSegment(value: AiDifficulty.medium, label: Text(l10n.medium)),
                          ButtonSegment(value: AiDifficulty.hard, label: Text(l10n.hard)),
                        ],
                        selected: {_difficulty},
                        onSelectionChanged: (set) => setState(() => _difficulty = set.first),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(
                  l10n.startGame,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _onStartMatch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
