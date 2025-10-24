import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/production_order.dart';
import '../../providers/production_order_provider.dart';
import 'production_order_form_screen.dart';

class ProductionOrdersListScreen extends StatefulWidget {
  const ProductionOrdersListScreen({super.key});

  @override
  State<ProductionOrdersListScreen> createState() =>
      _ProductionOrdersListScreenState();
}

class _ProductionOrdersListScreenState
    extends State<ProductionOrdersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    final productionStatus = ProductionStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => ProductionStatus.ocCriada,
    );
    
    final colorHex = productionStatus.statusColor.replaceAll('#', '');
    return Color(int.parse('FF$colorHex', radix: 16));
  }

  String _getStatusDisplayName(String status) {
    final productionStatus = ProductionStatus.values.firstWhere(
      (e) => e.toString().split('.').last == status,
      orElse: () => ProductionStatus.ocCriada,
    );
    return productionStatus.displayName;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductionOrderProvider>();
    List<ProductionOrder> productionOrders = provider.productionOrders;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      productionOrders = provider.searchProductionOrders(_searchQuery);
    }

    // Apply status filter
    if (_filterStatus != 'all') {
      productionOrders = productionOrders
          .where((po) => po.status == _filterStatus)
          .toList();
    }

    // Sort by date (newest first)
    productionOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Produção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.pushNamed(context, '/production_dashboard');
            },
            tooltip: 'Dashboard de Produção',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por número, cliente, campanha...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

            // Status Filter Chips
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('all', 'Todos', productionOrders.length),
                  const SizedBox(width: 8),
                  ...ProductionStatus.values.map((status) {
                    final statusString = status.toString().split('.').last;
                    final count = provider
                        .getProductionOrdersByStatus(statusString)
                        .length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip(
                        statusString,
                        status.displayName,
                        count,
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Production Orders List
            Expanded(
              child: productionOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: productionOrders.length,
                      itemBuilder: (context, index) {
                        final po = productionOrders[index];
                        return _buildProductionOrderCard(po);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductionOrderFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova OP'),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int count) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = value);
      },
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildProductionOrderCard(ProductionOrder po) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor(po.status);
    final statusDisplayName = _getStatusDisplayName(po.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductionOrderFormScreen(
                productionOrder: po,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusDisplayName,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      po.productionOrderNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.business, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          po.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (po.customerCompany.isNotEmpty)
                          Text(
                            po.customerCompany,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              if (po.campaignName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.campaign, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      po.campaignName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],

              const Divider(height: 24),

              // Items Summary
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${po.items.length} ${po.items.length == 1 ? 'item' : 'itens'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.shopping_cart, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${po.items.fold(0, (sum, item) => sum + item.quantity)} unidades',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Dates
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Criado: ${dateFormat.format(po.createdAt)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (po.deliveryDeadline != null) ...[
                    const SizedBox(width: 16),
                    Icon(Icons.event, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Prazo: ${dateFormat.format(po.deliveryDeadline!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              if (po.supplierName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_shipping, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Fornecedor: ${po.supplierName}',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Total Amount
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withValues(alpha: 0.1),
                      Colors.green.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 18, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Total: R\$ ${po.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'all'
                ? 'Nenhuma OP encontrada'
                : 'Nenhuma ordem de produção',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _filterStatus != 'all'
                ? 'Tente ajustar os filtros'
                : 'Crie uma nova ordem de produção',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
