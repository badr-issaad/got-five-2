import 'package:flutter/material.dart';
import '../../../domain/engine/game_engine.dart';
import '../../../l10n/app_localizations.dart';
import '../../controllers/game_controller.dart';
import '../pdf/printable_materials_screen.dart';
import 'pass_and_play_screen.dart';

class TabletopModeScreen extends StatelessWidget {
  final GameController controller;

  const TabletopModeScreen({super.key, required this.controller});

  void _startPassAndPlay(BuildContext context, int count) {
    final configs = List.generate(
      count,
      (i) => PlayerConfig(id: 'human_${i + 1}', name: 'Player ${i + 1}', isAi: false),
    );
    controller.startNewGame(configs);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PassAndPlayScreen(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabletopPaperModeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Option A: Connected + Paper Notes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.feed_rounded, color: Colors.amberAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Option A: Connected + Paper Notes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tabletopModeADesc,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.print_rounded),
                        label: Text(l10n.printMaterials),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PrintableMaterialsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Option B: Single Shared Phone (Pass-and-Play)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phonelink_ring_rounded, color: Colors.greenAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Option B: Single Shared Phone',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tabletopModeBDesc,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () => _startPassAndPlay(context, 2),
                        child: const Text('2 Players Pass & Play'),
                      ),
                      ElevatedButton(
                        onPressed: () => _startPassAndPlay(context, 3),
                        child: const Text('3 Players Pass & Play'),
                      ),
                      ElevatedButton(
                        onPressed: () => _startPassAndPlay(context, 4),
                        child: const Text('4 Players Pass & Play'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Option C: Assistant for Physical Tiles
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.extension_rounded, color: Colors.cyanAccent, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Option C: Helper Phone + Physical Tiles',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tabletopModeCDesc,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Note: This mode requires physical tiles or printed cut-outs. The app acts as an impartial clue judge without spoiling secrets.',
                      style: TextStyle(fontSize: 12, color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
