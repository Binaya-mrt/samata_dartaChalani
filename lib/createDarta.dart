import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nepali_utils/nepali_utils.dart';
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
  }

  void _initializeSN() {
    final box = Hive.box<Darta>('darta');
    if (box.isNotEmpty) {
      _snNumber = int.parse(box.values.last.snNumber) + 1;
    }
  }

  void getTodayDate() {
    _selectedNepaliDate = NepaliDateTime.now();
  }

// pick today date and display instead of select date

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
        const SnackBar(content: Text('Darta Created Successfully')),
      );

      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all the details')),
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
          child: Stack(children: [
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Tauko(header: 'Darta'),
                Container(
                  width: getwidth(context) / 1.5,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xff108841))),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Date: ${_selectedNepaliDate != null ? NepaliDateFormat.yMMMMd().format(_selectedNepaliDate!) : 'Select Date'}",
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
                        ListTile(
                          title: Text(
                              "Darta No: ${NepaliUnicode.convert("$_snNumber")}"),
                        ),
                        SizedBox(
                          width: getwidth(context) / 1.66,
                          child: DropdownButtonFormField<String>(
                            value: _selectedFiscalYear,
                            // focusColor: Color(0xff108841),
                            style: Theme.of(context).textTheme.headlineMedium,
                            decoration:
                                const InputDecoration(labelText: 'Fiscal Year'),
                            items: const [
                              DropdownMenuItem(
                                  value: '2078/79', child: Text('2078/79')),
                              DropdownMenuItem(
                                  value: '2079/80', child: Text('2079/80')),
                              DropdownMenuItem(
                                  value: '2080/81', child: Text('2080/81')),
                              DropdownMenuItem(
                                  value: '2081/82', child: Text('2081/82')),
                              DropdownMenuItem(
                                  value: '2082/83', child: Text('2082/83')),
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
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                subtitle: TextFormField(
                                  controller: _institutionNameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Incoming Institution Name'),
                                  validator: (value) => value!.isEmpty
                                      ? 'Enter institution name'
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                subtitle: TextFormField(
                                  controller: _subjectController,
                                  decoration: const InputDecoration(
                                      labelText: 'Subject'),
                                  validator: (value) =>
                                      value!.isEmpty ? 'Enter subject' : null,
                                ),
                              ),
                            )
                          ],
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
                                      child: Icon(
                                        Icons.upload,
                                        color: Color(0xff108841),
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    Text(
                                      'Upload Image',
                                      style: TextStyle(
                                          color: Color(0xff108841),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                        // ElevatedButton(
                        //   onPressed: _pickFile,
                        //   child: const Text('Pick Image or PDF'),
                        // ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 8),
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff108841),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Positioned(
                  left: 0,
                  top: 0,
                  child: Icon(Icons.arrow_back, size: 40, color: Colors.black)),
            )
          ]),
        ),
      ),
    );
  }
}
