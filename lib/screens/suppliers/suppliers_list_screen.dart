import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/supplier.dart';
import '../../providers/supplier_provider.dart';
import 'supplier_form_screen.dart';
import 'supplier_detail_screen.dart';

class SuppliersListScreen extends StatefulWidget {
  const SuppliersListScreen({super.key});

  @override
  State<SuppliersListScreen> createState() => _SuppliersListScreenState();
}

class _SuppliersListScreenState extends State<SuppliersListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final supplierProvider = context.watch<SupplierProvider>();
    final suppliers = _getFilteredSuppliers(supplierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtores/Fornecedores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(supplierProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats Card
            _buildStatsCard(supplierProvider),
            
            // Search/Filter Display
            if (_searchQuery.isNotEmpty || _selectedCategory != 'Todos')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    if (_searchQuery.isNotEmpty) ...[
                      const Icon(Icons.search, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Busca: "$_searchQuery"',
                        style: const TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (_selectedCategory != 'Todos') ...[
                      const Icon(Icons.category, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCategory,
                        style: const TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'Todos';
                        });
                      },
                      child: const Text('Limpar'),
                    ),
                  ],
                ),
              ),

            // Suppliers List
            Expanded(
              child: suppliers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        return _buildSupplierCard(suppliers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SupplierFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Produtor'),
      ),
    );
  }

  List<Supplier> _getFilteredSuppliers(SupplierProvider provider) {
    var suppliers = provider.suppliers;

    if (_searchQuery.isNotEmpty) {
      suppliers = provider.searchSuppliers(_searchQuery);
    }

    if (_selectedCategory != 'Todos') {
      suppliers = suppliers
          .where((s) => s.category == _selectedCategory)
          .toList();
    }

    return suppliers;
  }

  Widget _buildStatsCard(SupplierProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.inventory,
              label: 'Total',
              value: provider.totalSuppliers.toString(),
              color: Colors.indigo,
            ),
            _buildStatItem(
              icon: Icons.check_circle,
              label: 'Ativos',
              value: provider.activeCount.toString(),
              color: Colors.green,
            ),
            _buildStatItem(
              icon: Icons.star,
              label: 'Média',
              value: provider.averageRating.toStringAsFixed(1),
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierCard(Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: supplier.isActive
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Icon(
            Icons.factory,
            color: supplier.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                supplier.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (supplier.rating > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      supplier.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.company.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(supplier.company, style: const TextStyle(fontSize: 13)),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (supplier.category.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      supplier.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (supplier.leadTimeDays > 0) ...[
                  Icon(Icons.schedule, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 2),
                  Text(
                    '${supplier.leadTimeDays} dias',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
            if (supplier.phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    supplier.phone,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupplierDetailScreen(supplier: supplier),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.factory, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Todos'
                ? 'Nenhum produtor encontrado'
                : 'Nenhum produtor cadastrado',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != 'Todos'
                ? 'Tente ajustar os filtros'
                : 'Clique no botão + para adicionar',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        return AlertDialog(
          title: const Text('Buscar Produtor'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nome, empresa, categoria...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => query = value,
            onSubmitted: (value) {
              setState(() => _searchQuery = value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = query);
                Navigator.pop(context);
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog(SupplierProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedCategory = _selectedCategory;
        return AlertDialog(
          title: const Text('Filtrar por Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Todos'),
                value: 'Todos',
                groupValue: selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                  Navigator.pop(context);
                },
              ),
              ...provider.categories.map((category) {
                return RadioListTile<String>(
                  title: Text(category),
                  value: category,
                  groupValue: selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
