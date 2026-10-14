import 'package:flutter/material.dart';
import '../../domain/models/tile.dart';
import '../core/theme.dart';

class TileWidget extends StatelessWidget {
  final Tile tile;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isCrossedOut;
  final bool showDots;

  const TileWidget({
    super.key,
    required this.tile,
    this.width = 54,
    this.height = 76,
    this.isSelected = false,
    this.onTap,
    this.isCrossedOut = false,
    this.showDots = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = AppColors.colorForTileColor(tile.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: width,
        height: height,
        transform: isSelected ? Matrix4.translationValues(0, -6, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isCrossedOut
                ? [Colors.grey.shade700, Colors.grey.shade800]
                : [
                    baseColor.withValues(alpha: 0.95),
                    baseColor.withValues(alpha: 0.75),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? Colors.amberAccent
                : (isCrossedOut ? Colors.grey.shade600 : Colors.white.withValues(alpha: 0.35)),
            width: isSelected ? 3.0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.amberAccent.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.35),
              offset: Offset(0, isSelected ? 8 : 4),
              blurRadius: isSelected ? 12 : 6,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Bar: Shape Symbol + Dots
            Positioned(
              top: (width * 0.06).clamp(2.0, 4.0),
              left: (width * 0.06).clamp(2.0, 4.0),
              right: (width * 0.06).clamp(2.0, 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Shape symbol for accessibility
                    Text(
                      tile.symbol.symbolUnicode,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: (width * 0.18).clamp(7.0, 14.0),
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    // Dots indicator (1, 2, or 3)
                    if (showDots && !tile.isHidden && tile.dots > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          tile.dots,
                          (index) => Container(
                            margin: EdgeInsets.only(left: (width * 0.03).clamp(0.8, 1.5)),
                            width: (width * 0.07).clamp(2.0, 5.0),
                            height: (width * 0.07).clamp(2.0, 5.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Center Content: Large Number or Masked '?'
            Center(
              child: tile.isHidden
                  ? Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: width * 0.5,
                    )
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${tile.number}',
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Diagonal Strike-Through if crossed out
            if (isCrossedOut)
              Positioned.fill(
                child: CustomPaint(
                  painter: _CrossOutPainter(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CrossOutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.85)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(6, 6), Offset(size.width - 6, size.height - 6), paint);
    canvas.drawLine(Offset(size.width - 6, 6), Offset(6, size.height - 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
