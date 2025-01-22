// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitorAdapter extends TypeAdapter<Visitor> {
  @override
  final int typeId = 0;

  @override
  Visitor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Visitor(
      eventsId: fields[0] as String,
      uniqueId: fields[1] as String,
      name: fields[2] as String,
      designation: fields[3] as String,
      gate: fields[4] as String?,
      deviceId: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Visitor obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.eventsId)
      ..writeByte(1)
      ..write(obj.uniqueId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.designation)
      ..writeByte(4)
      ..write(obj.gate)
      ..writeByte(5)
      ..write(obj.deviceId)
      ..writeByte(6)
      ..write(obj.entryDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
