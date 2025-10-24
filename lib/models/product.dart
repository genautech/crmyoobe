import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 6)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  double price;

  @HiveField(5)
  String sku;

  @HiveField(6)
  int stock;

  @HiveField(7)
  String imageUrl;

  @HiveField(8)
  bool isAvailable;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  DateTime updatedAt;

  // New fields for comprehensive product management
  @HiveField(11)
  String brand;

  @HiveField(12)
  List<String> colors;

  @HiveField(13)
  List<String> sizes;

  @HiveField(14)
  String material;

  @HiveField(15)
  double weight;

  @HiveField(16)
  String dimensions; // "10x5x2 cm"

  @HiveField(17)
  int minimumOrderQuantity;

  @HiveField(18)
  double costPrice;

  @HiveField(19)
  List<String> tags;

  @HiveField(20)
  String supplier;

  @HiveField(21)
  int leadTimeDays;

  @HiveField(22)
  String printingArea;

  @HiveField(23)
  List<String> printingMethods;

  @HiveField(24)
  String barcode;

  @HiveField(25)
  String origin;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.sku,
    this.stock = 0,
    this.imageUrl = '',
    this.isAvailable = true,
    this.brand = '',
    this.colors = const [],
    this.sizes = const [],
    this.material = '',
    this.weight = 0.0,
    this.dimensions = '',
    this.minimumOrderQuantity = 1,
    this.costPrice = 0.0,
    this.tags = const [],
    this.supplier = '',
    this.leadTimeDays = 0,
    this.printingArea = '',
    this.printingMethods = const [],
    this.barcode = '',
    this.origin = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'sku': sku,
      'stock': stock,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'brand': brand,
      'colors': colors,
      'sizes': sizes,
      'material': material,
      'weight': weight,
      'dimensions': dimensions,
      'minimumOrderQuantity': minimumOrderQuantity,
      'costPrice': costPrice,
      'tags': tags,
      'supplier': supplier,
      'leadTimeDays': leadTimeDays,
      'printingArea': printingArea,
      'printingMethods': printingMethods,
      'barcode': barcode,
      'origin': origin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      sku: json['sku'] as String,
      stock: json['stock'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      brand: json['brand'] as String? ?? '',
      colors: (json['colors'] as List?)?.cast<String>() ?? [],
      sizes: (json['sizes'] as List?)?.cast<String>() ?? [],
      material: json['material'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: json['dimensions'] as String? ?? '',
      minimumOrderQuantity: json['minimumOrderQuantity'] as int? ?? 1,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      tags: (json['tags'] as List?)?.cast<String>() ?? [],
      supplier: json['supplier'] as String? ?? '',
      leadTimeDays: json['leadTimeDays'] as int? ?? 0,
      printingArea: json['printingArea'] as String? ?? '',
      printingMethods: (json['printingMethods'] as List?)?.cast<String>() ?? [],
      barcode: json['barcode'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
