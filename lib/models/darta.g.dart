// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'darta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DartaAdapter extends TypeAdapter<Darta> {
  @override
  final int typeId = 1;

  @override
  Darta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Darta(
      date: fields[0] as String,
      snNumber: fields[1] as String,
      fiscalYear: fields[2] as String,
      incomingInstitutionName: fields[3] as String,
      subject: fields[4] as String,
      filePath: fields[5] as String?,
      fileType: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Darta obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.snNumber)
      ..writeByte(2)
      ..write(obj.fiscalYear)
      ..writeByte(3)
      ..write(obj.incomingInstitutionName)
      ..writeByte(4)
      ..write(obj.subject)
      ..writeByte(5)
      ..write(obj.filePath)
      ..writeByte(6)
      ..write(obj.fileType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DartaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
