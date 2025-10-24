import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductProvider() {
    loadProducts();
  }

  void loadProducts() {
    final box = StorageService.getProductsBox();
    _products = box.values.toList();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final box = StorageService.getProductsBox();
    await box.put(product.id, product);
    loadProducts();
  }

  Future<void> updateProduct(Product product) async {
    product.updatedAt = DateTime.now();
    final box = StorageService.getProductsBox();
    await box.put(product.id, product);
    loadProducts();
  }

  Future<void> deleteProduct(String id) async {
    final box = StorageService.getProductsBox();
    await box.delete(id);
    loadProducts();
  }

  Product? getProduct(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    final lowerQuery = query.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerQuery) ||
             product.description.toLowerCase().contains(lowerQuery) ||
             product.category.toLowerCase().contains(lowerQuery) ||
             product.sku.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<Product> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  List<String> getAllCategories() {
    return _products.map((p) => p.category).toSet().toList()..sort();
  }
}
