import 'package:hive/hive.dart';

part 'darta.g.dart'; // This will be generated

@HiveType(typeId: 1)
class Darta extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final String snNumber;

  @HiveField(2)
  final String fiscalYear;

  @HiveField(3)
  final String incomingInstitutionName;

  @HiveField(4)
  final String subject;

  @HiveField(5)
  final String filePath;
  @HiveField(6)
  final String fileType;

  Darta({
    required this.date,
    required this.snNumber,
    required this.fiscalYear,
    required this.incomingInstitutionName,
    required this.subject,
    required this.filePath,
    required this.fileType,
  });
}
