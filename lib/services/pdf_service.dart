import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String> extrageTextDinPdf(Uint8List bytes) async {
    try {
      final document = PdfDocument(inputBytes: bytes);
      String fullText = "";
      
      // Aflăm câte pagini are documentul
      int pageCount = document.pages.count;
      print("Documentul are $pageCount pagini.");

      // Extragem textul pagină cu pagină (mai sigur pentru fișiere mari)
      // Limităm la primele 20 de pagini pentru a nu bloca AI-ul
      int limit = pageCount > 20 ? 20 : pageCount;

      for (int i = 0; i < limit; i++) {
        fullText += PdfTextExtractor(document).extractText(startPageIndex: i, endPageIndex: i);
      }

      document.dispose();

      // Curățăm puțin textul de spații multiple inutile care consumă memorie
      fullText = fullText.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (fullText.isEmpty || fullText.length < 10) {
        print("Avertisment: Textul extras este prea scurt sau gol.");
      }

      return fullText;
    } catch (e) {
      print("Eroare la citirea PDF-ului: $e");
      return "";
    }
  }
}