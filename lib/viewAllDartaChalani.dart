import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart'; // Ensure correct package and import
import 'package:nepali_utils/nepali_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:samata_dartachalani/exportToexcel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/darta.dart';
import 'models/chalani.dart';

class ViewAllScreen extends StatefulWidget {
  @override
  _ViewAllScreenState createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  String? _selectedFiscalYear;
  String? _incomingInstitutionFilter;
  String? _outgoingInstitutionFilter;
  NepaliDateTimeRange? _selectedDateRange;

  final List<String> fiscalYears = [
    '2079/80',
    '2080/81',
    '2081/82'
  ]; // Replace with your fiscal years

  @override
  Widget build(BuildContext context) {
    final dartaBox = Hive.box<Darta>('darta');
    final chalaniBox = Hive.box<Chalani>('chalani');

    List<Darta> filteredDartaList = _filterDarta(dartaBox.values.toList());
    List<Chalani> filteredChalaniList =
        _filterChalani(chalaniBox.values.toList());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('View All Darta Chalanis'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Darta'),
              Tab(text: 'Chalani'),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment:CrossAxisAlignment.end
          children: [
            ElevatedButton(
                onPressed: () {
                  ExportService().exportToExcel(context);
                },
                child: Text('Export to excel')),
            SizedBox(
              height: 500,
              child: TabBarView(
                children: [
                  _buildDartaTab(filteredDartaList),
                  _buildChalaniTab(filteredChalaniList),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDartaTab(List<Darta> dartaList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDartaFilterWidgets(),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: dartaList.length,
              itemBuilder: (context, index) {
                final darta = dartaList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      'Darta No. ${NepaliUnicode.convert("${darta.snNumber}")} - ${darta.subject}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${darta.incomingInstitutionName}'),
                        Text('${darta.fiscalYear}'),
                        Text('${darta.date}'),
                      ],
                    ),
                    // trailing: Text(darta.date ?? 'No Date'),
                    trailing: GestureDetector(
                      onTap: () => {
// display the image on dialog box full of screen
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: Container(
                              // imageProvider: FileImage(File(chalani.filePath
                              // )),
                              height: double.infinity,
                              width: double.infinity,
                              child: Image.file(File(darta.filePath)),
                            ),
                          ),
                        )
                      },
                      // child: Image.file(File(chalani.filePath)),

                      child: InteractiveViewer(
                        child: Image.file(File(darta.filePath)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChalaniTab(List<Chalani> chalaniList) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildChalaniFilterWidgets(),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: chalaniList.length,
              itemBuilder: (context, index) {
                final chalani = chalaniList[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      'Chalani No. ${NepaliUnicode.convert("${chalani.snNumber}")} - ${chalani.subject}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    isThreeLine: true,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${chalani.outgoingInstitutionName}'),
                        Text('${chalani.fiscalYear}'),
                        Text('${chalani.date}'),
                      ],
                    ),
                    // trailing: Text(chalani.date ?? 'No Date'),
                    trailing: GestureDetector(
                      onTap: () => {
// display the image on dialog box full of screen
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            content: Container(
                              // imageProvider: FileImage(File(chalani.filePath
                              // )),
                              height: double.infinity,
                              width: double.infinity,
                              child: Image.file(File(chalani.filePath)),
                            ),
                          ),
                        )
                      },
                      // child: Image.file(File(chalani.filePath)),

                      child: InteractiveViewer(
                        child: Image.file(File(chalani.filePath)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDartaFilterWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Incoming Institution Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _incomingInstitutionFilter = value;
            });
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _selectDateRange(context),
          child: Text('Select Date Range'),
        ),
        if (_selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Selected Range: ${_selectedDateRange!.start.toNepaliDateTime()} - ${_selectedDateRange!.end.toNepaliDateTime()}',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
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
              .map((fiscalYear) => DropdownMenuItem<String>(
                    value: fiscalYear,
                    child: Text(fiscalYear),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildChalaniFilterWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filters',
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Outgoing Institution Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: (value) {
            setState(() {
              _outgoingInstitutionFilter = value;
            });
          },
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _selectDateRange(context),
          child: Text('Select Date Range'),
        ),
        if (_selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Selected Range: ${_selectedDateRange!.start.toNepaliDateTime()} - ${_selectedDateRange!.end.toNepaliDateTime().toLocal()}',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
        SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
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
              .map((fiscalYear) => DropdownMenuItem<String>(
                    value: fiscalYear,
                    child: Text(fiscalYear),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (startDate != null) {
      DateTime? endDate = await showDatePicker(
        context: context,
        initialDate: startDate.add(Duration(days: 1)),
        firstDate: startDate,
        lastDate: DateTime(2100),
      );

      if (endDate != null) {
        setState(() {
          _selectedDateRange = NepaliDateTimeRange(
              start: startDate.toNepaliDateTime(),
              end: endDate.toNepaliDateTime());
        });
      }
    }
  }

  List<Darta> _filterDarta(List<Darta> dartaList) {
    return dartaList.where((darta) {
      bool matchesDateRange = _selectedDateRange == null ||
          (darta.date != null &&
              DateTime.parse(darta.date!)
                  .isAfter(_selectedDateRange!.start.toNepaliDateTime()) &&
              DateTime.parse(darta.date!)
                  .isBefore(_selectedDateRange!.end.toNepaliDateTime()));
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
      bool matchesDateRange = _selectedDateRange == null ||
          (chalani.date != null &&
              DateTime.parse(chalani.date!)
                  .isAfter(_selectedDateRange!.start.toNepaliDateTime()) &&
              DateTime.parse(chalani.date!)
                  .isBefore(_selectedDateRange!.end.toNepaliDateTime()));
      bool matchesInstitution = _outgoingInstitutionFilter == null ||
          chalani.outgoingInstitutionName
              .toLowerCase()
              .contains(_outgoingInstitutionFilter!.toLowerCase());

      return matchesDateRange && matchesInstitution;
    }).toList();
  }
}
