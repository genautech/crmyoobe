import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/production_order.dart';
import '../../providers/production_order_provider.dart';
import '../../providers/supplier_provider.dart';
import 'production_order_detail_screen.dart';
import 'production_order_form_screen.dart';

class ProductionDashboardScreen extends StatelessWidget {
  const ProductionDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard de Produção'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer<ProductionOrderProvider>(
        builder: (context, provider, child) {
          final orders = provider.productionOrders;
          
          if (orders.isEmpty) {
            return _buildEmptyState(context);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Statistics Cards
                _buildOverviewStats(context, orders),
                const SizedBox(height: 24),
                
                // Status Breakdown
                _buildStatusBreakdown(context, orders),
                const SizedBox(height: 24),
                
                // Campaign Grouping
                _buildCampaignGroups(context, orders),
                const SizedBox(height: 24),
                
                // Supplier Statistics
                _buildSupplierStats(context, orders),
                const SizedBox(height: 24),
                
                // Deadline Alerts
                _buildDeadlineAlerts(context, orders),
                const SizedBox(height: 24),
                
                // Recent Activity
                _buildRecentActivity(context, orders),
              ],
            ),
          );
        },
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
        label: const Text('Nova Ordem'),
        backgroundColor: Colors.indigo.shade600,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.factory_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhuma ordem de produção',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie uma nova ordem para começar',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductionOrderFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nova Ordem de Produção'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStats(BuildContext context, List<ProductionOrder> orders) {
    final totalOrders = orders.length;
    final totalValue = orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
    final inProduction = orders.where((o) => 
      o.status == 'producaoIniciada' || 
      o.status == 'produtoEmProducao'
    ).length;
    final completed = orders.where((o) => o.status == 'produtoDespachado').length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Total de Ordens',
            value: totalOrders.toString(),
            icon: Icons.inventory_2,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Em Produção',
            value: inProduction.toString(),
            icon: Icons.settings,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Finalizadas',
            value: completed.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            title: 'Valor Total',
            value: 'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(totalValue)}',
            icon: Icons.attach_money,
            color: Colors.purple,
            isValueSmall: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isValueSmall = false,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: isValueSmall ? 16 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(BuildContext context, List<ProductionOrder> orders) {
    final statusCounts = <String, int>{};
    for (final status in ProductionStatus.values) {
      final statusString = status.toString().split('.').last;
      statusCounts[statusString] = orders.where((o) => o.status == statusString).length;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: Colors.indigo.shade600),
                const SizedBox(width: 8),
                Text(
                  'Status das Ordens',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ProductionStatus.values.map((status) {
                final statusString = status.toString().split('.').last;
                final count = statusCounts[statusString] ?? 0;
                final colorHex = status.statusColor;
                final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.displayName,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignGroups(BuildContext context, List<ProductionOrder> orders) {
    final campaignGroups = <String, List<ProductionOrder>>{};
    for (final order in orders) {
      final campaign = order.campaignName.isEmpty ? 'Sem Campanha' : order.campaignName;
      campaignGroups.putIfAbsent(campaign, () => []).add(order);
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.campaign, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                Text(
                  'Ordens por Campanha',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...campaignGroups.entries.map((entry) {
              final campaign = entry.key;
              final campaignOrders = entry.value;
              final totalValue = campaignOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple.shade600,
                    child: Text(
                      campaignOrders.length.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    campaign,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(totalValue)} • ${campaignOrders.length} ordens',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  children: campaignOrders.map((order) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.inventory_2,
                        size: 20,
                        color: Colors.purple.shade400,
                      ),
                      title: Text(
                        order.productionOrderNumber,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        order.customerName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: _buildStatusBadge(order.productionStatus),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductionOrderDetailScreen(order: order),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierStats(BuildContext context, List<ProductionOrder> orders) {
    final supplierGroups = <String, List<ProductionOrder>>{};
    for (final order in orders) {
      final supplier = order.supplierName.isEmpty ? 'Sem Fornecedor' : order.supplierName;
      supplierGroups.putIfAbsent(supplier, () => []).add(order);
    }

    final sortedSuppliers = supplierGroups.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.factory, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'Ordens por Fornecedor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...sortedSuppliers.take(5).map((entry) {
              final supplier = entry.key;
              final supplierOrders = entry.value;
              final totalValue = supplierOrders.fold<double>(0, (sum, o) => sum + o.totalAmount);
              final percentage = (supplierOrders.length / orders.length * 100).toStringAsFixed(0);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            supplier,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '${supplierOrders.length} ordens ($percentage%)',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(totalValue)}',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: supplierOrders.length / orders.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineAlerts(BuildContext context, List<ProductionOrder> orders) {
    final now = DateTime.now();
    final overdueOrders = orders.where((o) {
      if (o.deliveryDeadline == null) return false;
      return o.deliveryDeadline!.isBefore(now) && o.status != 'produtoDespachado';
    }).toList();

    final urgentOrders = orders.where((o) {
      if (o.deliveryDeadline == null) return false;
      final daysUntil = o.deliveryDeadline!.difference(now).inDays;
      return daysUntil >= 0 && daysUntil <= 3 && o.status != 'produtoDespachado';
    }).toList();

    final approachingOrders = orders.where((o) {
      if (o.deliveryDeadline == null) return false;
      final daysUntil = o.deliveryDeadline!.difference(now).inDays;
      return daysUntil > 3 && daysUntil <= 7 && o.status != 'produtoDespachado';
    }).toList();

    if (overdueOrders.isEmpty && urgentOrders.isEmpty && approachingOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Text(
                  'Alertas de Prazo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (overdueOrders.isNotEmpty) ...[
              _buildDeadlineAlertSection(
                context,
                title: 'Atrasadas',
                orders: overdueOrders,
                color: Colors.red,
                icon: Icons.error,
              ),
              const SizedBox(height: 12),
            ],
            if (urgentOrders.isNotEmpty) ...[
              _buildDeadlineAlertSection(
                context,
                title: 'Urgentes (≤3 dias)',
                orders: urgentOrders,
                color: Colors.orange,
                icon: Icons.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (approachingOrders.isNotEmpty) ...[
              _buildDeadlineAlertSection(
                context,
                title: 'Próximas (4-7 dias)',
                orders: approachingOrders,
                color: Colors.blue,
                icon: Icons.info,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineAlertSection(
    BuildContext context, {
    required String title,
    required List<ProductionOrder> orders,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${orders.length} ordens',
          style: TextStyle(color: color, fontSize: 12),
        ),
        children: orders.take(5).map((order) {
          return ListTile(
            dense: true,
            leading: Icon(Icons.inventory_2, size: 20, color: color),
            title: Text(
              order.productionOrderNumber,
              style: const TextStyle(fontSize: 13),
            ),
            subtitle: Text(
              '${order.customerName} • ${DateFormat('dd/MM/yyyy').format(order.deliveryDeadline!)}',
              style: const TextStyle(fontSize: 11),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductionOrderDetailScreen(order: order),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, List<ProductionOrder> orders) {
    final recentOrders = orders.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Atividade Recente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...recentOrders.take(5).map((order) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Icon(Icons.inventory_2, color: Colors.blue.shade600, size: 20),
                ),
                title: Text(
                  order.productionOrderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Atualizado ${_getRelativeTime(order.updatedAt)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: _buildStatusBadge(order.productionStatus),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductionOrderDetailScreen(order: order),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProductionStatus status) {
    final colorHex = status.statusColor;
    final color = Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'agora';
    }
  }
}
