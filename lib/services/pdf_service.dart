import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/group_model.dart';

class PdfService {
  static Future<void> exportReport({
    required GroupModel group,
    required List<Map<String, dynamic>> rows,
    required String program,
    required String period,
  }) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final tableRows = rows
              .map(
                (row) => [
                  row['studentName'],
                  row['institutionalCode'],
                  row['totalPoints'],
                  row['attendance'],
                  row['tardiness'],
                  row['absence'],
                  row['justified'],
                ],
              )
              .toList();

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SENATI - AULA PUNTOS',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Grupo: ${group.name}'),
              pw.Text('Programa: $program'),
              pw.Text('Periodo: $period'),
              pw.Text('Fecha de generación: ${DateTime.now().toLocal()}'),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                headers: ['Estudiante', 'Código', 'Puntos', 'Asistencias', 'Tardanzas', 'Faltas', 'Justificados'],
                data: tableRows,
                border: null,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue50),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellPadding: const pw.EdgeInsets.all(8),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'reporte-${group.sectionCode}.pdf');
  }
}
