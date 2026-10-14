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
import '../game/declare_got_five_dialog.dart';

class PassAndPlayScreen extends StatefulWidget {
  final GameController controller;

  const PassAndPlayScreen({super.key, required this.controller});

  @override
  State<PassAndPlayScreen> createState() => _PassAndPlayScreenState();
}

class _PassAndPlayScreenState extends State<PassAndPlayScreen> {
  bool _isPrivacyCoverActive = true;
  Tile? _selectedPoolTile;
  bool _isComparingDots = false;
  int? _selectedCompareSlot;
  int? _highlightedGapIndex;
  String? _latestExplanation;

  // Notes per active player
  Set<int> _crossedOut = {};
  final List<Set<int>> _undoHistory = [];
  List<String> _guesses = ['', '', '', '', ''];
  Set<int> _autoFilledSlots = {};
  Set<TileColor> _exhaustedColors = {};
  String? _currentLoadedPlayerId;

  // Newly revealed tile highlight state
  int? _highlightedRevealedNumber;
  int? _lastKnownRevealedTileNumber;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onStateChange);
    final state = widget.controller.state;
    if (state != null) {
      _loadNotesForPlayer(state.gameId, state.activePlayer.id);
      _checkNewRevealedTile(state);
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    widget.controller.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    final state = widget.controller.state;
    if (state != null) {
      _checkNewRevealedTile(state);
      if (state.isGameOver) {
        _showGameOverDialog(state);
      } else if (_currentLoadedPlayerId != state.activePlayer.id) {
        _loadNotesForPlayer(state.gameId, state.activePlayer.id);
      } else {
        _syncAutoGuesses(save: true);
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

  void _loadNotesForPlayer(String gameId, String playerId) {
    _currentLoadedPlayerId = playerId;
    final loaded = widget.controller.storage.loadPlayerNotes(
      gameId: gameId,
      playerId: playerId,
    );
    _crossedOut = Set<int>.from(loaded.crossedOut);
    _guesses = List<String>.from(loaded.guesses);
    _autoFilledSlots = Set<int>.from(loaded.autoFilledSlots);
    _undoHistory.clear();
    _syncAutoGuesses(save: false);
  }

  void _saveNotes() {
    final state = widget.controller.state;
    if (state == null) return;
    widget.controller.storage.savePlayerNotes(
      gameId: state.gameId,
      playerId: state.activePlayer.id,
      crossedOut: _crossedOut,
      guesses: _guesses,
      autoFilledSlots: _autoFilledSlots,
    );
  }

  void _syncAutoGuesses({bool save = true}) {
    final state = widget.controller.state;
    if (state == null) return;
    final activePlayer = state.activePlayer;
    final autoRevealed = GameEngine.getRevealedNumbersForPlayer(
      state,
      state.activePlayerIndex,
    );

    final result = AutoGuessManager.computeAutoGuesses(
      rackColors: activePlayer.rackColors,
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
      final autoRevealed = GameEngine.getRevealedNumbersForPlayer(
        state,
        state.activePlayerIndex,
      );
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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.victory),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, size: 56, color: Colors.amberAccent),
              const SizedBox(height: 12),
              Text(
                '🏆 ${winner.name} won the match!\n${state.winnerReason ?? ""}',
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
    final activePlayer = state.activePlayer;

    final numbers = await showDialog<List<int>>(
      context: context,
      builder: (_) => DeclareGotFiveDialog(
        player: activePlayer,
        initialGuesses: _guesses,
      ),
    );

    if (numbers != null) {
      widget.controller.declareGotFive(numbers);
      if (mounted && widget.controller.state != null && !widget.controller.state!.isGameOver) {
        setState(() => _isPrivacyCoverActive = true);
      }
    }
  }

  void _handlePoolTileTap(Tile tile) {
    final state = widget.controller.state;
    if (state == null || state.isGameOver) return;
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
    final activePlayer = state.activePlayer;

    int targetSlot = 0;
    for (int i = 0; i < activePlayer.rack.length; i++) {
      if (tile.number > activePlayer.rack[i].number) {
        targetSlot = i + 1;
      }
    }

    final clue = SortClue(
      id: 'preview',
      tile: tile,
      targetPlayerIndex: state.activePlayerIndex,
      slotIndex: targetSlot,
    );
    final explanation = ClueExplanationHelper.explainSortClue(
      context: context,
      clue: clue,
      rackColors: activePlayer.rackColors,
    );

    setState(() {
      _highlightedGapIndex = targetSlot;
      _latestExplanation = explanation;
      _selectedPoolTile = null;
      _isComparingDots = false;
      _selectedCompareSlot = null;
    });

    widget.controller.askSortClue(tile);

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _highlightedGapIndex = null;
          _isPrivacyCoverActive = true; // Guard screen after turn ends
        });
      }
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
    final activePlayer = state.activePlayer;

    final isMatch = tile.dots == activePlayer.rack[slot].dots;
    final clue = CompareClue(
      id: 'preview',
      tile: tile,
      targetPlayerIndex: state.activePlayerIndex,
      targetSlotIndex: slot,
      match: isMatch,
    );
    final explanation = ClueExplanationHelper.explainCompareClue(
      context: context,
      clue: clue,
      rackColors: activePlayer.rackColors,
    );

    setState(() {
      _latestExplanation = explanation;
      _selectedPoolTile = null;
      _isComparingDots = false;
      _selectedCompareSlot = null;
    });

    widget.controller.askCompareClue(tile, slot);

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _isPrivacyCoverActive = true; // Guard screen after turn ends
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = widget.controller.state;

    if (state == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tableMode)),
        body: Center(child: Text(l10n.gameOver)),
      );
    }

    final activeIndex = state.activePlayerIndex;
    final activePlayer = state.players[activeIndex];
    final opponents = [
      for (int i = 0; i < state.players.length; i++)
        if (i != activeIndex) state.players[i]
    ];

    // Privacy Guard Screen between player turns
    if (_isPrivacyCoverActive) {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security_rounded, size: 72, color: Colors.amberAccent),
              const SizedBox(height: 24),
              Text(
                l10n.passPhoneTo(activePlayer.name),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.privacyScreenNotice,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                ),
                icon: const Icon(Icons.visibility_rounded),
                label: Text(
                  l10n.revealMyTurn(activePlayer.name),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _loadNotesForPlayer(state.gameId, activePlayer.id);
                  setState(() => _isPrivacyCoverActive = false);
                },
              ),
            ],
          ),
        ),
      );
    }

    // Active Player Turn View
    return Scaffold(
      appBar: AppBar(
        title: Text('${activePlayer.name} • ${l10n.yourTurn}'),
        actions: [
          if (!activePlayer.isEliminated && !activePlayer.hasGuessed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.stars_rounded, size: 16),
                label: Text(
                  l10n.announceNumbers,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
            final mediaQuery = MediaQuery.of(context);
            final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;

            final topWorkspace = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Compact Opponents
                if (opponents.isNotEmpty) ...[
                  CompactOpponentsWidget(
                    opponents: opponents,
                    activePlayerIndex: activeIndex,
                  ),
                  const SizedBox(height: 2.5),
                ],

                // 2. Compact Status & Guidance Banner (unifies revealed tile info + turn instruction)
                _buildCompactStatusBanner(context, l10n, state, activePlayer),

                const SizedBox(height: 2.5),

                // 3. Pool & In-place Actions
                _buildCommonPoolSection(context, l10n, state),

                const SizedBox(height: 2.5),

                // 4. Physical Tabletop Stand Workspace for active player (PINNED)
                PhysicalStandWorkspaceWidget(
                  player: activePlayer,
                  isCurrentPlayer: true,
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

            // If keyboard is open (user typing in guess box), make outer view scrollable to prevent overflow
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
                      autoRevealedNumbers: GameEngine.getRevealedNumbersForPlayer(
                        state,
                        state.activePlayerIndex,
                      ),
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

            // Normal Portrait View: Pinned Stand + Independently Scrolling Notes
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  topWorkspace,
                  const SizedBox(height: 3),
                  Expanded(
                    child: SingleChildScrollView(
                      child: CompactDeductionSheetWidget(
                        manualCrossedOutNumbers: _crossedOut,
                        autoRevealedNumbers: GameEngine.getRevealedNumbersForPlayer(
                          state,
                          state.activePlayerIndex,
                        ),
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
          },
        ),
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

  Widget _buildCompactStatusBanner(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
    Player activePlayer,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String instruction;
    if (state.phase == GamePhase.revealingTile) {
      instruction = l10n.chooseColorToReveal;
    } else if (_selectedPoolTile == null) {
      instruction = _latestExplanation != null ? l10n.clueSavedUpdateNotes : l10n.chooseSharedTile;
    } else if (_isComparingDots) {
      instruction = l10n.tapTileToCompare;
    } else {
      instruction = l10n.chooseClueAction;
    }

    final hasRevealedTile = state.lastRevealedTile != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.5) : const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.indigoAccent.withValues(alpha: 0.4) : Colors.indigo.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.play_arrow_rounded,
                size: 15,
                color: isDark ? Colors.amberAccent : Colors.indigo.shade800,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  instruction,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.amberAccent : Colors.indigo.shade900,
                  ),
                ),
              ),
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

  Widget _buildCommonPoolSection(
    BuildContext context,
    AppLocalizations l10n,
    GameState state,
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
                  style: const TextStyle(fontSize: 10.5, color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          if (state.phase == GamePhase.revealingTile) ...[
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
                    onTap: (state.phase == GamePhase.askingClue)
                        ? () => _handlePoolTileTap(tile)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),

          if (_selectedPoolTile != null) ...[
            const SizedBox(height: 4),
            _buildSelectedTileActionBar(context, l10n, _selectedPoolTile!),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedTileActionBar(
    BuildContext context,
    AppLocalizations l10n,
    Tile tile,
  ) {
    final colorVal = AppColors.colorForTileColor(tile.color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black38,
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
                  style: const TextStyle(fontSize: 10.5, color: Colors.white70),
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
