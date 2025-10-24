import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import 'task_form_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = _filterStatus == 'all'
        ? taskProvider.tasks
        : taskProvider.getTasksByStatus(_filterStatus);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todas',
                      isSelected: _filterStatus == 'all',
                      onTap: () => setState(() => _filterStatus = 'all'),
                    ),
                    _FilterChip(
                      label: 'Pendente',
                      isSelected: _filterStatus == 'pending',
                      onTap: () => setState(() => _filterStatus = 'pending'),
                    ),
                    _FilterChip(
                      label: 'Em Andamento',
                      isSelected: _filterStatus == 'inProgress',
                      onTap: () => setState(() => _filterStatus = 'inProgress'),
                    ),
                    _FilterChip(
                      label: 'Concluída',
                      isSelected: _filterStatus == 'completed',
                      onTap: () => setState(() => _filterStatus = 'completed'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text('Nenhuma tarefa encontrada', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) {
                                taskProvider.toggleTaskComplete(task.id);
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.customerName),
                                Text(
                                  'Vencimento: ${DateFormat('dd/MM/yyyy').format(task.dueDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.dueDate.isBefore(DateTime.now()) && !task.isCompleted
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                                const PopupMenuItem(value: 'delete', child: Text('Excluir', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => TaskFormScreen(task: task)),
                                  );
                                } else if (value == 'delete') {
                                  await taskProvider.deleteTask(task.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Tarefa excluída')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
