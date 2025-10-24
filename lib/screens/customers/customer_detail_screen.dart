import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/customer_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/quote_provider.dart';
import '../../providers/production_order_provider.dart';
import '../../models/quote.dart';
import '../../models/order.dart';
import '../../models/production_order.dart';
import 'customer_form_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<CustomerProvider>().getCustomer(customerId);
    final taskProvider = context.watch<TaskProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final quoteProvider = context.watch<QuoteProvider>();
    final productionProvider = context.watch<ProductionOrderProvider>();

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente')),
        body: const Center(child: Text('Cliente não encontrado')),
      );
    }

    final customerTasks = taskProvider.getTasksByCustomer(customerId);
    final customerOrders = orderProvider.getOrdersByCustomer(customerId);
    final customerQuotes = quoteProvider.getQuotesByCustomer(customerId);
    final customerProductions = productionProvider.productionOrders
        .where((po) => po.customerId == customerId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Cliente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerFormScreen(customer: customer),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            customer.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (customer.company.isNotEmpty)
                                Text(
                                  customer.company,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _InfoRow(icon: Icons.email, label: 'Email', value: customer.email),
                    _InfoRow(icon: Icons.phone, label: 'Telefone', value: customer.phone),
                    if (customer.address.isNotEmpty)
                      _InfoRow(icon: Icons.location_on, label: 'Endereço', value: customer.address),
                    if (customer.notes.isNotEmpty)
                      _InfoRow(icon: Icons.notes, label: 'Observações', value: customer.notes),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    color: Colors.orange,
                    icon: Icons.request_quote,
                    count: customerQuotes.length,
                    label: 'Orçamentos',
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    color: Colors.green,
                    icon: Icons.shopping_cart,
                    count: customerOrders.length,
                    label: 'Pedidos',
                  ),
                ),
                Expanded(
                  child: _StatCard(
                    color: Colors.indigo,
                    icon: Icons.factory,
                    count: customerProductions.length,
                    label: 'Produções',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timeline Section
            Text(
              'Timeline de Atividades',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Build unified timeline
            ..._buildTimeline(
              context,
              customerQuotes,
              customerOrders,
              customerProductions,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline(
    BuildContext context,
    List<Quote> quotes,
    List<Order> orders,
    List<ProductionOrder> productions,
  ) {
    // Create timeline events
    final List<_TimelineEvent> events = [];

    // Add quotes
    for (final quote in quotes) {
      events.add(_TimelineEvent(
        date: quote.createdAt,
        type: 'quote',
        data: quote,
      ));
    }

    // Add orders
    for (final order in orders) {
      events.add(_TimelineEvent(
        date: order.createdAt,
        type: 'order',
        data: order,
      ));
    }

    // Add productions
    for (final production in productions) {
      events.add(_TimelineEvent(
        date: production.createdAt,
        type: 'production',
        data: production,
      ));
    }

    // Sort by date (newest first)
    events.sort((a, b) => b.date.compareTo(a.date));

    if (events.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.timeline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma atividade registrada',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    return events.map((event) {
      switch (event.type) {
        case 'quote':
          return _buildQuoteTimelineItem(context, event.data as Quote);
        case 'order':
          return _buildOrderTimelineItem(context, event.data as Order);
        case 'production':
          return _buildProductionTimelineItem(context, event.data as ProductionOrder);
        default:
          return const SizedBox.shrink();
      }
    }).toList();
  }

  Widget _buildQuoteTimelineItem(BuildContext context, Quote quote) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes do orçamento
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.request_quote, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Orçamento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getQuoteStatusColor(quote.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _getQuoteStatusColor(quote.status),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getQuoteStatusLabel(quote.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _getQuoteStatusColor(quote.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${quote.items.length} ${quote.items.length == 1 ? 'item' : 'itens'} • ${currencyFormat.format(quote.total)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(quote.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    if (quote.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        quote.notes,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTimelineItem(BuildContext context, Order order) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes do pedido
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pedido',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'} • ${currencyFormat.format(order.totalAmount)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (order.campaignName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.campaign, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            order.campaignName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    if (order.nfVenda.isNotEmpty || order.paymentLink.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (order.nfVenda.isNotEmpty)
                            Chip(
                              label: Text('NF: ${order.nfVenda}'),
                              backgroundColor: Colors.blue.shade50,
                              labelStyle: const TextStyle(fontSize: 11),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          if (order.paymentLink.isNotEmpty)
                            const Chip(
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.link, size: 12),
                                  SizedBox(width: 4),
                                  Text('Link Pagamento'),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(fontSize: 11, color: Colors.white),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductionTimelineItem(BuildContext context, ProductionOrder production) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusColor = _getProductionStatusColor(production.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes da produção
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.factory, color: statusColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Produção',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: statusColor, width: 1),
                          ),
                          child: Text(
                            _getProductionStatusLabel(production.status),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'PO: ${production.productionOrderNumber}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (production.campaignName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.campaign, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            production.campaignName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(production.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    if (production.deliveryDeadline != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.event_available, size: 12, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            'Entrega: ${DateFormat('dd/MM/yyyy').format(production.deliveryDeadline!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getQuoteStatusColor(String status) {
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

  String _getQuoteStatusLabel(String status) {
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
        return 'Não Decidiu';
      default:
        return status;
    }
  }

  Color _getProductionStatusColor(String status) {
    switch (status) {
      case 'ocCriada':
        return Colors.indigo;
      case 'produtoPago':
        return Colors.green;
      case 'producaoIniciada':
        return Colors.blue;
      case 'amostraSolicitada':
        return Colors.amber;
      case 'amostraRecebida':
        return Colors.purple;
      case 'produtoAprovado':
        return Colors.green;
      case 'produtoRejeitado':
        return Colors.red;
      case 'produtoEmProducao':
        return Colors.lightBlue;
      case 'produtoDespachado':
        return Colors.teal;
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

class _TimelineEvent {
  final DateTime date;
  final String type;
  final dynamic data;

  _TimelineEvent({
    required this.date,
    required this.type,
    required this.data,
  });
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final int count;
  final String label;

  const _StatCard({
    required this.color,
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
