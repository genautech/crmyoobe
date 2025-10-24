import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../models/production_order.dart';
import '../../providers/order_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/production_order_provider.dart';
import '../customers/quick_customer_dialog.dart';
import '../products/quick_product_dialog.dart';

class OrderFormScreen extends StatefulWidget {
  final Order? order;

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  Customer? _selectedCustomer;
  List<OrderItem> _items = [];
  String _status = 'pending';
  DateTime? _deliveryDate;
  late TextEditingController _notesController;
  late TextEditingController _campaignNameController;
  late TextEditingController _supplierNameController;
  late TextEditingController _nfFornecedorController;
  late TextEditingController _nfVendaController;
  late TextEditingController _paymentLinkController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.order?.notes ?? '');
    _campaignNameController = TextEditingController(text: widget.order?.campaignName ?? '');
    _supplierNameController = TextEditingController(text: widget.order?.supplierName ?? '');
    _nfFornecedorController = TextEditingController(text: widget.order?.nfFornecedor ?? '');
    _nfVendaController = TextEditingController(text: widget.order?.nfVenda ?? '');
    _paymentLinkController = TextEditingController(text: widget.order?.paymentLink ?? '');
    
    if (widget.order != null) {
      _items = List.from(widget.order!.items);
      _status = widget.order!.status;
      _deliveryDate = widget.order!.deliveryDate;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customer = context.read<CustomerProvider>().getCustomer(widget.order!.customerId);
        setState(() => _selectedCustomer = customer);
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _campaignNameController.dispose();
    _supplierNameController.dispose();
    _nfFornecedorController.dispose();
    _nfVendaController.dispose();
    _paymentLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.order == null ? 'Novo Pedido' : 'Editar Pedido'),
        actions: [
          if (widget.order != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
              tooltip: 'Excluir pedido',
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cliente Selection Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Cliente',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Customer>(
                            value: _selectedCustomer,
                            decoration: const InputDecoration(
                              labelText: 'Selecione o cliente *',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: customers.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      c.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    if (c.company.isNotEmpty)
                                      Text(
                                        c.company,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (c) => setState(() => _selectedCustomer = c),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addNewCustomer,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Novo'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedCustomer != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_selectedCustomer!.phone.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    _selectedCustomer!.phone,
                                    style: TextStyle(color: Colors.blue.shade900),
                                  ),
                                ],
                              ),
                            if (_selectedCustomer!.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.email, size: 16, color: Colors.blue.shade700),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _selectedCustomer!.email,
                                      style: TextStyle(color: Colors.blue.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Itens do Pedido Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Itens do Pedido',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddItemDialog(products),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Adicionar Item'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_items.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Nenhum item adicionado',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Clique em "Adicionar Item" para começar',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              'Qtd: ${item.quantity} × R\$ ${item.price.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      'R\$ ${item.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    setState(() => _items.removeAt(index));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Item removido'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'Remover item',
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status e Data de Entrega
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Detalhes do Pedido',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'pending', child: Text('⏳ Pendente')),
                        DropdownMenuItem(value: 'processing', child: Text('🔄 Processando')),
                        DropdownMenuItem(value: 'shipped', child: Text('📦 Enviado')),
                        DropdownMenuItem(value: 'delivered', child: Text('✅ Entregue')),
                        DropdownMenuItem(value: 'cancelled', child: Text('❌ Cancelado')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _campaignNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Campanha',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.campaign),
                        hintText: 'Ex: Campanha Verão 2024',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _supplierNameController,
                      decoration: const InputDecoration(
                        labelText: 'Fornecedor (uso interno)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping),
                        hintText: 'Nome do fornecedor',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nfFornecedorController,
                      decoration: const InputDecoration(
                        labelText: 'NF Fornecedor',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt_long),
                        hintText: 'Número da nota fiscal do fornecedor',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nfVendaController,
                      decoration: const InputDecoration(
                        labelText: 'NF Venda',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt),
                        hintText: 'Número da nota fiscal de venda',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _paymentLinkController,
                      decoration: const InputDecoration(
                        labelText: 'Link de Pagamento',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: 'URL do link de pagamento',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Data de Entrega'),
                      subtitle: Text(
                        _deliveryDate == null
                            ? 'Nenhuma data definida'
                            : '${_deliveryDate!.day}/${_deliveryDate!.month}/${_deliveryDate!.year}',
                      ),
                      trailing: ElevatedButton(
                        onPressed: _selectDeliveryDate,
                        child: Text(_deliveryDate == null ? 'Definir' : 'Alterar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Observações
            Card(
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Observações do pedido',
                        hintText: 'Ex: Cliente solicitou embalagem especial',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total do Pedido',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Valor a pagar',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'R\$ ${_items.fold(0.0, (sum, item) => sum + item.total).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton.icon(
              onPressed: _saveOrder,
              icon: const Icon(Icons.check_circle),
              label: Text(
                widget.order == null ? 'Criar Pedido' : 'Salvar Alterações',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            
            // Botão Enviar para Produção (apenas para pedidos existentes)
            if (widget.order != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _sendToProduction(context),
                icon: const Icon(Icons.factory, size: 24),
                label: const Text(
                  'Enviar para Produção',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addNewCustomer() async {
    final customer = await showDialog<Customer>(
      context: context,
      builder: (context) => const QuickCustomerDialog(),
    );

    if (customer != null) {
      // Adiciona cliente ao provider
      context.read<CustomerProvider>().addCustomer(customer);

      // Seleciona automaticamente
      setState(() => _selectedCustomer = customer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cliente "${customer.name}" criado e selecionado!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddItemDialog(List<Product> products) {
    Product? selectedProduct;
    int quantity = 1;
    final quantityController = TextEditingController(text: '1');
    final searchController = TextEditingController();
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter products based on search query
          final filteredProducts = searchQuery.isEmpty
              ? products
              : products.where((p) {
                  final query = searchQuery.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      p.category.toLowerCase().contains(query) ||
                      p.sku.toLowerCase().contains(query);
                }).toList();

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_shopping_cart, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text('Adicionar Item ao Pedido'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Search Field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar Produto',
                      hintText: 'Nome, categoria ou SKU',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                setDialogState(() {
                                  searchQuery = '';
                                  selectedProduct = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value;
                        // Reset selected product if it's not in filtered list
                        if (selectedProduct != null &&
                            !filteredProducts.contains(selectedProduct)) {
                          selectedProduct = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Product>(
                          value: selectedProduct,
                          decoration: const InputDecoration(
                            labelText: 'Produto *',
                            border: OutlineInputBorder(),
                          ),
                          items: filteredProducts.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'R\$ ${p.price.toStringAsFixed(2)} - Estoque: ${p.stock}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (p) => setDialogState(() => selectedProduct = p),
                        ),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        // Fecha dialog atual
                        Navigator.pop(context);
                        
                        // Abre dialog de novo produto
                        final product = await showDialog<Product>(
                          context: context,
                          builder: (context) => const QuickProductDialog(),
                        );

                        if (product != null && mounted) {
                          // Adiciona produto ao provider
                          context.read<ProductProvider>().addProduct(product);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Produto "${product.name}" criado!'),
                              backgroundColor: Colors.green,
                            ),
                          );

                          // Reabre dialog de adicionar item com o produto selecionado
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (mounted) {
                            _showAddItemDialogWithProduct(product);
                          }
                        } else {
                          // Se cancelou, reabre dialog de adicionar item
                          if (mounted) {
                            _showAddItemDialog(context.read<ProductProvider>().products);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantidade *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.numbers),
                    hintText: '1',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    quantity = int.tryParse(v) ?? 1;
                    if (quantity < 1) quantity = 1;
                  },
                ),
                if (selectedProduct != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Preço unitário:'),
                            Text(
                              'R\$ ${selectedProduct!.price.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal:'),
                            Text(
                              'R\$ ${(selectedProduct!.price * quantity).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: selectedProduct == null
                  ? null
                  : () {
                      setState(() {
                        _items.add(OrderItem(
                          productId: selectedProduct!.id,
                          productName: selectedProduct!.name,
                          quantity: quantity,
                          price: selectedProduct!.price,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${selectedProduct!.name} adicionado!'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Adicionar'),
            ),
          ],
          );
        },
      ),
    );
  }

  void _showAddItemDialogWithProduct(Product product) {
    int quantity = 1;
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.add_shopping_cart, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text('Adicionar Item ao Pedido'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  setDialogState(() {
                    quantity = int.tryParse(v) ?? 1;
                    if (quantity < 1) quantity = 1;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:'),
                    Text(
                      'R\$ ${(product.price * quantity).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _items.add(OrderItem(
                    productId: product.id,
                    productName: product.name,
                    quantity: quantity,
                    price: product.price,
                  ));
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} adicionado!'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      setState(() => _deliveryDate = picked);
    }
  }

  void _saveOrder() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Selecione um cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Adicione pelo menos um item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final order = Order(
      id: widget.order?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      items: _items,
      status: _status,
      deliveryDate: _deliveryDate,
      notes: _notesController.text,
      campaignName: _campaignNameController.text.trim(),
      supplierName: _supplierNameController.text.trim(),
      nfFornecedor: _nfFornecedorController.text.trim(),
      nfVenda: _nfVendaController.text.trim(),
      paymentLink: _paymentLinkController.text.trim(),
      quoteId: widget.order?.quoteId ?? '',
      createdAt: widget.order?.createdAt ?? DateTime.now(),
    );

    if (widget.order == null) {
      context.read<OrderProvider>().addOrder(order);
    } else {
      context.read<OrderProvider>().updateOrder(order);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(widget.order == null ? 'Pedido criado com sucesso!' : 'Pedido atualizado!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OrderProvider>().deleteOrder(widget.order!.id);
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Fecha tela
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pedido excluído'),
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

  Future<void> _sendToProduction(BuildContext context) async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Cliente não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar para Produção'),
        content: const Text(
          'Deseja criar uma ordem de produção para este pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Create order from current form data
      final order = Order(
        id: widget.order?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        items: _items,
        status: _status,
        deliveryDate: _deliveryDate,
        notes: _notesController.text,
        campaignName: _campaignNameController.text.trim(),
        supplierName: _supplierNameController.text.trim(),
        nfFornecedor: _nfFornecedorController.text.trim(),
        nfVenda: _nfVendaController.text.trim(),
        paymentLink: _paymentLinkController.text.trim(),
        quoteId: widget.order?.quoteId ?? '',
        createdAt: widget.order?.createdAt ?? DateTime.now(),
      );

      // Save/update order first
      if (widget.order == null) {
        await context.read<OrderProvider>().addOrder(order);
      } else {
        await context.read<OrderProvider>().updateOrder(order);
      }

      // Create production order from order
      final productionOrder = ProductionOrder.fromOrder(
        order,
        _selectedCustomer!.company,
        _selectedCustomer!.address,
      );

      // Save production order
      await context.read<ProductionOrderProvider>().addProductionOrder(productionOrder);

      if (!context.mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.factory, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Ordem de produção criada com sucesso!')),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Erro ao criar ordem de produção: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
