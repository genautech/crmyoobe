// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuoteItemAdapter extends TypeAdapter<QuoteItem> {
  @override
  final int typeId = 4;

  @override
  QuoteItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuoteItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      description: fields[2] as String,
      quantity: fields[3] as int,
      unitPrice: fields[4] as double,
      discount: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, QuoteItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.discount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuoteAdapter extends TypeAdapter<Quote> {
  @override
  final int typeId = 5;

  @override
  Quote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Quote(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      items: (fields[3] as List).cast<QuoteItem>(),
      status: fields[4] as String,
      quoteDate: fields[5] as DateTime?,
      validUntil: fields[6] as DateTime?,
      subtotal: fields[7] as double?,
      discount: fields[8] as double,
      tax: fields[9] as double,
      total: fields[10] as double?,
      notes: fields[11] as String,
      termsAndConditions: fields[12] as String,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Quote obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.quoteDate)
      ..writeByte(6)
      ..write(obj.validUntil)
      ..writeByte(7)
      ..write(obj.subtotal)
      ..writeByte(8)
      ..write(obj.discount)
      ..writeByte(9)
      ..write(obj.tax)
      ..writeByte(10)
      ..write(obj.total)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.termsAndConditions)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
