// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplierAdapter extends TypeAdapter<Supplier> {
  @override
  final int typeId = 14;

  @override
  Supplier read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Supplier(
      id: fields[0] as String,
      name: fields[1] as String,
      company: fields[2] as String,
      cnpj: fields[3] as String,
      phone: fields[4] as String,
      email: fields[5] as String,
      address: fields[6] as String,
      city: fields[7] as String,
      state: fields[8] as String,
      zipCode: fields[9] as String,
      category: fields[10] as String,
      paymentTerms: fields[11] as String,
      leadTimeDays: fields[12] as int,
      rating: fields[13] as double,
      notes: fields[14] as String,
      isActive: fields[15] as bool,
      createdAt: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
      bankName: fields[18] as String,
      bankAccount: fields[19] as String,
      pixKey: fields[20] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Supplier obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.company)
      ..writeByte(3)
      ..write(obj.cnpj)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.city)
      ..writeByte(8)
      ..write(obj.state)
      ..writeByte(9)
      ..write(obj.zipCode)
      ..writeByte(10)
      ..write(obj.category)
      ..writeByte(11)
      ..write(obj.paymentTerms)
      ..writeByte(12)
      ..write(obj.leadTimeDays)
      ..writeByte(13)
      ..write(obj.rating)
      ..writeByte(14)
      ..write(obj.notes)
      ..writeByte(15)
      ..write(obj.isActive)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt)
      ..writeByte(18)
      ..write(obj.bankName)
      ..writeByte(19)
      ..write(obj.bankAccount)
      ..writeByte(20)
      ..write(obj.pixKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
