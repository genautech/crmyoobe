import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/production_order.dart';
import '../../providers/production_order_provider.dart';
import 'production_order_form_screen.dart';
import 'production_order_detail_screen.dart';

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
  bool _groupByCampaign = true; // NEW: Toggle for campaign grouping

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
            icon: Icon(_groupByCampaign ? Icons.view_list : Icons.view_agenda),
            onPressed: () {
              setState(() => _groupByCampaign = !_groupByCampaign);
            },
            tooltip: _groupByCampaign ? 'Ver Lista Simples' : 'Agrupar por Campanha',
          ),
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
                  : _groupByCampaign
                      ? _buildCampaignGroupedList(productionOrders)
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

  Widget _buildCampaignGroupedList(List<ProductionOrder> orders) {
    // Group orders by campaign
    final campaignGroups = <String, List<ProductionOrder>>{};
    for (final order in orders) {
      final campaign = order.campaignName.isEmpty ? '🔷 Sem Campanha' : order.campaignName;
      campaignGroups.putIfAbsent(campaign, () => []).add(order);
    }

    // Sort campaigns by total value (descending)
    final sortedCampaigns = campaignGroups.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<double>(0, (sum, o) => sum + o.totalAmount);
        final totalB = b.value.fold<double>(0, (sum, o) => sum + o.totalAmount);
        return totalB.compareTo(totalA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCampaigns.length,
      itemBuilder: (context, index) {
        final entry = sortedCampaigns[index];
        final campaign = entry.key;
        final campaignOrders = entry.value;
        
        // Sort orders within campaign by date (newest first)
        campaignOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        final totalValue = campaignOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);
        final totalItems = campaignOrders.fold(0, (sum, o) => sum + o.items.length);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.purple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade600,
                      Colors.purple.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    campaignOrders.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      campaign,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(totalValue)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$totalItems itens',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.local_shipping, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${campaignOrders.where((o) => o.supplierName.isNotEmpty).map((o) => o.supplierName).toSet().length} fornecedores',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              children: campaignOrders.map((po) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: Colors.grey[50],
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductionOrderDetailScreen(order: po),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Number and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.inventory_2, size: 16, color: Colors.grey[700]),
                                      const SizedBox(width: 6),
                                      Text(
                                        po.productionOrderNumber,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(po.status).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _getStatusColor(po.status).withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    _getStatusDisplayName(po.status),
                                    style: TextStyle(
                                      color: _getStatusColor(po.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Customer and Supplier
                            Row(
                              children: [
                                Icon(Icons.person, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    po.customerName,
                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (po.supplierName.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Icon(Icons.local_shipping, size: 14, color: Colors.blue[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    po.supplierName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 6),
                            
                            // Items and Total
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shopping_bag, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${po.items.length} itens',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                Text(
                                  'R\$ ${po.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Deadline Alert if applicable
                            if (po.deliveryDeadline != null)
                              _buildCompactDeadlineAlert(po.deliveryDeadline!),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactDeadlineAlert(DateTime deadline) {
    final now = DateTime.now();
    final daysUntil = deadline.difference(now).inDays;
    
    Color? alertColor;
    String alertText = '';
    IconData? alertIcon;
    
    if (daysUntil < 0) {
      alertColor = Colors.red;
      alertText = 'ATRASADO ${daysUntil.abs()}d';
      alertIcon = Icons.error;
    } else if (daysUntil == 0) {
      alertColor = Colors.orange;
      alertText = 'VENCE HOJE';
      alertIcon = Icons.warning;
    } else if (daysUntil <= 3) {
      alertColor = Colors.orange;
      alertText = 'URGENTE ${daysUntil}d';
      alertIcon = Icons.warning;
    } else if (daysUntil <= 7) {
      alertColor = Colors.blue;
      alertText = 'Prazo: ${daysUntil}d';
      alertIcon = Icons.info;
    }
    
    if (alertColor == null || alertText.isEmpty) return const SizedBox(height: 4);
    
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: alertColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(alertIcon, size: 11, color: alertColor),
          const SizedBox(width: 4),
          Text(
            alertText,
            style: TextStyle(
              color: alertColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
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
