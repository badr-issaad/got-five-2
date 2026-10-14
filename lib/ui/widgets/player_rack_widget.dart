import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import 'tile_widget.dart';

class PlayerRackWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isOwnerView;
  final int? selectedSlotIndex;
  final ValueChanged<int>? onSlotSelected;

  const PlayerRackWidget({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isOwnerView = false,
    this.selectedSlotIndex,
    this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.indigo.withValues(alpha: 0.25)
            : Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.indigoAccent
              : Colors.white.withValues(alpha: 0.15),
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Player Name + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    player.isAi ? Icons.smart_toy_rounded : Icons.person_rounded,
                    size: 20,
                    color: isCurrentPlayer ? Colors.amberAccent : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    player.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isCurrentPlayer ? Colors.amberAccent : Colors.white,
                    ),
                  ),
                  if (player.isAi && player.aiDifficulty != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        player.aiDifficulty!.displayName,
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
              if (player.isEliminated)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ELIMINATED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (player.isWinner)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'WINNER 🏆',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Physical Stand View
          // CRITICAL: Force LTR directionality so ascending rack order and +/- indicators
          // preserve exact mathematical meaning in both Arabic RTL and LTR languages.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                // Direction Arrow & Mathematical Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.remove_circle_outline, size: 14, color: Colors.white60),
                          SizedBox(width: 3),
                          Text('MIN', style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 2,
                            width: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white70),
                        ],
                      ),
                      const Row(
                        children: [
                          Text('MAX', style: TextStyle(fontSize: 10, color: Colors.white60, fontWeight: FontWeight.bold)),
                          SizedBox(width: 3),
                          Icon(Icons.add_circle_outline, size: 14, color: Colors.white60),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Stand Base Shelf with 5 Slots
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3E2723), // Warm wood/shelf finish
                        Color(0xFF271612),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(0, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(player.rack.length, (slotIndex) {
                      final tile = player.rack[slotIndex];
                      final isSelected = selectedSlotIndex == slotIndex;

                      return GestureDetector(
                        onTap: onSlotSelected != null
                            ? () => onSlotSelected!(slotIndex)
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.amberAccent : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: TileWidget(
                            tile: tile,
                            width: 52,
                            height: 74,
                            isSelected: isSelected,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
