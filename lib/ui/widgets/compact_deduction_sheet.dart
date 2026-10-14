import 'package:flutter/material.dart';
import '../../domain/models/tile.dart';
import '../../l10n/app_localizations.dart';
import '../core/theme.dart';

class CompactDeductionSheetWidget extends StatelessWidget {
  /// Backward-compatible manual notes set if [manualCrossedOutNumbers] is omitted
  final Set<int>? crossedOutNumbers;
  final Set<int> manualCrossedOutNumbers;
  final Set<int> autoRevealedNumbers;
  final int? highlightedNumber;
  final ValueChanged<int> onToggleNumber;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;
  final bool canUndo;

  const CompactDeductionSheetWidget({
    super.key,
    this.crossedOutNumbers,
    this.manualCrossedOutNumbers = const {},
    this.autoRevealedNumbers = const {},
    this.highlightedNumber,
    required this.onToggleNumber,
    this.onUndo,
    this.onClear,
    this.canUndo = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final manual = crossedOutNumbers ?? manualCrossedOutNumbers;
    final totalCrossed = {...manual, ...autoRevealedNumbers};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E222B) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar with Title, Counts, Undo, Clear
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 14, color: Colors.amberAccent),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.deductionSheet,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${totalCrossed.length}/60',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (onUndo != null)
                IconButton(
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  tooltip: l10n.undo,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: canUndo ? onUndo : null,
                ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                  tooltip: l10n.clearAll,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  onPressed: manual.isNotEmpty ? onClear : null,
                ),
            ],
          ),
          const SizedBox(height: 3),

          // 5 Rows (1 per color), each containing all 12 numbers simultaneously.
          // Zero horizontal scrolling. Full screen width calculation.
          // Left column has pinned fixed color label/symbol.
          // Wrapped in Directionality(ltr) to guarantee Left-to-Right ascending order
          // in both Arabic and English locales.
          LayoutBuilder(
            builder: (context, constraints) {
              final double totalWidth =
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 360.0;
              final bool isVeryNarrow = totalWidth < 340.0;
              final double labelWidth = isVeryNarrow ? 18.0 : 22.0;
              final double labelGap = isVeryNarrow ? 2.0 : 3.0;
              final double colSpacing = isVeryNarrow ? 1.0 : 1.5;
              const double rowSpacing = 2.0;

              final double availableForGrid = totalWidth - labelWidth - labelGap;
              final double cellWidth =
                  (availableForGrid - (11 * colSpacing)) / 12.0;
              final textScale = MediaQuery.maybeOf(context)?.textScaler.scale(1.0) ?? 1.0;
              final double cellHeight = (cellWidth * 1.25 * textScale.clamp(1.0, 1.25)).clamp(28.0, 38.0);

              return Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fixed Left Column: Color label & symbol at the start of each row
                    SizedBox(
                      width: labelWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: TileColor.values.map((color) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: rowSpacing),
                            child: _ColorRowHeader(
                              color: color,
                              width: labelWidth,
                              height: cellHeight,
                              isVeryNarrow: isVeryNarrow,
                              isDark: isDark,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(width: labelGap),

                    // Non-scrolling 12-cell rows: All 12 numbers visible simultaneously in each row
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: TileColor.values.map((color) {
                          final tiles = Tile.tilesForColor(color);
                          final colorVal = AppColors.colorForTileColor(color);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: rowSpacing),
                            child: SizedBox(
                              height: cellHeight,
                              child: Row(
                                children: [
                                  for (int i = 0; i < tiles.length; i++) ...[
                                    if (i > 0) SizedBox(width: colSpacing),
                                    Expanded(
                                      child: _CompactCell(
                                        tile: tiles[i],
                                        colorVal: colorVal,
                                        isCrossed: autoRevealedNumbers
                                                .contains(tiles[i].number) ||
                                            manual.contains(tiles[i].number),
                                        isAutoRevealed: autoRevealedNumbers
                                            .contains(tiles[i].number),
                                        isHighlighted: highlightedNumber ==
                                            tiles[i].number,
                                        isVeryNarrow: isVeryNarrow,
                                        onTap: autoRevealedNumbers
                                                .contains(tiles[i].number)
                                            ? null
                                            : () => onToggleNumber(
                                                tiles[i].number),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ColorRowHeader extends StatelessWidget {
  final TileColor color;
  final double width;
  final double height;
  final bool isVeryNarrow;
  final bool isDark;

  const _ColorRowHeader({
    required this.color,
    required this.width,
    required this.height,
    required this.isVeryNarrow,
    required this.isDark,
  });

  String _getColorName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'ar') return color.arabicName;
    if (locale == 'fr') return color.frenchName;
    return color.englishName;
  }

  @override
  Widget build(BuildContext context) {
    final colorVal = AppColors.colorForTileColor(color);
    final symbol = Tile.symbolForColor(color).symbolUnicode;

    return Tooltip(
      message: _getColorName(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorVal.withValues(alpha: isDark ? 0.30 : 0.22),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: colorVal.withValues(alpha: 0.9),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            symbol,
            style: TextStyle(
              fontSize: isVeryNarrow ? 9.5 : 11.5,
              fontWeight: FontWeight.bold,
              color: colorVal,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactCell extends StatelessWidget {
  final Tile tile;
  final Color colorVal;
  final bool isCrossed;
  final bool isAutoRevealed;
  final bool isHighlighted;
  final bool isVeryNarrow;
  final VoidCallback? onTap;

  const _CompactCell({
    super.key,
    required this.tile,
    required this.colorVal,
    required this.isCrossed,
    this.isAutoRevealed = false,
    this.isHighlighted = false,
    this.isVeryNarrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3.5),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isCrossed
              ? colorVal.withValues(alpha: isDark ? 0.16 : 0.12)
              : colorVal.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(3.5),
          border: Border.all(
            color: isHighlighted
                ? Colors.amberAccent
                : (isCrossed
                    ? (isDark ? Colors.white12 : Colors.black12)
                    : colorVal),
            width: isHighlighted ? 2.0 : 0.8,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.8),
                    blurRadius: 5,
                    spreadRadius: 1.0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 1.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Clear, bold number without repeated symbols
                    Text(
                      '${tile.number}',
                      style: TextStyle(
                        fontSize: isVeryNarrow ? 10.5 : 11.5,
                        fontWeight: FontWeight.w800,
                        color: isHighlighted
                            ? Colors.amberAccent
                            : (isCrossed
                                ? (isDark ? Colors.white70 : Colors.black87)
                                : Colors.white),
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    // Compact dots row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(tile.dots, (i) {
                        return Container(
                          width: 2.0,
                          height: 2.0,
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: isCrossed
                                ? (isDark ? Colors.white38 : Colors.black38)
                                : Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            // Diagonal crossing-out mark (clear without obscuring number)
            if (isCrossed)
              CustomPaint(
                size: Size.infinite,
                painter: _CrossPainter(isAutoRevealed: isAutoRevealed),
              ),
          ],
        ),
      ),
    );
  }
}

class _CrossPainter extends CustomPainter {
  final bool isAutoRevealed;

  const _CrossPainter({this.isAutoRevealed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isAutoRevealed
          ? Colors.redAccent.withValues(alpha: 0.90)
          : Colors.redAccent.withValues(alpha: 0.80)
      ..strokeWidth = isAutoRevealed ? 1.7 : 1.4
      ..strokeCap = StrokeCap.round;

    // Diagonal X slash with 15% margin to preserve clear number legibility
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.85, size.height * 0.15),
      Offset(size.width * 0.15, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) =>
      oldDelegate.isAutoRevealed != isAutoRevealed;
}
