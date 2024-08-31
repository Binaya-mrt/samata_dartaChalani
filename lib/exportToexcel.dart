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
    CellStyle boldStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Arial),
      bold: true,
    );
// gives border to sheet

    // add auto width to cells

    // dartaSheet.autoWidth = true;
    dartaSheet.setColumnAutoFit(1);
    dartaSheet.setColumnAutoFit(2);
    dartaSheet.setColumnAutoFit(3);
    dartaSheet.setColumnAutoFit(4);
    dartaSheet.setColumnAutoFit(5);
    dartaSheet.setColumnAutoFit(6);
    // dartaSheet.setColumnAutoFit(1);

    var cellSn = dartaSheet.cell(
      CellIndex.indexByString('A1'),
    );
    cellSn.value = TextCellValue('SN');
    cellSn.cellStyle = boldStyle;
//
    var cellDate = dartaSheet.cell(
      CellIndex.indexByString('B1'),
    );
    cellDate.value = TextCellValue('Date');
    cellDate.cellStyle = boldStyle;
//

    var cellFy = dartaSheet.cell(
      CellIndex.indexByString('C1'),
    );
    cellFy.value = TextCellValue('Fiscal Year');
    cellFy.cellStyle = boldStyle;
//
    var cellname = dartaSheet.cell(
      CellIndex.indexByString('D1'),
    );
    cellname.value = TextCellValue('Incoming Institution Name');
    cellname.cellStyle = boldStyle;
//
    var cellPath = dartaSheet.cell(
      CellIndex.indexByString('E1'),
    );
    cellPath.value = TextCellValue('Type');
    cellPath.cellStyle = boldStyle;
//
    var cellSubject = dartaSheet.cell(
      CellIndex.indexByString('F1'),
    );
    cellSubject.value = TextCellValue('Subject');
    cellSubject.cellStyle = boldStyle;
//

    for (var i = 0; i < dartaBox.length; i++) {
      final darta = dartaBox.getAt(i);
      dartaSheet.appendRow([
        TextCellValue(darta?.snNumber ?? ''),
        TextCellValue(darta?.date ?? ''),
        TextCellValue(darta?.fiscalYear ?? ''),
        TextCellValue(darta?.incomingInstitutionName ?? ''),
        TextCellValue(darta?.type ?? ''), // Exporting the image path
        TextCellValue(darta?.subject ?? ''),
      ]);
    }

    // Add Chalani sheet
    Sheet? chalaniSheet = excel['Chalani'];

    // dartaSheet.autoWidth = true;
    chalaniSheet.setColumnAutoFit(1);
    chalaniSheet.setColumnAutoFit(2);
    chalaniSheet.setColumnAutoFit(3);
    chalaniSheet.setColumnAutoFit(4);
    chalaniSheet.setColumnAutoFit(5);
    chalaniSheet.setColumnAutoFit(6);
    // dartaSheet.setColumnAutoFit(1);

    var cellSnc = chalaniSheet.cell(
      CellIndex.indexByString('A1'),
    );
    cellSnc.value = TextCellValue('SN');
    cellSnc.cellStyle = boldStyle;
//
    var cellDatec = chalaniSheet.cell(
      CellIndex.indexByString('B1'),
    );
    cellDatec.value = TextCellValue('Date');
    cellDatec.cellStyle = boldStyle;
//

    var cellFyc = chalaniSheet.cell(
      CellIndex.indexByString('C1'),
    );
    cellFyc.value = TextCellValue('Fiscal Year');
    cellFyc.cellStyle = boldStyle;
//
    var cellnamec = chalaniSheet.cell(
      CellIndex.indexByString('D1'),
    );
    cellnamec.value = TextCellValue('Outgoing Institution Name');
    cellnamec.cellStyle = boldStyle;
//

    var cellPathc = chalaniSheet.cell(
      CellIndex.indexByString('E1'),
    );
    cellPathc.value = TextCellValue('Type');
    cellPathc.cellStyle = boldStyle;
// //

    var cellSubjectc = chalaniSheet.cell(
      CellIndex.indexByString('F1'),
    );
    cellSubjectc.value = TextCellValue('Subject');
    cellSubjectc.cellStyle = boldStyle;

    for (var i = 0; i < chalaniBox.length; i++) {
      final chalani = chalaniBox.getAt(i);
      chalaniSheet.appendRow([
        TextCellValue(chalani?.snNumber ?? ''),
        TextCellValue(chalani?.date ?? ''),
        TextCellValue(chalani?.fiscalYear ?? ''),
        TextCellValue(chalani?.outgoingInstitutionName ?? ''),
        TextCellValue(chalani?.subject ?? ''),
        TextCellValue(chalani?.type ?? ''),
        // TextCellValue(chalani?.filePath ?? ''), // Exporting the image path
      ]);
    }

    // Save the Excel file
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }
    excel.delete('Sheet1');

    var filePath = '$selectedDirectory/darta_chalani_export.xlsx';
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
