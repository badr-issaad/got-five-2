import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/local_game_storage.dart';
import '../../domain/ai/ai_player.dart';
import '../../domain/engine/game_engine.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/tile.dart';

class GameController extends ChangeNotifier {
  final LocalGameStorage storage;
  final AiBrain _aiBrain;

  GameState? _state;
  bool _isProcessingAi = false;
  String? _errorMessage;

  GameController({
    required this.storage,
    AiBrain? aiBrain,
  })  : _aiBrain = aiBrain ?? AiBrain() {
    _restoreSavedGame();
  }

  GameState? get state => _state;
  bool get hasActiveGame => _state != null;
  bool get isProcessingAi => _isProcessingAi;
  String? get errorMessage => _errorMessage;

  void _restoreSavedGame() {
    final saved = storage.loadSavedGame();
    if (saved != null && !saved.isGameOver) {
      _state = saved;
      notifyListeners();
      if (_state!.activePlayer.isAi) {
        _triggerAiIfNeeded();
      }
    }
  }

  /// Start a new local match with given player configurations
  void startNewGame(List<PlayerConfig> playerConfigs) {
    _state = GameEngine.createGame(playerConfigs: playerConfigs);
    _errorMessage = null;
    storage.saveGame(_state!);
    notifyListeners();

    _triggerAiIfNeeded();
  }

  /// Step 1: Reveal tile from reserve
  void revealTile(TileColor color) {
    if (_state == null || _state!.isGameOver) return;
    try {
      _state = GameEngine.revealTile(_state!, color);
      _errorMessage = null;
      storage.saveGame(_state!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Step 2A: Ask for SORT clue
  void askSortClue(Tile poolTile) {
    if (_state == null || _state!.isGameOver) return;
    try {
      _state = GameEngine.askSortClue(_state!, poolTile);
      _errorMessage = null;
      storage.saveGame(_state!);
      notifyListeners();

      _triggerAiIfNeeded();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Step 2B: Ask for COMPARE clue
  void askCompareClue(Tile poolTile, int targetSlotIndex) {
    if (_state == null || _state!.isGameOver) return;
    try {
      _state = GameEngine.askCompareClue(_state!, poolTile, targetSlotIndex);
      _errorMessage = null;
      storage.saveGame(_state!);
      notifyListeners();

      _triggerAiIfNeeded();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Submit Got Five guess
  void declareGotFive(List<int> guessedNumbers) {
    if (_state == null || _state!.isGameOver) return;
    try {
      _state = GameEngine.declareGotFive(
        _state!,
        _state!.activePlayerIndex,
        guessedNumbers,
      );
      _errorMessage = null;

      if (_state!.isGameOver) {
        storage.clearSavedGame();
      } else {
        storage.saveGame(_state!);
      }
      notifyListeners();

      if (!_state!.isGameOver) {
        _triggerAiIfNeeded();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void abandonCurrentGame() {
    _state = null;
    storage.clearSavedGame();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Handles AI moves sequentially with smooth pacing
  void _triggerAiIfNeeded() {
    if (_state == null || _state!.isGameOver || _isProcessingAi) return;
    if (!_state!.activePlayer.isAi) return;

    _isProcessingAi = true;
    notifyListeners();

    // Natural delay so human player can observe board changes (800ms)
    Timer(const Duration(milliseconds: 750), () {
      if (_state == null || _state!.isGameOver) {
        _isProcessingAi = false;
        notifyListeners();
        return;
      }

      try {
        final action = _aiBrain.decideNextAction(_state!);
        if (action is AiGuessAction) {
          _state = GameEngine.declareGotFive(
            _state!,
            _state!.activePlayerIndex,
            action.guessedNumbers,
          );
        } else if (action is AiRevealAction) {
          _state = GameEngine.revealTile(_state!, action.color);
        } else if (action is AiSortClueAction) {
          _state = GameEngine.askSortClue(_state!, action.tile);
        } else if (action is AiCompareClueAction) {
          _state = GameEngine.askCompareClue(
            _state!,
            action.tile,
            action.targetSlotIndex,
          );
        }

        if (_state!.isGameOver) {
          storage.clearSavedGame();
        } else {
          storage.saveGame(_state!);
        }
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isProcessingAi = false;
        notifyListeners();

        // If next player is also AI, recurse
        if (_state != null && !_state!.isGameOver && _state!.activePlayer.isAi) {
          _triggerAiIfNeeded();
        }
      }
    });
  }
}
