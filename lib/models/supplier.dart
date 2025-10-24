import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 14)
class Supplier extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String company;

  @HiveField(3)
  String cnpj;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String email;

  @HiveField(6)
  String address;

  @HiveField(7)
  String city;

  @HiveField(8)
  String state;

  @HiveField(9)
  String zipCode;

  @HiveField(10)
  String category; // Categoria de produtos que fornece

  @HiveField(11)
  String paymentTerms; // Condições de pagamento

  @HiveField(12)
  int leadTimeDays; // Prazo médio de produção em dias

  @HiveField(13)
  double rating; // Avaliação (0-5)

  @HiveField(14)
  String notes;

  @HiveField(15)
  bool isActive;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  DateTime updatedAt;

  @HiveField(18)
  String bankName;

  @HiveField(19)
  String bankAccount;

  @HiveField(20)
  String pixKey;

  Supplier({
    required this.id,
    required this.name,
    this.company = '',
    this.cnpj = '',
    required this.phone,
    required this.email,
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.category = '',
    this.paymentTerms = '',
    this.leadTimeDays = 15,
    this.rating = 0.0,
    this.notes = '',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.bankName = '',
    this.bankAccount = '',
    this.pixKey = '',
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'cnpj': cnpj,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'category': category,
      'paymentTerms': paymentTerms,
      'leadTimeDays': leadTimeDays,
      'rating': rating,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'bankName': bankName,
      'bankAccount': bankAccount,
      'pixKey': pixKey,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as String,
      name: json['name'] as String,
      company: json['company'] as String? ?? '',
      cnpj: json['cnpj'] as String? ?? '',
      phone: json['phone'] as String,
      email: json['email'] as String,
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      category: json['category'] as String? ?? '',
      paymentTerms: json['paymentTerms'] as String? ?? '',
      leadTimeDays: json['leadTimeDays'] as int? ?? 15,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      bankName: json['bankName'] as String? ?? '',
      bankAccount: json['bankAccount'] as String? ?? '',
      pixKey: json['pixKey'] as String? ?? '',
    );
  }

  String get displayName => company.isNotEmpty ? '$name - $company' : name;
  
  String get location {
    final parts = <String>[];
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  String get formattedCnpj {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }
}
