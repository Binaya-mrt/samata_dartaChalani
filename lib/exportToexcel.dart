import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'models/darta.dart';
import 'models/chalani.dart';

class ExportService {
  Future<void> exportToExcel(BuildContext context) async {
    var excel = Excel.createExcel();

    // Fetch Darta and Chalani data from Hive
    var dartaBox = Hive.box<Darta>('darta');
    var chalaniBox = Hive.box<Chalani>('chalani');

    // Add Darta sheet
    Sheet? dartaSheet = excel['Darta'];
    dartaSheet.appendRow([
      TextCellValue('SN'),
      TextCellValue('Date'),
      TextCellValue('Fiscal Year'),
      TextCellValue('Incoming Institution Name'),
      TextCellValue('Subject'),
    ]);

    for (var i = 0; i < dartaBox.length; i++) {
      final darta = dartaBox.getAt(i);
      dartaSheet.appendRow([
        TextCellValue(darta?.snNumber ?? ''),
        TextCellValue(darta?.date ?? ''),
        TextCellValue(darta?.fiscalYear ?? ''),
        TextCellValue(darta?.incomingInstitutionName ?? ''),
        TextCellValue(darta?.subject ?? ''),
      ]);
    }

    // Add Chalani sheet
    Sheet? chalaniSheet = excel['Chalani'];
    chalaniSheet.appendRow([
      TextCellValue('SN'),
      TextCellValue('Date'),
      TextCellValue('Fiscal Year'),
      TextCellValue('Outgoing Institution Name'),
      TextCellValue('Subject'),
    ]);

    for (var i = 0; i < chalaniBox.length; i++) {
      final chalani = chalaniBox.getAt(i);
      chalaniSheet.appendRow([
        TextCellValue(chalani?.snNumber ?? ''),
        TextCellValue(chalani?.date ?? ''),
        TextCellValue(chalani?.fiscalYear ?? ''),
        TextCellValue(chalani?.outgoingInstitutionName ?? ''),
        TextCellValue(chalani?.subject ?? ''),
      ]);
    }

    // Save the Excel file
    Directory directory = await getApplicationDocumentsDirectory();
    excel.delete('Sheet1');

    var filePath = '${directory.path}/darta_chalani_export.xlsx';
    var fileBytes = excel.save();
    if (fileBytes == null) return;

    // Ensure file is not in use by another process
    File file = File(filePath);
    try {
      // If file exists, delete it first
      if (await file.exists()) {
        await file.delete();
      }
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'The file is being used by another application,so it can\'t be completed at the moment')),
      );
    }
  }
}
