// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionOrderItemAdapter extends TypeAdapter<ProductionOrderItem> {
  @override
  final int typeId = 7;

  @override
  ProductionOrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionOrderItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      price: fields[3] as double,
      specifications: fields[4] as String,
      printingDetails: fields[5] as String,
      color: fields[6] as String,
      size: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionOrderItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.specifications)
      ..writeByte(5)
      ..write(obj.printingDetails)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.size);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionOrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductionOrderAdapter extends TypeAdapter<ProductionOrder> {
  @override
  final int typeId = 8;

  @override
  ProductionOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionOrder(
      id: fields[0] as String,
      productionOrderNumber: fields[1] as String,
      orderId: fields[2] as String,
      quoteId: fields[3] as String,
      customerId: fields[4] as String,
      customerName: fields[5] as String,
      customerCompany: fields[6] as String,
      items: (fields[7] as List).cast<ProductionOrderItem>(),
      status: fields[8] as String,
      productionDate: fields[9] as DateTime?,
      deliveryDeadline: fields[10] as DateTime?,
      dispatchAddress: fields[11] as String,
      dispatchCity: fields[12] as String,
      dispatchState: fields[13] as String,
      dispatchZipCode: fields[14] as String,
      totalAmount: fields[15] as double?,
      supplierName: fields[16] as String,
      campaignName: fields[17] as String,
      notes: fields[18] as String,
      internalNotes: fields[19] as String,
      createdAt: fields[20] as DateTime?,
      updatedAt: fields[21] as DateTime?,
      sampleRequestDate: fields[22] as DateTime?,
      sampleReceivedDate: fields[23] as DateTime?,
      approvalDate: fields[24] as DateTime?,
      dispatchDate: fields[25] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionOrder obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productionOrderNumber)
      ..writeByte(2)
      ..write(obj.orderId)
      ..writeByte(3)
      ..write(obj.quoteId)
      ..writeByte(4)
      ..write(obj.customerId)
      ..writeByte(5)
      ..write(obj.customerName)
      ..writeByte(6)
      ..write(obj.customerCompany)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.productionDate)
      ..writeByte(10)
      ..write(obj.deliveryDeadline)
      ..writeByte(11)
      ..write(obj.dispatchAddress)
      ..writeByte(12)
      ..write(obj.dispatchCity)
      ..writeByte(13)
      ..write(obj.dispatchState)
      ..writeByte(14)
      ..write(obj.dispatchZipCode)
      ..writeByte(15)
      ..write(obj.totalAmount)
      ..writeByte(16)
      ..write(obj.supplierName)
      ..writeByte(17)
      ..write(obj.campaignName)
      ..writeByte(18)
      ..write(obj.notes)
      ..writeByte(19)
      ..write(obj.internalNotes)
      ..writeByte(20)
      ..write(obj.createdAt)
      ..writeByte(21)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.sampleRequestDate)
      ..writeByte(23)
      ..write(obj.sampleReceivedDate)
      ..writeByte(24)
      ..write(obj.approvalDate)
      ..writeByte(25)
      ..write(obj.dispatchDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
