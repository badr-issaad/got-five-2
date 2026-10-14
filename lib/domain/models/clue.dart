import 'tile.dart';

enum ClueType {
  sort,
  compare,
}

abstract class GameClue {
  final String id;
  final ClueType type;
  final Tile tile;
  final int targetPlayerIndex;
  final DateTime timestamp;

  GameClue({
    required this.id,
    required this.type,
    required this.tile,
    required this.targetPlayerIndex,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson();

  factory GameClue.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    if (typeStr == ClueType.sort.name) {
      return SortClue.fromJson(json);
    } else {
      return CompareClue.fromJson(json);
    }
  }
}

/// Sort Clue (دليل الترتيب)
/// Determines where [tile] fits among the player's 5 hidden tiles.
/// 6 slots:
/// slot 0: Before all tiles (< tile 1)
/// slot 1: Between tile 1 and tile 2
/// slot 2: Between tile 2 and tile 3
/// slot 3: Between tile 3 and tile 4
/// slot 4: Between tile 4 and tile 5
/// slot 5: After all tiles (> tile 5)
class SortClue extends GameClue {
  final int slotIndex; // 0 to 5

  SortClue({
    required super.id,
    required super.tile,
    required super.targetPlayerIndex,
    required this.slotIndex,
    super.timestamp,
  })  : assert(slotIndex >= 0 && slotIndex <= 5, 'Slot index must be between 0 and 5'),
        super(type: ClueType.sort);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'tile': tile.toJson(),
        'targetPlayerIndex': targetPlayerIndex,
        'slotIndex': slotIndex,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SortClue.fromJson(Map<String, dynamic> json) {
    return SortClue(
      id: json['id'] as String,
      tile: Tile.fromJson(json['tile'] as Map<String, dynamic>),
      targetPlayerIndex: json['targetPlayerIndex'] as int,
      slotIndex: json['slotIndex'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'SortClue(tile: #${tile.number}, targetPlayer: $targetPlayerIndex, slot: $slotIndex)';
}

/// Compare Clue (دليل مقارنة النقاط)
/// Checks if [tile] has the same number of dots (points) as the player's hidden tile at [targetSlotIndex] (0 to 4).
/// Returns true (YES) or false (NO).
class CompareClue extends GameClue {
  final int targetSlotIndex; // 0 to 4 (which rack position was queried)
  final bool match; // true if dots match, false otherwise

  CompareClue({
    required super.id,
    required super.tile,
    required super.targetPlayerIndex,
    required this.targetSlotIndex,
    required this.match,
    super.timestamp,
  })  : assert(targetSlotIndex >= 0 && targetSlotIndex <= 4, 'Target slot must be 0..4'),
        super(type: ClueType.compare);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'tile': tile.toJson(),
        'targetPlayerIndex': targetPlayerIndex,
        'targetSlotIndex': targetSlotIndex,
        'match': match,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CompareClue.fromJson(Map<String, dynamic> json) {
    return CompareClue(
      id: json['id'] as String,
      tile: Tile.fromJson(json['tile'] as Map<String, dynamic>),
      targetPlayerIndex: json['targetPlayerIndex'] as int,
      targetSlotIndex: json['targetSlotIndex'] as int,
      match: json['match'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() =>
      'CompareClue(tile: #${tile.number}, slot: $targetSlotIndex, match: $match)';
}
