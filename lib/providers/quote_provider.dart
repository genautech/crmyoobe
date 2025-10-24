import 'package:flutter/foundation.dart';
import '../models/quote.dart';
import '../services/storage_service.dart';

class QuoteProvider with ChangeNotifier {
  List<Quote> _quotes = [];

  List<Quote> get quotes => _quotes;

  QuoteProvider() {
    loadQuotes();
  }

  void loadQuotes() {
    final box = StorageService.getQuotesBox();
    _quotes = box.values.toList();
    // Sort by quote date (newest first)
    _quotes.sort((a, b) => b.quoteDate.compareTo(a.quoteDate));
    notifyListeners();
  }

  Future<void> addQuote(Quote quote) async {
    final box = StorageService.getQuotesBox();
    await box.put(quote.id, quote);
    loadQuotes();
  }

  Future<void> updateQuote(Quote quote) async {
    quote.updatedAt = DateTime.now();
    final box = StorageService.getQuotesBox();
    await box.put(quote.id, quote);
    loadQuotes();
  }

  Future<void> deleteQuote(String id) async {
    final box = StorageService.getQuotesBox();
    await box.delete(id);
    loadQuotes();
  }

  Future<void> updateQuoteStatus(String id, String newStatus) async {
    final quote = _quotes.firstWhere((q) => q.id == id);
    quote.status = newStatus;
    await updateQuote(quote);
  }

  List<Quote> getQuotesByCustomer(String customerId) {
    return _quotes.where((quote) => quote.customerId == customerId).toList();
  }

  List<Quote> getQuotesByStatus(String status) {
    return _quotes.where((quote) => quote.status == status).toList();
  }

  List<Quote> getExpiredQuotes() {
    final now = DateTime.now();
    return _quotes.where((quote) => 
      quote.validUntil.isBefore(now) && quote.status != 'accepted'
    ).toList();
  }

  double getTotalQuotedAmount() {
    return _quotes.fold(0.0, (sum, quote) => sum + quote.total);
  }

  double getAcceptedQuotesAmount() {
    return _quotes
        .where((quote) => quote.status == 'accepted')
        .fold(0.0, (sum, quote) => sum + quote.total);
  }
}
