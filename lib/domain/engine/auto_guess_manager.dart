import '../models/tile.dart';

/// Encapsulates the result of computing auto-guesses from the deduction sheet state.
class AutoGuessResult {
  /// The updated 5 guesses (strings '1'..'60' or '')
  final List<String> guesses;

  /// The indices of rack slots (0..4) whose current guess is automatically filled
  final Set<int> autoFilledSlots;

  /// The colors that currently have 0 candidates remaining (all 12 numbers crossed out)
  final Set<TileColor> exhaustedColors;

  const AutoGuessResult({
    required this.guesses,
    required this.autoFilledSlots,
    required this.exhaustedColors,
  });
}

class AutoGuessManager {
  /// Pure function that computes the auto-filled guesses based purely on:
  /// 1. The colors of the slots in the player's rack.
  /// 2. The visible deduction sheet numbers crossed out (manual notes + public revealed tiles).
  /// 3. The current guesses in the boxes.
  /// 4. The current set of auto-filled slot indices.
  ///
  /// Rules:
  /// - For each color, counts uncrossed numbers (out of 12).
  /// - When exactly one number remains, automatically puts it into the guess box belonging
  ///   to that color (matching by color across all rack slots).
  /// - If > 1 candidate remains, clears any previously auto-filled guess for that color.
  /// - If 0 candidates remain, clears any previously auto-filled guess and marks the color as exhausted.
  /// - Preserves manually entered guesses and allows editing an automatically filled guess.
  /// - Does NOT inspect the player's hidden tile values.
  static AutoGuessResult computeAutoGuesses({
    required List<TileColor> rackColors,
    required Set<int> manualCrossedOutNumbers,
    required Set<int> autoRevealedNumbers,
    required List<String> currentGuesses,
    required Set<int> currentAutoFilledSlots,
  }) {
    final totalCrossedOut = {...manualCrossedOutNumbers, ...autoRevealedNumbers};

    // Calculate uncrossed candidate numbers for all 5 colors
    final Map<TileColor, List<int>> candidatesByColor = {};
    final Set<TileColor> exhaustedColors = {};

    for (final color in TileColor.values) {
      final candidates = Tile.tilesForColor(color)
          .map((t) => t.number)
          .where((n) => !totalCrossedOut.contains(n))
          .toList();

      candidatesByColor[color] = candidates;
      if (candidates.isEmpty) {
        exhaustedColors.add(color);
      }
    }

    final updatedGuesses = List<String>.from(currentGuesses);
    while (updatedGuesses.length < rackColors.length) {
      updatedGuesses.add('');
    }

    final newAutoFilledSlots = Set<int>.from(currentAutoFilledSlots);

    for (int i = 0; i < rackColors.length; i++) {
      final color = rackColors[i];
      final candidates = candidatesByColor[color] ?? [];
      final wasAutoFilled = currentAutoFilledSlots.contains(i);

      if (wasAutoFilled) {
        if (candidates.length == 1) {
          // Exactly 1 candidate remains -> keep / update auto-filled value
          updatedGuesses[i] = candidates.first.toString();
          newAutoFilledSlots.add(i);
        } else {
          // >1 candidate or 0 candidates -> clear the auto-filled guess
          updatedGuesses[i] = '';
          newAutoFilledSlots.remove(i);
        }
      } else {
        // Not marked as auto-filled
        if (updatedGuesses[i].isEmpty) {
          // Empty slot: if exactly 1 candidate remains, auto-fill it!
          if (candidates.length == 1) {
            updatedGuesses[i] = candidates.first.toString();
            newAutoFilledSlots.add(i);
          }
        } else {
          // User manually entered a guess: PRESERVE IT!
        }
      }
    }

    return AutoGuessResult(
      guesses: updatedGuesses,
      autoFilledSlots: newAutoFilledSlots,
      exhaustedColors: exhaustedColors,
    );
  }
}
