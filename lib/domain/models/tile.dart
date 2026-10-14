/// Five distinct colors used in Got Five!
enum TileColor {
  green,
  pink,
  blue,
  red,
  yellow;

  String get englishName {
    switch (this) {
      case TileColor.green:
        return 'Green';
      case TileColor.pink:
        return 'Pink';
      case TileColor.blue:
        return 'Blue';
      case TileColor.red:
        return 'Red';
      case TileColor.yellow:
        return 'Yellow';
    }
  }

  String get arabicName {
    switch (this) {
      case TileColor.green:
        return 'أخضر';
      case TileColor.pink:
        return 'وردي';
      case TileColor.blue:
        return 'أزرق';
      case TileColor.red:
        return 'أحمر';
      case TileColor.yellow:
        return 'أصفر';
    }
  }

  String get frenchName {
    switch (this) {
      case TileColor.green:
        return 'Vert';
      case TileColor.pink:
        return 'Rose';
      case TileColor.blue:
        return 'Bleu';
      case TileColor.red:
        return 'Rouge';
      case TileColor.yellow:
        return 'Jaune';
    }
  }
}

/// Geometric shape symbols for accessibility / color-blindness
enum TileShapeSymbol {
  triangle, // Green
  circle,   // Pink
  square,   // Blue
  diamond,  // Red
  star;     // Yellow

  String get symbolUnicode {
    switch (this) {
      case TileShapeSymbol.triangle:
        return '▲';
      case TileShapeSymbol.circle:
        return '●';
      case TileShapeSymbol.square:
        return '■';
      case TileShapeSymbol.diamond:
        return '◆';
      case TileShapeSymbol.star:
        return '★';
    }
  }
}

/// Represents one of the 60 unique Got Five tiles.
class Tile implements Comparable<Tile> {
  final int number; // 1 to 60
  final TileColor color;
  final int dots; // 1, 2, or 3
  final TileShapeSymbol symbol;

  const Tile({
    required this.number,
    required this.color,
    required this.dots,
    required this.symbol,
  })  : assert(number >= 0 && number <= 60, 'Tile number must be between 0 and 60'),
        assert(dots >= 0 && dots <= 3, 'Tile dots must be between 0 and 3');

  /// Indicates if this tile's number and dots are hidden/masked from the current player
  bool get isHidden => number == 0;

  /// Creates a masked/hidden tile showing only the color and shape symbol
  factory Tile.hidden(TileColor color) {
    return Tile(
      number: 0,
      color: color,
      dots: 0,
      symbol: symbolForColor(color),
    );
  }

  /// Dots pattern calculation:
  /// 1-5: 1 dot, 6-10: 2 dots, 11-15: 3 dots, repeating every 15 tiles.
  /// Tile 38 is in range 36-40, which yields 2 dots.
  static int calculateDots(int number) {
    assert(number >= 1 && number <= 60);
    return (((number - 1) ~/ 5) % 3) + 1;
  }

  /// Color formula based on number modulo 5:
  /// Green: 1, 6, 11, ... (mod 5 == 1)
  /// Pink: 2, 7, 12, ... (mod 5 == 2)
  /// Blue: 3, 8, 13, ... (mod 5 == 3)
  /// Red: 4, 9, 14, ... (mod 5 == 4)
  /// Yellow: 5, 10, 15, ... (mod 5 == 0)
  static TileColor colorForNumber(int number) {
    assert(number >= 1 && number <= 60);
    switch (number % 5) {
      case 1:
        return TileColor.green;
      case 2:
        return TileColor.pink;
      case 3:
        return TileColor.blue;
      case 4:
        return TileColor.red;
      case 0:
      default:
        return TileColor.yellow;
    }
  }

  static TileShapeSymbol symbolForColor(TileColor color) {
    switch (color) {
      case TileColor.green:
        return TileShapeSymbol.triangle;
      case TileColor.pink:
        return TileShapeSymbol.circle;
      case TileColor.blue:
        return TileShapeSymbol.square;
      case TileColor.red:
        return TileShapeSymbol.diamond;
      case TileColor.yellow:
        return TileShapeSymbol.star;
    }
  }

  /// Factory to construct a tile by its unique number (1 to 60).
  factory Tile.fromNumber(int number) {
    final color = colorForNumber(number);
    final dots = calculateDots(number);
    final symbol = symbolForColor(color);
    return Tile(
      number: number,
      color: color,
      dots: dots,
      symbol: symbol,
    );
  }

  /// All 60 official tiles.
  static final List<Tile> all60Tiles = List.unmodifiable(
    List.generate(60, (index) => Tile.fromNumber(index + 1)),
  );

  /// All 12 tiles for a specific color.
  static List<Tile> tilesForColor(TileColor color) {
    return all60Tiles.where((t) => t.color == color).toList();
  }

  @override
  int compareTo(Tile other) => number.compareTo(other.number);

  Map<String, dynamic> toJson() => {
        'number': number,
        'color': color.name,
        'dots': dots,
        'symbol': symbol.name,
      };

  factory Tile.fromJson(Map<String, dynamic> json) {
    return Tile.fromNumber(json['number'] as int);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && runtimeType == other.runtimeType && number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Tile(#$number, ${color.name}, $dots dots, ${symbol.symbolUnicode})';
}
