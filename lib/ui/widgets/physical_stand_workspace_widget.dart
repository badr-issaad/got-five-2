import 'package:flutter/material.dart';
import '../../domain/models/clue.dart';
import '../../domain/models/player.dart';
import '../../domain/models/tile.dart';
import '../../l10n/app_localizations.dart';
import '../core/theme.dart';
import 'clue_explanation_helper.dart';
import 'tile_widget.dart';

class PhysicalStandWorkspaceWidget extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isOwnerView;
  final int? selectedSlotIndex;
  final ValueChanged<int>? onSlotSelected;
  final int? highlightedGapIndex;
  final List<String> guesses;
  final Set<int> autoFilledSlots;
  final Set<TileColor> exhaustedColors;
  final void Function(int slotIndex, String value)? onGuessChanged;
  final ValueChanged<GameClue>? onClueTapped;

  const PhysicalStandWorkspaceWidget({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isOwnerView = true,
    this.selectedSlotIndex,
    this.onSlotSelected,
    this.highlightedGapIndex,
    this.guesses = const ['', '', '', '', ''],
    this.autoFilledSlots = const {},
    this.exhaustedColors = const {},
    this.onGuessChanged,
    this.onClueTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter clues for player
    final sortClues = player.cluesReceived.whereType<SortClue>().toList();
    final compareClues = player.cluesReceived.whereType<CompareClue>().toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? (isDark ? const Color(0xFF1B2333) : const Color(0xFFE8EEF8))
            : (isDark ? const Color(0xFF15181F) : const Color(0xFFF0F2F5)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer ? Colors.indigoAccent : (isDark ? Colors.white12 : Colors.black12),
          width: isCurrentPlayer ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Bar: Player Name, Rack Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      player.isAi ? Icons.smart_toy_rounded : Icons.person_rounded,
                      size: 15,
                      color: isCurrentPlayer
                          ? (isDark ? Colors.amberAccent : Colors.indigo.shade800)
                          : (isDark ? Colors.white70 : Colors.black54),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        player.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: isCurrentPlayer
                              ? (isDark ? Colors.amberAccent : Colors.indigo.shade900)
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_right_alt_rounded, size: 14, color: isDark ? Colors.white54 : Colors.black38),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        l10n.yourRack,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Physical Tabletop Stand View
          // CRITICAL: Always LTR to preserve ascending tile order (< to >) in both LTR & Arabic RTL
          Directionality(
            textDirection: TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double totalWidth = constraints.maxWidth;
                // Calculate tileWidth and gapWidth ensuring 5 * tileWidth + 6 * gapWidth <= totalWidth strictly
                double computedTileWidth = ((totalWidth - 45) / 5).clamp(28.0, 38.0);
                double computedGapWidth = (totalWidth - 5 * computedTileWidth) / 6;
                if (computedGapWidth < 4.0) {
                  computedGapWidth = 4.0;
                  computedTileWidth = ((totalWidth - 6 * computedGapWidth) / 5).clamp(24.0, 38.0);
                }
                if (5 * computedTileWidth + 6 * computedGapWidth > totalWidth) {
                  final factor = totalWidth / (5 * computedTileWidth + 6 * computedGapWidth);
                  computedTileWidth *= factor;
                  computedGapWidth *= factor;
                }
                final double tileWidth = computedTileWidth;
                final double gapWidth = computedGapWidth;
                final double tileHeight = tileWidth * 1.25;

                return Column(
                  children: [
                    // ROW 1: Attached Dot Comparison Clues (HIDDEN until there are comparison clues)
                    if (compareClues.isNotEmpty) ...[
                      _buildComparisonCluesRow(
                        context,
                        tileWidth,
                        gapWidth,
                        compareClues,
                      ),
                      const SizedBox(height: 2),
                    ],

                    // ROW 2: Separate Order Clues Band (aligned to actual rack destinations with connectors)
                    _buildOrderCluesBand(
                      context,
                      totalWidth,
                      sortClues,
                      gapWidth,
                      tileWidth,
                    ),

                    const SizedBox(height: 2),

                    // ROW 3: Tabletop Shelf with 5 Hidden Tiles and 6 Gap Position Notches
                    _buildPhysicalShelf(
                      context,
                      tileWidth,
                      tileHeight,
                      gapWidth,
                    ),

                    const SizedBox(height: 3),

                    // ROW 4: Aligned Guess Boxes ("My guesses")
                    if (isOwnerView && onGuessChanged != null)
                      _buildGuessBoxesRow(
                        context,
                        tileWidth,
                        gapWidth,
                        l10n,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds Row 1: Comparison badges aligned directly over each of the 5 hidden tile slots
  Widget _buildComparisonCluesRow(
    BuildContext context,
    double tileWidth,
    double gapWidth,
    List<CompareClue> compareClues,
  ) {
    return SizedBox(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: gapWidth), // Leading offset matching Gap 0
          for (int slot = 0; slot < 5; slot++) ...[
            SizedBox(
              width: tileWidth,
              child: _buildSlotComparisonBadges(context, slot, compareClues),
            ),
            if (slot < 4) SizedBox(width: gapWidth),
          ],
          SizedBox(width: gapWidth), // Trailing offset matching Gap 5
        ],
      ),
    );
  }

  Widget _buildSlotComparisonBadges(
    BuildContext context,
    int slot,
    List<CompareClue> allCompareClues,
  ) {
    final cluesForSlot = allCompareClues.where((c) => c.targetSlotIndex == slot).toList();
    if (cluesForSlot.isEmpty) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black12,
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    final latestClue = cluesForSlot.last;
    final colorVal = AppColors.colorForTileColor(latestClue.tile.color);

    return InkWell(
      onTap: () {
        _showComparisonCluesGroupDialog(context, slot, cluesForSlot);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: latestClue.match
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: latestClue.match ? Colors.greenAccent : Colors.redAccent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#${latestClue.tile.number}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: colorVal,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    latestClue.match ? '=' : '≠',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: latestClue.match ? Colors.greenAccent : Colors.redAccent,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(latestClue.tile.dots, (d) => Container(
                    width: 2,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 0.4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
                if (cluesForSlot.length > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '+${cluesForSlot.length - 1}',
                    style: const TextStyle(fontSize: 8, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds Row 2: Separate Order Clues Band
  /// Connects each clue chip accurately to its rack gap destination (before 1st, between tiles, after last)
  /// Maintains a consistent minimum height from the start of the game, keeping positions 1–6 clearly visible.
  Widget _buildOrderCluesBand(
    BuildContext context,
    double totalWidth,
    List<SortClue> sortClues,
    double gapWidth,
    double tileWidth,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textScale = MediaQuery.maybeTextScalerOf(context)?.scale(1.0) ?? 1.0;

    // Fixed consistent height from the start of the game:
    // Sufficient to display all six position numbers and their full arrows clearly
    // Never collapses when empty, eliminating layout shifts when clues are added.
    final double bandHeight = (54.0 * textScale.clamp(1.0, 1.25)).roundToDouble();

    const double badgeSize = 16.0;
    const double topMargin = 2.0;
    const double chipTop = topMargin + badgeSize + 2.0; // 20.0
    final double arrowTipY = bandHeight - 2.0;
    const double arrowHeadHeight = 5.5;
    final double arrowBaseY = arrowTipY - arrowHeadHeight; // ~46.5
    final double chipHeight = (arrowBaseY - chipTop).clamp(24.0, 32.0); // ~26.5
    final double chipBottom = chipTop + chipHeight;
    final double chipWidth = (32.0 * (textScale > 1.2 ? 1.15 : 1.0)).clamp(30.0, 38.0);

    // Calculate layout positions & connector data
    final connectors = <_BayConnectorData>[];
    final bayWidgets = <Widget>[];

    for (int gapIndex = 0; gapIndex < 6; gapIndex++) {
      final cluesInGap = sortClues.where((c) => c.slotIndex == gapIndex).toList();
      final isHighlighted = highlightedGapIndex == gapIndex;

      // Exact destination center on rack shelf notch
      final double targetX = gapIndex * (tileWidth + gapWidth) + gapWidth / 2;

      // Horizontal bay positioning:
      // When empty: centered exactly at targetX (straight vertical arrows for all 6 gaps).
      // When occupied: centered at targetX, clamped to band margins if at edges.
      final double chipLeft = (targetX - chipWidth / 2).clamp(2.0, totalWidth - chipWidth - 2.0);
      final double bayCenterX = cluesInGap.isEmpty ? targetX : (chipLeft + chipWidth / 2);

      final Color connectorColor = isHighlighted
          ? Colors.amberAccent
          : (cluesInGap.isEmpty
              ? (isDark ? Colors.white38 : Colors.black38)
              : AppColors.colorForTileColor(cluesInGap.last.tile.color));

      final double startY = cluesInGap.isEmpty ? (topMargin + badgeSize) : chipBottom;

      connectors.add(_BayConnectorData(
        startX: bayCenterX,
        startY: startY,
        endX: targetX,
        endY: arrowTipY,
        color: connectorColor,
        isHighlighted: isHighlighted,
      ));

      // 1. Position Number Badge (always visible 1–6 whether empty or occupied)
      bayWidgets.add(Positioned(
        left: bayCenterX - badgeSize / 2,
        top: topMargin,
        width: badgeSize,
        height: badgeSize,
        child: _buildPositionBadge(
          context,
          gapIndex,
          cluesInGap,
          isHighlighted,
          badgeSize,
        ),
      ));

      // 2. Clue Chip (displayed when clue occupies this gap)
      if (cluesInGap.isNotEmpty) {
        bayWidgets.add(Positioned(
          left: chipLeft,
          top: chipTop,
          width: chipWidth,
          height: chipHeight,
          child: _buildOrderClueChip(
            context,
            gapIndex,
            cluesInGap,
            isHighlighted,
            chipWidth,
            chipHeight,
          ),
        ));
      }

      // 3. Downward connector arrow icon targeting the gap notch
      bayWidgets.add(Positioned(
        left: targetX - 6.5,
        top: bandHeight - 11.0,
        child: Icon(
          Icons.arrow_drop_down,
          size: 13,
          color: connectorColor,
        ),
      ));
    }

    return Container(
      height: bandHeight,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background connector lines pointing to exact rack notch destinations
          Positioned.fill(
            child: CustomPaint(
              painter: _OrderClueConnectorsPainter(
                connectors: connectors,
                isDark: isDark,
              ),
            ),
          ),
          // Readable position badges & clue chips
          ...bayWidgets,
        ],
      ),
    );
  }

  /// Builds the persistent position number badge (1–6) at the top of each bay
  Widget _buildPositionBadge(
    BuildContext context,
    int gapIndex,
    List<SortClue> cluesInGap,
    bool isHighlighted,
    double badgeSize,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasClues = cluesInGap.isNotEmpty;
    final colorVal = hasClues
        ? AppColors.colorForTileColor(cluesInGap.last.tile.color)
        : null;

    final borderColor = isHighlighted
        ? Colors.amberAccent
        : (hasClues ? colorVal! : (isDark ? Colors.white38 : Colors.black38));

    final bgColor = isHighlighted
        ? Colors.amberAccent.withValues(alpha: 0.3)
        : (hasClues
            ? colorVal!.withValues(alpha: isDark ? 0.38 : 0.24)
            : (isDark ? Colors.white.withValues(alpha: 0.10) : Colors.black.withValues(alpha: 0.06)));

    final textColor = isHighlighted
        ? (isDark ? Colors.amberAccent : Colors.amber.shade900)
        : (hasClues
            ? (isDark ? Colors.white : (cluesInGap.last.tile.color == TileColor.yellow ? Colors.brown.shade900 : colorVal!))
            : (isDark ? Colors.white70 : Colors.black87));

    Widget badge = Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: isHighlighted ? 1.5 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '${gapIndex + 1}',
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: textColor,
          height: 1.0,
        ),
      ),
    );

    if (hasClues) {
      badge = GestureDetector(
        onTap: () {
          if (cluesInGap.length > 1) {
            _showCluesGroupDialog(context, gapIndex, cluesInGap);
          } else if (onClueTapped != null) {
            onClueTapped!(cluesInGap.last);
          } else {
            _showClueDetailDialog(context, cluesInGap.last);
          }
        },
        child: badge,
      );
    }

    return badge;
  }

  /// Builds the clue chip positioned directly below the gap position badge
  Widget _buildOrderClueChip(
    BuildContext context,
    int gapIndex,
    List<SortClue> cluesInGap,
    bool isHighlighted,
    double chipWidth,
    double chipHeight,
  ) {
    final latestClue = cluesInGap.last;
    final clueTile = latestClue.tile;
    final colorVal = AppColors.colorForTileColor(clueTile.color);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return InkWell(
      onTap: () {
        if (cluesInGap.length > 1) {
          _showCluesGroupDialog(context, gapIndex, cluesInGap);
        } else if (onClueTapped != null) {
          onClueTapped!(latestClue);
        } else {
          _showClueDetailDialog(context, latestClue);
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
        width: chipWidth,
        height: chipHeight,
        padding: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorVal.withValues(alpha: 0.95),
              colorVal.withValues(alpha: 0.80),
            ],
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isHighlighted ? Colors.amberAccent : colorVal,
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.75),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 1.5),
                    blurRadius: 2.5,
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top: Symbol
                  Text(
                    Tile.symbolForColor(clueTile.color).symbolUnicode,
                    style: const TextStyle(
                      fontSize: 8.0,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1.0),
                  // Middle: Two-digit number strictly horizontal on one line
                  Text(
                    '${clueTile.number}',
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 1.0),
                  // Bottom: Dots indicator row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(clueTile.dots, (d) => Container(
                      width: 2.0,
                      height: 2.0,
                      margin: const EdgeInsets.symmetric(horizontal: 0.3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )),
                  ),
                ],
              ),
            ),
            // Multiple clues grouping badge
            if (cluesInGap.length > 1)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 0.5),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.black54, width: 0.8),
                  ),
                  child: Text(
                    '+${cluesInGap.length - 1}',
                    style: const TextStyle(
                      fontSize: 7.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds Row 3: Physical Shelf with 5 Hidden Tiles and 6 Gap Position Notches
  Widget _buildPhysicalShelf(
    BuildContext context,
    double tileWidth,
    double tileHeight,
    double gapWidth,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF38231C), // Tabletop shelf wood finish
            Color(0xFF22120C),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Gap 0 (Before Tile 1)
          _buildShelfGapNotch(context, 0, gapWidth, tileHeight),

          for (int slot = 0; slot < 5; slot++) ...[
            // Hidden Rack Tile `slot`
            _buildHiddenRackTile(context, slot, tileWidth, tileHeight),

            // Gap `slot + 1`
            _buildShelfGapNotch(context, slot + 1, gapWidth, tileHeight),
          ],
        ],
      ),
    );
  }

  Widget _buildShelfGapNotch(
    BuildContext context,
    int gapIndex,
    double gapWidth,
    double tileHeight,
  ) {
    final isHighlighted = highlightedGapIndex == gapIndex;

    return Container(
      width: gapWidth,
      height: tileHeight,
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isHighlighted ? 4 : 2.5,
        height: isHighlighted ? tileHeight * 0.8 : tileHeight * 0.45,
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.amberAccent : Colors.white12,
          borderRadius: BorderRadius.circular(2),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.8),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildHiddenRackTile(
    BuildContext context,
    int slotIndex,
    double tileWidth,
    double tileHeight,
  ) {
    final rackTile = player.rack[slotIndex];
    final isSelected = selectedSlotIndex == slotIndex;
    final colorVal = AppColors.colorForTileColor(rackTile.color);

    return GestureDetector(
      onTap: onSlotSelected != null ? () => onSlotSelected!(slotIndex) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: tileWidth,
        height: tileHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.amberAccent : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.7),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: isOwnerView
            ? _MaskedRackTile(
                color: rackTile.color,
                colorVal: colorVal,
                slotIndex: slotIndex,
              )
            : TileWidget(
                tile: rackTile,
                width: tileWidth,
                height: tileHeight,
                isSelected: isSelected,
              ),
      ),
    );
  }

  /// Builds Row 4: 5 Guess Boxes aligned directly with Tile 0..4
  Widget _buildGuessBoxesRow(
    BuildContext context,
    double tileWidth,
    double gapWidth,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: gapWidth),
          child: Row(
            children: [
              const Icon(Icons.edit_note_rounded, size: 12, color: Colors.amberAccent),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  l10n.myGuesses,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
              ),
              if (exhaustedColors.isNotEmpty) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.7),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 10, color: Colors.redAccent),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            _formatExhaustedWarning(context, exhaustedColors),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: gapWidth), // Leading gap 0 offset
            for (int slot = 0; slot < 5; slot++) ...[
              SizedBox(
                width: tileWidth,
                child: _GuessInputBox(
                  slotIndex: slot,
                  tileColor: player.rackColors[slot],
                  currentValue: slot < guesses.length ? guesses[slot] : '',
                  isAutoFilled: autoFilledSlots.contains(slot),
                  isExhausted: exhaustedColors.contains(player.rackColors[slot]),
                  onChanged: (val) => onGuessChanged!(slot, val),
                ),
              ),
              if (slot < 4) SizedBox(width: gapWidth),
            ],
            SizedBox(width: gapWidth), // Trailing gap 5 offset
          ],
        ),
      ],
    );
  }

  String _formatExhaustedWarning(BuildContext context, Set<TileColor> exhausted) {
    final locale = Localizations.localeOf(context).languageCode;
    final names = exhausted.map((c) {
      if (locale == 'ar') return c.arabicName;
      if (locale == 'fr') return c.frenchName;
      return c.englishName;
    }).join(', ');

    if (locale == 'ar') {
      return 'أرقام $names مشطوبة كلها!';
    } else if (locale == 'fr') {
      return 'Tous $names barrés !';
    } else {
      return 'All $names crossed out!';
    }
  }

  void _showCluesGroupDialog(BuildContext context, int gapIndex, List<SortClue> clues) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.sort_rounded, color: Colors.amberAccent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.sortClue} (${clues.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: clues.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, index) {
              final clue = clues[index];
              final desc = ClueExplanationHelper.explainSortClue(
                context: context,
                clue: clue,
                rackColors: player.rackColors,
              );
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.colorForTileColor(clue.tile.color).withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    TileWidget(tile: clue.tile, width: 38, height: 52),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        desc,
                        style: const TextStyle(fontSize: 12.5, height: 1.3),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showClueDetailDialog(BuildContext context, GameClue clue) {
    final l10n = AppLocalizations.of(context)!;
    String description;
    if (clue is SortClue) {
      description = ClueExplanationHelper.explainSortClue(
        context: context,
        clue: clue,
        rackColors: player.rackColors,
      );
    } else if (clue is CompareClue) {
      description = ClueExplanationHelper.explainCompareClue(
        context: context,
        clue: clue,
        rackColors: player.rackColors,
      );
    } else {
      description = '';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            TileWidget(tile: clue.tile, width: 38, height: 52),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                clue is SortClue ? l10n.sortClue : l10n.compareClue,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showComparisonCluesGroupDialog(
    BuildContext context,
    int slot,
    List<CompareClue> clues,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetColor = player.rackColors[slot];
    final targetColorVal = AppColors.colorForTileColor(targetColor);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.compare_arrows_rounded, color: Colors.amberAccent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.comparisonCluesForSlot(slot + 1, clues.length),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prominent banner identifying target hidden tile
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: targetColorVal.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: targetColorVal, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 48,
                      decoration: BoxDecoration(
                        color: targetColorVal,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            Tile.symbolForColor(targetColor).symbolUnicode,
                            style: const TextStyle(fontSize: 10, color: Colors.white70),
                          ),
                          const Text(
                            '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.targetHiddenTile(targetColor.localizedName(context), slot + 1),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${targetColor.localizedName(context)} (${Tile.symbolForColor(targetColor).symbolUnicode})',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // List of all comparison clues for this slot
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: clues.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, index) {
                    final clue = clues[index];
                    final clueColorVal = AppColors.colorForTileColor(clue.tile.color);
                    final desc = ClueExplanationHelper.explainCompareClue(
                      context: context,
                      clue: clue,
                      rackColors: player.rackColors,
                    );

                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: clue.match
                            ? Colors.green.withValues(alpha: isDark ? 0.18 : 0.12)
                            : Colors.red.withValues(alpha: isDark ? 0.18 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: clue.match ? Colors.greenAccent : Colors.redAccent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TileWidget(tile: clue.tile, width: 38, height: 52),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: clue.match ? Colors.green.shade700 : Colors.red.shade700,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            clue.match ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                            size: 13,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            clue.match ? l10n.sameDots : l10n.differentDots,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '#${clue.tile.number} (${clue.tile.dots} ${l10n.dots(clue.tile.dots)})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: clueColorVal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

class _BayConnectorData {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final Color color;
  final bool isHighlighted;

  _BayConnectorData({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.color,
    required this.isHighlighted,
  });
}

class _OrderClueConnectorsPainter extends CustomPainter {
  final List<_BayConnectorData> connectors;
  final bool isDark;

  _OrderClueConnectorsPainter({
    required this.connectors,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connectors) {
      final paint = Paint()
        ..color = conn.color
        ..strokeWidth = conn.isHighlighted ? 2.2 : 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const double arrowHeadHeight = 5.5;
      final double stemEndY = conn.endY - arrowHeadHeight;

      if (stemEndY > conn.startY) {
        final path = Path();
        path.moveTo(conn.startX, conn.startY);
        if ((conn.startX - conn.endX).abs() < 1.0) {
          path.lineTo(conn.endX, stemEndY);
        } else {
          path.cubicTo(
            conn.startX,
            conn.startY + (stemEndY - conn.startY) * 0.45,
            conn.endX,
            conn.startY + (stemEndY - conn.startY) * 0.55,
            conn.endX,
            stemEndY,
          );
        }
        canvas.drawPath(path, paint);
      }

      // Downward arrowhead precisely targeting the gap notch
      final arrowPaint = Paint()
        ..color = conn.color
        ..style = PaintingStyle.fill;
      final arrowPath = Path()
        ..moveTo(conn.endX, conn.endY)
        ..lineTo(conn.endX - 3.8, conn.endY - arrowHeadHeight)
        ..lineTo(conn.endX + 3.8, conn.endY - arrowHeadHeight)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrderClueConnectorsPainter oldDelegate) => true;
}

class _MaskedRackTile extends StatelessWidget {
  final TileColor color;
  final Color colorVal;
  final int slotIndex;

  const _MaskedRackTile({
    required this.color,
    required this.colorVal,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorVal.withValues(alpha: 0.9),
            colorVal.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorVal, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              Tile.symbolForColor(color).symbolUnicode,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            const Text(
              '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '#${slotIndex + 1}',
              style: const TextStyle(fontSize: 9, color: Colors.white60, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuessInputBox extends StatefulWidget {
  final int slotIndex;
  final TileColor tileColor;
  final String currentValue;
  final bool isAutoFilled;
  final bool isExhausted;
  final ValueChanged<String> onChanged;

  const _GuessInputBox({
    required this.slotIndex,
    required this.tileColor,
    required this.currentValue,
    this.isAutoFilled = false,
    this.isExhausted = false,
    required this.onChanged,
  });

  @override
  State<_GuessInputBox> createState() => _GuessInputBoxState();
}

class _GuessInputBoxState extends State<_GuessInputBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void didUpdateWidget(covariant _GuessInputBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentValue != _controller.text) {
      _controller.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorVal = AppColors.colorForTileColor(widget.tileColor);

    final borderColor = widget.isExhausted
        ? Colors.redAccent
        : (widget.isAutoFilled ? Colors.amberAccent : colorVal);

    final fillColor = widget.isExhausted
        ? Colors.redAccent.withValues(alpha: isDark ? 0.25 : 0.15)
        : (widget.isAutoFilled
            ? colorVal.withValues(alpha: isDark ? 0.38 : 0.22)
            : colorVal.withValues(alpha: isDark ? 0.25 : 0.14));

    final textColor = widget.isAutoFilled
        ? Colors.amberAccent
        : (isDark ? Colors.white : Colors.black87);

    final hintText = widget.isExhausted && widget.currentValue.isEmpty
        ? '!'
        : Tile.symbolForColor(widget.tileColor).symbolUnicode;

    final hintStyle = widget.isExhausted && widget.currentValue.isEmpty
        ? const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          )
        : TextStyle(
            color: colorVal.withValues(alpha: isDark ? 0.6 : 0.8),
            fontSize: 10,
          );

    return SizedBox(
      height: 24,
      child: Tooltip(
        message: widget.isExhausted
            ? 'All numbers of this color are crossed out'
            : (widget.isAutoFilled ? 'Auto-filled from deduction sheet' : ''),
        child: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 2,
          onChanged: widget.onChanged,
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 1),
            filled: true,
            fillColor: fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: borderColor,
                width: (widget.isExhausted || widget.isAutoFilled) ? 1.8 : (isDark ? 1.2 : 1.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.amberAccent, width: 2),
            ),
            hintText: hintText,
            hintStyle: hintStyle,
          ),
        ),
      ),
    );
  }
}
