import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/storage_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];

  List<Customer> get customers => _customers;

  CustomerProvider() {
    loadCustomers();
  }

  void loadCustomers() {
    final box = StorageService.getCustomersBox();
    _customers = box.values.toList();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    final box = StorageService.getCustomersBox();
    await box.put(customer.id, customer);
    loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    final box = StorageService.getCustomersBox();
    await box.put(customer.id, customer);
    loadCustomers();
  }

  Future<void> deleteCustomer(String id) async {
    final box = StorageService.getCustomersBox();
    await box.delete(id);
    loadCustomers();
  }

  Customer? getCustomer(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Customer> searchCustomers(String query) {
    if (query.isEmpty) return _customers;
    
    final lowerQuery = query.toLowerCase();
    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(lowerQuery) ||
             customer.email.toLowerCase().contains(lowerQuery) ||
             customer.company.toLowerCase().contains(lowerQuery) ||
             customer.phone.contains(query);
    }).toList();
  }
}
