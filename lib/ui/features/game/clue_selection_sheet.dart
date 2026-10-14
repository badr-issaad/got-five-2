import 'package:flutter/material.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../widgets/tile_widget.dart';

sealed class ClueSelectionResult {}

class SortClueResult extends ClueSelectionResult {
  final Tile tile;
  SortClueResult(this.tile);
}

class CompareClueResult extends ClueSelectionResult {
  final Tile tile;
  final int targetSlotIndex;
  CompareClueResult(this.tile, this.targetSlotIndex);
}

class ClueSelectionSheet extends StatefulWidget {
  final Tile selectedTile;
  final Player player;

  const ClueSelectionSheet({
    super.key,
    required this.selectedTile,
    required this.player,
  });

  @override
  State<ClueSelectionSheet> createState() => _ClueSelectionSheetState();
}

class _ClueSelectionSheetState extends State<ClueSelectionSheet> {
  int _selectedMode = 0; // 0 = Sort, 1 = Compare
  int _selectedSlotForCompare = 0; // 0..4

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tile = widget.selectedTile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Selected tile preview
          Row(
            children: [
              TileWidget(tile: tile, width: 50, height: 70),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tile #${tile.number} (${tile.color.englishName})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tile.dots} ${tile.dots == 1 ? "dot" : "dots"} • ${tile.symbol.symbolUnicode}',
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Clue Mode Selector (Sort vs Compare)
          SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                icon: const Icon(Icons.sort_rounded),
                label: Text(l10n.sortClue),
              ),
              ButtonSegment(
                value: 1,
                icon: const Icon(Icons.compare_arrows_rounded),
                label: Text(l10n.compareClue),
              ),
            ],
            selected: {_selectedMode},
            onSelectionChanged: (set) => setState(() => _selectedMode = set.first),
          ),

          const SizedBox(height: 16),

          if (_selectedMode == 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
              ),
              child: Text(
                l10n.sortClueDesc,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ),
          ] else ...[
            Text(
              l10n.selectRackSlotToCompare,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  final rackColor = widget.player.rackColors[index];
                  final isSelected = _selectedSlotForCompare == index;
                  final colorVal = AppColors.colorForTileColor(rackColor);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlotForCompare = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colorVal : colorVal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? Colors.white : colorVal,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            Tile.symbolForColor(rackColor).symbolUnicode,
                            style: TextStyle(
                              color: isSelected ? Colors.white : colorVal,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${index + 1}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.compareClueDesc,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],

          const SizedBox(height: 24),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (_selectedMode == 0) {
                Navigator.of(context).pop(SortClueResult(tile));
              } else {
                Navigator.of(context).pop(CompareClueResult(tile, _selectedSlotForCompare));
              }
            },
            child: Text(
              _selectedMode == 0 ? l10n.sortClue : l10n.compareClue,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
