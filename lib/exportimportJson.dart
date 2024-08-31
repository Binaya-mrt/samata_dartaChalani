import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:samata_dartachalani/models/chalani.dart';
import 'package:samata_dartachalani/models/darta.dart';

// Make sure to import your Darta and Chalani classes
// import 'path_to_your_models/darta.dart';
// import 'path_to_your_models/chalani.dart';

class HiveExportImport {
  static Future<void> exportData(context) async {
    final dartaBox = Hive.box<Darta>('darta');
    final chalaniBox = Hive.box<Chalani>('chalani');

    final allData = {
      'darta': dartaBox.values.map((darta) => darta.toJson()).toList(),
      'chalani': chalaniBox.values.map((chalani) => chalani.toJson()).toList(),
    };

    final jsonString = jsonEncode(allData);

    // Prompt user to select a directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }
    final file = File('$selectedDirectory/hive_export.json');
    await file.writeAsString(jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data Exported successfully to ${file.path}')),
    );
  }

  static Future<void> importData(context) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final allData = jsonDecode(jsonString);

        final dartaBox = Hive.box<Darta>('darta');
        final chalaniBox = Hive.box<Chalani>('chalani');

        // Import data to dartaBox
        final dartaData = allData['darta'] as List<dynamic>;
        for (var dartaJson in dartaData) {
          final importedDarta = Darta.fromJson(dartaJson);
          final existingDarta = dartaBox.values.firstWhere(
            (d) => d.snNumber == importedDarta.snNumber,
          );

          // Update existing entry
          final index = dartaBox.values.toList().indexOf(existingDarta);
          await dartaBox.putAt(index, importedDarta);
                }

        // Import data to chalaniBox
        final chalaniData = allData['chalani'] as List<dynamic>;
        for (var chalaniJson in chalaniData) {
          final importedChalani = Chalani.fromJson(chalaniJson);
          final existingChalani = chalaniBox.values.firstWhere(
            (c) => c.snNumber == importedChalani.snNumber,
          );

          // Update existing entry
          final index = chalaniBox.values.toList().indexOf(existingChalani);
          await chalaniBox.putAt(index, importedChalani);
                }
// show snackabr

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error Importing data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
