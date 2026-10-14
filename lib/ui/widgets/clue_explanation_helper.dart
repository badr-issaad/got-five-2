import 'package:flutter/material.dart';
import '../../domain/models/clue.dart';
import '../../domain/models/tile.dart';
import '../../l10n/app_localizations.dart';

extension TileColorL10n on TileColor {
  String localizedName(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'ar') return arabicName;
    if (code == 'fr') return frenchName;
    return englishName;
  }
}

class ClueExplanationHelper {
  static String getOrdinal(BuildContext context, int slotOneBased) {
    final l10n = AppLocalizations.of(context)!;
    switch (slotOneBased) {
      case 1:
        return l10n.posFirst;
      case 2:
        return l10n.posSecond;
      case 3:
        return l10n.posThird;
      case 4:
        return l10n.posFourth;
      case 5:
        return l10n.posFifth;
      default:
        return '$slotOneBased';
    }
  }

  static String getGapName(BuildContext context, int gapIndex) {
    final l10n = AppLocalizations.of(context)!;
    if (gapIndex == 0) return l10n.gapBeforeFirst;
    if (gapIndex == 5) return l10n.gapAfterLast;
    return l10n.gapBetween(getOrdinal(context, gapIndex), getOrdinal(context, gapIndex + 1));
  }

  static String explainSortClue({
    required BuildContext context,
    required SortClue clue,
    required List<TileColor> rackColors,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final slot = clue.slotIndex;
    final num = clue.tile.number;

    if (slot == 0) {
      final colorStr = rackColors[0].localizedName(context);
      return l10n.orderClueBeforeFirstDesc(num, colorStr);
    } else if (slot == 5) {
      final colorStr = rackColors[4].localizedName(context);
      return l10n.orderClueAfterLastDesc(num, colorStr);
    } else {
      final pos1 = getOrdinal(context, slot);
      final color1 = rackColors[slot - 1].localizedName(context);
      final pos2 = getOrdinal(context, slot + 1);
      final color2 = rackColors[slot].localizedName(context);
      return l10n.orderClueBetweenDesc(num, pos1, color1, pos2, color2, slot, 5 - slot);
    }
  }

  static String explainCompareClue({
    required BuildContext context,
    required CompareClue clue,
    required List<TileColor> rackColors,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final pos = getOrdinal(context, clue.targetSlotIndex + 1);
    final color = rackColors[clue.targetSlotIndex].localizedName(context);
    if (clue.match) {
      return l10n.compareClueSameDesc(clue.tile.number, clue.tile.dots, pos, color);
    } else {
      return l10n.compareClueDiffDesc(clue.tile.number, clue.tile.dots, pos, color);
    }
  }
}
