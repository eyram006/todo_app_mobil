import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/models/task.dart';
import 'package:todo_app/dashboard/services/task_service.dart';
import 'package:todo_app/theme.dart';

class TasksPage extends StatefulWidget {
  final String? projectId;

  const TasksPage({super.key, this.projectId});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      if (widget.projectId != null) {
        // Filtrer par projet sélectionné
        _tasks = await _taskService.getTasksByProject(widget.projectId!);
      } else {
        // Charger toutes les tâches de l'utilisateur
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId != null) {
          // Récupérer tous les projets de l'utilisateur
          final projectsResponse = await Supabase.instance.client
              .from('projects')
              .select('id')
              .contains('member_ids', [userId]);

          final projectIds = (projectsResponse as List)
              .map((p) => p['id'] as String)
              .toList();

          // Charger toutes les tâches de ces projets
          final allTasks = <Task>[];
          for (final projectId in projectIds) {
            final projectTasks = await _taskService.getTasksByProject(
              projectId,
            );
            allTasks.addAll(projectTasks);
          }

          _tasks = allTasks;
        }
      }
      setState(() => _loading = false);
    } catch (e) {
      debugPrint('Erreur chargement tâches: $e');
      setState(() => _loading = false);
    }
  }

  List<Task> _getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  Future<void> _updateTaskStatus(Task task, String newStatus) async {
    try {
      await _taskService.updateTaskStatus(task.id, newStatus);
      _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur mise à jour')));
    }
  }

  Widget _buildTaskColumn(
    String title,
    List<Task> tasks,
    Function(Task) onTap,
  ) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  onTap: () => onTap(task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTaskColumn(
                    'À faire',
                    _getTasksByStatus('To Do'),
                    (task) => _updateTaskStatus(task, 'In Progress'),
                  ),
                  _buildTaskColumn(
                    'En cours',
                    _getTasksByStatus('In Progress'),
                    (task) => _updateTaskStatus(task, 'Done'),
                  ),
                  _buildTaskColumn(
                    'Terminé',
                    _getTasksByStatus('Done'),
                    (task) => _updateTaskStatus(task, 'To Do'),
                  ),
                ],
              ),
            ),
    );
  }
}
