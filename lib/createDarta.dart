import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mime/mime.dart';
import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/tauko.dart';
import 'dart:io';
import 'models/darta.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';

class CreateDartaScreen extends StatefulWidget {
  const CreateDartaScreen({super.key});

  @override
  _CreateDartaScreenState createState() => _CreateDartaScreenState();
}

class _CreateDartaScreenState extends State<CreateDartaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionNameController = TextEditingController();
  final _snController = TextEditingController();

  final _subjectController = TextEditingController();
  NepaliDateTime? _selectedNepaliDate;
  String? _selectedFiscalYear;

  File? _selectedFile;
  int _snNumber = 1;

  @override
  void initState() {
    super.initState();
    _initializeSN();
    getTodayDate();
    _snController.value = TextEditingValue(text: "$_snNumber ");
  }

  void _initializeSN() {
    final box = Hive.box<Darta>('darta');
    if (box.isNotEmpty) {
      _snNumber = int.parse(box.values.last.snNumber.split(' ')[0]) + 1;
    }
  }

  String? _selectedOption;
  String? _selectedCompany;
  String? _customCompanyName;

  List<String> _filteredCompanies = [];

  void getTodayDate() {
    _selectedNepaliDate = NepaliDateTime.now();
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

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedFile != null) {
      try {
        String? documentBase64;
        if (_selectedFile != null) {
          final bytes = await _selectedFile!.readAsBytes();
          final mimeType = lookupMimeType(_selectedFile!.path);
          if (mimeType != null) {
            documentBase64 = 'data:$mimeType;base64,${base64Encode(bytes)}';
          } else {
            log('Unsupported file type');
          }
        }

        // Create a new Darta object with the new file path
        final newDarta = Darta(
            date: _selectedNepaliDate!.toString().split(' ')[0],
            snNumber: _snController.text,
            fiscalYear: _selectedFiscalYear!,
            incomingInstitutionName: _selectedCompany == 'Others'
                ? _institutionNameController.text
                : _selectedCompany!,
            subject: _subjectController.text,
            imageBase64: documentBase64,
            type: _selectedOption);

        // Save the Darta object in Hive
        Hive.box<Darta>('darta').add(newDarta);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Darta Created Successfully')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save Darta: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the details'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Tauko(
                      header: 'Darta',
                    ),
                    Container(
                      width: getwidth(context) / 1.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xff108841)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: getwidth(context) / 4,
                                    child: ListTile(
                                      title: RichText(
                                        text: TextSpan(
                                          text: 'Date:  ',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: _selectedNepaliDate !=
                                                        null
                                                    ? NepaliDateFormat.yMMMMd()
                                                        .format(
                                                            _selectedNepaliDate!)
                                                    : 'Select Date',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 16,
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      ),
                                      trailing:
                                          const Icon(Icons.calendar_today),
                                      onTap: () async {
                                        NepaliDateTime? picked =
                                            await showAdaptiveDatePicker(
                                          context: context,
                                          initialDate: NepaliDateTime.now(),
                                          firstDate: NepaliDateTime(2000),
                                          lastDate: NepaliDateTime(2100),
                                          initialDatePickerMode:
                                              DatePickerMode.day,
                                        );
                                        if (picked != null &&
                                            picked != _selectedNepaliDate) {
                                          setState(() {
                                            _selectedNepaliDate = picked;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Darta Number: ',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red),
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      SizedBox(
                                        width: 70,
                                        height: 30,
                                        child: Center(
                                          child: TextFormField(
                                            controller: _snController,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 10, left: 5),
                                              // border: OutlineInputBorder(),
                                              // focusedBorder:
                                              //     OutlineInputBorder(),
                                            ),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                            validator: (value) => value!.isEmpty
                                                ? 'Enter subject'
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Column(
                                          children: [],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    Row(
                                      children: [
                                        const Text(
                                          'Select Fiscal Year',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red),
                                        ),
                                        SizedBox(
                                            width: getheight(context) * 0.11),
                                        SizedBox(
                                          width: getwidth(context) / 8,
                                          child:
                                              DropdownButtonFormField<String>(
                                            hint: const Text(
                                                'Choose fiscal year'),
                                            value: _selectedFiscalYear,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            items: fiscalYears
                                                .map((year) => DropdownMenuItem(
                                                    value: year,
                                                    child: Text(year)))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedFiscalYear = value!;
                                              });
                                            },
                                            validator: (value) => value == null
                                                ? 'Select a fiscal year'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    Row(
                                      children: [
                                        const Text(
                                          'Institution Type ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red),
                                        ),
                                        SizedBox(
                                          width: getwidth(context) * 0.07,
                                        ),
                                        DropdownButton<String>(
                                          style: inside,
                                          hint: const Text('Select One',
                                              style: inside),
                                          value: _selectedOption,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedOption = newValue;
                                              _filteredCompanies =
                                                  companyOptions[newValue] ??
                                                      [];

                                              if (newValue == 'Internal') {
                                                _selectedCompany = 'Samata';
                                              } else {
                                                _selectedCompany = null;
                                                _customCompanyName =
                                                    null; // Reset custom company name
                                              }
                                            });
                                          },
                                          items:
                                              companyOptions.keys.map((option) {
                                            return DropdownMenuItem<String>(
                                              value: option,
                                              child: Text(option),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    const Text('Incoming Institution',
                                        style: title),
                                    if (_selectedOption == 'Internal') ...[
                                      const Text('Samata', style: inside),
                                    ] else ...[
                                      DropdownButton<String>(
                                        hint: const Text('Select company',
                                            style: inside),
                                        value: _selectedCompany,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedCompany = newValue;
                                            _customCompanyName =
                                                null; // Reset custom company name when a new company is selected
                                          });
                                        },
                                        items:
                                            _filteredCompanies.map((company) {
                                          return DropdownMenuItem<String>(
                                            value: company,
                                            child: Text(company, style: inside),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    if (_selectedCompany == 'Others') ...[
                                      TextField(
                                        controller: _institutionNameController,
                                        style: inside,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter company name',
                                          hintStyle: inside,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _customCompanyName = value;
                                          });
                                        },
                                      ),
                                    ],
                                    const Text(
                                      'Enter Subject',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red),
                                    ),
                                    SizedBox(
                                      height: 35,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                bottom: 10, left: 5)),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                        controller: _subjectController,
                                        validator: (value) => value!.isEmpty
                                            ? 'Enter subject'
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _selectedFile != null
                                            ? _selectedFile!.path
                                                    .endsWith('.pdf')
                                                ? Text(
                                                    'Selected PDF: ${_selectedFile!.path.split('/').last}')
                                                : Image.file(
                                                    _selectedFile!,
                                                    height: 100,
                                                    width: 150,
                                                  )
                                            : GestureDetector(
                                                onTap: _pickFile,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons.upload,
                                                        color:
                                                            Color(0xff108841),
                                                      ),
                                                    ),
                                                    const Text(
                                                      'Upload Document',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff108841),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30.0, vertical: 8),
                                            child: Text(
                                              'Back',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: _submitForm,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xff108841),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30.0, vertical: 8),
                                            child: Text(
                                              'Submit',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Adjust the bottom padding as needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
