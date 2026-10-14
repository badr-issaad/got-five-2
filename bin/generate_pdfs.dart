import 'dart:io';
import 'package:got_five_app/pdf/pdf_generator_service.dart';

void main() async {
  final dir = Directory('assets/pdf');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  print('Generating Color A4 Deduction Sheet...');
  final colorPdf = await PdfGeneratorService.generateColorDeductionSheet();
  File('assets/pdf/GotFive_Color_Deduction_Sheet.pdf').writeAsBytesSync(colorPdf);

  print('Generating Eco B&W Deduction Sheet...');
  final bwPdf = await PdfGeneratorService.generateBwEcoDeductionSheet();
  File('assets/pdf/GotFive_Eco_BW_Deduction_Sheet.pdf').writeAsBytesSync(bwPdf);

  print('Generating Cut-Out Tiles Sheet...');
  final cutoutPdf = await PdfGeneratorService.generateCutoutTilesSheet();
  File('assets/pdf/GotFive_Cutout_Tiles_Sheet.pdf').writeAsBytesSync(cutoutPdf);

  print('Successfully generated all PDF files in assets/pdf/');
}
