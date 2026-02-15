import 'package:flutter/material.dart';
import 'package:todo_app/dashboard/models/project.dart';
import 'package:todo_app/dashboard/models/task.dart';
import 'package:todo_app/dashboard/services/task_service.dart';
import 'package:todo_app/theme.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage({super.key, required this.project});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final TaskService _taskService = TaskService();
  List<Task> tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final data = await _taskService.getTasksByProject(widget.project.id);
      if (mounted) {
        setState(() {
          tasks = data;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur chargement tâches')),
        );
      }
    }
  }

  Future<void> _createTask() async {
    final titleController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nouvelle tâche"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Titre de la tâche"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isEmpty) return;

              try {
                // Assuming 'To Do' is default status
                await _taskService.createTask(
                  title,
                  widget.project.id,
                  'To Do',
                );
                if (mounted) Navigator.pop(context);
                _loadTasks();
              } catch (e) {
                debugPrint('Erreur création tâche: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur création tâche')),
                  );
                }
              }
            },
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(Task task) async {
    // Simple toggle logic: To Do -> In Progress -> Done -> To Do
    String newStatus = 'To Do';
    if (task.status == 'To Do')
      newStatus = 'In Progress';
    else if (task.status == 'In Progress')
      newStatus = 'Done';

    try {
      await _taskService.updateTaskStatus(task.id, newStatus);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur mise à jour status')),
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await _taskService.deleteTask(taskId);
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Erreur suppression')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.project.name),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: AppColors.textGrey.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aucune tâche pour le moment",
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final status = task.status;

                Color statusColor = AppColors.textGrey;
                if (status == 'To Do') statusColor = Colors.orange;
                if (status == 'In Progress') statusColor = Colors.blue;
                if (status == 'Done') statusColor = AppColors.success;

                return Card(
                  elevation: 0,
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.textGrey.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withValues(alpha: 0.1),
                      child: Icon(
                        status == 'Done' ? Icons.check : Icons.circle,
                        color: statusColor,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: status == 'Done'
                            ? TextDecoration.lineThrough
                            : null,
                        color: status == 'done'
                            ? AppColors.textGrey
                            : AppColors.textDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      "Status: $status",
                      style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      onPressed: () => _deleteTask(task.id),
                    ),
                    onTap: () => _updateTaskStatus(task),
                  ),
                );
              },
            ),
    );
  }
}
