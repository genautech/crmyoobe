import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _darkMode = false;
  String _language = 'pt_BR';
  String _companyName = 'Yoobe CRM';
  String _companyPhone = '+55 41 93618-3128';
  String _companyEmail = 'contato@yoobe.com.br';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? false;
      _darkMode = prefs.getBool('dark_mode') ?? false;
      _language = prefs.getString('language') ?? 'pt_BR';
      _companyName = prefs.getString('company_name') ?? 'Yoobe CRM';
      _companyPhone = prefs.getString('company_phone') ?? '+55 41 93618-3128';
      _companyEmail = prefs.getString('company_email') ?? 'contato@yoobe.com.br';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          // App Info
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.business_center_rounded,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yoobe CRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Versão 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Conta
          _buildSection('Conta', [
            _buildListTile(
              icon: Icons.business_rounded,
              title: 'Nome da Empresa',
              subtitle: _companyName,
              onTap: () => _showEditDialog(
                'Nome da Empresa',
                _companyName,
                (value) {
                  setState(() => _companyName = value);
                  _saveSetting('company_name', value);
                },
              ),
            ),
            _buildListTile(
              icon: Icons.phone_rounded,
              title: 'Telefone da Empresa',
              subtitle: _companyPhone,
              onTap: () => _showEditDialog(
                'Telefone da Empresa',
                _companyPhone,
                (value) {
                  setState(() => _companyPhone = value);
                  _saveSetting('company_phone', value);
                },
              ),
            ),
            _buildListTile(
              icon: Icons.email_rounded,
              title: 'Email da Empresa',
              subtitle: _companyEmail,
              onTap: () => _showEditDialog(
                'Email da Empresa',
                _companyEmail,
                (value) {
                  setState(() => _companyEmail = value);
                  _saveSetting('company_email', value);
                },
                isEmail: true,
              ),
            ),
          ]),

          // Notificações
          _buildSection('Notificações', [
            _buildSwitchTile(
              icon: Icons.notifications_rounded,
              title: 'Notificações Push',
              subtitle: 'Receba alertas sobre tarefas e orçamentos',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _saveSetting('notifications_enabled', value);
              },
            ),
            _buildSwitchTile(
              icon: Icons.email_rounded,
              title: 'Notificações por Email',
              subtitle: 'Receba resumos diários por email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() => _emailNotifications = value);
                _saveSetting('email_notifications', value);
              },
            ),
          ]),

          // Aparência
          _buildSection('Aparência', [
            _buildSwitchTile(
              icon: Icons.dark_mode_rounded,
              title: 'Modo Escuro',
              subtitle: 'Em breve: Interface com tema escuro',
              value: _darkMode,
              onChanged: (value) {
                setState(() => _darkMode = value);
                _saveSetting('dark_mode', value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Modo escuro será implementado em breve!'),
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.language_rounded,
              title: 'Idioma',
              subtitle: _language == 'pt_BR' ? 'Português (Brasil)' : 'English',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Futura implementação de seleção de idioma
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Seleção de idioma será implementada em breve!'),
                  ),
                );
              },
            ),
          ]),

          // Dados
          _buildSection('Dados', [
            _buildListTile(
              icon: Icons.backup_rounded,
              title: 'Backup de Dados',
              subtitle: 'Exportar dados do CRM',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Backup de Dados'),
                    content: const Text(
                      'Esta funcionalidade permitirá exportar todos os seus dados (clientes, tarefas, pedidos e orçamentos) em formato JSON.\n\nEm breve!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Entendi'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildListTile(
              icon: Icons.delete_rounded,
              title: 'Limpar Dados',
              subtitle: 'Remover todos os dados locais',
              textColor: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar Dados'),
                    content: const Text(
                      'Tem certeza que deseja remover TODOS os dados?\n\nEsta ação não pode ser desfeita!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade será implementada em breve'),
                            ),
                          );
                        },
                        child: const Text('Limpar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]),

          // Suporte
          _buildSection('Suporte', [
            _buildListTile(
              icon: Icons.help_rounded,
              title: 'Central de Ajuda',
              subtitle: 'Tutoriais e perguntas frequentes',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Central de ajuda em breve!')),
                );
              },
            ),
            _buildListTile(
              icon: Icons.chat_bubble_rounded,
              title: 'Falar com Suporte',
              subtitle: 'WhatsApp: $_companyPhone',
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () async {
                final phone = _companyPhone.replaceAll(RegExp(r'[^\d]'), '');
                final message = Uri.encodeComponent('Olá! Preciso de ajuda com o Yoobe CRM.');
                final url = 'https://api.whatsapp.com/send?phone=$phone&text=$message';
                
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                }
              },
            ),
            _buildListTile(
              icon: Icons.info_rounded,
              title: 'Sobre o App',
              subtitle: 'Informações e créditos',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Yoobe CRM',
                  applicationVersion: '1.0.0',
                  applicationIcon: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.business_center, color: Colors.white, size: 32),
                  ),
                  children: const [
                    Text('Sistema completo de gestão de relacionamento com clientes.'),
                    SizedBox(height: 16),
                    Text('Recursos:'),
                    Text('• Gestão de clientes e contatos'),
                    Text('• Controle de tarefas e atividades'),
                    Text('• Orçamentos e pedidos'),
                    Text('• Catálogo de produtos'),
                    Text('• Integração WhatsApp'),
                  ],
                );
              },
            ),
          ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? Theme.of(context).primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showEditDialog(String title, String initialValue, Function(String) onSave, {bool isEmail = false}) {
    final controller = TextEditingController(text: initialValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
            hintText: isEmail ? 'exemplo@empresa.com' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuração salva!')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
