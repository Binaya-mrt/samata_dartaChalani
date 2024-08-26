import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/tauko.dart';
import 'dart:io';
import 'models/darta.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'models/darta.dart';

class CreateDartaScreen extends StatefulWidget {
  @override
  _CreateDartaScreenState createState() => _CreateDartaScreenState();
}

class _CreateDartaScreenState extends State<CreateDartaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionNameController = TextEditingController();
  final _subjectController = TextEditingController();
  NepaliDateTime? _selectedNepaliDate;
  String? _selectedFiscalYear;

  File? _selectedFile;
  int _snNumber = 1;

  @override
  void initState() {
    super.initState();
    _initializeSN();
  }

  void _initializeSN() {
    final box = Hive.box<Darta>('darta');
    if (box.isNotEmpty) {
      _snNumber = int.parse(box.values.last.snNumber) + 1;
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newDarta = Darta(
        date: _selectedNepaliDate!.toString().split(' ')[0],
        snNumber: _snNumber.toString(),
        fiscalYear: _selectedFiscalYear!,
        incomingInstitutionName: _institutionNameController.text,
        subject: _subjectController.text,
        filePath: _selectedFile!.path,
        fileType:
            _selectedFile?.path.endsWith('.pdf') == true ? 'pdf' : 'image',
      );

      Hive.box<Darta>('darta').add(newDarta);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Darta Created Successfully')),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all the details')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: Align(
          alignment: Alignment.topCenter,
          child: Stack(
            children:[ Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Tauko(header: 'Darta'),
                Container(
                  width: getwidth(context) / 1.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xff108841))),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Date: ${_selectedNepaliDate != null ? NepaliDateFormat.yMMMMd().format(_selectedNepaliDate!) : 'Select Date'}",
                          ),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            NepaliDateTime? picked = await showAdaptiveDatePicker(
                              context: context,
                              initialDate: NepaliDateTime.now(),
                              firstDate: NepaliDateTime(2000),
                              lastDate: NepaliDateTime(2100),
                              initialDatePickerMode: DatePickerMode.day,
                            );
                            if (picked != null && picked != _selectedNepaliDate)
                              setState(() {
                                _selectedNepaliDate = picked;
                              });
                          },
                        ),
                        ListTile(
                          title: Text(
                              "Darta No: ${NepaliUnicode.convert("$_snNumber")}"),
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedFiscalYear,
                          decoration: InputDecoration(labelText: 'Fiscal Year'),
                          items: [
                            DropdownMenuItem(
                                child: Text('2078/79'), value: '2078/79'),
                            DropdownMenuItem(
                                child: Text('2079/80'), value: '2079/80'),
                            // Add more fiscal years as needed
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFiscalYear = value!;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Select a fiscal year' : null,
                        ),
                        TextFormField(
                          controller: _institutionNameController,
                          decoration: InputDecoration(
                              labelText: 'Incoming Institution Name'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter institution name' : null,
                        ),
                        TextFormField(
                          controller: _subjectController,
                          decoration: InputDecoration(labelText: 'Subject'),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter subject' : null,
                        ),
                        SizedBox(height: 20),
                        _selectedFile != null
                            ? _selectedFile!.path.endsWith('.pdf')
                                ? Text(
                                    'Selected PDF: ${_selectedFile!.path.split('/').last}')
                                : Image.file(
                                    _selectedFile!,
                                    height: 150,
                                    width: 150,
                                  )
                            : Text('No file selected.',
                                style: TextStyle(color: Colors.red)),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _pickFile,
                          child: Text('Pick Image or PDF'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Text('Submit'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Positioned(
                left:0,
                top: 0,
                child: Icon(Icons.arrow_back,
                size: 40,
                color: Colors.black)),
            )
          ]),
        ),
      ),
    );
  }
}
