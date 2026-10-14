import '../engine/game_engine.dart';
import '../models/clue.dart';
import '../models/game_state.dart';
import '../models/tile.dart';

/// Tracks deductions for a player's 5 hidden slots.
/// Strictly uses only public game information (visible racks of opponents,
/// public pool tiles, all public clues on the table, and the player's own clue history).
class DeductionTracker {
  final List<TileColor> rackColors;
  final List<Set<int>> slotCandidates; // candidates for slots 0..4

  DeductionTracker({
    required this.rackColors,
    required this.slotCandidates,
  });

  /// Factory to initialize candidates from visible public information
  factory DeductionTracker.fromGameState({
    required GameState state,
    required int targetPlayerIndex,
  }) {
    final targetPlayer = state.players[targetPlayerIndex];
    final rackColors = targetPlayer.rackColors;

    // 1. Gather all publicly visible tiles that can NEVER be in the player's hidden rack:
    final eliminatedNumbers = GameEngine.getRevealedNumbersForPlayer(
      state,
      targetPlayerIndex,
    );

    // 2. Initialize candidates for each slot based on its known color
    final List<Set<int>> slotCandidates = [];
    for (int slot = 0; slot < 5; slot++) {
      final color = rackColors[slot];
      final colorTileNumbers = Tile.tilesForColor(color).map((t) => t.number).toSet();
      // Remove any known revealed numbers
      colorTileNumbers.removeAll(eliminatedNumbers);
      slotCandidates.add(colorTileNumbers);
    }

    final tracker = DeductionTracker(
      rackColors: rackColors,
      slotCandidates: slotCandidates,
    );

    // 3. Apply target player's clue history
    for (final clue in targetPlayer.cluesReceived) {
      tracker.applyClue(clue);
    }

    // 4. Propagate order constraints until equilibrium
    tracker.propagateOrderConstraints();

    return tracker;
  }

  /// Applies a Sort or Compare clue to narrow candidates
  void applyClue(GameClue clue) {
    if (clue is SortClue) {
      final tileNum = clue.tile.number;
      final slotIdx = clue.slotIndex;

      for (int slot = 0; slot < 5; slot++) {
        if (slot < slotIdx) {
          // Must be strictly less than tileNum
          slotCandidates[slot].removeWhere((n) => n >= tileNum);
        } else {
          // Must be strictly greater than tileNum
          slotCandidates[slot].removeWhere((n) => n <= tileNum);
        }
      }
    } else if (clue is CompareClue) {
      final targetSlot = clue.targetSlotIndex;
      final clueDots = clue.tile.dots;
      final match = clue.match;

      slotCandidates[targetSlot].removeWhere((n) {
        final dots = Tile.calculateDots(n);
        return match ? (dots != clueDots) : (dots == clueDots);
      });
    }

    propagateOrderConstraints();
  }

  /// Enforces rack ascending order constraints:
  /// candidate[0] < candidate[1] < candidate[2] < candidate[3] < candidate[4]
  void propagateOrderConstraints() {
    final count = slotCandidates.length;
    if (count <= 1) return;

    bool changed = true;
    int iterations = 0;
    while (changed && iterations < 20) {
      changed = false;
      iterations++;

      // Forward pass: slot[i] must be strictly greater than min(slot[i-1])
      for (int i = 1; i < count; i++) {
        if (slotCandidates[i - 1].isEmpty) continue;
        final minPrev = slotCandidates[i - 1].reduce((a, b) => a < b ? a : b);
        final beforeCount = slotCandidates[i].length;
        slotCandidates[i].removeWhere((n) => n <= minPrev);
        if (slotCandidates[i].length != beforeCount) changed = true;
      }

      // Backward pass: slot[i] must be strictly less than max(slot[i+1])
      for (int i = count - 2; i >= 0; i--) {
        if (slotCandidates[i + 1].isEmpty) continue;
        final maxNext = slotCandidates[i + 1].reduce((a, b) => a > b ? a : b);
        final beforeCount = slotCandidates[i].length;
        slotCandidates[i].removeWhere((n) => n >= maxNext);
        if (slotCandidates[i].length != beforeCount) changed = true;
      }
    }
  }

  /// Are all 5 slots completely determined (exactly 1 candidate per slot)?
  bool get isFullySolved =>
      slotCandidates.every((candidates) => candidates.length == 1);

  /// Total number of remaining candidates across all slots
  int get totalRemainingPossibilities =>
      slotCandidates.fold(0, (sum, set) => sum + set.length);

  /// Returns the current best guess list (smallest remaining candidate for each slot)
  List<int> getBestGuess() {
    final guess = <int>[];
    for (int i = 0; i < 5; i++) {
      if (slotCandidates[i].isNotEmpty) {
        // pick candidate closest to median or single candidate
        final sorted = slotCandidates[i].toList()..sort();
        guess.add(sorted[sorted.length ~/ 2]);
      } else {
        guess.add(i + 1); // fallback
      }
    }
    // ensure strictly ascending
    for (int i = 1; i < 5; i++) {
      if (guess[i] <= guess[i - 1]) {
        guess[i] = guess[i - 1] + 1;
      }
    }
    return guess;
  }
}
