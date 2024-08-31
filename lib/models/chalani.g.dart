// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chalani.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChalaniAdapter extends TypeAdapter<Chalani> {
  @override
  final int typeId = 3;

  @override
  Chalani read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chalani(
      date: fields[0] as String,
      snNumber: fields[1] as String,
      fiscalYear: fields[2] as String,
      outgoingInstitutionName: fields[3] as String,
      subject: fields[4] as String,
      imageBase64: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Chalani obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.snNumber)
      ..writeByte(2)
      ..write(obj.fiscalYear)
      ..writeByte(3)
      ..write(obj.outgoingInstitutionName)
      ..writeByte(4)
      ..write(obj.subject)
      ..writeByte(5)
      ..write(obj.imageBase64);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChalaniAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
