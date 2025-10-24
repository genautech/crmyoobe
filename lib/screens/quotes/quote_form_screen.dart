import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/quote.dart';
import '../../models/customer.dart';
import '../../models/product.dart';
import '../../providers/quote_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/product_provider.dart';
import '../customers/quick_customer_dialog.dart';
import '../products/quick_product_dialog.dart';

class QuoteFormScreen extends StatefulWidget {
  final Quote? quote;

  const QuoteFormScreen({super.key, this.quote});

  @override
  State<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends State<QuoteFormScreen> {
  Customer? _selectedCustomer;
  List<QuoteItem> _items = [];
  String _status = 'requested';
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  double _generalDiscount = 0.0;
  double _tax = 0.0;
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.quote?.notes ?? '');
    _termsController = TextEditingController(text: widget.quote?.termsAndConditions ?? '');
    
    if (widget.quote != null) {
      _items = List.from(widget.quote!.items);
      _status = widget.quote!.status;
      _validUntil = widget.quote!.validUntil;
      _generalDiscount = widget.quote!.discount;
      _tax = widget.quote!.tax;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final customer = context.read<CustomerProvider>().getCustomer(widget.quote!.customerId);
        setState(() => _selectedCustomer = customer);
      });
    }
  }

  double get _subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get _itemDiscounts => _items.fold(0.0, (sum, item) => sum + item.discountAmount);
  double get _totalAfterDiscounts => _subtotal - _itemDiscounts - _generalDiscount;
  double get _taxAmount => _totalAfterDiscounts * (_tax / 100);
  double get _total => _totalAfterDiscounts + _taxAmount;

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      appBar: AppBar(title: Text(widget.quote == null ? 'Novo Orçamento' : 'Editar Orçamento')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                    items: customers.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
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
            const SizedBox(height: 16),
            if (_selectedCustomer != null && widget.quote != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Contato via WhatsApp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enviar mensagem para ${_selectedCustomer!.name}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _sendWhatsAppFollowUp(),
                            icon: const Icon(Icons.message),
                            label: const Text('Acompanhamento'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF25D366),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _sendWhatsAppSchedule(),
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Agendar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF25D366),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (_selectedCustomer != null && widget.quote != null) const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'requested', child: Text('Orçamento Solicitado')),
                DropdownMenuItem(value: 'sent', child: Text('Orçamento Enviado')),
                DropdownMenuItem(value: 'approved', child: Text('Orçamento Aprovado')),
                DropdownMenuItem(value: 'cancelled', child: Text('Orçamento Cancelado')),
                DropdownMenuItem(value: 'pending', child: Text('Cliente Não Decidiu Ainda')),
              ],
              onChanged: (v) => setState(() => _status = v!),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Válido até'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_validUntil)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _validUntil,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => _validUntil = date);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Itens', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                  onPressed: () => _showAddItemDialog(products),
                ),
              ],
            ),
            ..._items.map((item) => Card(
              child: ListTile(
                title: Text(item.productName),
                subtitle: Text(
                  'Qtd: ${item.quantity} × R\$ ${item.unitPrice.toStringAsFixed(2)}'
                  '${item.discount > 0 ? ' (${item.discount}% desc)' : ''}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discount > 0)
                          Text(
                            'R\$ ${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(decoration: TextDecoration.lineThrough, fontSize: 12),
                          ),
                        Text('R\$ ${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _items.remove(item)),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _generalDiscount.toStringAsFixed(2),
                    decoration: const InputDecoration(labelText: 'Desconto Geral (R\$)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _generalDiscount = double.tryParse(v) ?? 0.0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _tax.toStringAsFixed(2),
                    decoration: const InputDecoration(labelText: 'Imposto (%)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => _tax = double.tryParse(v) ?? 0.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Observações', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _termsController,
              decoration: const InputDecoration(labelText: 'Termos e Condições', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TotalRow(label: 'Subtotal', value: _subtotal),
                    if (_itemDiscounts > 0) _TotalRow(label: 'Descontos itens', value: -_itemDiscounts),
                    if (_generalDiscount > 0) _TotalRow(label: 'Desconto geral', value: -_generalDiscount),
                    if (_tax > 0) _TotalRow(label: 'Impostos', value: _taxAmount),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          'R\$ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveQuote,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: Text(widget.quote == null ? 'Criar Orçamento' : 'Salvar', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(List<Product> products) {
    Product? selectedProduct;
    int quantity = 1;
    double discount = 0.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      decoration: const InputDecoration(labelText: 'Produto', border: OutlineInputBorder()),
                      items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (p) => setDialogState(() => selectedProduct = p),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final product = await showDialog<Product>(
                        context: context,
                        builder: (context) => const QuickProductDialog(),
                      );
                      if (product != null && mounted) {
                        context.read<ProductProvider>().addProduct(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Produto "${product.name}" criado!'), backgroundColor: Colors.green),
                        );
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (mounted) _showAddItemDialog(context.read<ProductProvider>().products);
                      } else {
                        if (mounted) _showAddItemDialog(context.read<ProductProvider>().products);
                      }
                    },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
                    child: const Icon(Icons.add, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '1',
                decoration: const InputDecoration(labelText: 'Quantidade', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => quantity = int.tryParse(v) ?? 1,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: '0',
                decoration: const InputDecoration(labelText: 'Desconto (%)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => discount = double.tryParse(v) ?? 0.0,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                if (selectedProduct != null) {
                  setState(() {
                    _items.add(QuoteItem(
                      productId: selectedProduct!.id,
                      productName: selectedProduct!.name,
                      description: selectedProduct!.description,
                      quantity: quantity,
                      unitPrice: selectedProduct!.price,
                      discount: discount,
                    ));
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendWhatsAppFollowUp() async {
    if (_selectedCustomer == null) return;
    
    // Remove non-numeric characters from phone
    final phone = _selectedCustomer!.phone.replaceAll(RegExp(r'[^\d]'), '');
    
    final message = '''
Olá ${_selectedCustomer!.name}! 👋

Tudo bem? Sou da Yoobe CRM e estou entrando em contato sobre o orçamento #${widget.quote?.id.substring(widget.quote!.id.length - 6)}.

Gostaria de saber se você ainda tem interesse em prosseguir com o orçamento ou se precisa de algum ajuste?

*Valor Total:* R\$ ${_total.toStringAsFixed(2)}
*Válido até:* ${DateFormat('dd/MM/yyyy').format(_validUntil)}

Estou à disposição para esclarecer dúvidas e realizar ajustes! 😊
''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    }
  }

  Future<void> _sendWhatsAppSchedule() async {
    if (_selectedCustomer == null) return;
    
    final phone = _selectedCustomer!.phone.replaceAll(RegExp(r'[^\d]'), '');
    
    final message = '''
Olá ${_selectedCustomer!.name}! 👋

Aqui é da Yoobe CRM. Gostaria de agendar uma conversa para alinharmos os detalhes do orçamento #${widget.quote?.id.substring(widget.quote!.id.length - 6)}.

*Orçamento:* R\$ ${_total.toStringAsFixed(2)}
*${_items.length} ${_items.length == 1 ? 'item' : 'itens'}*

Quando seria melhor para você? Podemos conversar por aqui ou agendar uma reunião! 📅

Aguardo seu retorno! 😊
''';

    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://api.whatsapp.com/send?phone=$phone&text=$encodedMessage';
    
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    }
  }

  void _saveQuote() {
    if (_selectedCustomer == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente e adicione itens')),
      );
      return;
    }

    final quote = Quote(
      id: widget.quote?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: _selectedCustomer!.id,
      customerName: _selectedCustomer!.name,
      items: _items,
      status: _status,
      validUntil: _validUntil,
      discount: _generalDiscount,
      tax: _tax,
      notes: _notesController.text,
      termsAndConditions: _termsController.text,
      createdAt: widget.quote?.createdAt ?? DateTime.now(),
    );

    if (widget.quote == null) {
      context.read<QuoteProvider>().addQuote(quote);
    } else {
      context.read<QuoteProvider>().updateQuote(quote);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.quote == null ? 'Orçamento criado' : 'Orçamento atualizado')),
    );
  }

  Future<void> _addNewCustomer() async {
    final customer = await showDialog<Customer>(
      context: context,
      builder: (context) => const QuickCustomerDialog(),
    );

    if (customer != null) {
      context.read<CustomerProvider>().addCustomer(customer);
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
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;

  const _TotalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('R\$ ${value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
