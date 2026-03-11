import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/question.dart';

class PdfExportService {
  static Future<void> exporteazaTest(String numeTest, List<Question> intrebari) async {
    final pdf = pw.Document();

    // 1. Descărcăm un font compatibil cu diacriticele românești (Roboto)
    final fontNormal = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        // 2. Setăm tema documentului să folosească fontul nou
        theme: pw.ThemeData.withFont(
          base: fontNormal,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Test: $numeTest', 
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
              ),
            ),
            pw.SizedBox(height: 20),
            
            ...intrebari.asMap().entries.map((entry) {
              int index = entry.key + 1;
              Question q = entry.value;

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$index. ${q.textIntrebare}', 
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)
                  ),
                  pw.SizedBox(height: 8),
                  
                  // Am înlocuit bullet-ul problematic cu un liniuță "-"
                  ...q.variante.map((v) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4, left: 15),
                        child: pw.Text('- $v', style: const pw.TextStyle(fontSize: 12)),
                      )).toList(),
                  pw.SizedBox(height: 16),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(), 
      filename: '$numeTest.pdf'
    );
  }
}