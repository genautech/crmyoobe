import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/customer_provider.dart';
import '../providers/task_provider.dart';
import '../providers/order_provider.dart';
import '../providers/quote_provider.dart';
import '../providers/production_order_provider.dart';
import '../providers/supplier_provider.dart';
import 'customers/customers_list_screen.dart';
import 'tasks/tasks_list_screen.dart';
import 'orders/orders_list_screen.dart';
import 'quotes/quotes_list_screen.dart';
import 'products/products_list_screen.dart';
import 'production/production_orders_list_screen.dart';
import 'suppliers/suppliers_list_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const CustomersListScreen(),
    const TasksListScreen(),
    const OrdersListScreen(),
    const QuotesListScreen(),
    const ProductsListScreen(),
    const ProductionOrdersListScreen(),
    const SuppliersListScreen(),
  ];

  int _getDeadlineAlertCount() {
    final productionProvider = context.watch<ProductionOrderProvider>();
    final orders = productionProvider.productionOrders;
    final now = DateTime.now();
    
    int count = 0;
    for (final order in orders) {
      if (order.deliveryDeadline != null && order.status != 'produtoDespachado') {
        final daysUntil = order.deliveryDeadline!.difference(now).inDays;
        if (daysUntil <= 7) { // Alert for orders within 7 days or overdue
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final alertCount = _getDeadlineAlertCount();
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/yoobe_logo.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.business_center, size: 32);
              },
            ),
            const SizedBox(width: 8),
            const Text('Yoobe CRM'),
          ],
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Ajuda',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: alertCount > 0,
              label: Text(alertCount.toString()),
              backgroundColor: Colors.red,
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: alertCount > 0 ? '$alertCount alertas de prazo' : 'Notificações',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tarefas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.request_quote_outlined),
            selectedIcon: Icon(Icons.request_quote),
            label: 'Orçamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produtos',
          ),
          NavigationDestination(
            icon: Icon(Icons.precision_manufacturing_outlined),
            selectedIcon: Icon(Icons.precision_manufacturing),
            label: 'Produção',
          ),
          NavigationDestination(
            icon: Icon(Icons.factory_outlined),
            selectedIcon: Icon(Icons.factory),
            label: 'Produtores',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = context.watch<CustomerProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final quoteProvider = context.watch<QuoteProvider>();
    final productionProvider = context.watch<ProductionOrderProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Visão Geral',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Clientes',
                    value: '${customerProvider.customers.length}',
                    icon: Icons.people_rounded,
                    color: const Color(0xFF6366F1),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Tarefas Ativas',
                    value: '${taskProvider.tasks.where((t) => !t.isCompleted).length}',
                    icon: Icons.task_rounded,
                    color: const Color(0xFFF59E0B),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pedidos',
                    value: '${orderProvider.orders.length}',
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF10B981),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Orçamentos',
                    value: '${quoteProvider.quotes.length}',
                    icon: Icons.request_quote_rounded,
                    color: const Color(0xFF8B5CF6),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Active Productions Widget
            Row(
              children: [
                Icon(Icons.factory_rounded, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Produções em Andamento',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ActiveProductionsWidget(productionProvider: productionProvider),
            
            const SizedBox(height: 32),
            
            // CRM Timeline Section
            Row(
              children: [
                Icon(Icons.timeline_rounded, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Acompanhamento CRM',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CRMTimeline(
              taskProvider: taskProvider,
              orderProvider: orderProvider,
              quoteProvider: quoteProvider,
            ),
            
            const SizedBox(height: 32),
            
            // Today's Tasks
            Row(
              children: [
                Icon(Icons.event_rounded, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tarefas de Hoje',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...taskProvider.getTodayTasks().map((task) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPriorityColor(task.priority),
                  child: const Icon(Icons.task, color: Colors.white, size: 20),
                ),
                title: Text(task.title),
                subtitle: Text(task.customerName),
                trailing: Chip(
                  label: Text(task.status),
                  backgroundColor: _getStatusColor(task.status).withAlpha(51),
                ),
              ),
            )),

            if (taskProvider.getTodayTasks().isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('Nenhuma tarefa para hoje'),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Overdue Tasks
            if (taskProvider.getOverdueTasks().isNotEmpty) ...[
              Text(
                'Tarefas Atrasadas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ...taskProvider.getOverdueTasks().take(5).map((task) => Card(
                color: Colors.red.shade50,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.warning, color: Colors.white, size: 20),
                  ),
                  title: Text(task.title),
                  subtitle: Text(task.customerName),
                  trailing: Text(
                    'Venceu: ${task.dueDate.day}/${task.dueDate.month}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )),
            ],

            const SizedBox(height: 24),

            // Recent Orders
            Text(
              'Pedidos Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...orderProvider.orders.take(5).map((order) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                ),
                title: Text(order.customerName),
                subtitle: Text('${order.items.length} itens'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'R\$ ${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Chip(
                      label: Text(
                        order.status,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getStatusColor(order.status).withAlpha(51),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            )),

            if (orderProvider.orders.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('Nenhum pedido registrado'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'delivered':
      case 'accepted':
        return Colors.green;
      case 'inprogress':
      case 'processing':
      case 'shipped':
        return Colors.blue;
      case 'pending':
      case 'draft':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient? gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CRMTimeline extends StatelessWidget {
  final TaskProvider taskProvider;
  final OrderProvider orderProvider;
  final QuoteProvider quoteProvider;

  const _CRMTimeline({
    required this.taskProvider,
    required this.orderProvider,
    required this.quoteProvider,
  });

  @override
  Widget build(BuildContext context) {
    final activities = _generateActivities();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atividades Recentes e Pendentes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 20),
          ...activities.asMap().entries.map((entry) {
            final index = entry.key;
            final activity = entry.value;
            final isLast = index == activities.length - 1;
            
            return _TimelineItem(
              activity: activity,
              isLast: isLast,
            );
          }),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      'Tudo em dia!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<TimelineActivity> _generateActivities() {
    final activities = <TimelineActivity>[];
    final now = DateTime.now();

    final overdueTasks = taskProvider.getOverdueTasks();
    for (var task in overdueTasks.take(3)) {
      activities.add(TimelineActivity(
        title: task.title,
        description: 'Tarefa atrasada - ${task.customerName}',
        time: task.dueDate,
        icon: Icons.warning_rounded,
        color: Colors.red,
        isCompleted: false,
        isPending: true,
      ));
    }

    final todayTasks = taskProvider.getTodayTasks();
    for (var task in todayTasks.take(2)) {
      activities.add(TimelineActivity(
        title: task.title,
        description: 'Tarefa para hoje - ${task.customerName}',
        time: task.dueDate,
        icon: Icons.event_rounded,
        color: Colors.orange,
        isCompleted: false,
        isPending: true,
      ));
    }

    final pendingQuotes = quoteProvider.getQuotesByStatus('pending').take(2);
    for (var quote in pendingQuotes) {
      activities.add(TimelineActivity(
        title: 'Orçamento aguardando decisão',
        description: '${quote.customerName} - R\$ ${quote.total.toStringAsFixed(2)}',
        time: quote.createdAt,
        icon: Icons.schedule_rounded,
        color: Colors.amber,
        isCompleted: false,
        isPending: true,
      ));
    }

    final completedTasks = taskProvider.tasks.where((task) {
      return task.isCompleted && now.difference(task.updatedAt).inHours <= 24;
    }).take(3);
    
    for (var task in completedTasks) {
      activities.add(TimelineActivity(
        title: task.title,
        description: 'Tarefa concluída - ${task.customerName}',
        time: task.updatedAt,
        icon: Icons.check_circle_rounded,
        color: Colors.green,
        isCompleted: true,
        isPending: false,
      ));
    }

    final approvedQuotes = quoteProvider.quotes.where((quote) {
      return quote.status == 'approved' && now.difference(quote.updatedAt).inDays <= 3;
    }).take(2);
    
    for (var quote in approvedQuotes) {
      activities.add(TimelineActivity(
        title: 'Orçamento aprovado',
        description: '${quote.customerName} - R\$ ${quote.total.toStringAsFixed(2)}',
        time: quote.updatedAt,
        icon: Icons.thumb_up_rounded,
        color: Colors.green,
        isCompleted: true,
        isPending: false,
      ));
    }

    activities.sort((a, b) {
      if (a.isPending && !b.isPending) return -1;
      if (!a.isPending && b.isPending) return 1;
      return b.time.compareTo(a.time);
    });

    return activities.take(8).toList();
  }
}

class TimelineActivity {
  final String title;
  final String description;
  final DateTime time;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isPending;

  TimelineActivity({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.isPending,
  });
}

class _TimelineItem extends StatelessWidget {
  final TimelineActivity activity;
  final bool isLast;

  const _TimelineItem({
    required this.activity,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity.isCompleted
                      ? activity.color.withValues(alpha: 0.15)
                      : activity.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: activity.color,
                    width: activity.isPending ? 3 : 2,
                  ),
                ),
                child: Icon(activity.icon, color: activity.color, size: 20),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          activity.color.withValues(alpha: 0.5),
                          activity.color.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
                            color: activity.isCompleted ? Colors.grey.shade600 : Colors.grey.shade900,
                          ),
                        ),
                      ),
                      if (activity.isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: activity.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('PENDENTE', style: TextStyle(color: activity.color, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      if (activity.isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('CONCLUÍDO', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(activity.description, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(activity.time), style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Active Productions Widget
class _ActiveProductionsWidget extends StatelessWidget {
  final ProductionOrderProvider productionProvider;

  const _ActiveProductionsWidget({required this.productionProvider});

  @override
  Widget build(BuildContext context) {
    // Get active productions (not dispatched)
    final activeProductions = productionProvider.productionOrders
        .where((po) => po.status != 'produtoDespachado')
        .toList();

    // Sort by creation date (newest first)
    activeProductions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (activeProductions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.factory_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma produção em andamento',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: activeProductions.take(5).map((production) {
        final statusColor = _getProductionStatusColor(production.status);
        final daysUntilDeadline = production.deliveryDeadline != null
            ? production.deliveryDeadline!.difference(DateTime.now()).inDays
            : null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // Navigate to production details
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductionOrdersListScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.factory, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              production.customerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PO: ${production.productionOrderNumber}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor, width: 1.5),
                        ),
                        child: Text(
                          _getProductionStatusLabel(production.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.inventory_2_outlined,
                          label: '${production.items.length} ${production.items.length == 1 ? 'item' : 'itens'}',
                        ),
                      ),
                      if (production.campaignName.isNotEmpty)
                        Expanded(
                          child: _InfoChip(
                            icon: Icons.campaign,
                            label: production.campaignName,
                          ),
                        ),
                    ],
                  ),
                  if (production.deliveryDeadline != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: daysUntilDeadline! < 0
                            ? Colors.red.withValues(alpha: 0.1)
                            : daysUntilDeadline < 7
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: daysUntilDeadline < 0
                              ? Colors.red
                              : daysUntilDeadline < 7
                                  ? Colors.orange
                                  : Colors.blue,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            daysUntilDeadline < 0 ? Icons.error : Icons.event_available,
                            size: 16,
                            color: daysUntilDeadline < 0
                                ? Colors.red
                                : daysUntilDeadline < 7
                                    ? Colors.orange
                                    : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            daysUntilDeadline < 0
                                ? 'Atrasado ${-daysUntilDeadline} ${-daysUntilDeadline == 1 ? 'dia' : 'dias'}'
                                : daysUntilDeadline == 0
                                    ? 'Entrega HOJE'
                                    : 'Entrega em $daysUntilDeadline ${daysUntilDeadline == 1 ? 'dia' : 'dias'}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: daysUntilDeadline < 0
                                  ? Colors.red
                                  : daysUntilDeadline < 7
                                      ? Colors.orange
                                      : Colors.blue,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('dd/MM/yyyy').format(production.deliveryDeadline!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getProductionStatusColor(String status) {
    switch (status) {
      case 'ocCriada':
        return const Color(0xFF6366F1);
      case 'produtoPago':
        return const Color(0xFF10B981);
      case 'producaoIniciada':
        return const Color(0xFF3B82F6);
      case 'amostraSolicitada':
        return const Color(0xFFF59E0B);
      case 'amostraRecebida':
        return const Color(0xFF8B5CF6);
      case 'produtoAprovado':
        return const Color(0xFF10B981);
      case 'produtoRejeitado':
        return const Color(0xFFEF4444);
      case 'produtoEmProducao':
        return const Color(0xFF0EA5E9);
      case 'produtoDespachado':
        return const Color(0xFF22C55E);
      default:
        return Colors.grey;
    }
  }

  String _getProductionStatusLabel(String status) {
    switch (status) {
      case 'ocCriada':
        return 'OC Criada';
      case 'produtoPago':
        return 'Pago';
      case 'producaoIniciada':
        return 'Iniciada';
      case 'amostraSolicitada':
        return 'Amostra Solicitada';
      case 'amostraRecebida':
        return 'Amostra Recebida';
      case 'produtoAprovado':
        return 'Aprovado';
      case 'produtoRejeitado':
        return 'Rejeitado';
      case 'produtoEmProducao':
        return 'Em Produção';
      case 'produtoDespachado':
        return 'Despachado';
      default:
        return status;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
