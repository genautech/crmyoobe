// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 6;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      price: fields[4] as double,
      sku: fields[5] as String,
      stock: fields[6] as int,
      imageUrl: fields[7] as String,
      isAvailable: fields[8] as bool,
      brand: fields[11] as String,
      colors: (fields[12] as List).cast<String>(),
      sizes: (fields[13] as List).cast<String>(),
      material: fields[14] as String,
      weight: fields[15] as double,
      dimensions: fields[16] as String,
      minimumOrderQuantity: fields[17] as int,
      costPrice: fields[18] as double,
      tags: (fields[19] as List).cast<String>(),
      supplier: fields[20] as String,
      leadTimeDays: fields[21] as int,
      printingArea: fields[22] as String,
      printingMethods: (fields[23] as List).cast<String>(),
      barcode: fields[24] as String,
      origin: fields[25] as String,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.sku)
      ..writeByte(6)
      ..write(obj.stock)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.isAvailable)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.brand)
      ..writeByte(12)
      ..write(obj.colors)
      ..writeByte(13)
      ..write(obj.sizes)
      ..writeByte(14)
      ..write(obj.material)
      ..writeByte(15)
      ..write(obj.weight)
      ..writeByte(16)
      ..write(obj.dimensions)
      ..writeByte(17)
      ..write(obj.minimumOrderQuantity)
      ..writeByte(18)
      ..write(obj.costPrice)
      ..writeByte(19)
      ..write(obj.tags)
      ..writeByte(20)
      ..write(obj.supplier)
      ..writeByte(21)
      ..write(obj.leadTimeDays)
      ..writeByte(22)
      ..write(obj.printingArea)
      ..writeByte(23)
      ..write(obj.printingMethods)
      ..writeByte(24)
      ..write(obj.barcode)
      ..writeByte(25)
      ..write(obj.origin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
