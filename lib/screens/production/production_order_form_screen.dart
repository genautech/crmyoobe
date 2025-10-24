import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/production_order.dart';
import '../../models/customer.dart';
import '../../providers/production_order_provider.dart';
import '../../providers/customer_provider.dart';

class ProductionOrderFormScreen extends StatefulWidget {
  final ProductionOrder? productionOrder;

  const ProductionOrderFormScreen({super.key, this.productionOrder});

  @override
  State<ProductionOrderFormScreen> createState() =>
      _ProductionOrderFormScreenState();
}

class _ProductionOrderFormScreenState extends State<ProductionOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  String _selectedStatus = 'ocCriada';
  DateTime? _deliveryDeadline;
  DateTime? _sampleRequestDate;
  DateTime? _sampleReceivedDate;
  DateTime? _approvalDate;
  DateTime? _dispatchDate;
  
  late TextEditingController _productionOrderNumberController;
  late TextEditingController _dispatchAddressController;
  late TextEditingController _dispatchCityController;
  late TextEditingController _dispatchStateController;
  late TextEditingController _dispatchZipCodeController;
  late TextEditingController _supplierNameController;
  late TextEditingController _campaignNameController;
  late TextEditingController _notesController;
  late TextEditingController _internalNotesController;
  
  List<ProductionOrderItem> _items = [];

  @override
  void initState() {
    super.initState();
    
    final po = widget.productionOrder;
    _productionOrderNumberController = TextEditingController(
      text: po?.productionOrderNumber ?? 'PO-${DateTime.now().millisecondsSinceEpoch}'
    );
    _dispatchAddressController = TextEditingController(text: po?.dispatchAddress ?? '');
    _dispatchCityController = TextEditingController(text: po?.dispatchCity ?? '');
    _dispatchStateController = TextEditingController(text: po?.dispatchState ?? '');
    _dispatchZipCodeController = TextEditingController(text: po?.dispatchZipCode ?? '');
    _supplierNameController = TextEditingController(text: po?.supplierName ?? '');
    _campaignNameController = TextEditingController(text: po?.campaignName ?? '');
    _notesController = TextEditingController(text: po?.notes ?? '');
    _internalNotesController = TextEditingController(text: po?.internalNotes ?? '');
    
    if (po != null) {
      _selectedStatus = po.status;
      _deliveryDeadline = po.deliveryDeadline;
      _sampleRequestDate = po.sampleRequestDate;
      _sampleReceivedDate = po.sampleReceivedDate;
      _approvalDate = po.approvalDate;
      _dispatchDate = po.dispatchDate;
      _items = List.from(po.items);
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customer = context.read<CustomerProvider>().getCustomer(po.customerId);
        setState(() => _selectedCustomer = customer);
      });
    }
  }

  @override
  void dispose() {
    _productionOrderNumberController.dispose();
    _dispatchAddressController.dispose();
    _dispatchCityController.dispose();
    _dispatchStateController.dispose();
    _dispatchZipCodeController.dispose();
    _supplierNameController.dispose();
    _campaignNameController.dispose();
    _notesController.dispose();
    _internalNotesController.dispose();
    super.dispose();
  }

  void _saveProductionOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente'),
            backgroundColor: Colors.red),
      );
      return;
    }
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final provider = context.read<ProductionOrderProvider>();
    final totalAmount = _items.fold(0.0, (sum, item) => sum + item.total);

    final productionOrder = ProductionOrder(
      id: widget.productionOrder?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      productionOrderNumber: _productionOrderNumberController.text.trim(),
      orderId: widget.productionOrder?.orderId ?? '',
      quoteId: widget.productionOrder?.quoteId ?? '',
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      customerCompany: _selectedCustomer!.company,
      items: _items,
      status: _selectedStatus,
      deliveryDeadline: _deliveryDeadline,
      dispatchAddress: _dispatchAddressController.text.trim(),
      dispatchCity: _dispatchCityController.text.trim(),
      dispatchState: _dispatchStateController.text.trim(),
      dispatchZipCode: _dispatchZipCodeController.text.trim(),
      totalAmount: totalAmount,
      supplierName: _supplierNameController.text.trim(),
      campaignName: _campaignNameController.text.trim(),
      notes: _notesController.text.trim(),
      internalNotes: _internalNotesController.text.trim(),
      sampleRequestDate: _sampleRequestDate,
      sampleReceivedDate: _sampleReceivedDate,
      approvalDate: _approvalDate,
      dispatchDate: _dispatchDate,
      createdAt: widget.productionOrder?.createdAt ?? DateTime.now(),
    );

    if (widget.productionOrder == null) {
      await provider.addProductionOrder(productionOrder);
    } else {
      await provider.updateProductionOrder(productionOrder);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productionOrder == null
              ? 'Ordem de produção criada com sucesso!'
              : 'Ordem de produção atualizada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Ordem de Produção'),
        content: const Text('Tem certeza que deseja excluir esta ordem de produção?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<ProductionOrderProvider>()
                  .deleteProductionOrder(widget.productionOrder!.id);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ordem de produção excluída!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        switch (field) {
          case 'delivery':
            _deliveryDeadline = picked;
            break;
          case 'sampleRequest':
            _sampleRequestDate = picked;
            break;
          case 'sampleReceived':
            _sampleReceivedDate = picked;
            break;
          case 'approval':
            _approvalDate = picked;
            break;
          case 'dispatch':
            _dispatchDate = picked;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productionOrder == null
            ? 'Nova Ordem de Produção'
            : 'Editar Ordem de Produção'),
        actions: [
          if (widget.productionOrder != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Excluir',
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildBasicInfoCard(customers),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 16),
              _buildItemsCard(),
              const SizedBox(height: 16),
              _buildDeliveryCard(),
              const SizedBox(height: 16),
              _buildNotesCard(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveProductionOrder,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Ordem de Produção'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(List<Customer> customers) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informações Básicas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _productionOrderNumberController,
              decoration: const InputDecoration(
                labelText: 'Número da OP *',
                prefixIcon: Icon(Icons.numbers),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer,
              decoration: const InputDecoration(
                labelText: 'Cliente *',
                prefixIcon: Icon(Icons.person),
              ),
              items: customers.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (customer) {
                setState(() {
                  _selectedCustomer = customer;
                  if (customer != null && _dispatchAddressController.text.isEmpty) {
                    _dispatchAddressController.text = customer.address;
                  }
                });
              },
              validator: (value) => value == null ? 'Selecione um cliente' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _campaignNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Campanha',
                prefixIcon: Icon(Icons.campaign),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplierNameController,
              decoration: const InputDecoration(
                labelText: 'Fornecedor',
                prefixIcon: Icon(Icons.local_shipping),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_turned_in, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Status de Produção',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                prefixIcon: Icon(Icons.timeline),
              ),
              items: ProductionStatus.values.map((status) {
                final statusString = status.toString().split('.').last;
                return DropdownMenuItem(
                  value: statusString,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getStatusColor(statusString),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
              },
            ),
            const SizedBox(height: 16),
            if (_selectedStatus == 'amostraSolicitada' ||
                _selectedStatus == 'amostraRecebida') ...[
              ListTile(
                leading: const Icon(Icons.science),
                title: const Text('Data Solicitação Amostra'),
                subtitle: Text(_sampleRequestDate != null
                    ? dateFormat.format(_sampleRequestDate!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'sampleRequest'),
              ),
            ],
            if (_selectedStatus == 'amostraRecebida') ...[
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Data Recebimento Amostra'),
                subtitle: Text(_sampleReceivedDate != null
                    ? dateFormat.format(_sampleReceivedDate!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'sampleReceived'),
              ),
            ],
            if (_selectedStatus == 'produtoAprovado') ...[
              ListTile(
                leading: const Icon(Icons.thumb_up),
                title: const Text('Data Aprovação'),
                subtitle: Text(_approvalDate != null
                    ? dateFormat.format(_approvalDate!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'approval'),
              ),
            ],
            if (_selectedStatus == 'produtoDespachado') ...[
              ListTile(
                leading: const Icon(Icons.local_shipping),
                title: const Text('Data Despacho'),
                subtitle: Text(_dispatchDate != null
                    ? dateFormat.format(_dispatchDate!)
                    : 'Não definida'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'dispatch'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    final totalQuantity = _items.fold(0, (sum, item) => sum + item.quantity);
    final totalAmount = _items.fold(0.0, (sum, item) => sum + item.total);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory_2, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Produtos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (_items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalQuantity un. | R\$ ${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhum produto adicionado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () {
                              setState(() => _items.removeAt(index));
                            },
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${item.quantity} un.',
                              style: const TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'R\$ ${item.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('=', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(
                            'R\$ ${item.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (item.specifications.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Especificações: ${item.specifications}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                      if (item.printingDetails.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Impressão: ${item.printingDetails}',
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],
                      if (item.color.isNotEmpty || item.size.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.color.isNotEmpty)
                              Text(
                                'Cor: ${item.color}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                            if (item.color.isNotEmpty && item.size.isNotEmpty)
                              Text(' | ', style: TextStyle(color: Colors.grey[700])),
                            if (item.size.isNotEmpty)
                              Text(
                                'Tamanho: ${item.size}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                // For simplicity, show dialog to add basic item
                _showAddItemDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Produto'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final priceController = TextEditingController();
    final specificationsController = TextEditingController();
    final printingController = TextEditingController();
    final colorController = TextEditingController();
    final sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Produto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome do Produto *'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantidade *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(labelText: 'Preço Unit. *'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specificationsController,
                decoration: const InputDecoration(labelText: 'Especificações'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: printingController,
                decoration: const InputDecoration(labelText: 'Detalhes de Impressão'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Cor'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(labelText: 'Tamanho'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;

              if (name.isEmpty || quantity <= 0 || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preencha nome, quantidade e preço válidos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final item = ProductionOrderItem(
                productId: DateTime.now().millisecondsSinceEpoch.toString(),
                productName: name,
                quantity: quantity,
                price: price,
                specifications: specificationsController.text.trim(),
                printingDetails: printingController.text.trim(),
                color: colorController.text.trim(),
                size: sizeController.text.trim(),
              );

              setState(() => _items.add(item));
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Entrega',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Prazo de Entrega'),
              subtitle: Text(_deliveryDeadline != null
                  ? dateFormat.format(_deliveryDeadline!)
                  : 'Não definido'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, 'delivery'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dispatchAddressController,
              decoration: const InputDecoration(
                labelText: 'Endereço de Despacho *',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dispatchCityController,
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: _dispatchStateController,
                    decoration: const InputDecoration(labelText: 'UF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dispatchZipCodeController,
              decoration: const InputDecoration(
                labelText: 'CEP',
                prefixIcon: Icon(Icons.pin_drop),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Observações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observações (visível para cliente)',
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _internalNotesController,
              decoration: const InputDecoration(
                labelText: 'Notas Internas (uso interno)',
                prefixIcon: Icon(Icons.lock),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
