import 'package:flutter/material.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart';
import 'package:nepali_utils/nepali_utils.dart'; // For Nepali date formatting
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'models/chalani.dart';

class CreateChalaniScreen extends StatefulWidget {
  @override
  _CreateChalaniScreenState createState() => _CreateChalaniScreenState();
}

class _CreateChalaniScreenState extends State<CreateChalaniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _outgoingInstitutionNameController = TextEditingController();
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
    final box = Hive.box<Chalani>('chalani');
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
      final newChalani = Chalani(
        date: _selectedNepaliDate!.toString().split(' ')[0],
        snNumber: _snNumber.toString(),
        fiscalYear: _selectedFiscalYear!,
        outgoingInstitutionName: _outgoingInstitutionNameController.text,
        subject: _subjectController.text,
        filePath: _selectedFile?.path ?? '',
        fileType:
            _selectedFile?.path.endsWith('.pdf') == true ? 'pdf' : 'image',
      );

      Hive.box<Chalani>('chalani').add(newChalani);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chalani Created Successfully')),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Chalani')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
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
                title:
                    Text("SN Number: ${NepaliUnicode.convert("$_snNumber")}"),
              ),
              DropdownButtonFormField<String>(
                value: _selectedFiscalYear,
                decoration: InputDecoration(labelText: 'Fiscal Year'),
                items: [
                  DropdownMenuItem(child: Text('2078/79'), value: '2078/79'),
                  DropdownMenuItem(child: Text('2079/80'), value: '2079/80'),
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
                controller: _outgoingInstitutionNameController,
                decoration:
                    InputDecoration(labelText: 'Outgoing Institution Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter institution name' : null,
              ),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (value) => value!.isEmpty ? 'Enter subject' : null,
              ),
              SizedBox(height: 20),
              _selectedFile != null
                  ? _selectedFile!.path.endsWith('.pdf')
                      ? Text(
                          'Selected PDF: ${_selectedFile!.path.split('/').last}')
                      : Image.file(_selectedFile!, height: 150, width: 150)
                  : TextButton.icon(
                      icon: Icon(Icons.image),
                      label: Text('Select Image or PDF'),
                      onPressed: _pickFile,
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
    );
  }
}
