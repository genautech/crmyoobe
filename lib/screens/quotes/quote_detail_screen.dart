import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/quote.dart';
import '../../models/order.dart';
import '../../models/production_order.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/production_order_provider.dart';
import 'quote_form_screen.dart';

class QuoteDetailScreen extends StatelessWidget {
  final Quote quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final isApproved = quote.status.toLowerCase() == 'approved';
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Orçamento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuoteFormScreen(quote: quote),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orçamento #${quote.id.substring(0, 8)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  quote.customerName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(quote.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getStatusColor(quote.status),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              _getStatusLabel(quote.status),
                              style: TextStyle(
                                color: _getStatusColor(quote.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Data do Orçamento',
                              DateFormat('dd/MM/yyyy').format(quote.quoteDate),
                              Icons.calendar_today,
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              'Válido até',
                              DateFormat('dd/MM/yyyy').format(quote.validUntil),
                              Icons.event_available,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Items Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Itens do Orçamento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...quote.items.map((item) => _buildQuoteItem(item, currencyFormat)),
                      const Divider(height: 24),
                      _buildTotalRow(
                        'Subtotal',
                        currencyFormat.format(quote.subtotal),
                        false,
                      ),
                      if (quote.discount > 0)
                        _buildTotalRow(
                          'Desconto',
                          '- ${currencyFormat.format(quote.discount)}',
                          false,
                          color: Colors.red,
                        ),
                      if (quote.tax > 0)
                        _buildTotalRow(
                          'Impostos (${quote.tax}%)',
                          currencyFormat.format(quote.subtotal * (quote.tax / 100)),
                          false,
                        ),
                      const Divider(height: 16),
                      _buildTotalRow(
                        'Total',
                        currencyFormat.format(quote.total),
                        true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Notes Card
              if (quote.notes.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Observações',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          quote.notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Convert to Order Button
              if (isApproved)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _convertToOrder(context),
                    icon: const Icon(Icons.shopping_cart, size: 24),
                    label: const Text(
                      'Converter para Pedido',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

              // Multi-Supplier Production Order Creation
              if (isApproved) ..._buildMultiSupplierProductionButtons(context),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuoteItem(QuoteItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (item.supplier.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_shipping, size: 12, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              item.supplier,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (item.discount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${item.discount.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (item.discount > 0) ...[
                const SizedBox(height: 2),
                Text(
                  currencyFormat.format(item.subtotal),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, bool isBold, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 20 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isBold ? Colors.green : null),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'sent':
        return Colors.blue;
      case 'requested':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'Solicitado';
      case 'sent':
        return 'Enviado';
      case 'approved':
        return 'Aprovado';
      case 'cancelled':
        return 'Cancelado';
      case 'pending':
        return 'Cliente não decidiu';
      default:
        return status;
    }
  }

  List<Widget> _buildMultiSupplierProductionButtons(BuildContext context) {
    // Get unique suppliers from quote items
    final suppliers = quote.items
        .where((item) => item.supplier.isNotEmpty)
        .map((item) => item.supplier)
        .toSet()
        .toList();

    if (suppliers.isEmpty) return [];

    return [
      const SizedBox(height: 16),
      Card(
        elevation: 3,
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.factory, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Text(
                    'Criar Ordens de Produção por Fornecedor',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Este orçamento tem ${suppliers.length} fornecedor${suppliers.length > 1 ? 'es' : ''}. Crie ordens de produção separadas:',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              ...suppliers.map((supplier) {
                final supplierItems = quote.items
                    .where((item) => item.supplier == supplier)
                    .toList();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _createProductionOrderForSupplier(context, supplier),
                    icon: const Icon(Icons.local_shipping, size: 18),
                    label: Text(
                      '$supplier (${supplierItems.length} ${supplierItems.length == 1 ? 'item' : 'itens'})',
                      style: const TextStyle(fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ];
  }

  Future<void> _createProductionOrderForSupplier(BuildContext context, String supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Ordem de Produção'),
        content: Text(
          'Criar ordem de produção para fornecedor "$supplier"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Get customer data
      final customerProvider = context.read<CustomerProvider>();
      final customer = customerProvider.getCustomer(quote.customerId);
      
      if (customer == null) {
        throw Exception('Cliente não encontrado');
      }

      // Filter items by supplier
      final supplierItems = quote.items
          .where((item) => item.supplier == supplier)
          .toList();

      // Create order from quote (will be used to create production order)
      final order = Order.fromQuote(quote);
      
      // Filter order items by supplier
      final filteredOrderItems = order.items
          .where((item) => item.supplier == supplier)
          .toList();
      
      // Create a temporary order with only supplier items
      final supplierOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: order.customerId,
        customerName: order.customerName,
        items: filteredOrderItems,
        status: order.status,
        deliveryDate: order.deliveryDate,
        notes: order.notes,
        campaignName: order.campaignName,
        supplierName: supplier,
        quoteId: quote.id,
        createdAt: DateTime.now(),
      );

      // Create production order from supplier-specific order
      final productionOrder = ProductionOrder.fromOrder(
        supplierOrder,
        customer.company,
        customer.address,
      );

      // Save production order
      await context.read<ProductionOrderProvider>().addProductionOrder(productionOrder);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.factory, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Ordem de produção criada para $supplier!'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erro ao criar ordem: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _convertToOrder(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Converter para Pedido'),
        content: const Text(
          'Deseja converter este orçamento aprovado em um pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Converter'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Create order from quote
      final order = Order.fromQuote(quote);
      
      // Save order
      final orderProvider = context.read<OrderProvider>();
      await orderProvider.addOrder(order);

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Pedido criado com sucesso!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erro ao criar pedido: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
