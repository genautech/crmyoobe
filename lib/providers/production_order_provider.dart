import 'package:flutter/foundation.dart';
import '../models/production_order.dart';
import '../services/storage_service.dart';

class ProductionOrderProvider extends ChangeNotifier {
  List<ProductionOrder> _productionOrders = [];

  List<ProductionOrder> get productionOrders => _productionOrders;

  ProductionOrderProvider() {
    _loadProductionOrders();
  }

  Future<void> _loadProductionOrders() async {
    try {
      final box = await StorageService.getProductionOrderBox();
      _productionOrders = box.values.toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Error loading production orders: $e');
        debugPrint('💡 Clearing production orders box and restarting...');
      }
      try {
        final box = await StorageService.getProductionOrderBox();
        await box.clear();
        _productionOrders = [];
        notifyListeners();
      } catch (clearError) {
        if (kDebugMode) {
          debugPrint('❌ Error clearing production orders box: $clearError');
        }
      }
    }
  }

  ProductionOrder? getProductionOrder(String id) {
    try {
      return _productionOrders.firstWhere((po) => po.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductionOrder> getProductionOrdersByStatus(String status) {
    return _productionOrders.where((po) => po.status == status).toList();
  }

  List<ProductionOrder> getProductionOrdersByCustomer(String customerId) {
    return _productionOrders.where((po) => po.customerId == customerId).toList();
  }

  List<ProductionOrder> searchProductionOrders(String query) {
    final lowerQuery = query.toLowerCase();
    return _productionOrders.where((po) {
      return po.productionOrderNumber.toLowerCase().contains(lowerQuery) ||
          po.customerName.toLowerCase().contains(lowerQuery) ||
          po.customerCompany.toLowerCase().contains(lowerQuery) ||
          po.campaignName.toLowerCase().contains(lowerQuery) ||
          po.supplierName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Map<String, int> getStatusCounts() {
    final counts = <String, int>{};
    for (final status in ProductionStatus.values) {
      final statusString = status.toString().split('.').last;
      counts[statusString] = _productionOrders
          .where((po) => po.status == statusString)
          .length;
    }
    return counts;
  }

  Future<void> addProductionOrder(ProductionOrder productionOrder) async {
    final box = await StorageService.getProductionOrderBox();
    await box.put(productionOrder.id, productionOrder);
    await _loadProductionOrders();
  }

  Future<void> updateProductionOrder(ProductionOrder productionOrder) async {
    final box = await StorageService.getProductionOrderBox();
    productionOrder.updatedAt = DateTime.now();
    await box.put(productionOrder.id, productionOrder);
    await _loadProductionOrders();
  }

  Future<void> deleteProductionOrder(String id) async {
    final box = await StorageService.getProductionOrderBox();
    await box.delete(id);
    await _loadProductionOrders();
  }

  Future<void> updateStatus(String id, String newStatus, {DateTime? statusDate}) async {
    final productionOrder = getProductionOrder(id);
    if (productionOrder == null) return;

    productionOrder.status = newStatus;
    productionOrder.updatedAt = DateTime.now();

    // Update specific date fields based on status
    switch (newStatus) {
      case 'amostraSolicitada':
        productionOrder.sampleRequestDate = statusDate ?? DateTime.now();
        break;
      case 'amostraRecebida':
        productionOrder.sampleReceivedDate = statusDate ?? DateTime.now();
        break;
      case 'produtoAprovado':
        productionOrder.approvalDate = statusDate ?? DateTime.now();
        break;
      case 'produtoDespachado':
        productionOrder.dispatchDate = statusDate ?? DateTime.now();
        break;
    }

    await updateProductionOrder(productionOrder);
  }

  Future<void> clearAll() async {
    final box = await StorageService.getProductionOrderBox();
    await box.clear();
    await _loadProductionOrders();
  }
}
