import 'package:flutter/material.dart';
import '../../../domain/models/game_state.dart';
import '../../../domain/models/tile.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/theme.dart';
import '../../widgets/compact_deduction_sheet.dart';
import '../../widgets/tile_widget.dart';

class DeductionSheetDialog extends StatefulWidget {
  final GameState state;
  final int playerIndex;

  const DeductionSheetDialog({
    super.key,
    required this.state,
    required this.playerIndex,
  });

  @override
  State<DeductionSheetDialog> createState() => _DeductionSheetDialogState();
}

class _DeductionSheetDialogState extends State<DeductionSheetDialog> {
  // Set of crossed out numbers (1..60)
  final Set<int> _crossedOut = {};
  final List<Set<int>> _history = [];

  // Hypothesized 5 numbers
  final List<TextEditingController> _guessControllers =
      List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    _autoCrossInitialPublicTiles();
  }

  /// Automatically crosses out tiles that are publicly visible to everyone
  void _autoCrossInitialPublicTiles() {
    for (int i = 0; i < widget.state.players.length; i++) {
      if (i != widget.playerIndex) {
        for (final tile in widget.state.players[i].rack) {
          if (!tile.isHidden) {
            _crossedOut.add(tile.number);
          }
        }
      }
    }
    for (final tile in widget.state.pool) {
      if (!tile.isHidden) {
        _crossedOut.add(tile.number);
      }
    }
  }

  void _toggleTile(int number) {
    setState(() {
      _history.add(Set<int>.from(_crossedOut));
      if (_crossedOut.contains(number)) {
        _crossedOut.remove(number);
      } else {
        _crossedOut.add(number);
      }
    });
  }

  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _crossedOut.clear();
        _crossedOut.addAll(_history.removeLast());
      });
    }
  }

  void _clearAll() {
    setState(() {
      _history.add(Set<int>.from(_crossedOut));
      _crossedOut.clear();
      for (final c in _guessControllers) {
        c.clear();
      }
    });
  }

  @override
  void dispose() {
    for (final c in _guessControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final player = widget.state.players[widget.playerIndex];

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.deductionSheet),
          actions: [
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              tooltip: l10n.undo,
              onPressed: _history.isNotEmpty ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: l10n.clearAll,
              onPressed: _clearAll,
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Top Section: 5 Candidate Boxes (Ascending Order)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.candidateNumbers,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '(${_crossedOut.length}/60 ${l10n.crossOut})',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        final color = player.rackColors[index];
                        final tileColor = AppColors.colorForTileColor(color);

                        return SizedBox(
                          width: 58,
                          child: TextField(
                            controller: _guessControllers[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 2,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              filled: true,
                              fillColor: tileColor.withValues(alpha: 0.3),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: tileColor, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.amberAccent, width: 2.5),
                              ),
                              hintText: '#${index + 1}',
                              hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // 60-Tile Deduction Grid (5 horizontal rows, 12 numbers each, visible simultaneously)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: CompactDeductionSheetWidget(
                  manualCrossedOutNumbers: _crossedOut,
                  onToggleNumber: _toggleTile,
                  onUndo: _undo,
                  onClear: _clearAll,
                  canUndo: _history.isNotEmpty,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
