import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/supplier.dart';
import '../../models/production_order.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/production_order_provider.dart';
import 'supplier_form_screen.dart';

class SupplierDetailScreen extends StatelessWidget {
  final Supplier supplier;

  const SupplierDetailScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    final productionProvider = context.watch<ProductionOrderProvider>();
    final supplierOrders = productionProvider.productionOrders
        .where((po) => po.supplierName == supplier.name || po.supplierName == supplier.company)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Produtor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupplierFormScreen(supplier: supplier),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            _buildHeaderCard(context),
            const SizedBox(height: 16),

            // Contact Actions
            _buildContactActions(context),
            const SizedBox(height: 16),

            // Stats Card
            _buildStatsCard(supplierOrders),
            const SizedBox(height: 16),

            // Details Card
            _buildDetailsCard(),
            const SizedBox(height: 16),

            // Production Orders
            _buildProductionOrdersSection(context, supplierOrders),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: supplier.isActive
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              child: Icon(
                Icons.factory,
                size: 48,
                color: supplier.isActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              supplier.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (supplier.company.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                supplier.company,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: supplier.isActive ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    supplier.isActive ? 'Ativo' : 'Inativo',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (supplier.category.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      supplier.category,
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
            if (supplier.rating > 0) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < supplier.rating.round() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 28,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    supplier.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactActions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contato Rápido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendWhatsApp(context),
                    icon: const Icon(Icons.chat),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(),
                    icon: const Icon(Icons.phone),
                    label: const Text('Ligar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _sendEmail(),
              icon: const Icon(Icons.email),
              label: const Text('Enviar E-mail'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<ProductionOrder> orders) {
    final activeOrders = orders.where((o) => 
      o.status != 'produtoDespachado' && o.status != 'produtoRejeitado'
    ).length;
    final completedOrders = orders.where((o) => o.status == 'produtoDespachado').length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas de Produção',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', orders.length.toString(), Icons.inventory, Colors.indigo),
                _buildStatItem('Em Produção', activeOrders.toString(), Icons.pending_actions, Colors.orange),
                _buildStatItem('Concluídos', completedOrders.toString(), Icons.check_circle, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Detalhadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (supplier.phone.isNotEmpty)
              _buildDetailRow(Icons.phone, 'Telefone', supplier.phone),
            if (supplier.email.isNotEmpty)
              _buildDetailRow(Icons.email, 'E-mail', supplier.email),
            if (supplier.cnpj.isNotEmpty)
              _buildDetailRow(Icons.badge, 'CNPJ', supplier.formattedCnpj),
            if (supplier.location.isNotEmpty)
              _buildDetailRow(Icons.location_on, 'Localização', supplier.location),
            if (supplier.address.isNotEmpty)
              _buildDetailRow(Icons.home, 'Endereço', supplier.address),
            if (supplier.paymentTerms.isNotEmpty)
              _buildDetailRow(Icons.payment, 'Pagamento', supplier.paymentTerms),
            if (supplier.leadTimeDays > 0)
              _buildDetailRow(Icons.schedule, 'Prazo Médio', '${supplier.leadTimeDays} dias'),
            if (supplier.bankName.isNotEmpty)
              _buildDetailRow(Icons.account_balance, 'Banco', supplier.bankName),
            if (supplier.pixKey.isNotEmpty)
              _buildDetailRow(Icons.pix, 'Chave PIX', supplier.pixKey),
            if (supplier.notes.isNotEmpty) ...[
              const Divider(height: 24),
              const Text('Observações:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(supplier.notes, style: const TextStyle(fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionOrdersSection(BuildContext context, List<ProductionOrder> orders) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ordens de Produção',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${orders.length} ${orders.length == 1 ? 'ordem' : 'ordens'}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            if (orders.isEmpty) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Nenhuma ordem de produção',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              ...orders.take(5).map((order) => _buildProductionOrderItem(context, order)),
              if (orders.length > 5) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Navigate to full production orders list filtered by this supplier
                  },
                  child: const Text('Ver todas as ordens'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductionOrderItem(BuildContext context, ProductionOrder order) {
    final status = order.productionStatus;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: Color(int.parse(status.statusColor.substring(1), radix: 16) + 0xFF000000),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productionOrderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Color(int.parse(status.statusColor.substring(1), radix: 16) + 0xFF000000).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status.displayName,
              style: TextStyle(
                fontSize: 10,
                color: Color(int.parse(status.statusColor.substring(1), radix: 16) + 0xFF000000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendWhatsApp(BuildContext context) async {
    final phone = supplier.phone.replaceAll(RegExp(r'[^\d]'), '');
    final message = Uri.encodeComponent(
      'Olá ${supplier.name}! Sou da Yoobe CRM e gostaria de falar sobre uma nova ordem de produção.'
    );
    final whatsappUrl = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    }
  }

  void _makePhoneCall() async {
    final phoneUrl = 'tel:${supplier.phone}';
    if (await canLaunchUrl(Uri.parse(phoneUrl))) {
      await launchUrl(Uri.parse(phoneUrl));
    }
  }

  void _sendEmail() async {
    final emailUrl = 'mailto:${supplier.email}';
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o produtor "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SupplierProvider>().deleteSupplier(supplier.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produtor excluído'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
