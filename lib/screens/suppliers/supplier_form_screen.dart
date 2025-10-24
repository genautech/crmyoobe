import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier.dart';
import '../../providers/supplier_provider.dart';

class SupplierFormScreen extends StatefulWidget {
  final Supplier? supplier;

  const SupplierFormScreen({super.key, this.supplier});

  @override
  State<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _cnpjController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;
  late TextEditingController _categoryController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _leadTimeDaysController;
  late TextEditingController _notesController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _pixKeyController;
  double _rating = 0.0;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _companyController = TextEditingController(text: widget.supplier?.company ?? '');
    _cnpjController = TextEditingController(text: widget.supplier?.cnpj ?? '');
    _phoneController = TextEditingController(text: widget.supplier?.phone ?? '');
    _emailController = TextEditingController(text: widget.supplier?.email ?? '');
    _addressController = TextEditingController(text: widget.supplier?.address ?? '');
    _cityController = TextEditingController(text: widget.supplier?.city ?? '');
    _stateController = TextEditingController(text: widget.supplier?.state ?? '');
    _zipCodeController = TextEditingController(text: widget.supplier?.zipCode ?? '');
    _categoryController = TextEditingController(text: widget.supplier?.category ?? '');
    _paymentTermsController = TextEditingController(text: widget.supplier?.paymentTerms ?? '');
    _leadTimeDaysController = TextEditingController(text: widget.supplier?.leadTimeDays.toString() ?? '15');
    _notesController = TextEditingController(text: widget.supplier?.notes ?? '');
    _bankNameController = TextEditingController(text: widget.supplier?.bankName ?? '');
    _bankAccountController = TextEditingController(text: widget.supplier?.bankAccount ?? '');
    _pixKeyController = TextEditingController(text: widget.supplier?.pixKey ?? '');
    _rating = widget.supplier?.rating ?? 0.0;
    _isActive = widget.supplier?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _cnpjController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _categoryController.dispose();
    _paymentTermsController.dispose();
    _leadTimeDaysController.dispose();
    _notesController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _pixKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.supplier == null ? 'Novo Produtor' : 'Editar Produtor'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Informações Básicas
              _buildSectionHeader('Informações Básicas', Icons.person),
              _buildTextField(_nameController, 'Nome do Produtor *', Icons.person),
              _buildTextField(_companyController, 'Empresa', Icons.business),
              _buildTextField(_cnpjController, 'CNPJ', Icons.badge),
              _buildTextField(_phoneController, 'Telefone *', Icons.phone, keyboardType: TextInputType.phone),
              _buildTextField(_emailController, 'E-mail *', Icons.email, keyboardType: TextInputType.emailAddress),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Endereço', Icons.location_on),
              _buildTextField(_addressController, 'Endereço Completo', Icons.home),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'Cidade', Icons.location_city)),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: _buildTextField(_stateController, 'UF', Icons.map),
                  ),
                ],
              ),
              _buildTextField(_zipCodeController, 'CEP', Icons.pin_drop),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Informações Comerciais', Icons.business_center),
              _buildTextField(_categoryController, 'Categoria de Produtos', Icons.category),
              _buildTextField(_paymentTermsController, 'Condições de Pagamento', Icons.payment),
              _buildTextField(_leadTimeDaysController, 'Prazo Médio (dias)', Icons.schedule, 
                  keyboardType: TextInputType.number),
              
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Avaliação', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return IconButton(
                              icon: Icon(
                                index < _rating.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () => setState(() => _rating = (index + 1).toDouble()),
                            );
                          }),
                          const SizedBox(width: 8),
                          Text('${_rating.toStringAsFixed(1)}/5.0'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Produtor Ativo'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Dados Bancários', Icons.account_balance),
              _buildTextField(_bankNameController, 'Banco', Icons.account_balance),
              _buildTextField(_bankAccountController, 'Conta/Agência', Icons.numbers),
              _buildTextField(_pixKeyController, 'Chave PIX', Icons.pix),
              
              const SizedBox(height: 24),
              _buildSectionHeader('Observações', Icons.notes),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSupplier,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  widget.supplier == null ? 'Cadastrar Produtor' : 'Salvar Alterações',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (label.contains('*') && (value == null || value.isEmpty)) {
            return 'Campo obrigatório';
          }
          return null;
        },
      ),
    );
  }

  void _saveSupplier() {
    if (!_formKey.currentState!.validate()) return;

    final supplier = Supplier(
      id: widget.supplier?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      company: _companyController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipCodeController.text.trim(),
      category: _categoryController.text.trim(),
      paymentTerms: _paymentTermsController.text.trim(),
      leadTimeDays: int.tryParse(_leadTimeDaysController.text) ?? 15,
      rating: _rating,
      notes: _notesController.text.trim(),
      isActive: _isActive,
      bankName: _bankNameController.text.trim(),
      bankAccount: _bankAccountController.text.trim(),
      pixKey: _pixKeyController.text.trim(),
      createdAt: widget.supplier?.createdAt,
    );

    try {
      if (widget.supplier == null) {
        context.read<SupplierProvider>().addSupplier(supplier);
      } else {
        context.read<SupplierProvider>().updateSupplier(supplier);
      }
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.supplier == null 
              ? 'Produtor cadastrado com sucesso!' 
              : 'Produtor atualizado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
