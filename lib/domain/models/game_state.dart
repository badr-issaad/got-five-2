import 'player.dart';
import 'tile.dart';

enum GamePhase {
  /// Player must select a color to draw a random tile from the reserve and place it into the pool.
  revealingTile,

  /// Player selects 1 of the pool tiles to ask a SORT or COMPARE clue.
  askingClue,

  /// Game has ended (winner declared).
  gameOver,
}

class GameState {
  final String gameId;
  final List<Player> players;
  final int activePlayerIndex;
  final List<Tile> pool;
  final Map<TileColor, List<Tile>> reserveByColor;
  final GamePhase phase;
  final Tile? justRevealedTile;
  final Tile? lastRevealedTile;
  final String? lastRevealedMessage;
  final String? lastRevealedPlayerName;
  final bool? lastRevealedPlayerIsAi;
  final int? lastRevealedPlayerIndex;
  final int? winnerIndex;
  final String? winnerReason;
  final int turnNumber;
  final List<String> gameLog;

  const GameState({
    required this.gameId,
    required this.players,
    required this.activePlayerIndex,
    required this.pool,
    required this.reserveByColor,
    required this.phase,
    this.justRevealedTile,
    this.lastRevealedTile,
    this.lastRevealedMessage,
    this.lastRevealedPlayerName,
    this.lastRevealedPlayerIsAi,
    this.lastRevealedPlayerIndex,
    this.winnerIndex,
    this.winnerReason,
    this.turnNumber = 1,
    this.gameLog = const [],
  });

  Player get activePlayer => players[activePlayerIndex];

  bool get isGameOver => phase == GamePhase.gameOver;

  /// Counts remaining tiles in reserve across all colors
  int get totalReserveCount =>
      reserveByColor.values.fold(0, (sum, list) => sum + list.length);

  /// Check which colors still have tiles in reserve
  List<TileColor> get availableReserveColors => reserveByColor.entries
      .where((entry) => entry.value.isNotEmpty)
      .map((entry) => entry.key)
      .toList();

  /// Total active non-eliminated players
  List<Player> get activePlayers =>
      players.where((p) => !p.isEliminated).toList();

  GameState copyWith({
    String? gameId,
    List<Player>? players,
    int? activePlayerIndex,
    List<Tile>? pool,
    Map<TileColor, List<Tile>>? reserveByColor,
    GamePhase? phase,
    Tile? justRevealedTile,
    bool clearJustRevealedTile = false,
    Tile? lastRevealedTile,
    String? lastRevealedMessage,
    String? lastRevealedPlayerName,
    bool? lastRevealedPlayerIsAi,
    int? lastRevealedPlayerIndex,
    int? winnerIndex,
    String? winnerReason,
    int? turnNumber,
    List<String>? gameLog,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      players: players ?? this.players,
      activePlayerIndex: activePlayerIndex ?? this.activePlayerIndex,
      pool: pool ?? this.pool,
      reserveByColor: reserveByColor ?? this.reserveByColor,
      phase: phase ?? this.phase,
      justRevealedTile: clearJustRevealedTile
          ? null
          : (justRevealedTile ?? this.justRevealedTile),
      lastRevealedTile: lastRevealedTile ?? this.lastRevealedTile,
      lastRevealedMessage: lastRevealedMessage ?? this.lastRevealedMessage,
      lastRevealedPlayerName: lastRevealedPlayerName ?? this.lastRevealedPlayerName,
      lastRevealedPlayerIsAi: lastRevealedPlayerIsAi ?? this.lastRevealedPlayerIsAi,
      lastRevealedPlayerIndex: lastRevealedPlayerIndex ?? this.lastRevealedPlayerIndex,
      winnerIndex: winnerIndex ?? this.winnerIndex,
      winnerReason: winnerReason ?? this.winnerReason,
      turnNumber: turnNumber ?? this.turnNumber,
      gameLog: gameLog ?? this.gameLog,
    );
  }

  /// Creates a sanitized copy of the game state for network transmission to [playerIndex].
  /// The recipient's own rack will have its numbers and dots masked (colors preserved).
  /// Opponents' racks remain visible as per the official rules.
  GameState sanitizedForPlayer(int playerIndex) {
    final sanitizedPlayers = <Player>[];
    for (int i = 0; i < players.length; i++) {
      if (i == playerIndex && !isGameOver) {
        // Mask player's own rack
        sanitizedPlayers.add(players[i].copyWith(
          rack: players[i].rack.map((t) => Tile.hidden(t.color)).toList(),
        ));
      } else {
        sanitizedPlayers.add(players[i]);
      }
    }

    return GameState(
      gameId: gameId,
      players: sanitizedPlayers,
      activePlayerIndex: activePlayerIndex,
      pool: pool,
      // For network security, the exact reserve tile order/contents are masked,
      // client only receives the count per color.
      reserveByColor: isGameOver
          ? reserveByColor
          : {
              for (final entry in reserveByColor.entries)
                entry.key: List.generate(
                  entry.value.length,
                  (_) => Tile.hidden(entry.key),
                ),
            },
      phase: phase,
      justRevealedTile: justRevealedTile,
      lastRevealedTile: lastRevealedTile,
      lastRevealedMessage: lastRevealedMessage,
      lastRevealedPlayerName: lastRevealedPlayerName,
      lastRevealedPlayerIsAi: lastRevealedPlayerIsAi,
      lastRevealedPlayerIndex: lastRevealedPlayerIndex,
      winnerIndex: winnerIndex,
      winnerReason: winnerReason,
      turnNumber: turnNumber,
      gameLog: gameLog,
    );
  }

  Map<String, dynamic> toJson({int? sanitizeForPlayerIndex}) {
    final state = sanitizeForPlayerIndex != null
        ? sanitizedForPlayer(sanitizeForPlayerIndex)
        : this;

    return {
      'gameId': state.gameId,
      'players': state.players.map((p) => p.toJson()).toList(),
      'activePlayerIndex': state.activePlayerIndex,
      'pool': state.pool.map((t) => t.toJson()).toList(),
      'reserveByColor': {
        for (final entry in state.reserveByColor.entries)
          entry.key.name: entry.value.map((t) => t.toJson()).toList(),
      },
      'phase': state.phase.name,
      'justRevealedTile': state.justRevealedTile?.toJson(),
      'lastRevealedTile': state.lastRevealedTile?.toJson(),
      'lastRevealedMessage': state.lastRevealedMessage,
      'lastRevealedPlayerName': state.lastRevealedPlayerName,
      'lastRevealedPlayerIsAi': state.lastRevealedPlayerIsAi,
      'lastRevealedPlayerIndex': state.lastRevealedPlayerIndex,
      'winnerIndex': state.winnerIndex,
      'winnerReason': state.winnerReason,
      'turnNumber': state.turnNumber,
      'gameLog': state.gameLog,
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    final rawPlayers = (json['players'] as List<dynamic>)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawPool = (json['pool'] as List<dynamic>)
        .map((t) => Tile.fromJson(t as Map<String, dynamic>))
        .toList();

    final rawReserveMap = json['reserveByColor'] as Map<String, dynamic>;
    final reserveByColor = <TileColor, List<Tile>>{};
    for (final entry in rawReserveMap.entries) {
      final color = TileColor.values.firstWhere((c) => c.name == entry.key);
      final tileList = (entry.value as List<dynamic>)
          .map((t) => Tile.fromJson(t as Map<String, dynamic>))
          .toList();
      reserveByColor[color] = tileList;
    }

    return GameState(
      gameId: json['gameId'] as String,
      players: rawPlayers,
      activePlayerIndex: json['activePlayerIndex'] as int,
      pool: rawPool,
      reserveByColor: reserveByColor,
      phase: GamePhase.values.firstWhere((p) => p.name == json['phase']),
      justRevealedTile: json['justRevealedTile'] != null
          ? Tile.fromJson(json['justRevealedTile'] as Map<String, dynamic>)
          : null,
      lastRevealedTile: json['lastRevealedTile'] != null
          ? Tile.fromJson(json['lastRevealedTile'] as Map<String, dynamic>)
          : null,
      lastRevealedMessage: json['lastRevealedMessage'] as String?,
      lastRevealedPlayerName: json['lastRevealedPlayerName'] as String?,
      lastRevealedPlayerIsAi: json['lastRevealedPlayerIsAi'] as bool?,
      lastRevealedPlayerIndex: json['lastRevealedPlayerIndex'] as int?,
      winnerIndex: json['winnerIndex'] as int?,
      winnerReason: json['winnerReason'] as String?,
      turnNumber: json['turnNumber'] as int? ?? 1,
      gameLog: (json['gameLog'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
