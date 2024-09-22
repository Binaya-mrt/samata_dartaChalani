import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:samata_dartachalani/models/chalani.dart';
import 'package:samata_dartachalani/models/darta.dart';

class HiveExportImport {
  static Future<void> exportData(BuildContext context) async {
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

  static Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final allData = jsonDecode(jsonString);

        final dartaBox = Hive.box<Darta>('darta');
        final chalaniBox = Hive.box<Chalani>('chalani');

        // Import data to dartaBox
        final dartaData = allData['darta'] as List<dynamic>;
        for (var dartaJson in dartaData) {
          final importedDarta = Darta.fromJson(dartaJson);
          
          // Find existing or add new entry
          Darta? existingDarta;
          try {
            existingDarta = dartaBox.values.firstWhere(
              (d) => d.snNumber == importedDarta.snNumber,
            );
          } catch (e) {
            existingDarta = null;
          }

          if (existingDarta != null) {
            // Update existing entry
            final index = dartaBox.values.toList().indexOf(existingDarta);
            await dartaBox.putAt(index, importedDarta);
          } else {
            // Add new entry
            await dartaBox.add(importedDarta);
          }
        }

        // Import data to chalaniBox
        final chalaniData = allData['chalani'] as List<dynamic>;
        for (var chalaniJson in chalaniData) {
          final importedChalani = Chalani.fromJson(chalaniJson);
          
          // Find existing or add new entry
          Chalani? existingChalani;
          try {
            existingChalani = chalaniBox.values.firstWhere(
              (c) => c.snNumber == importedChalani.snNumber,
            );
          } catch (e) {
            existingChalani = null;
          }

          if (existingChalani != null) {
            // Update existing entry
            final index = chalaniBox.values.toList().indexOf(existingChalani);
            await chalaniBox.putAt(index, importedChalani);
          } else {
            // Add new entry
            await chalaniBox.add(importedChalani);
          }
        }

        // Show success message
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
