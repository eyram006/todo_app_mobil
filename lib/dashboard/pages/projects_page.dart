import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/widgets/widgets.dart';

import '../models/project.dart';
import '../services/project_service.dart';
import 'project_details_page.dart';

// Use AppColors directly

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ProjectService _projectService = ProjectService();

  List<Project> projects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      final data = await _projectService.getUserProjects(user.id);
      if (mounted) {
        setState(() {
          projects = data;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement projets: $e");
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
  }

  void _showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime? selectedDate;
    String selectedStatus = 'todo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Nouveau projet"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nom du projet",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: "Statut",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'todo', child: Text("À faire")),
                      DropdownMenuItem(
                        value: 'in_progress',
                        child: Text("En cours"),
                      ),
                      DropdownMenuItem(value: 'done', child: Text("Terminé")),
                    ],
                    onChanged: (val) {
                      if (val != null)
                        setStateDialog(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? "Pas de date limite"
                              : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setStateDialog(() => selectedDate = picked);
                          }
                        },
                        child: const Text("Choisir date"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  final user = supabase.auth.currentUser;
                  if (user == null) return;

                  final newProject = Project(
                    id: '', // Supabase generates ID
                    name: name,
                    description: descriptionController.text.trim(),
                    status: selectedStatus,
                    deadline: selectedDate,
                    ownerId: user.id,
                  );

                  try {
                    await _projectService.createProject(newProject);
                    if (mounted) Navigator.pop(context);
                    _loadProjects();
                  } catch (e) {
                    debugPrint("Erreur création projet: $e");
                  }
                },
                child: const Text("Créer"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mes Projets"),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0.5,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProjectDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nouveau Projet",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : projects.isEmpty
          ? _buildEmptyState()
          : _buildProjectList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "Aucun projet pour le moment",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Créez votre premier projet pour commencer",
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailsPage(project: project),
              ),
            );
          },
          child: ProjectCard(project: project),
        );
      },
    );
  }
}
