import 'package:flutter/material.dart';
import '../../domain/models/clue.dart';
import '../../domain/models/player.dart';
import '../../l10n/app_localizations.dart';
import 'tile_widget.dart';

class ClueTrayWidget extends StatelessWidget {
  final Player player;

  const ClueTrayWidget({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clues = player.cluesReceived;

    if (clues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.step2ClueDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt_rounded, size: 18, color: Colors.amberAccent),
              const SizedBox(width: 6),
              Text(
                '${l10n.cluesReceived} (${clues.length})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: clues.map((clue) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TileWidget(
                        tile: clue.tile,
                        width: 44,
                        height: 62,
                      ),
                      const SizedBox(height: 4),
                      if (clue is SortClue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Slot ${clue.slotIndex}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        )
                      else if (clue is CompareClue)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: clue.match ? Colors.green.withValues(alpha: 0.8) : Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                clue.match ? Icons.check_circle : Icons.cancel,
                                size: 11,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                clue.match ? 'YES' : 'NO',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
