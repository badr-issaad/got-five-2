import 'dart:math';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';
import 'deduction_tracker.dart';

sealed class AiAction {}

class AiRevealAction extends AiAction {
  final TileColor color;
  AiRevealAction(this.color);
}

class AiSortClueAction extends AiAction {
  final Tile tile;
  AiSortClueAction(this.tile);
}

class AiCompareClueAction extends AiAction {
  final Tile tile;
  final int targetSlotIndex;
  AiCompareClueAction(this.tile, this.targetSlotIndex);
}

class AiGuessAction extends AiAction {
  final List<int> guessedNumbers;
  AiGuessAction(this.guessedNumbers);
}

class AiBrain {
  final Random _rng;

  AiBrain({Random? random}) : _rng = random ?? Random();

  /// Determines the AI's next move based on current game state and AI difficulty.
  /// FAIR GUARANTEE: Does not access active player's hidden rack numbers,
  /// seed, or reserve tile ordering.
  AiAction decideNextAction(GameState state) {
    final aiIndex = state.activePlayerIndex;
    final aiPlayer = state.players[aiIndex];
    final difficulty = aiPlayer.aiDifficulty ?? AiDifficulty.medium;

    final tracker = DeductionTracker.fromGameState(
      state: state,
      targetPlayerIndex: aiIndex,
    );

    // 1. Check if we should declare "GOT FIVE!"
    if (!aiPlayer.hasGuessed && _shouldDeclareGotFive(tracker, difficulty, state.turnNumber)) {
      final guess = tracker.getBestGuess();
      return AiGuessAction(guess);
    }

    // 2. Turn Step 1: REVEAL A TILE
    if (state.phase == GamePhase.revealingTile) {
      final chosenColor = _chooseColorToReveal(state, tracker, difficulty);
      return AiRevealAction(chosenColor);
    }

    // 3. Turn Step 2: ASK FOR A CLUE
    if (state.phase == GamePhase.askingClue) {
      return _chooseClueAction(state, tracker, difficulty);
    }

    throw StateError('AI cannot act in phase ${state.phase}');
  }

  bool _shouldDeclareGotFive(
    DeductionTracker tracker,
    AiDifficulty difficulty,
    int turnNumber,
  ) {
    if (tracker.isFullySolved) {
      switch (difficulty) {
        case AiDifficulty.hard:
          return true; // Hard AI declares immediately when 100% certain
        case AiDifficulty.medium:
          return true;
        case AiDifficulty.easy:
          // Easy AI hesitates 30% of the time to give the player a chance
          return _rng.nextDouble() > 0.3;
      }
    }

    if (difficulty == AiDifficulty.medium) {
      // If 4 slots are solved and the 5th has at most 2 candidates
      final solvedCount = tracker.slotCandidates.where((s) => s.length == 1).length;
      if (solvedCount == 4 && tracker.totalRemainingPossibilities <= 6 && turnNumber > 8) {
        return _rng.nextDouble() > 0.5;
      }
    }

    return false;
  }

  TileColor _chooseColorToReveal(
    GameState state,
    DeductionTracker tracker,
    AiDifficulty difficulty,
  ) {
    final availableColors = state.availableReserveColors;
    if (availableColors.isEmpty) {
      return TileColor.green; // fallback
    }

    if (difficulty == AiDifficulty.easy) {
      return availableColors[_rng.nextInt(availableColors.length)];
    }

    // Medium & Hard: Pick the color corresponding to the rack slot that has the most remaining candidates
    int maxCandidates = -1;
    TileColor preferredColor = availableColors.first;

    for (int slot = 0; slot < 5; slot++) {
      final color = tracker.rackColors[slot];
      if (availableColors.contains(color)) {
        final count = tracker.slotCandidates[slot].length;
        if (count > maxCandidates) {
          maxCandidates = count;
          preferredColor = color;
        }
      }
    }

    return preferredColor;
  }

  AiAction _chooseClueAction(
    GameState state,
    DeductionTracker tracker,
    AiDifficulty difficulty,
  ) {
    final pool = state.pool;
    if (pool.isEmpty) {
      throw StateError('Cannot choose clue from empty pool.');
    }

    if (difficulty == AiDifficulty.easy) {
      // Pick random pool tile, then 50% sort or compare
      final randomTile = pool[_rng.nextInt(pool.length)];
      if (_rng.nextBool()) {
        return AiSortClueAction(randomTile);
      } else {
        final randomSlot = _rng.nextInt(5);
        return AiCompareClueAction(randomTile, randomSlot);
      }
    }

    // Medium & Hard: Evaluate candidate actions by expected candidate reduction (utility)
    double bestScore = -1.0;
    AiAction bestAction = AiSortClueAction(pool.first);

    for (final tile in pool) {
      // Option A: Evaluate SORT clue with this tile
      final sortScore = _evaluateSortClueUtility(tracker, tile);
      if (sortScore > bestScore) {
        bestScore = sortScore;
        bestAction = AiSortClueAction(tile);
      }

      // Option B: Evaluate COMPARE clue with this tile across all 5 slots
      for (int slot = 0; slot < 5; slot++) {
        // If slot candidate dots are already uniform, compare is useless
        final compareScore = _evaluateCompareClueUtility(tracker, tile, slot);
        if (compareScore > bestScore) {
          bestScore = compareScore;
          bestAction = AiCompareClueAction(tile, slot);
        }
      }
    }

    return bestAction;
  }

  /// Estimates the utility of a SORT clue with [tile]
  /// A tile whose number splits remaining candidates evenly provides high information gain
  double _evaluateSortClueUtility(DeductionTracker tracker, Tile tile) {
    double totalEntropyReduction = 0;
    final tileNum = tile.number;

    for (int slot = 0; slot < 5; slot++) {
      final candidates = tracker.slotCandidates[slot];
      if (candidates.length <= 1) continue;

      final countLess = candidates.where((n) => n < tileNum).length;
      final countGreater = candidates.where((n) => n > tileNum).length;

      // Variance penalty: better if it splits candidates towards the middle
      final splitBalance = 1.0 - ((countLess - countGreater).abs() / candidates.length);
      totalEntropyReduction += splitBalance * (candidates.length);
    }

    return totalEntropyReduction;
  }

  /// Estimates the utility of a COMPARE clue with [tile] on [targetSlot]
  double _evaluateCompareClueUtility(
    DeductionTracker tracker,
    Tile tile,
    int targetSlot,
  ) {
    final candidates = tracker.slotCandidates[targetSlot];
    if (candidates.length <= 1) return 0.0;

    final matchCount =
        candidates.where((n) => Tile.calculateDots(n) == tile.dots).length;
    final mismatchCount = candidates.length - matchCount;

    if (matchCount == 0 || mismatchCount == 0) {
      return 0.0; // provides no information
    }

    // Expected candidates eliminated:
    // With probability (matchCount / total), we eliminate mismatchCount;
    // With probability (mismatchCount / total), we eliminate matchCount.
    final pMatch = matchCount / candidates.length;
    final pMismatch = mismatchCount / candidates.length;
    final expectedEliminated = (pMatch * mismatchCount) + (pMismatch * matchCount);

    return expectedEliminated * 1.5; // weight compare clues when highly discriminative
  }
}
