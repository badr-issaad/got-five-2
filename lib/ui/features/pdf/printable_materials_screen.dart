import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../pdf/pdf_generator_service.dart';

class PrintableMaterialsScreen extends StatelessWidget {
  const PrintableMaterialsScreen({super.key});

  void _printColorSheet(BuildContext context) async {
    final pdfBytes = await PdfGeneratorService.generateColorDeductionSheet();
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'GotFive_Color_Deduction_Sheet.pdf',
    );
  }

  void _printBwSheet(BuildContext context) async {
    final pdfBytes = await PdfGeneratorService.generateBwEcoDeductionSheet();
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'GotFive_Eco_BW_Deduction_Sheet.pdf',
    );
  }

  void _printCutoutSheet(BuildContext context) async {
    final pdfBytes = await PdfGeneratorService.generateCutoutTilesSheet();
    await Printing.layoutPdf(
      onLayout: (_) => pdfBytes,
      name: 'GotFive_Cutout_Tiles_Sheet.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.printMaterials)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.indigo.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.offline_pin_rounded, color: Colors.greenAccent, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pdfSheetsTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.offlineReady,
                        style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 1. Color A4 Sheet
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette_rounded, color: Colors.amberAccent, size: 32),
              title: Text(l10n.pdfA4ColorSheet, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Full A4 sheet with 60 color tiles, dots, and 5 solution slots.'),
              trailing: const Icon(Icons.print_rounded),
              onTap: () => _printColorSheet(context),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Eco B&W Sheet
          Card(
            child: ListTile(
              leading: const Icon(Icons.eco_rounded, color: Colors.greenAccent, size: 32),
              title: Text(l10n.pdfBwEcoSheet, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ink-saver black & white with geometrical shape symbols.'),
              trailing: const Icon(Icons.print_rounded),
              onTap: () => _printBwSheet(context),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Cut-out tiles
          Card(
            child: ListTile(
              leading: const Icon(Icons.content_cut_rounded, color: Colors.cyanAccent, size: 32),
              title: Text(l10n.pdfCutoutTiles, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('All 60 tiles ready to cut with scissors for real tabletop games.'),
              trailing: const Icon(Icons.print_rounded),
              onTap: () => _printCutoutSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}
