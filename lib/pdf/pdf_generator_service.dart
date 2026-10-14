import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../domain/models/tile.dart';

class PdfGeneratorService {
  /// Generates the full-color A4 Got Five Deduction Sheet
  static Future<Uint8List> generateColorDeductionSheet() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GOT FIVE! - Deduction Sheet',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Cross out eliminated tiles • Record your 5 numbers in ascending order',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey600),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text('Player Name: ______________', style: const pw.TextStyle(fontSize: 10)),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),

              // 5 Solution Slots (Ascending Order)
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'YOUR 5 SECRET NUMBERS (Ascending Order: Min -> Max):',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: List.generate(5, (index) {
                        return pw.Container(
                          width: 80,
                          height: 44,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(color: PdfColors.grey800, width: 1.5),
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Center(
                            child: pw.Text('#${index + 1}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey500)),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // 60-Tile Deduction Grid (5 Colors, 12 numbers each)
              pw.Text(
                'ALL 60 TILES IN THE GAME:',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 8),

              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.8),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        _buildTableHeader('Color & Symbol'),
                        _buildTableHeader('1 Dot'),
                        _buildTableHeader('2 Dots'),
                        _buildTableHeader('3 Dots'),
                      ],
                    ),
                    for (final color in TileColor.values) ...[
                      pw.TableRow(
                        children: [
                          // Color column
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            color: _getPdfColor(color).flatten(),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${color.englishName} ${Tile.symbolForColor(color).symbolUnicode}',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 1 Dot tiles
                          _buildTilesCell(
                            Tile.tilesForColor(color).where((t) => t.dots == 1).toList(),
                          ),
                          // 2 Dots tiles
                          _buildTilesCell(
                            Tile.tilesForColor(color).where((t) => t.dots == 2).toList(),
                          ),
                          // 3 Dots tiles
                          _buildTilesCell(
                            Tile.tilesForColor(color).where((t) => t.dots == 3).toList(),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Text(
                'Got Five! is designed by Yoann Levet. Printable sheet generated by the open deduction companion app.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates ink-saver Black & White A4 Deduction Sheet
  static Future<Uint8List> generateBwEcoDeductionSheet() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'GOT FIVE! - Eco B&W Deduction Sheet',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text('Ink-Saver Edition • Differentiated with accessibility shapes', style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Text('Player: ____________', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 12),

              // Solution boxes
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: List.generate(5, (i) => pw.Container(
                  width: 75,
                  height: 40,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1.5),
                  ),
                  child: pw.Center(child: pw.Text('Slot ${i + 1}', style: const pw.TextStyle(fontSize: 10))),
                )),
              ),
              pw.SizedBox(height: 14),

              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 0.8),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        _buildTableHeader('Symbol & Color'),
                        _buildTableHeader('● (1 Dot)'),
                        _buildTableHeader('●● (2 Dots)'),
                        _buildTableHeader('●●● (3 Dots)'),
                      ],
                    ),
                    for (final color in TileColor.values)
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              '${Tile.symbolForColor(color).symbolUnicode} ${color.englishName}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                            ),
                          ),
                          _buildTilesCellBw(Tile.tilesForColor(color).where((t) => t.dots == 1).toList()),
                          _buildTilesCellBw(Tile.tilesForColor(color).where((t) => t.dots == 2).toList()),
                          _buildTilesCellBw(Tile.tilesForColor(color).where((t) => t.dots == 3).toList()),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Generates printable cut-out tiles sheet
  static Future<Uint8List> generateCutoutTilesSheet() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Text(
              'GOT FIVE! - Cut-Out Printable Tiles (1 to 60)',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Cut along the dotted borders. 12 tiles per color, total 60 tiles.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Tile.all60Tiles.map((tile) {
                return pw.Container(
                  width: 58,
                  height: 72,
                  decoration: pw.BoxDecoration(
                    color: _getPdfColor(tile.color),
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.black, width: 0.8),
                  ),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(top: 4, left: 4, right: 4),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              tile.symbol.symbolUnicode,
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                            ),
                            pw.Text(
                              '•' * tile.dots,
                              style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
                            ),
                          ],
                        ),
                      ),
                      pw.Center(
                        child: pw.Text(
                          '${tile.number}',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                    ],
                  ),
                );
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Center(
        child: pw.Text(text, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  static pw.Widget _buildTilesCell(List<Tile> tiles) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tiles.map((t) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text('#${t.number}', style: const pw.TextStyle(fontSize: 9)),
        )).toList(),
      ),
    );
  }

  static pw.Widget _buildTilesCellBw(List<Tile> tiles) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Wrap(
        spacing: 6,
        runSpacing: 4,
        children: tiles.map((t) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black),
          ),
          child: pw.Text('${t.number}', style: const pw.TextStyle(fontSize: 9)),
        )).toList(),
      ),
    );
  }

  static PdfColor _getPdfColor(TileColor color) {
    switch (color) {
      case TileColor.green:
        return PdfColor.fromHex('#10B981');
      case TileColor.pink:
        return PdfColor.fromHex('#EC4899');
      case TileColor.blue:
        return PdfColor.fromHex('#2563EB');
      case TileColor.red:
        return PdfColor.fromHex('#DC2626');
      case TileColor.yellow:
        return PdfColor.fromHex('#D97706');
    }
  }
}
