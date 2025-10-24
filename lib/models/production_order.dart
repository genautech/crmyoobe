import 'package:hive/hive.dart';
import 'order.dart';

part 'production_order.g.dart';

enum ProductionStatus {
  ocCriada,              // OC criada
  produtoPago,           // Produto pago
  producaoIniciada,      // Produção iniciada
  amostraSolicitada,     // Amostra solicitada
  amostraRecebida,       // Amostra recebida
  produtoAprovado,       // Produto aprovado pelo cliente
  produtoRejeitado,      // Produto rejeitado
  produtoEmProducao,     // Produto em produção
  produtoDespachado,     // Produto despachado para logística
}

extension ProductionStatusExtension on ProductionStatus {
  String get displayName {
    switch (this) {
      case ProductionStatus.ocCriada:
        return 'OC Criada';
      case ProductionStatus.produtoPago:
        return 'Produto Pago';
      case ProductionStatus.producaoIniciada:
        return 'Produção Iniciada';
      case ProductionStatus.amostraSolicitada:
        return 'Amostra Solicitada';
      case ProductionStatus.amostraRecebida:
        return 'Amostra Recebida';
      case ProductionStatus.produtoAprovado:
        return 'Produto Aprovado';
      case ProductionStatus.produtoRejeitado:
        return 'Produto Rejeitado';
      case ProductionStatus.produtoEmProducao:
        return 'Em Produção';
      case ProductionStatus.produtoDespachado:
        return 'Despachado';
    }
  }

  String get statusColor {
    switch (this) {
      case ProductionStatus.ocCriada:
        return '#6366F1'; // Indigo
      case ProductionStatus.produtoPago:
        return '#10B981'; // Green
      case ProductionStatus.producaoIniciada:
        return '#3B82F6'; // Blue
      case ProductionStatus.amostraSolicitada:
        return '#F59E0B'; // Amber
      case ProductionStatus.amostraRecebida:
        return '#8B5CF6'; // Purple
      case ProductionStatus.produtoAprovado:
        return '#10B981'; // Green
      case ProductionStatus.produtoRejeitado:
        return '#EF4444'; // Red
      case ProductionStatus.produtoEmProducao:
        return '#0EA5E9'; // Sky
      case ProductionStatus.produtoDespachado:
        return '#22C55E'; // Lime
    }
  }
}

@HiveType(typeId: 7)
class ProductionOrderItem {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  @HiveField(4)
  String specifications;

  @HiveField(5)
  String printingDetails;

  @HiveField(6)
  String color;

  @HiveField(7)
  String size;

  ProductionOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.specifications = '',
    this.printingDetails = '',
    this.color = '',
    this.size = '',
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'specifications': specifications,
      'printingDetails': printingDetails,
      'color': color,
      'size': size,
    };
  }

  factory ProductionOrderItem.fromJson(Map<String, dynamic> json) {
    return ProductionOrderItem(
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      specifications: json['specifications'] as String? ?? '',
      printingDetails: json['printingDetails'] as String? ?? '',
      color: json['color'] as String? ?? '',
      size: json['size'] as String? ?? '',
    );
  }

  factory ProductionOrderItem.fromOrderItem(OrderItem item) {
    return ProductionOrderItem(
      productId: item.productId,
      productName: item.productName,
      quantity: item.quantity,
      price: item.price,
    );
  }
}

@HiveType(typeId: 8)
class ProductionOrder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productionOrderNumber;

  @HiveField(2)
  String orderId;

  @HiveField(3)
  String quoteId;

  @HiveField(4)
  String customerId;

  @HiveField(5)
  String customerName;

  @HiveField(6)
  String customerCompany;

  @HiveField(7)
  List<ProductionOrderItem> items;

  @HiveField(8)
  String status;

  @HiveField(9)
  DateTime productionDate;

  @HiveField(10)
  DateTime? deliveryDeadline;

  @HiveField(11)
  String dispatchAddress;

  @HiveField(12)
  String dispatchCity;

  @HiveField(13)
  String dispatchState;

  @HiveField(14)
  String dispatchZipCode;

  @HiveField(15)
  double totalAmount;

  @HiveField(16)
  String supplierName;

  @HiveField(17)
  String campaignName;

  @HiveField(18)
  String notes;

  @HiveField(19)
  String internalNotes;

  @HiveField(20)
  DateTime createdAt;

  @HiveField(21)
  DateTime updatedAt;

  @HiveField(22)
  DateTime? sampleRequestDate;

  @HiveField(23)
  DateTime? sampleReceivedDate;

  @HiveField(24)
  DateTime? approvalDate;

  @HiveField(25)
  DateTime? dispatchDate;

  ProductionOrder({
    required this.id,
    required this.productionOrderNumber,
    this.orderId = '',
    this.quoteId = '',
    required this.customerId,
    required this.customerName,
    this.customerCompany = '',
    required this.items,
    this.status = 'ocCriada',
    DateTime? productionDate,
    this.deliveryDeadline,
    required this.dispatchAddress,
    this.dispatchCity = '',
    this.dispatchState = '',
    this.dispatchZipCode = '',
    double? totalAmount,
    this.supplierName = '',
    this.campaignName = '',
    this.notes = '',
    this.internalNotes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sampleRequestDate,
    this.sampleReceivedDate,
    this.approvalDate,
    this.dispatchDate,
  })  : productionDate = productionDate ?? DateTime.now(),
        totalAmount = totalAmount ?? _calculateTotal(items),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static double _calculateTotal(List<ProductionOrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  ProductionStatus get productionStatus {
    try {
      return ProductionStatus.values.firstWhere(
        (e) => e.toString() == 'ProductionStatus.$status',
        orElse: () => ProductionStatus.ocCriada,
      );
    } catch (e) {
      return ProductionStatus.ocCriada;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productionOrderNumber': productionOrderNumber,
      'orderId': orderId,
      'quoteId': quoteId,
      'customerId': customerId,
      'customerName': customerName,
      'customerCompany': customerCompany,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'productionDate': productionDate.toIso8601String(),
      'deliveryDeadline': deliveryDeadline?.toIso8601String(),
      'dispatchAddress': dispatchAddress,
      'dispatchCity': dispatchCity,
      'dispatchState': dispatchState,
      'dispatchZipCode': dispatchZipCode,
      'totalAmount': totalAmount,
      'supplierName': supplierName,
      'campaignName': campaignName,
      'notes': notes,
      'internalNotes': internalNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sampleRequestDate': sampleRequestDate?.toIso8601String(),
      'sampleReceivedDate': sampleReceivedDate?.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'dispatchDate': dispatchDate?.toIso8601String(),
    };
  }

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      id: json['id'] as String? ?? '',
      productionOrderNumber: json['productionOrderNumber'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      quoteId: json['quoteId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerCompany: json['customerCompany'] as String? ?? '',
      items: (json['items'] as List?)
              ?.map((item) =>
                  ProductionOrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? 'ocCriada',
      productionDate: json['productionDate'] != null
          ? DateTime.parse(json['productionDate'] as String)
          : DateTime.now(),
      deliveryDeadline: json['deliveryDeadline'] != null
          ? DateTime.parse(json['deliveryDeadline'] as String)
          : null,
      dispatchAddress: json['dispatchAddress'] as String? ?? '',
      dispatchCity: json['dispatchCity'] as String? ?? '',
      dispatchState: json['dispatchState'] as String? ?? '',
      dispatchZipCode: json['dispatchZipCode'] as String? ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      supplierName: json['supplierName'] as String? ?? '',
      campaignName: json['campaignName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      internalNotes: json['internalNotes'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      sampleRequestDate: json['sampleRequestDate'] != null
          ? DateTime.parse(json['sampleRequestDate'] as String)
          : null,
      sampleReceivedDate: json['sampleReceivedDate'] != null
          ? DateTime.parse(json['sampleReceivedDate'] as String)
          : null,
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      dispatchDate: json['dispatchDate'] != null
          ? DateTime.parse(json['dispatchDate'] as String)
          : null,
    );
  }

  factory ProductionOrder.fromOrder(Order order, String customerCompany, String dispatchAddress) {
    final poNumber = 'PO-${DateTime.now().millisecondsSinceEpoch}';
    return ProductionOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productionOrderNumber: poNumber,
      orderId: order.id,
      customerId: order.customerId,
      customerName: order.customerName,
      customerCompany: customerCompany,
      items: order.items
          .map((item) => ProductionOrderItem.fromOrderItem(item))
          .toList(),
      deliveryDeadline: order.deliveryDate,
      dispatchAddress: dispatchAddress,
      totalAmount: order.totalAmount,
      supplierName: order.supplierName,
      campaignName: order.campaignName,
      notes: order.notes,
    );
  }
}
