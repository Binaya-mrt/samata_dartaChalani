import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
      TextCellValue('Image Path'), // New column for image path
    ]);

    for (var i = 0; i < dartaBox.length; i++) {
      final darta = dartaBox.getAt(i);
      dartaSheet.appendRow([
        TextCellValue(darta?.snNumber ?? ''),
        TextCellValue(darta?.date ?? ''),
        TextCellValue(darta?.fiscalYear ?? ''),
        TextCellValue(darta?.incomingInstitutionName ?? ''),
        TextCellValue(darta?.subject ?? ''),
        TextCellValue(darta?.filePath ?? ''), // Exporting the image path
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
      TextCellValue('Image Path'), // New column for image path
    ]);

    for (var i = 0; i < chalaniBox.length; i++) {
      final chalani = chalaniBox.getAt(i);
      chalaniSheet.appendRow([
        TextCellValue(chalani?.snNumber ?? ''),
        TextCellValue(chalani?.date ?? ''),
        TextCellValue(chalani?.fiscalYear ?? ''),
        TextCellValue(chalani?.outgoingInstitutionName ?? ''),
        TextCellValue(chalani?.subject ?? ''),
        TextCellValue(chalani?.filePath ?? ''), // Exporting the image path
      ]);
    }

    // Save the Excel file
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }
    excel.delete('Sheet1');

    var filePath = '${selectedDirectory}/darta_chalani_export.xlsx';
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
        const SnackBar(
            content: Text(
                'The file is being used by another application, so it can\'t be completed at the moment')),
      );
    }
  }
}
