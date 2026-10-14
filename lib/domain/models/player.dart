import 'clue.dart';
import 'tile.dart';

enum AiDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case AiDifficulty.easy:
        return 'Easy';
      case AiDifficulty.medium:
        return 'Medium';
      case AiDifficulty.hard:
        return 'Hard';
    }
  }

  String get arabicName {
    switch (this) {
      case AiDifficulty.easy:
        return 'سهل';
      case AiDifficulty.medium:
        return 'متوسط';
      case AiDifficulty.hard:
        return 'صعب';
    }
  }

  String get frenchName {
    switch (this) {
      case AiDifficulty.easy:
        return 'Facile';
      case AiDifficulty.medium:
        return 'Moyen';
      case AiDifficulty.hard:
        return 'Difficile';
    }
  }
}

class Player {
  final String id;
  final String name;
  final bool isAi;
  final AiDifficulty? aiDifficulty;

  /// Exactly 5 tiles, one per color, sorted in strictly ascending order.
  final List<Tile> rack;

  /// Clues given to this player regarding their hidden rack.
  final List<GameClue> cluesReceived;

  final bool isEliminated;
  final bool hasGuessed;
  final bool isWinner;
  final List<int>? submittedGuess;
  final String? preferredLocale;

  const Player({
    required this.id,
    required this.name,
    this.isAi = false,
    this.aiDifficulty,
    required this.rack,
    this.cluesReceived = const [],
    this.isEliminated = false,
    this.hasGuessed = false,
    this.isWinner = false,
    this.submittedGuess,
    this.preferredLocale,
  });

  /// Colors of the 5 rack tiles in ascending order (visible to the player themselves).
  List<TileColor> get rackColors => rack.map((t) => t.color).toList();

  /// Determine the sort slot (0 to 5) where [tile] fits among this player's rack.
  /// 0: < rack[0]
  /// 1: between rack[0] and rack[1]
  /// 2: between rack[1] and rack[2]
  /// 3: between rack[2] and rack[3]
  /// 4: between rack[3] and rack[4]
  /// 5: > rack[4]
  int calculateSortSlot(Tile tile) {
    if (tile.number < rack[0].number) return 0;
    if (tile.number > rack[4].number) return 5;
    for (int i = 0; i < 4; i++) {
      if (tile.number > rack[i].number && tile.number < rack[i + 1].number) {
        return i + 1;
      }
    }
    throw StateError('Tile #${tile.number} duplicate with rack tiles');
  }

  /// Compares [tile]'s dots with the dots on hidden rack tile at [slotIndex].
  bool calculateCompareDots(Tile tile, int slotIndex) {
    assert(slotIndex >= 0 && slotIndex < rack.length);
    return tile.dots == rack[slotIndex].dots;
  }

  Player copyWith({
    String? id,
    String? name,
    bool? isAi,
    AiDifficulty? aiDifficulty,
    List<Tile>? rack,
    List<GameClue>? cluesReceived,
    bool? isEliminated,
    bool? hasGuessed,
    bool? isWinner,
    List<int>? submittedGuess,
    String? preferredLocale,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      isAi: isAi ?? this.isAi,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      rack: rack ?? this.rack,
      cluesReceived: cluesReceived ?? this.cluesReceived,
      isEliminated: isEliminated ?? this.isEliminated,
      hasGuessed: hasGuessed ?? this.hasGuessed,
      isWinner: isWinner ?? this.isWinner,
      submittedGuess: submittedGuess ?? this.submittedGuess,
      preferredLocale: preferredLocale ?? this.preferredLocale,
    );
  }

  Map<String, dynamic> toJson({bool sanitizeForOwner = false}) {
    return {
      'id': id,
      'name': name,
      'isAi': isAi,
      'aiDifficulty': aiDifficulty?.name,
      // If sanitizeForOwner is true, we ONLY export color information for the rack tiles,
      // never leaking the numbers or dots to the client!
      'rack': sanitizeForOwner
          ? rack.map((t) => {'color': t.color.name}).toList()
          : rack.map((t) => t.toJson()).toList(),
      'rackColors': rackColors.map((c) => c.name).toList(),
      'cluesReceived': cluesReceived.map((c) => c.toJson()).toList(),
      'isEliminated': isEliminated,
      'hasGuessed': hasGuessed,
      'isWinner': isWinner,
      'submittedGuess': submittedGuess,
      'preferredLocale': preferredLocale,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    final rawRack = json['rack'] as List<dynamic>;
    final List<Tile> parsedRack = [];
    for (final item in rawRack) {
      final map = item as Map<String, dynamic>;
      if (map.containsKey('number')) {
        parsedRack.add(Tile.fromJson(map));
      } else {
        // Sanitized rack tile - placeholder with color only for client display
        final color = TileColor.values.firstWhere((c) => c.name == map['color']);
        parsedRack.add(Tile(
          number: 0,
          color: color,
          dots: 0,
          symbol: Tile.symbolForColor(color),
        ));
      }
    }

    final rawClues = json['cluesReceived'] as List<dynamic>? ?? [];
    final clues = rawClues
        .map((c) => GameClue.fromJson(c as Map<String, dynamic>))
        .toList();

    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      isAi: json['isAi'] as bool? ?? false,
      aiDifficulty: json['aiDifficulty'] != null
          ? AiDifficulty.values.firstWhere((d) => d.name == json['aiDifficulty'])
          : null,
      rack: parsedRack,
      cluesReceived: clues,
      isEliminated: json['isEliminated'] as bool? ?? false,
      hasGuessed: json['hasGuessed'] as bool? ?? false,
      isWinner: json['isWinner'] as bool? ?? false,
      submittedGuess: (json['submittedGuess'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      preferredLocale: json['preferredLocale'] as String?,
    );
  }
}
