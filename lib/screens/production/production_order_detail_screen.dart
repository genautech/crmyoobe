import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
// import 'package:printing/printing.dart';
import '../../models/production_order.dart';
import '../../models/supplier.dart';
import '../../providers/supplier_provider.dart';
// import '../../services/pdf_service.dart';
import 'production_order_form_screen.dart';

class ProductionOrderDetailScreen extends StatelessWidget {
  final ProductionOrder order;

  const ProductionOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final supplier = supplierProvider.getSupplierByName(order.supplierName);
    final status = order.productionStatus;
    final statusColor = Color(int.parse(status.statusColor.substring(1), radix: 16) + 0xFF000000);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Ordem de Produção'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductionOrderFormScreen(productionOrder: order),
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
            // Header Card
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.factory, color: statusColor, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.productionOrderNumber,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.displayName,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (order.campaignName.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.campaign, size: 20, color: Colors.purple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Campanha', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                  Text(
                                    order.campaignName,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
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
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _generateAndSharePdf(context, supplier),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Gerar PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: supplier != null ? () => _sendWhatsAppWithPdf(context, supplier) : null,
                    icon: const Icon(Icons.send),
                    label: const Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Customer Info
            _buildInfoCard(
              'Cliente',
              Icons.person,
              [
                _buildInfoRow('Nome', order.customerName),
                if (order.customerCompany.isNotEmpty)
                  _buildInfoRow('Empresa', order.customerCompany),
              ],
            ),
            const SizedBox(height: 16),

            // Supplier Info
            _buildInfoCard(
              'Produtor',
              Icons.factory,
              [
                _buildInfoRow('Nome', order.supplierName),
                if (supplier != null) ...[
                  if (supplier.phone.isNotEmpty)
                    _buildInfoRow('Telefone', supplier.phone),
                  if (supplier.email.isNotEmpty)
                    _buildInfoRow('E-mail', supplier.email),
                  if (supplier.leadTimeDays > 0)
                    _buildInfoRow('Prazo Médio', '${supplier.leadTimeDays} dias'),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Dates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        const Text('Prazos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Data de Criação', DateFormat('dd/MM/yyyy').format(order.productionDate)),
                    if (order.deliveryDeadline != null) ...[
                      _buildInfoRow('Prazo de Entrega', DateFormat('dd/MM/yyyy').format(order.deliveryDeadline!)),
                      _buildDeadlineAlert(order.deliveryDeadline!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.inventory_2, size: 20),
                            SizedBox(width: 8),
                            Text('Itens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(
                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'itens'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  'Qtd: ${item.quantity} × R\$ ${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'R\$ ${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          'R\$ ${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Delivery Address
            if (order.dispatchAddress.isNotEmpty)
              _buildInfoCard(
                'Endereço de Entrega',
                Icons.location_on,
                [
                  Text(order.dispatchAddress),
                  if (order.dispatchCity.isNotEmpty || order.dispatchState.isNotEmpty)
                    Text('${order.dispatchCity}${order.dispatchCity.isNotEmpty && order.dispatchState.isNotEmpty ? ', ' : ''}${order.dispatchState}'),
                  if (order.dispatchZipCode.isNotEmpty)
                    Text('CEP: ${order.dispatchZipCode}'),
                ],
              ),

            // Notes
            if (order.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes, size: 20, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Text(
                            'Observações',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(order.notes),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildDeadlineAlert(DateTime deadline) {
    final now = DateTime.now();
    final daysUntil = deadline.difference(now).inDays;
    
    Color alertColor;
    String alertText;
    IconData alertIcon;

    if (daysUntil < 0) {
      alertColor = Colors.red;
      alertText = 'ATRASADO - ${daysUntil.abs()} ${daysUntil.abs() == 1 ? 'dia' : 'dias'}';
      alertIcon = Icons.error;
    } else if (daysUntil == 0) {
      alertColor = Colors.orange;
      alertText = 'VENCE HOJE';
      alertIcon = Icons.warning;
    } else if (daysUntil <= 3) {
      alertColor = Colors.orange;
      alertText = 'URGENTE - $daysUntil ${daysUntil == 1 ? 'dia' : 'dias'}';
      alertIcon = Icons.warning;
    } else if (daysUntil <= 7) {
      alertColor = Colors.blue;
      alertText = 'Faltam $daysUntil dias';
      alertIcon = Icons.info;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        border: Border.all(color: alertColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(alertIcon, color: alertColor, size: 20),
          const SizedBox(width: 8),
          Text(
            alertText,
            style: TextStyle(color: alertColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _generateAndSharePdf(BuildContext context, Supplier? supplier) async {
    // PDF generation temporarily disabled for web platform
    // The full PDF service with Yoobe logo is implemented in pdf_service.dart
    // and will work once the platform-specific implementation is configured
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PDF disponível para Android',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Versão web em desenvolvimento. Use o app Android para gerar PDFs.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _sendWhatsAppWithPdf(BuildContext context, Supplier supplier) async {
    try {
      final phone = supplier.phone.replaceAll(RegExp(r'[^\d]'), '');
      
      final message = Uri.encodeComponent('''
Olá ${supplier.name}! 👋

Nova ordem de produção da Yoobe CRM:

📋 *Ordem:* ${order.productionOrderNumber}
👤 *Cliente:* ${order.customerName}
${order.campaignName.isNotEmpty ? '🎯 *Campanha:* ${order.campaignName}\n' : ''}📦 *Itens:* ${order.items.length} ${order.items.length == 1 ? 'produto' : 'produtos'}
💰 *Valor:* R\$ ${order.totalAmount.toStringAsFixed(2)}
${order.deliveryDeadline != null ? '📅 *Prazo:* ${DateFormat('dd/MM/yyyy').format(order.deliveryDeadline!)}\n' : ''}
*Produtos:*
${order.items.map((item) => '• ${item.productName} - Qtd: ${item.quantity}').join('\n')}

Estamos gerando o PDF com todos os detalhes. Por favor, confirme o recebimento desta ordem!

Att,
Equipe Yoobe CRM
''');

      final whatsappUrl = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
      
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ WhatsApp aberto! Envie a mensagem e depois compartilhe o PDF.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Also generate and show PDF for sharing
        await _generateAndSharePdf(context, supplier);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
