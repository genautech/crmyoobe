import 'package:hive/hive.dart';

part 'task.g.dart';

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String customerId;

  @HiveField(4)
  String customerName;

  @HiveField(5)
  DateTime dueDate;

  @HiveField(6)
  String status;

  @HiveField(7)
  String priority;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime updatedAt;

  @HiveField(10)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.customerId,
    required this.customerName,
    required this.dueDate,
    this.status = 'pending',
    this.priority = 'medium',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isCompleted = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'customerId': customerId,
      'customerName': customerName,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String? ?? 'pending',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
