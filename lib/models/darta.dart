import 'package:hive/hive.dart';

part 'darta.g.dart'; // This will be generated

@HiveType(typeId: 1)
class Darta extends HiveObject {
  @HiveField(0)
  final String date; // Date as a string

  @HiveField(1)
  final String snNumber;

  @HiveField(2)
  final String fiscalYear;

  @HiveField(3)
  final String incomingInstitutionName;

  @HiveField(4)
  final String subject;

  @HiveField(5)
  String? imageBase64; // Store the image as a base64 string

  @HiveField(6)
  String? type;

  Darta(
      {required this.date,
      required this.snNumber,
      required this.fiscalYear,
      required this.incomingInstitutionName,
      required this.subject,
      this.imageBase64,
      this.type});
  Map<String, dynamic> toJson() {
    return {
      'snNumber': snNumber,
      'date': date,
      'fiscalYear': fiscalYear,
      'subject': subject,
      'incomingInstitutionName': incomingInstitutionName,
      'imageBase64': imageBase64,
      'type': type
    };
  }

  factory Darta.fromJson(Map<String, dynamic> json) {
    return Darta(
      date: json['date'],
      snNumber: json['snNumber'],
      fiscalYear: json['fiscalYear'],
      incomingInstitutionName: json['incomingInstitutionName'],
      subject: json['subject'],
      imageBase64: json['imageBase64'],
      type: json['type'],
    );
  }
}
