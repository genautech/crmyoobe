import 'package:hive/hive.dart';

part 'order.g.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled,
}

@HiveType(typeId: 12)
class OrderItem {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }
}

@HiveType(typeId: 13)
class Order extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  List<OrderItem> items;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime orderDate;

  @HiveField(6)
  DateTime? deliveryDate;

  @HiveField(7)
  double totalAmount;

  @HiveField(8)
  String notes;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  @HiveField(11)
  String campaignName;

  @HiveField(12)
  String supplierName;

  Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    this.status = 'pending',
    DateTime? orderDate,
    this.deliveryDate,
    double? totalAmount,
    this.notes = '',
    this.campaignName = '',
    this.supplierName = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : orderDate = orderDate ?? DateTime.now(),
        totalAmount = totalAmount ?? _calculateTotal(items),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static double _calculateTotal(List<OrderItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'totalAmount': totalAmount,
      'notes': notes,
      'campaignName': campaignName,
      'supplierName': supplierName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'pending',
      orderDate: DateTime.parse(json['orderDate'] as String),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'] as String)
          : null,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      campaignName: json['campaignName'] as String? ?? '',
      supplierName: json['supplierName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
