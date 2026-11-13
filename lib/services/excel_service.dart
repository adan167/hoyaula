import 'dart:io';

import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';

class ExcelService {
  static Future<void> exportReport({
    required List<Map<String, dynamic>> rows,
    required String groupName,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Reporte'];

    final headers = [
      'Estudiante',
      'Código',
      'Puntos',
      'Asistencias',
      'Tardanzas',
      'Faltas',
      'Justificados',
    ];
    sheet.appendRow(headers.map((value) => TextCellValue(value)).toList());

    for (final row in rows) {
      sheet.appendRow([
        TextCellValue(row['studentName'].toString()),
        TextCellValue(row['institutionalCode'].toString()),
        TextCellValue(row['totalPoints'].toString()),
        TextCellValue(row['attendance'].toString()),
        TextCellValue(row['tardiness'].toString()),
        TextCellValue(row['absence'].toString()),
        TextCellValue(row['justified'].toString()),
      ]);
    }

    final file = File('${Directory.systemTemp.path}/$groupName-report.xlsx');
    final bytes = excel.encode();
    if (bytes == null) {
      return;
    }
    await file.writeAsBytes(bytes);
    await OpenFile.open(file.path);
  }
}
