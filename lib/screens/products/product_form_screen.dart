import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;
  late TextEditingController _skuController;
  late TextEditingController _stockController;
  late TextEditingController _imageUrlController;
  late TextEditingController _brandController;
  late TextEditingController _materialController;
  late TextEditingController _weightController;
  late TextEditingController _dimensionsController;
  late TextEditingController _minOrderController;
  late TextEditingController _costPriceController;
  late TextEditingController _supplierController;
  late TextEditingController _leadTimeController;
  late TextEditingController _printingAreaController;
  late TextEditingController _barcodeController;
  late TextEditingController _originController;
  
  bool _isAvailable = true;
  List<String> _selectedColors = [];
  List<String> _selectedSizes = [];
  List<String> _selectedTags = [];
  List<String> _selectedPrintingMethods = [];

  // Common options
  final List<String> _commonColors = [
    'Branco', 'Preto', 'Vermelho', 'Azul', 'Verde', 'Amarelo', 
    'Laranja', 'Rosa', 'Roxo', 'Cinza', 'Marrom', 'Bege'
  ];
  
  final List<String> _commonSizes = [
    'PP', 'P', 'M', 'G', 'GG', 'XG', 'Único'
  ];
  
  final List<String> _commonPrintingMethods = [
    'Serigrafia', 'Sublimação', 'Bordado', 'Transfer', 
    'Laser', 'UV', 'Tampografia', 'Digital'
  ];
  
  final List<String> _commonCategories = [
    'Camisetas', 'Bonés e Chapéus', 'Canecas', 'Garrafas e Squeezes',
    'Mochilas e Bolsas', 'Canetas e Lápis', 'Cadernos', 'Chaveiros',
    'Eletrônicos', 'Escritório', 'Eco-Friendly', 'Tecnologia'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '0');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _brandController = TextEditingController(text: widget.product?.brand ?? '');
    _materialController = TextEditingController(text: widget.product?.material ?? '');
    _weightController = TextEditingController(text: widget.product?.weight.toString() ?? '0');
    _dimensionsController = TextEditingController(text: widget.product?.dimensions ?? '');
    _minOrderController = TextEditingController(text: widget.product?.minimumOrderQuantity.toString() ?? '1');
    _costPriceController = TextEditingController(text: widget.product?.costPrice.toString() ?? '0');
    _supplierController = TextEditingController(text: widget.product?.supplier ?? '');
    _leadTimeController = TextEditingController(text: widget.product?.leadTimeDays.toString() ?? '0');
    _printingAreaController = TextEditingController(text: widget.product?.printingArea ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _originController = TextEditingController(text: widget.product?.origin ?? '');
    
    _isAvailable = widget.product?.isAvailable ?? true;
    _selectedColors = widget.product?.colors ?? [];
    _selectedSizes = widget.product?.sizes ?? [];
    _selectedTags = widget.product?.tags ?? [];
    _selectedPrintingMethods = widget.product?.printingMethods ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _brandController.dispose();
    _materialController.dispose();
    _weightController.dispose();
    _dimensionsController.dispose();
    _minOrderController.dispose();
    _costPriceController.dispose();
    _supplierController.dispose();
    _leadTimeController.dispose();
    _printingAreaController.dispose();
    _barcodeController.dispose();
    _originController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
        actions: widget.product != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _showDeleteDialog,
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Basic Information Section
              _buildSectionHeader('Informações Básicas'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Produto *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Insira o nome' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição Detalhada',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Descreva o produto, suas características e vantagens',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _commonCategories.contains(_categoryController.text) ? _categoryController.text : null,
                decoration: const InputDecoration(
                  labelText: 'Categoria *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _commonCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _categoryController.text = value ?? ''),
                validator: (value) => _categoryController.text.isEmpty ? 'Selecione a categoria' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca/Fabricante',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 24),
              
              // Pricing Section
              _buildSectionHeader('Preços e Estoque'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Custo (R\$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monetization_on),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Preço Venda (R\$) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Insira o preço';
                        if (double.tryParse(value!) == null) return 'Preço inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Estoque Atual',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.storage),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _minOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Pedido Mínimo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_cart),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Product Specifications
              _buildSectionHeader('Especificações'),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(
                  labelText: 'SKU / Código *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Insira o SKU' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras / EAN',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.barcode_reader),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _materialController,
                decoration: const InputDecoration(
                  labelText: 'Material',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.texture),
                  hintText: 'Ex: Algodão 100%, Poliéster, Metal, etc',
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Peso (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dimensionsController,
                      decoration: const InputDecoration(
                        labelText: 'Dimensões',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                        hintText: '10x5x2 cm',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origem/Fabricação',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                  hintText: 'Ex: Brasil, China, Nacional',
                ),
              ),
              const SizedBox(height: 24),
              
              // Colors and Sizes
              _buildSectionHeader('Cores e Tamanhos Disponíveis'),
              _buildMultiSelectChips(
                'Cores',
                _commonColors,
                _selectedColors,
                Icons.palette,
              ),
              const SizedBox(height: 16),
              _buildMultiSelectChips(
                'Tamanhos',
                _commonSizes,
                _selectedSizes,
                Icons.straighten,
              ),
              const SizedBox(height: 24),
              
              // Printing/Personalization
              _buildSectionHeader('Personalização'),
              TextFormField(
                controller: _printingAreaController,
                decoration: const InputDecoration(
                  labelText: 'Área de Impressão',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.print),
                  hintText: 'Ex: Frente 20x30cm, Costa 15x20cm',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildMultiSelectChips(
                'Métodos de Impressão',
                _commonPrintingMethods,
                _selectedPrintingMethods,
                Icons.brush,
              ),
              const SizedBox(height: 24),
              
              // Supplier Information
              _buildSectionHeader('Fornecimento'),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_shipping),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _leadTimeController,
                decoration: const InputDecoration(
                  labelText: 'Prazo de Entrega (dias)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              
              // Media
              _buildSectionHeader('Imagem'),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              
              // Availability
              SwitchListTile(
                title: const Text('Produto Disponível para Venda'),
                subtitle: const Text('Produto aparecerá no catálogo'),
                value: _isAvailable,
                onChanged: (value) => setState(() => _isAvailable = value),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 24),
              
              // Save Button
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  widget.product == null ? 'Cadastrar Produto' : 'Salvar Alterações',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectChips(String label, List<String> options, List<String> selected, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: const Text('Deseja realmente excluir este produto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductProvider>().deleteProduct(widget.product!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Produto excluído')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        price: double.parse(_priceController.text),
        sku: _skuController.text,
        stock: int.tryParse(_stockController.text) ?? 0,
        imageUrl: _imageUrlController.text,
        isAvailable: _isAvailable,
        brand: _brandController.text,
        colors: _selectedColors,
        sizes: _selectedSizes,
        material: _materialController.text,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        dimensions: _dimensionsController.text,
        minimumOrderQuantity: int.tryParse(_minOrderController.text) ?? 1,
        costPrice: double.tryParse(_costPriceController.text) ?? 0.0,
        tags: _selectedTags,
        supplier: _supplierController.text,
        leadTimeDays: int.tryParse(_leadTimeController.text) ?? 0,
        printingArea: _printingAreaController.text,
        printingMethods: _selectedPrintingMethods,
        barcode: _barcodeController.text,
        origin: _originController.text,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      if (widget.product == null) {
        context.read<ProductProvider>().addProduct(product);
      } else {
        context.read<ProductProvider>().updateProduct(product);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.product == null ? 'Produto cadastrado com sucesso!' : 'Produto atualizado com sucesso!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
