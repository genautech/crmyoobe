import 'package:hive/hive.dart';

part 'quote.g.dart';

enum QuoteStatus {
  requested,      // Orçamento solicitado
  sent,          // Orçamento enviado
  approved,      // Orçamento aprovado
  cancelled,     // Orçamento cancelado
  pending,       // Cliente não decidiu ainda
}

@HiveType(typeId: 4)
class QuoteItem {
  @HiveField(0)
  String productId;

  @HiveField(1)
  String productName;

  @HiveField(2)
  String description;

  @HiveField(3)
  int quantity;

  @HiveField(4)
  double unitPrice;

  @HiveField(5)
  double discount;

  QuoteItem({
    required this.productId,
    required this.productName,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0.0,
  });

  double get subtotal => quantity * unitPrice;
  double get discountAmount => subtotal * (discount / 100);
  double get total => subtotal - discountAmount;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

@HiveType(typeId: 5)
class Quote extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String customerName;

  @HiveField(3)
  List<QuoteItem> items;

  @HiveField(4)
  String status;

  @HiveField(5)
  DateTime quoteDate;

  @HiveField(6)
  DateTime validUntil;

  @HiveField(7)
  double subtotal;

  @HiveField(8)
  double discount;

  @HiveField(9)
  double tax;

  @HiveField(10)
  double total;

  @HiveField(11)
  String notes;

  @HiveField(12)
  String termsAndConditions;

  @HiveField(13)
  DateTime createdAt;

  @HiveField(14)
  DateTime updatedAt;

  Quote({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    this.status = 'draft',
    DateTime? quoteDate,
    DateTime? validUntil,
    double? subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    double? total,
    this.notes = '',
    this.termsAndConditions = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : quoteDate = quoteDate ?? DateTime.now(),
        validUntil = validUntil ?? DateTime.now().add(const Duration(days: 30)),
        subtotal = subtotal ?? _calculateSubtotal(items),
        total = total ?? _calculateTotal(items, discount, tax),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static double _calculateSubtotal(List<QuoteItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  static double _calculateTotal(
      List<QuoteItem> items, double discount, double tax) {
    double subtotal = _calculateSubtotal(items);
    double itemDiscounts =
        items.fold(0.0, (sum, item) => sum + item.discountAmount);
    double afterItemDiscounts = subtotal - itemDiscounts;
    double afterGeneralDiscount = afterItemDiscounts - discount;
    double taxAmount = afterGeneralDiscount * (tax / 100);
    return afterGeneralDiscount + taxAmount;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'quoteDate': quoteDate.toIso8601String(),
      'validUntil': validUntil.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      items: (json['items'] as List)
          .map((item) => QuoteItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'draft',
      quoteDate: DateTime.parse(json['quoteDate'] as String),
      validUntil: DateTime.parse(json['validUntil'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      termsAndConditions: json['termsAndConditions'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
