import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/order_provider.dart';
import '../providers/quote_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final quoteProvider = context.watch<QuoteProvider>();

    // Generate notifications
    final notifications = _generateNotifications(taskProvider, orderProvider, quoteProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar Notificações'),
                    content: const Text('Deseja marcar todas as notificações como lidas?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notificações marcadas como lidas')),
                          );
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Limpar tudo'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Nenhuma notificação',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você está em dia com tudo! 🎉',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _NotificationCard(notification: notification);
              },
            ),
    );
  }

  List<NotificationItem> _generateNotifications(
    TaskProvider taskProvider,
    OrderProvider orderProvider,
    QuoteProvider quoteProvider,
  ) {
    final notifications = <NotificationItem>[];
    final now = DateTime.now();

    // Tarefas atrasadas
    final overdueTasks = taskProvider.getOverdueTasks();
    for (var task in overdueTasks) {
      notifications.add(NotificationItem(
        type: NotificationType.taskOverdue,
        title: 'Tarefa Atrasada',
        message: 'A tarefa "${task.title}" venceu em ${DateFormat('dd/MM/yyyy').format(task.dueDate)}',
        time: task.dueDate,
        icon: Icons.warning_rounded,
        color: Colors.red,
        priority: 3,
      ));
    }

    // Tarefas para hoje
    final todayTasks = taskProvider.getTodayTasks();
    for (var task in todayTasks) {
      notifications.add(NotificationItem(
        type: NotificationType.taskToday,
        title: 'Tarefa para Hoje',
        message: 'Não esqueça: "${task.title}" deve ser concluída hoje',
        time: task.dueDate,
        icon: Icons.event_rounded,
        color: Colors.orange,
        priority: 2,
      ));
    }

    // Orçamentos pendentes
    final pendingQuotes = quoteProvider.getQuotesByStatus('pending');
    for (var quote in pendingQuotes) {
      final daysSinceCreated = now.difference(quote.createdAt).inDays;
      if (daysSinceCreated >= 3) {
        notifications.add(NotificationItem(
          type: NotificationType.quotePending,
          title: 'Orçamento Pendente',
          message: '${quote.customerName} ainda não decidiu sobre o orçamento de R\$ ${quote.total.toStringAsFixed(2)}',
          time: quote.createdAt,
          icon: Icons.schedule_rounded,
          color: Colors.amber,
          priority: 2,
        ));
      }
    }

    // Orçamentos próximos do vencimento
    final expiringSoon = quoteProvider.quotes.where((quote) {
      final daysUntilExpiry = quote.validUntil.difference(now).inDays;
      return daysUntilExpiry > 0 && daysUntilExpiry <= 3 && quote.status != 'approved';
    }).toList();
    
    for (var quote in expiringSoon) {
      final daysLeft = quote.validUntil.difference(now).inDays;
      notifications.add(NotificationItem(
        type: NotificationType.quoteExpiring,
        title: 'Orçamento Expirando',
        message: 'Orçamento para ${quote.customerName} expira em $daysLeft ${daysLeft == 1 ? 'dia' : 'dias'}',
        time: quote.validUntil,
        icon: Icons.timer_rounded,
        color: Colors.deepOrange,
        priority: 2,
      ));
    }

    // Pedidos processando
    final processingOrders = orderProvider.getOrdersByStatus('processing');
    for (var order in processingOrders) {
      notifications.add(NotificationItem(
        type: NotificationType.orderProcessing,
        title: 'Pedido em Processamento',
        message: 'Pedido de ${order.customerName} (R\$ ${order.totalAmount.toStringAsFixed(2)}) está sendo processado',
        time: order.orderDate,
        icon: Icons.local_shipping_rounded,
        color: Colors.blue,
        priority: 1,
      ));
    }

    // Orçamentos aprovados (últimos 7 dias)
    final recentApproved = quoteProvider.quotes.where((quote) {
      return quote.status == 'approved' && 
             now.difference(quote.updatedAt).inDays <= 7;
    }).toList();
    
    for (var quote in recentApproved) {
      notifications.add(NotificationItem(
        type: NotificationType.quoteApproved,
        title: 'Orçamento Aprovado! 🎉',
        message: '${quote.customerName} aprovou o orçamento de R\$ ${quote.total.toStringAsFixed(2)}',
        time: quote.updatedAt,
        icon: Icons.check_circle_rounded,
        color: Colors.green,
        priority: 1,
      ));
    }

    // Ordenar por prioridade e depois por data
    notifications.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return b.time.compareTo(a.time);
    });

    return notifications;
  }
}

enum NotificationType {
  taskOverdue,
  taskToday,
  quotePending,
  quoteExpiring,
  quoteApproved,
  orderProcessing,
}

class NotificationItem {
  final NotificationType type;
  final String title;
  final String message;
  final DateTime time;
  final IconData icon;
  final Color color;
  final int priority; // 3 = urgent, 2 = high, 1 = normal

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.priority,
  });
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(notification.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: notification.color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navegação futura para detalhes
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (notification.priority == 3)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'URGENTE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
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

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Há ${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'}';
    } else if (difference.inHours > 0) {
      return 'Há ${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'}';
    } else if (difference.inMinutes > 0) {
      return 'Há ${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Agora';
    }
  }
}
