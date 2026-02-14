import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/project_service.dart';
import '../models/project.dart';


const Color primaryBlue = Color(0xFF21B6EC);
const Color textDark = Color(0xFF161E2B);

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> projects = [];
  List<dynamic> tasks = [];

  bool loading = true;
  String? selectedProjectId;

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    final response = await supabase.from('projects').select();

    setState(() {
      projects = response;
      loading = false;
    });
  }

  Future<void> fetchTasks(String projectId) async {
    final response = await supabase
        .from('tasks')
        .select()
        .eq('project_id', projectId);

    setState(() {
      tasks = response;
      selectedProjectId = projectId;
    });
  }

  // ===================== CREATE PROJECT =====================

  void showCreateProjectDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    String selectedStatus = 'todo';
    DateTime? selectedDeadline;

    final user = Supabase.instance.client.auth.currentUser;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Créer un projet"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// NOM
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Nom du projet",
                      ),
                    ),

                    const SizedBox(height: 12),
                    /// DESCRIPTION
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// STATUS
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      items: const [
                        DropdownMenuItem(
                            value: 'todo', child: Text("À faire")),
                        DropdownMenuItem(
                            value: 'in_progress',
                            child: Text("En cours")),
                        DropdownMenuItem(
                            value: 'done', child: Text("Terminé")),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedStatus = value!;
                        });
                      },
                      decoration:
                      const InputDecoration(labelText: "Statut"),
                    ),

                    const SizedBox(height: 12),

                    /// DEADLINE
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDeadline == null
                              ? "Pas de deadline"
                              : "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}",
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked =
                            await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2023),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setStateDialog(() {
                                selectedDeadline = picked;
                              });
                            }
                          },
                          child: const Text("Choisir date de fin"),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              /// ACTIONS
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty || user == null) return;

                    final newProject = Project(
                      id: '',
                      name: name,
                      description:
                      descriptionController.text.trim(),
                      status: selectedStatus,
                      deadline: selectedDeadline,
                      ownerId: user.id,
                    );

                    try {
                      await ProjectService().createProject(newProject);
                      if (mounted) {
                        Navigator.pop(context); // Ferme la boîte de dialogue
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Projet créé avec succès !")),
                        );
                        fetchProjects(); // Rafraîchit la liste des projets
                      }
                    } catch (e) {
                      // Capture l'erreur et l'affiche à l'utilisateur
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur lors de la création du projet : ${e.toString()}")),
                        );
                        print("Erreur de création de projet : $e"); // Pour le débogage technique en console
                      }
                    }
                  },
                  child: const Text("Créer"),
                )
              ],
            );
          },
        );
      },
    );
  }


  // ===================== CREATE TASK =====================

  void createTask() {
    if (selectedProjectId == null) return;

    final title = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Créer une tâche"),
        content: TextField(controller: title),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('tasks').insert({
                'title': title.text,
                'project_id': selectedProjectId,
                'status': 'To Do',
              });

              Navigator.pop(context);
              fetchTasks(selectedProjectId!);
            },
            child: const Text("Créer"),
          )
        ],
      ),
    );
  }

  // ===================== UPDATE STATUS =====================

  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    await supabase
        .from('tasks')
        .update({'status': newStatus})
        .eq('id', taskId);

    fetchTasks(selectedProjectId!);
  }

  // ===================== DELETE =====================

  Future<void> deleteTask(String id) async {
    await supabase.from('tasks').delete().eq('id', id);
    fetchTasks(selectedProjectId!);
  }

  Future<void> deleteProject(String id) async {
    await supabase.from('projects').delete().eq('id', id);
    fetchProjects();
    setState(() {
      tasks = [];
      selectedProjectId = null;
    });
  }

  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des projets"),
        backgroundColor: primaryBlue,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "addProject",
            onPressed: showCreateProjectDialog,
            child: const Icon(Icons.folder),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "addTask",
            onPressed: createTask,
            child: const Icon(Icons.task),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Row(
        children: [
          // ========= PROJECTS =========
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (_, index) {
                final project = projects[index];
                return ListTile(
                  title: Text(project['name'] ?? ''),
                  onTap: () => fetchTasks(project['id']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProject(project['id']),
                  ),
                );
              },
            ),
          ),

          // ========= TASKS =========
          Expanded(
            flex: 3,
            child: selectedProjectId == null
                ? const Center(child: Text("Sélectionnez un projet"))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];

                return Card(
                  child: ListTile(
                    title: Text(task['title']),
                    subtitle: Text(task['status']),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          updateTaskStatus(task['id'], value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'To Do',
                            child: Text("To Do")),
                        PopupMenuItem(
                            value: 'In Progress',
                            child: Text("In Progress")),
                        PopupMenuItem(
                            value: 'Done',
                            child: Text("Done")),
                      ],
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () =>
                          deleteTask(task['id']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
