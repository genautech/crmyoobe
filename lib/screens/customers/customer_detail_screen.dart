import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/quote_provider.dart';
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

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cliente')),
        body: const Center(child: Text('Cliente não encontrado')),
      );
    }

    final customerTasks = taskProvider.getTasksByCustomer(customerId);
    final customerOrders = orderProvider.getOrdersByCustomer(customerId);
    final customerQuotes = quoteProvider.getQuotesByCustomer(customerId);

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
            
            // Statistics
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${customerTasks.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Tarefas'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${customerOrders.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Pedidos'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '${customerQuotes.length}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Orçamentos'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
