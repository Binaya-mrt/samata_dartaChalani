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
  final String filePath;
  @HiveField(6)
  final String fileType;

  Chalani({
    required this.date,
    required this.snNumber,
    required this.fiscalYear,
    required this.outgoingInstitutionName,
    required this.subject,
    required this.filePath,
    required this.fileType,
  });
}
