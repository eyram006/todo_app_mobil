import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/models/task.dart';
import 'package:todo_app/dashboard/services/file_service.dart';
import 'package:todo_app/dashboard/services/task_service.dart';
import 'package:todo_app/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;

  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  final TaskService _taskService = TaskService();
  final FileService _fileService = FileService();
  late Task _task;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final comment = Comment(
      id: DateTime.now().toString(),
      userId: userId,
      content: _commentController.text,
      createdAt: DateTime.now(),
    );

    try {
      await _taskService.addCommentToTask(_task.id, comment);
      setState(() {
        _task.comments.add(comment);
        _commentController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Commentaire ajouté')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur ajout commentaire')));
    }
  }

  Future<void> _addAttachment() async {
    try {
      final fileUrl = await _fileService.pickAndUploadDocument(_task.id);
      if (fileUrl != null) {
        setState(() {
          _task.attachments.add(fileUrl);
        });
        await _taskService.updateTaskAttachments(_task.id, _task.attachments);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pièce jointe ajoutée')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur ajout pièce jointe: $e')));
    }
  }

  Future<void> _removeAttachment(String url) async {
    try {
      await _fileService.deleteFile(url, _task.id);
      setState(() {
        _task.attachments.remove(url);
      });
      await _taskService.updateTaskAttachments(_task.id, _task.attachments);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pièce jointe supprimée')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur suppression pièce jointe')),
      );
    }
  }

  Future<void> _openFile(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le fichier')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erreur ouverture fichier')));
    }
  }

  Future<void> _toggleSubTask(String subTaskId) async {
    final index = _task.subTasks.indexWhere((st) => st.id == subTaskId);
    if (index != -1) {
      final subTask = _task.subTasks[index];
      final updatedSubTask = SubTask(
        id: subTask.id,
        title: subTask.title,
        isCompleted: !subTask.isCompleted,
      );
      _task.subTasks[index] = updatedSubTask;
      try {
        await _taskService.updateTask(_task);
        setState(() {});
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur mise à jour sous-tâche')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_task.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(_task.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _task.status,
                style: TextStyle(
                  color: _getStatusColor(_task.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description (si ajoutée plus tard)
            if (_task.subTasks.isNotEmpty) ...[
              const Text(
                'Sous-tâches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._task.subTasks.map(
                (subTask) => CheckboxListTile(
                  title: Text(subTask.title),
                  value: subTask.isCompleted,
                  onChanged: (value) => _toggleSubTask(subTask.id),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Commentaires
            const Text(
              'Commentaires',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._task.comments.map(
              (comment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(comment.content),
                ),
              ),
            ),

            // Ajouter commentaire
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pièces jointes
            const Text(
              'Pièces jointes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._task.attachments.map(
              (url) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    _fileService.isImageFile(url)
                        ? Icons.image
                        : Icons.attach_file,
                    color: AppColors.primary,
                  ),
                  title: Text(_fileService.getFileNameFromUrl(url)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeAttachment(url),
                  ),
                  onTap: () => _openFile(url),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _addAttachment,
              icon: const Icon(Icons.attach_file),
              label: const Text('Ajouter une pièce jointe'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'To Do':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Done':
        return AppColors.success;
      default:
        return AppColors.textGrey;
    }
  }
}
