import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/storage_service.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];

  List<Order> get orders => _orders;

  OrderProvider() {
    loadOrders();
  }

  void loadOrders() {
    try {
      final box = StorageService.getOrdersBox();
      _orders = box.values.toList();
      // Sort by order date (newest first)
      _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error loading orders (possibly due to schema change): $e');
        debugPrint('💡 Clearing orders box and restarting...');
      }
      // Clear corrupted data and restart
      try {
        final box = StorageService.getOrdersBox();
        box.clear();
        _orders = [];
        notifyListeners();
      } catch (clearError) {
        if (kDebugMode) {
          debugPrint('❌ Error clearing orders box: $clearError');
        }
      }
    }
  }

  Future<void> addOrder(Order order) async {
    final box = StorageService.getOrdersBox();
    await box.put(order.id, order);
    loadOrders();
  }

  Future<void> updateOrder(Order order) async {
    order.updatedAt = DateTime.now();
    final box = StorageService.getOrdersBox();
    await box.put(order.id, order);
    loadOrders();
  }

  Future<void> deleteOrder(String id) async {
    final box = StorageService.getOrdersBox();
    await box.delete(id);
    loadOrders();
  }

  Future<void> updateOrderStatus(String id, String newStatus) async {
    final order = _orders.firstWhere((o) => o.id == id);
    order.status = newStatus;
    await updateOrder(order);
  }

  List<Order> getOrdersByCustomer(String customerId) {
    return _orders.where((order) => order.customerId == customerId).toList();
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  double getTotalRevenue() {
    return _orders.fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  double getRevenueByStatus(String status) {
    return _orders
        .where((order) => order.status == status)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }
}
