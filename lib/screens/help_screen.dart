import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Ajuda'),
        elevation: 2,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.help_outline, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Como usar o Yoobe CRM',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guia completo do sistema de gestão',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // Flow Diagram
            const Text(
              '📊 Fluxo do Sistema',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FlowDiagramCard(),

            const SizedBox(height: 32),

            // Topics
            const Text(
              '📚 Tópicos de Ajuda',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _HelpTopic(
              icon: Icons.people_rounded,
              title: '1. Gestão de Clientes',
              color: const Color(0xFF6366F1),
              items: const [
                'Cadastre clientes com informações completas (nome, empresa, email, telefone, endereço)',
                'Visualize o timeline completo de cada cliente mostrando orçamentos, pedidos e produções',
                'Acesse rapidamente o histórico de interações e campanhas',
                'Adicione notas e observações importantes sobre cada cliente',
              ],
            ),

            _HelpTopic(
              icon: Icons.request_quote_rounded,
              title: '2. Orçamentos',
              color: const Color(0xFFF59E0B),
              items: const [
                'Crie orçamentos com múltiplos itens e descontos personalizados',
                'Defina status: Solicitado → Enviado → Aprovado/Cancelado/Não Decidiu',
                'Adicione produtos diretamente do catálogo',
                'Configure prazo de validade e condições de pagamento',
                'IMPORTANTE: Orçamentos aprovados podem ser convertidos em pedidos com um clique!',
              ],
            ),

            _HelpTopic(
              icon: Icons.shopping_bag_rounded,
              title: '3. Pedidos',
              color: const Color(0xFF10B981),
              items: const [
                'Converta orçamentos aprovados em pedidos automaticamente',
                'Adicione nome da campanha e fornecedor para organização',
                'Gerencie notas fiscais: NF Fornecedor e NF Venda',
                'Insira link de pagamento para facilitar o processo',
                'Defina data de entrega e acompanhe o status',
                'IMPORTANTE: Pedidos podem ser enviados diretamente para produção!',
              ],
            ),

            _HelpTopic(
              icon: Icons.factory_rounded,
              title: '4. Produção',
              color: const Color(0xFF8B5CF6),
              items: const [
                'Envie pedidos para produção com um clique',
                '9 status de acompanhamento: OC Criada → Produto Despachado',
                'Gerencie especificações técnicas e detalhes de impressão',
                'Acompanhe prazos de entrega e alertas de atraso',
                'Visualize produções ativas no dashboard principal',
                'Adicione notas internas (não visíveis ao cliente)',
              ],
            ),

            _HelpTopic(
              icon: Icons.inventory_2_rounded,
              title: '5. Catálogo de Produtos',
              color: const Color(0xFF3B82F6),
              items: const [
                'Cadastre produtos com nome, categoria, SKU e preço',
                'Organize por categorias para facilitar busca',
                'Use a busca rápida ao criar orçamentos e pedidos',
                'Adicione descrições detalhadas dos produtos',
              ],
            ),

            _HelpTopic(
              icon: Icons.task_rounded,
              title: '6. Tarefas e Acompanhamento',
              color: const Color(0xFFEC4899),
              items: const [
                'Crie tarefas vinculadas a clientes',
                'Defina prioridades: Urgente, Alta, Normal, Baixa',
                'Acompanhe tarefas de hoje e atrasadas no dashboard',
                'Marque tarefas como concluídas ao finalizar',
              ],
            ),

            const SizedBox(height: 32),

            // Quick Tips
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.blue.shade700, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Dicas Rápidas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _QuickTip(
                    emoji: '⚡',
                    text: 'Use a busca em cada tela para encontrar rapidamente clientes, pedidos ou produtos',
                  ),
                  _QuickTip(
                    emoji: '🔄',
                    text: 'O fluxo completo é: Orçamento → Pedido → Produção. Cada etapa pode ser convertida com um clique!',
                  ),
                  _QuickTip(
                    emoji: '📊',
                    text: 'O dashboard mostra produções ativas e tarefas importantes. Acesse-o frequentemente',
                  ),
                  _QuickTip(
                    emoji: '🎯',
                    text: 'Adicione notas e observações em clientes, pedidos e produções para não perder informações',
                  ),
                  _QuickTip(
                    emoji: '📱',
                    text: 'O sistema funciona tanto no navegador quanto em dispositivos móveis',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Support Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 48, color: Colors.grey.shade600),
                  const SizedBox(height: 16),
                  const Text(
                    'Precisa de mais ajuda?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre em contato com o suporte técnico',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FlowDiagramCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _FlowStep(
              number: '1',
              icon: Icons.request_quote_rounded,
              title: 'Orçamento',
              description: 'Crie orçamento com produtos e valores',
              color: const Color(0xFFF59E0B),
              showArrow: true,
            ),
            _FlowStep(
              number: '2',
              icon: Icons.check_circle,
              title: 'Aprovação',
              description: 'Cliente aprova o orçamento',
              color: const Color(0xFF10B981),
              showArrow: true,
            ),
            _FlowStep(
              number: '3',
              icon: Icons.shopping_cart,
              title: 'Pedido',
              description: 'Converta em pedido com documentos',
              color: const Color(0xFF3B82F6),
              showArrow: true,
            ),
            _FlowStep(
              number: '4',
              icon: Icons.factory,
              title: 'Produção',
              description: 'Envie para produção e acompanhe',
              color: const Color(0xFF8B5CF6),
              showArrow: true,
            ),
            _FlowStep(
              number: '5',
              icon: Icons.local_shipping,
              title: 'Entrega',
              description: 'Produto despachado para o cliente',
              color: const Color(0xFF22C55E),
              showArrow: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowStep extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool showArrow;

  const _FlowStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showArrow)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(Icons.arrow_downward, color: Colors.grey.shade400, size: 24),
              ],
            ),
          ),
      ],
    );
  }
}

class _HelpTopic extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;

  const _HelpTopic({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 12),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTip extends StatelessWidget {
  final String emoji;
  final String text;

  const _QuickTip({
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
