import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/exportToexcel.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'models/darta.dart';
import 'dart:developer';
import 'models/chalani.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({Key? key}) : super(key: key);

  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  String? _selectedFiscalYear;
  String? _incomingInstitutionFilter;
  String? _outgoingInstitutionFilter;
  // NepaliDateTimeRange? _selectedDateRange;
  NepaliDateTime? _startDate;
  NepaliDateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final dartaBox = Hive.box<Darta>('darta');
    final chalaniBox = Hive.box<Chalani>('chalani');

    List<Darta> filteredDartaList = _filterDarta(dartaBox.values.toList());
    List<Chalani> filteredChalaniList =
        _filterChalani(chalaniBox.values.toList());

    return SizedBox(
      width: getwidth(context) / 1.5,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Darta Chalani Records',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            bottom: const TabBar(
              tabs: [Tab(text: 'Darta'), Tab(text: 'Chalani')],
              indicatorColor: Color(0xff108841),
              labelColor: Color(0xff108841),
              dividerHeight: 0,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.file_download, color: Colors.white),
                  label: const Text('Export to Excel',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => ExportService().exportToExcel(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff108841),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _buildDataTab(filteredDartaList, isDarta: true),
              _buildDataTab(filteredChalaniList, isDarta: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTab(List<dynamic> dataList, {required bool isDarta}) {
    return Column(
      children: [
        _buildFilterSection(isDarta),
        Expanded(
          child: ListView.builder(
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final item = dataList[index];
              return _buildDataCard(item, isDarta);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(bool isDarta) {
    return ExpansionTile(
      title:
          const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: isDarta
                      ? 'Incoming Institution Name'
                      : 'Outgoing Institution Name',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    if (isDarta) {
                      _incomingInstitutionFilter = value;
                    } else {
                      _outgoingInstitutionFilter = value;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        _selectNepaliDate(context, isStartDate: true),
                    child: Text(
                      _startDate == null
                          ? 'Select Start Date'
                          : 'Start: ${_formatNepaliDate(_startDate!)}',
                      style: TextStyle(
                          color: Color(0xff108841),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _selectNepaliDate(context, isStartDate: false),
                    child: Text(
                      _endDate == null
                          ? 'Select End Date'
                          : 'End: ${_formatNepaliDate(_endDate!)}',
                      style: TextStyle(
                          color: Color(0xff108841),
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                hint: const Text('Select Fiscal Year'),
                style: TextStyle(
                    color: Color(0xff108841),
                    fontWeight: FontWeight.w500,
                    fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Fiscal Year',
                  border: OutlineInputBorder(),
                ),
                value: _selectedFiscalYear,
                onChanged: (value) {
                  setState(() {
                    _selectedFiscalYear = value;
                  });
                },
                items: fiscalYears
                    .map((year) =>
                        DropdownMenuItem(value: year, child: Text(year)))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(dynamic item, bool isDarta) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${isDarta ? "Darta" : "Chalani"} No. ${item.snNumber} - ${item.subject}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(isDarta
                ? item.incomingInstitutionName
                : item.outgoingInstitutionName),
            Text('Fiscal Year: ${item.fiscalYear}'),
            Text('Date: ${item.date}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => _viewFile(item.imageBase64),
                  child: const Text(
                    'View Document',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff108841),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _downloadFile(
                      item.imageBase64,
                      isDarta
                          ? '${item.incomingInstitutionName}_${item.date}'
                          : '${item.outgoingInstitutionName}_${item.date}',
                      context),
                  child: const Text(
                    'Download Document',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff108841),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewFile(String base64File) {
    // Check the MIME type prefix
    final isPdf = base64File.startsWith('data:application/pdf;');
    final isImage = base64File.startsWith('data:image/');

    // Remove the data URL prefix
    final base64Data = base64File.split(',')[1];
    final bytes = base64Decode(base64Data);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: isPdf
              ? SfPdfViewer.memory(bytes)
              : isImage
                  ? InteractiveViewer(
                      child: Image.memory(bytes),
                    )
                  : Center(child: Text('Unsupported file type')),
        );
      },
    );
  }

  Future<void> _downloadFile(
      String base64File, String fileName, BuildContext context) async {
    try {
      // Check if the Base64 string has a MIME type prefix
      final base64Data =
          base64File.contains(',') ? base64File.split(',')[1] : base64File;
      final bytes = base64Decode(base64Data);

      // Determine the file extension based on the MIME type
      String extension = '';
      if (base64File.startsWith('data:image/jpeg;')) {
        extension = '.jpg';
      } else if (base64File.startsWith('data:image/png;')) {
        extension = '.png';
      } else if (base64File.startsWith('data:application/pdf;')) {
        extension = '.pdf';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unsupported file type')),
        );
        return;
      }

      // Append the extension to the file name if not already present
      if (!fileName.endsWith(extension)) {
        fileName += extension;
      }

      // Prompt user to select a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the picker
        return;
      }

      // Construct the destination path
      String destinationPath =
          '$selectedDirectory${Platform.pathSeparator}$fileName';

      // Write the bytes to a file
      File file = File(destinationPath);
      await file.writeAsBytes(bytes);

      // Notify user of success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File downloaded to $destinationPath')),
      );
    } catch (e) {
      // Notify user of failure
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download file: $e')),
      );
    }
  }

  Future<void> _selectNepaliDate(BuildContext context,
      {required bool isStartDate}) async {
    NepaliDateTime? picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? NepaliDateTime.now()
          : _endDate ?? NepaliDateTime.now(),
      firstDate: NepaliDateTime(2000),
      lastDate: NepaliDateTime(2100),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatNepaliDate(NepaliDateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Darta> _filterDarta(List<Darta> dartaList) {
    return dartaList.where((darta) {
      bool matchesDateRange = (_startDate == null && _endDate == null) ||
          (_isDateInRange(darta.date, _startDate, _endDate));
      bool matchesFiscalYear = _selectedFiscalYear == null ||
          darta.fiscalYear == _selectedFiscalYear;
      bool matchesInstitution = _incomingInstitutionFilter == null ||
          darta.incomingInstitutionName
              .toLowerCase()
              .contains(_incomingInstitutionFilter!.toLowerCase());

      return matchesDateRange && matchesFiscalYear && matchesInstitution;
    }).toList();
  }

  List<Chalani> _filterChalani(List<Chalani> chalaniList) {
    return chalaniList.where((chalani) {
      bool matchesDateRange = (_startDate == null && _endDate == null) ||
          (_isDateInRange(chalani.date, _startDate, _endDate));
      bool matchesFiscalYear = _selectedFiscalYear == null ||
          chalani.fiscalYear == _selectedFiscalYear;
      bool matchesInstitution = _outgoingInstitutionFilter == null ||
          chalani.outgoingInstitutionName
              .toLowerCase()
              .contains(_outgoingInstitutionFilter!.toLowerCase());

      return matchesDateRange && matchesFiscalYear && matchesInstitution;
    }).toList();
  }

  bool _isDateInRange(
      String dateStr, NepaliDateTime? start, NepaliDateTime? end) {
    if (start == null || end == null) return true;
    NepaliDateTime date = NepaliDateTime.parse(dateStr);
    return (date.isAfter(start) || date.isAtSameMomentAs(start)) &&
        (date.isBefore(end) || date.isAtSameMomentAs(end));
  }
}
