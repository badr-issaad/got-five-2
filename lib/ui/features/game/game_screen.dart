import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/engine/auto_guess_manager.dart';
import '../../../domain/engine/game_engine.dart';
import '../../../domain/models/clue.dart';
import '../../../domain/models/game_state.dart';
import '../../../domain/models/player.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../controllers/game_controller.dart';
import '../../core/theme.dart';
import '../../widgets/clue_explanation_helper.dart';
import '../../widgets/compact_deduction_sheet.dart';
import '../../widgets/compact_opponents_widget.dart';
import '../../widgets/physical_stand_workspace_widget.dart';
import '../../widgets/tile_widget.dart';
import 'declare_got_five_dialog.dart';

class GameScreen extends StatefulWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Tile selection state for in-place actions
  Tile? _selectedPoolTile;
  bool _isComparingDots = false;
  int? _selectedCompareSlot;
  int? _highlightedGapIndex;
  String? _latestExplanation;

  // Persistent notes & guesses state
  Set<int> _crossedOut = {};
  final List<Set<int>> _undoHistory = [];
  List<String> _guesses = ['', '', '', '', ''];
  Set<int> _autoFilledSlots = {};
  Set<TileColor> _exhaustedColors = {};
  String? _lastInitializedGameId;

  // Newly revealed tile highlight state
  int? _highlightedRevealedNumber;
  int? _lastKnownRevealedTileNumber;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    final state = widget.controller.state;
    if (state != null) {
      _initOrRestoreNotes(state);
      _checkNewRevealedTile(state);
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    final state = widget.controller.state;
    if (state != null) {
      _initOrRestoreNotes(state);
      _checkNewRevealedTile(state);
      _syncAutoGuesses(save: true);
      if (state.isGameOver) {
        _showGameOverDialog(state);
      }
    }
    setState(() {});
  }

  void _checkNewRevealedTile(GameState state) {
    if (state.lastRevealedTile != null &&
        state.lastRevealedTile!.number != _lastKnownRevealedTileNumber) {
      _lastKnownRevealedTileNumber = state.lastRevealedTile!.number;
      _highlightedRevealedNumber = state.lastRevealedTile!.number;
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(milliseconds: 3500), () {
        if (mounted) {
          setState(() {
            _highlightedRevealedNumber = null;
          });
        }
      });
    }
  }

  void _initOrRestoreNotes(GameState state) {
    if (_lastInitializedGameId != state.gameId) {
      _lastInitializedGameId = state.gameId;
      final human = state.players[0];
      final loaded = widget.controller.storage.loadPlayerNotes(
        gameId: state.gameId,
        playerId: human.id,
      );
      _crossedOut = Set<int>.from(loaded.crossedOut);
      _guesses = List<String>.from(loaded.guesses);
      _autoFilledSlots = Set<int>.from(loaded.autoFilledSlots);
      _undoHistory.clear();
      _syncAutoGuesses(save: false);
    }
  }

  void _saveNotes() {
    final state = widget.controller.state;
    if (state == null) return;
    widget.controller.storage.savePlayerNotes(
      gameId: state.gameId,
      playerId: state.players[0].id,
      crossedOut: _crossedOut,
      guesses: _guesses,
      autoFilledSlots: _autoFilledSlots,
    );
  }

  void _syncAutoGuesses({bool save = true}) {
    final state = widget.controller.state;
    if (state == null) return;
    final human = state.players[0];
    final autoRevealed = GameEngine.getRevealedNumbersForPlayer(state, 0);

    final result = AutoGuessManager.computeAutoGuesses(
      rackColors: human.rackColors,
      manualCrossedOutNumbers: _crossedOut,
      autoRevealedNumbers: autoRevealed,
      currentGuesses: _guesses,
      currentAutoFilledSlots: _autoFilledSlots,
    );

    _guesses = result.guesses;
    _autoFilledSlots = result.autoFilledSlots;
    _exhaustedColors = result.exhaustedColors;

    if (save) {
      _saveNotes();
    }
  }

  void _toggleCrossedOut(int number) {
    final state = widget.controller.state;
    if (state != null) {
      final autoRevealed = GameEngine.getRevealedNumbersForPlayer(state, 0);
      if (autoRevealed.contains(number)) {
        return; // Auto-revealed numbers cannot be toggled
      }
    }
    setState(() {
      _undoHistory.add(Set<int>.from(_crossedOut));
      if (_crossedOut.contains(number)) {
        _crossedOut.remove(number);
      } else {
        _crossedOut.add(number);
      }
      _syncAutoGuesses(save: false);
    });
    _saveNotes();
  }

  void _undoCrossOut() {
    if (_undoHistory.isNotEmpty) {
      setState(() {
        _crossedOut = _undoHistory.removeLast();
        _syncAutoGuesses(save: false);
      });
      _saveNotes();
    }
  }

  void _clearNotes() {
    if (_crossedOut.isNotEmpty) {
      setState(() {
        _undoHistory.add(Set<int>.from(_crossedOut));
        _crossedOut.clear();
        _syncAutoGuesses(save: false);
      });
      _saveNotes();
    }
  }

  void _onGuessChanged(int slotIndex, String value) {
    if (slotIndex >= 0 && slotIndex < _guesses.length) {
      setState(() {
        _guesses[slotIndex] = value.trim();
        _autoFilledSlots.remove(slotIndex);
      });
      _saveNotes();
    }
  }

  void _showGameOverDialog(GameState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final winner = state.players[state.winnerIndex!];
      final isHumanWinner = !winner.isAi;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(isHumanWinner ? l10n.victory : l10n.gameOver),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isHumanWinner ? Icons.emoji_events_rounded : Icons.info_outline_rounded,
                size: 56,
                color: isHumanWinner ? Colors.amberAccent : Colors.white70,
              ),
              const SizedBox(height: 12),
              Text(
                state.winnerReason ?? l10n.congratulations,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                widget.controller.abandonCurrentGame();
                Navigator.of(context).pop();
              },
              child: Text(l10n.backToHome),
            ),
          ],
        ),
      );
    });
  }

  void _openDeclareGotFive() async {
    final state = widget.controller.state;
    if (state == null) return;
    final human = state.players[0];
    if (human.isEliminated || human.hasGuessed) return;

    final numbers = await showDialog<List<int>>(
      context: context,
      builder: (_) => DeclareGotFiveDialog(
        player: human,
        initialGuesses: _guesses,
      ),
    );

    if (numbers != null) {
      widget.controller.declareGotFive(numbers);
    }
  }

  void _handlePoolTileTap(Tile tile) {
    final state = widget.controller.state;
    if (state == null || state.isGameOver || widget.controller.isProcessingAi) return;
    if (state.activePlayerIndex != 0) return;
    if (state.phase != GamePhase.askingClue) return;

    setState(() {
      if (_selectedPoolTile == tile) {
        _selectedPoolTile = null;
        _isComparingDots = false;
        _selectedCompareSlot = null;
      } else {
        _selectedPoolTile = tile;
        _isComparingDots = false;
        _selectedCompareSlot = null;
      }
    });
  }

  void _cancelAction() {
    setState(() {
      _selectedPoolTile = null;
      _isComparingDots = false;
      _selectedCompareSlot = null;
    });
  }

  void _askSortClue() {
    final tile = _selectedPoolTile;
    final state = widget.controller.state;
    if (tile == null || state == null) return;
    final human = state.players[0];

    // Compute target slot for animation and explanation
    int targetSlot = 0;
    for (int i = 0; i < human.rack.length; i++) {
      if (tile.number > human.rack[i].number) {
        targetSlot = i + 1;
      }
    }

    final clue = SortClue(
      id: 'preview',
      tile: tile,
      targetPlayerIndex: 0,
      slotIndex: targetSlot,
    );
    final explanation = ClueExplanationHelper.explainSortClue(
      context: context,
      clue: clue,
      rackColors: human.rackColors,
    );

    setState(() {
      _highlightedGapIndex = targetSlot;
      _latestExplanation = explanation;
      _selectedPoolTile = null;
      _isComparingDots = false;
      _selectedCompareSlot = null;
    });

    widget.controller.askSortClue(tile);

    // Keep highlight briefly, then reset
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _highlightedGapIndex = null);
    });
  }

  void _startCompareMode() {
    setState(() {
      _isComparingDots = true;
      _selectedCompareSlot = null;
    });
  }

  void _onRackSlotTapped(int slotIndex) {
    if (_isComparingDots) {
      setState(() {
        _selectedCompareSlot = slotIndex;
      });
    }
  }

  void _confirmCompareClue() {
    final tile = _selectedPoolTile;
    final slot = _selectedCompareSlot;
    final state = widget.controller.state;
    if (tile == null || slot == null || state == null) return;
    final human = state.players[0];

    final isMatch = tile.dots == human.rack[slot].dots;
    final clue = CompareClue(
      id: 'preview',
      tile: tile,
      targetPlayerIndex: 0,
      targetSlotIndex: slot,
      match: isMatch,
    );
    final explanation = ClueExplanationHelper.explainCompareClue(
      context: context,
      clue: clue,
      rackColors: human.rackColors,
    );

    setState(() {
      _latestExplanation = explanation;
      _selectedPoolTile = null;
      _isComparingDots = false;
      _selectedCompareSlot = null;
    });

    widget.controller.askCompareClue(tile, slot);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.controller.state;

    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: Center(child: Text(l10n.gameOver)),
      );
    }

    final activePlayer = state.activePlayer;
    final isHumanTurn = state.activePlayerIndex == 0;
    final humanPlayer = state.players[0];
    final opponents = state.players.sublist(1);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('${l10n.appTitle} • R${state.turnNumber}'),
        ),
        actions: [
          if (!humanPlayer.isEliminated && !humanPlayer.hasGuessed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.stars_rounded, size: 15),
                label: Text(
                  l10n.announceNumbers,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
                onPressed: _openDeclareGotFive,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.abandonGame,
            onPressed: () {
              widget.controller.abandonCurrentGame();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth >= 720;

            if (isLandscape) {
              return _buildLandscapeLayout(
                context,
                l10n,
                state,
                isHumanTurn,
                activePlayer,
                humanPlayer,
                opponents,
              );
            } else {
              return _buildPortraitLayout(
                context,
                l10n,
                state,
                isHumanTurn,
                activePlayer,
                humanPlayer,
                opponents,
              );
            }
          },
        ),
      ),
    );
  }

  /// Responsive Portrait View:
  /// Hidden rack and guess boxes remain pinned & visible while the deduction sheet scrolls independently!
  Widget _buildPortraitLayout(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
    bool isHumanTurn,
    Player activePlayer,
    Player humanPlayer,
    List<Player> opponents,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

    // Fixed upper tabletop workspace
    final topWorkspace = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Compact Opponents Area
        if (opponents.isNotEmpty) ...[
          CompactOpponentsWidget(
            opponents: opponents,
            activePlayerIndex: state.activePlayerIndex,
          ),
          const SizedBox(height: 2.5),
        ],

        // 2. Compact Status & Guidance Banner (unifies revealed tile info + turn instruction)
        _buildCompactStatusBanner(context, l10n, state, isHumanTurn, activePlayer),

        const SizedBox(height: 2.5),

        // 3. Shared Common Pool (with in-place actions)
        _buildCommonPoolSection(context, l10n, state, isHumanTurn),

        const SizedBox(height: 2.5),

        // 4. Physical Tabletop Stand Workspace (Attached clues + 5 tiles + 5 guess boxes)
        // PINNED AND ALWAYS VISIBLE
        PhysicalStandWorkspaceWidget(
          player: humanPlayer,
          isCurrentPlayer: isHumanTurn,
          isOwnerView: true,
          selectedSlotIndex: _selectedCompareSlot,
          onSlotSelected: _onRackSlotTapped,
          highlightedGapIndex: _highlightedGapIndex,
          guesses: _guesses,
          autoFilledSlots: _autoFilledSlots,
          exhaustedColors: _exhaustedColors,
          onGuessChanged: _onGuessChanged,
        ),
      ],
    );

    final screenWidth = MediaQuery.of(context).size.width;
    final hPadding = screenWidth < 340 ? 4.0 : (screenWidth < 380 ? 6.0 : 8.0);

    // If keyboard is open (user is typing guess in input box), wrap everything in SingleChildScrollView so keyboard won't overflow
    if (isKeyboardOpen) {
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            topWorkspace,
            const SizedBox(height: 3),
            CompactDeductionSheetWidget(
              manualCrossedOutNumbers: _crossedOut,
              autoRevealedNumbers: GameEngine.getRevealedNumbersForPlayer(state, 0),
              highlightedNumber: _highlightedRevealedNumber,
              onToggleNumber: _toggleCrossedOut,
              onUndo: _undoCrossOut,
              onClear: _clearNotes,
              canUndo: _undoHistory.isNotEmpty,
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    // Normal Portrait View:
    // Pinned rack + guess boxes at top, independently scrolling deduction sheet below!
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          topWorkspace,
          const SizedBox(height: 3),
          // 5. Independently Scrolling Deduction Sheet
          Expanded(
            child: SingleChildScrollView(
              child: CompactDeductionSheetWidget(
                manualCrossedOutNumbers: _crossedOut,
                autoRevealedNumbers: GameEngine.getRevealedNumbersForPlayer(state, 0),
                highlightedNumber: _highlightedRevealedNumber,
                onToggleNumber: _toggleCrossedOut,
                onUndo: _undoCrossOut,
                onClear: _clearNotes,
                canUndo: _undoHistory.isNotEmpty,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Responsive Landscape View: Two-pane Tabletop Workspace!
  Widget _buildLandscapeLayout(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
    bool isHumanTurn,
    Player activePlayer,
    Player humanPlayer,
    List<Player> opponents,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Pane (Flex 6): Opponents + Guidance + Pool + Stand
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (opponents.isNotEmpty) ...[
                    CompactOpponentsWidget(
                      opponents: opponents,
                      activePlayerIndex: state.activePlayerIndex,
                    ),
                    const SizedBox(height: 4),
                  ],
                  _buildCompactStatusBanner(context, l10n, state, isHumanTurn, activePlayer),
                  const SizedBox(height: 4),
                  _buildCommonPoolSection(context, l10n, state, isHumanTurn),
                  const SizedBox(height: 4),
                  PhysicalStandWorkspaceWidget(
                    player: humanPlayer,
                    isCurrentPlayer: isHumanTurn,
                    isOwnerView: true,
                    selectedSlotIndex: _selectedCompareSlot,
                    onSlotSelected: _onRackSlotTapped,
                    highlightedGapIndex: _highlightedGapIndex,
                    guesses: _guesses,
                    autoFilledSlots: _autoFilledSlots,
                    exhaustedColors: _exhaustedColors,
                    onGuessChanged: _onGuessChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Right Pane (Flex 5): Embedded Deduction Sheet
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: CompactDeductionSheetWidget(
                manualCrossedOutNumbers: _crossedOut,
                autoRevealedNumbers: GameEngine.getRevealedNumbersForPlayer(state, 0),
                highlightedNumber: _highlightedRevealedNumber,
                onToggleNumber: _toggleCrossedOut,
                onUndo: _undoCrossOut,
                onClear: _clearNotes,
                canUndo: _undoHistory.isNotEmpty,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRevealedMessage(BuildContext context, GameState state) {
    final l10n = AppLocalizations.of(context)!;
    final tile = state.lastRevealedTile;
    if (tile == null) return state.lastRevealedMessage ?? '';

    final isAi = state.lastRevealedPlayerIsAi ?? (state.activePlayer.isAi);
    final playerName = isAi
        ? l10n.computer
        : (state.lastRevealedPlayerName ?? state.activePlayer.name);
    return l10n.playerRevealedTile(playerName, tile.number);
  }

  /// Compact Status & Guidance Banner (combines turn guidance & revealed tile info)
  Widget _buildCompactStatusBanner(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
    bool isHumanTurn,
    Player activePlayer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String instruction;
    if (widget.controller.isProcessingAi) {
      instruction = l10n.waitingFor(activePlayer.name);
    } else if (!isHumanTurn) {
      instruction = l10n.waitingFor(activePlayer.name);
    } else {
      if (state.phase == GamePhase.revealingTile) {
        instruction = l10n.chooseColorToReveal;
      } else if (_selectedPoolTile == null) {
        instruction = _latestExplanation != null ? l10n.clueSavedUpdateNotes : l10n.chooseSharedTile;
      } else if (_isComparingDots) {
        instruction = l10n.tapTileToCompare;
      } else {
        instruction = l10n.chooseClueAction;
      }
    }

    final hasRevealedTile = state.lastRevealedTile != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isHumanTurn
            ? (isDark ? Colors.indigo.shade900.withValues(alpha: 0.5) : const Color(0xFFE0E7FF))
            : (isDark ? Colors.black26 : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHumanTurn
              ? (isDark ? Colors.indigoAccent.withValues(alpha: 0.4) : Colors.indigo.shade300)
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (widget.controller.isProcessingAi)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent),
                )
              else
                Icon(
                  isHumanTurn ? Icons.play_arrow_rounded : Icons.hourglass_empty_rounded,
                  size: 15,
                  color: isHumanTurn
                      ? (isDark ? Colors.amberAccent : Colors.indigo.shade800)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isHumanTurn
                        ? (isDark ? Colors.amberAccent : Colors.indigo.shade900)
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
              // Compact inline revealed badge if a tile was revealed
              if (hasRevealedTile) ...[
                const SizedBox(width: 6),
                _buildCompactRevealedChip(context, state),
              ],
            ],
          ),
          if (_latestExplanation != null) ...[
            const SizedBox(height: 2.5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: isDark ? 0.12 : 0.16),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Text(
                '💡 $_latestExplanation',
                style: TextStyle(
                  fontSize: 10.5,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactRevealedChip(BuildContext context, GameState state) {
    final tile = state.lastRevealedTile!;
    final colorVal = AppColors.colorForTileColor(tile.color);
    final msg = _formatRevealedMessage(context, state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorVal.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorVal.withValues(alpha: 0.7), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#${tile.number} ${Tile.symbolForColor(tile.color).symbolUnicode}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: colorVal,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            msg,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Section 3: Common Pool Tiles & Direct In-Place Action Bar
  Widget _buildCommonPoolSection(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
    bool isHumanTurn,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Pool Count + Reserve Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${l10n.poolTiles} (${state.pool.length})',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.inReserveCount(state.totalReserveCount),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // If revealing phase: Color picker buttons
          if (isHumanTurn && state.phase == GamePhase.revealingTile) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TileColor.values.map((color) {
                  final count = state.reserveByColor[color]?.length ?? 0;
                  final colorVal = AppColors.colorForTileColor(color);
                  final isDepleted = count == 0;

                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorVal.withValues(alpha: isDepleted ? 0.25 : 0.85),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: isDepleted ? null : () => widget.controller.revealTile(color),
                      icon: Text(
                        Tile.symbolForColor(color).symbolUnicode,
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      label: Text(
                        '${color.localizedName(context)} ($count)',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 3),
          ],

          // Face-up pool tiles
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: state.pool.map((tile) {
                final isSelected = _selectedPoolTile == tile;
                return Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: TileWidget(
                    tile: tile,
                    width: 36,
                    height: 48,
                    isSelected: isSelected || tile.number == _highlightedRevealedNumber,
                    onTap: (isHumanTurn && state.phase == GamePhase.askingClue)
                        ? () => _handlePoolTileTap(tile)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          // Direct In-Place Action Bar when a pool tile is selected
          if (_selectedPoolTile != null) ...[
            const SizedBox(height: 4),
            _buildSelectedTileActionBar(context, l10n, _selectedPoolTile!),
          ],
        ],
      ),
    );
  }

  /// In-place Action Bar: Show Position / Compare Dots / Confirm / Cancel
  Widget _buildSelectedTileActionBar(
    BuildContext context,
    AppLocalizations l10n,
    Tile tile,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorVal = AppColors.colorForTileColor(tile.color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.black38 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorVal.withValues(alpha: 0.6), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: colorVal.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '#${tile.number} ${Tile.symbolForColor(tile.color).symbolUnicode}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _isComparingDots
                      ? (_selectedCompareSlot != null
                          ? l10n.comparedWithSlot(_selectedCompareSlot! + 1)
                          : l10n.tapTileToCompare)
                      : l10n.chooseClueAction,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 15),
                tooltip: l10n.cancel,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                onPressed: _cancelAction,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (!_isComparingDots) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 28),
                    ),
                    icon: const Icon(Icons.low_priority_rounded, size: 14),
                    label: Text(l10n.showPosition, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _askSortClue,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 28),
                    ),
                    icon: const Icon(Icons.compare_arrows_rounded, size: 14),
                    label: Text(l10n.compareDots, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: _startCompareMode,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCompareSlot != null ? Colors.amber.shade700 : Colors.white12,
                      foregroundColor: _selectedCompareSlot != null ? Colors.black : Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      minimumSize: const Size(0, 28),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 14),
                    label: Text(
                      l10n.confirmCompare,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _selectedCompareSlot != null ? _confirmCompareClue : null,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
