import 'package:flutter/material.dart';
import '../../models/product.dart';

/// Dialog rápido para adicionar produto durante criação de pedido/orçamento
class QuickProductDialog extends StatefulWidget {
  const QuickProductDialog({super.key});

  @override
  State<QuickProductDialog> createState() => _QuickProductDialogState();
}

class _QuickProductDialogState extends State<QuickProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String _selectedCategory = 'Vestuário';

  final List<String> _categories = [
    'Vestuário',
    'Acessórios',
    'Casa e Cozinha',
    'Utilidades',
    'Bags',
    'Escritório',
    'Papelaria',
    'Tecnologia',
    'Outros',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.add_shopping_cart,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Novo Produto Rápido'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Campo obrigatório' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Preço (R\$) *',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '29.90',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Campo obrigatório';
                  if (double.tryParse(v!) == null) return 'Preço inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Estoque Inicial *',
                  prefixIcon: Icon(Icons.inventory),
                  hintText: '100',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Campo obrigatório';
                  if (int.tryParse(v!) == null) return 'Quantidade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você pode editar detalhes completos depois',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _saveProduct,
          icon: const Icon(Icons.check),
          label: const Text('Criar Produto'),
        ),
      ],
    );
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'Produto criado rapidamente'
          : _descriptionController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory,
      stock: int.parse(_stockController.text.trim()),
      sku: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
      imageUrl: '',
      // Campos adicionais com valores padrão
      brand: 'Yoobe',
      colors: [],
      sizes: [],
      material: '',
      weight: 0.0,
      dimensions: '',
      minimumOrderQuantity: 1,
      costPrice: double.parse(_priceController.text.trim()) * 0.6, // 60% do preço
      tags: [_selectedCategory.toLowerCase()],
      supplier: '',
      leadTimeDays: 15,
      printingArea: '',
      printingMethods: [],
      barcode: '',
      origin: 'Brasil',
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, product);
  }
}
