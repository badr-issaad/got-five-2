import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../../l10n/app_localizations.dart';
import 'tile_widget.dart';

class CompactOpponentsWidget extends StatefulWidget {
  final List<Player> opponents;
  final int activePlayerIndex;

  const CompactOpponentsWidget({
    super.key,
    required this.opponents,
    required this.activePlayerIndex,
  });

  @override
  State<CompactOpponentsWidget> createState() => _CompactOpponentsWidgetState();
}

class _CompactOpponentsWidgetState extends State<CompactOpponentsWidget> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.opponents.isEmpty) return const SizedBox.shrink();

    // If only 1 opponent (standard 2p game), show them directly without tabs
    if (widget.opponents.length == 1) {
      final opp = widget.opponents.first;
      final isActive = widget.activePlayerIndex != 0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amber.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.amberAccent : Colors.white12,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Opponent name & avatar
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opp.isAi ? Icons.smart_toy_rounded : Icons.person_rounded,
                  size: 13,
                  color: isActive ? Colors.amberAccent : Colors.white70,
                ),
                const SizedBox(width: 3),
                Text(
                  opp.name,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.amberAccent : Colors.white,
                  ),
                ),
                if (opp.isEliminated) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('OUT', style: TextStyle(fontSize: 8.0, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const Spacer(),
            // Opponent 5 visible tiles (Ascending LTR)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: opp.rack.map((tile) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: TileWidget(
                      tile: tile,
                      width: 24,
                      height: 32,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    // Multiple opponents (3p or 4p game): Tab selector + active opponent's rack on a single compact row
    final activeOpponent = widget.opponents[_selectedTabIndex.clamp(0, widget.opponents.length - 1)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(widget.opponents.length, (idx) {
                  final opp = widget.opponents[idx];
                  final isTabSelected = _selectedTabIndex == idx;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isTabSelected ? Colors.amber.shade700 : Colors.white12,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opp.isAi ? Icons.smart_toy_rounded : Icons.person_rounded,
                            size: 11,
                            color: isTabSelected ? Colors.black : Colors.white70,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            opp.name,
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: isTabSelected ? Colors.black : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 3),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: activeOpponent.rack.map((tile) {
                return Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: TileWidget(
                    tile: tile,
                    width: 24,
                    height: 32,
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
