import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
// For Nepali date formatting
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:samata_dartachalani/constants.dart';
import 'package:samata_dartachalani/tauko.dart';
import 'models/chalani.dart';

class CreateChalaniScreen extends StatefulWidget {
  const CreateChalaniScreen({super.key});

  @override
  _CreateChalaniScreenState createState() => _CreateChalaniScreenState();
}

class _CreateChalaniScreenState extends State<CreateChalaniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _institutionNameController = TextEditingController();
  NepaliDateTime? _selectedNepaliDate;
  String? _selectedFiscalYear;
  File? _selectedFile;

  int _snNumber = 1;
  final _snController = TextEditingController();
  final _subjectController = TextEditingController();
  //  _subjectController.text = _snNumber.toString();

  @override
  void initState() {
    super.initState();
    _initializeSN();
    getTodayDate();
    _snController.value = TextEditingValue(text: "$_snNumber ");
  }

  void _initializeSN() {
    final box = Hive.box<Chalani>('chalani');
    if (box.isNotEmpty) {
      _snNumber = int.parse(box.values.last.snNumber.split(' ')[0]) + 1;
    }
  }

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
    if (_formKey.currentState!.validate() || _selectedFile == null) {
      try {
        String? documentBase64;
        if (_selectedFile != null) {
          final bytes = await _selectedFile!.readAsBytes();
          final mimeType = lookupMimeType(_selectedFile!.path);
          if (mimeType != null) {
            documentBase64 = 'data:$mimeType;base64,${base64Encode(bytes)}';
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Unsupported file type'),
              ),
            );
            return;
          }
        }

        final newChalani = Chalani(
          date: _selectedNepaliDate!.toString().split(' ')[0],
          snNumber: _snController.text,
          fiscalYear: _selectedFiscalYear!,
          outgoingInstitutionName: _institutionNameController.text,
          subject: _subjectController.text,
          imageBase64: documentBase64,
        );

        Hive.box<Chalani>('chalani').add(newChalani);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chalani Created Successfully')),
        );

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save Darta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill in all the details',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
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
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                size: 14,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Tauko(
                      header: 'Chalani',
                    ),
                    Container(
                      width: getwidth(context) / 1.5,
                      decoration: BoxDecoration(
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
                              ListTile(
                                title: RichText(
                                  text: TextSpan(
                                    text: 'Date ',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: _selectedNepaliDate != null
                                              ? NepaliDateFormat.yMMMMd()
                                                  .format(_selectedNepaliDate!)
                                              : 'Select Date',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Colors.black)),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  NepaliDateTime? picked =
                                      await showAdaptiveDatePicker(
                                    context: context,
                                    initialDate: NepaliDateTime.now(),
                                    firstDate: NepaliDateTime(2000),
                                    lastDate: NepaliDateTime(2100),
                                    initialDatePickerMode: DatePickerMode.day,
                                  );
                                  if (picked != null &&
                                      picked != _selectedNepaliDate) {
                                    setState(() {
                                      _selectedNepaliDate = picked;
                                    });
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Chalani Number: ',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          height: 40,
                                          child: TextFormField(
                                            controller: _snController,
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              focusedBorder:
                                                  OutlineInputBorder(),
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
                                      ],
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    const Text(
                                      'Select Fiscal Year',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    SizedBox(
                                      width: getwidth(context) / 3,
                                      child: DropdownButtonFormField<String>(
                                        hint: const Text('Choose fiscal year'),
                                        value: _selectedFiscalYear,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        items: fiscalYears
                                            .map((year) => DropdownMenuItem(
                                                value: year, child: Text(year)))
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
                                    SizedBox(height: getheight(context) * 0.02),
                                    const Text(
                                      'Outgoing Institutions:-',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    ListTile(
                                      subtitle: TextFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            focusedBorder:
                                                OutlineInputBorder()),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black),
                                        controller: _institutionNameController,
                                        validator: (value) => value!.isEmpty
                                            ? 'Enter institution name'
                                            : null,
                                      ),
                                    ),
                                    SizedBox(height: getheight(context) * 0.02),
                                    const Text(
                                      'Enter Subject:-',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black),
                                    ),
                                    ListTile(
                                      subtitle: TextFormField(
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            focusedBorder:
                                                OutlineInputBorder()),
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
                                    SizedBox(height: getheight(context) * 0.04),
                                    _selectedFile != null
                                        ? _selectedFile!.path.endsWith('.pdf')
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
                                                  height: 100,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: const Icon(
                                                    Icons.upload,
                                                    color: Color(0xff108841),
                                                  ),
                                                ),
                                                const Text(
                                                  'Upload Document',
                                                  style: TextStyle(
                                                      color: Color(0xff108841),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                    const SizedBox(height: 20),
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
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
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
