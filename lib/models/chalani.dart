import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';

part 'chalani.g.dart';

@HiveType(typeId: 3)
class Chalani extends HiveObject {
  @HiveField(0)
  final String date; // Date as a string

  @HiveField(1)
  final String snNumber;

  @HiveField(2)
  final String fiscalYear;

  @HiveField(3)
  final String outgoingInstitutionName;

  @HiveField(4)
  final String subject;

  @HiveField(5)
  String? imageBase64; // Store the image as a base64 string

  Chalani({
    required this.date,
    required this.snNumber,
    required this.fiscalYear,
    required this.outgoingInstitutionName,
    required this.subject,
    this.imageBase64,
  });
  Map<String, dynamic> toJson() {
    return {
      'snNumber': snNumber,
      'date': date,
      'fiscalYear': fiscalYear,
      'subject': subject,
      'outgoingInstitutionName': outgoingInstitutionName,
      'imageBase64': imageBase64,
    };
  }

  factory Chalani.fromJson(Map<String, dynamic> json) {
    return Chalani(
      date: json['date'],
      snNumber: json['snNumber'],
      fiscalYear: json['fiscalYear'],
      outgoingInstitutionName: json['outgoingInstitutionName'],
      subject: json['subject'],
      imageBase64: json['imageBase64'],
    );
  }
}
