import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  void createProject() {
    final name = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Créer un projet"),
        content: TextField(controller: name),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('projects').insert({
                'name': name.text,
                'status': 'To Do',
              });

              Navigator.pop(context);
              fetchProjects();
            },
            child: const Text("Créer"),
          )
        ],
      ),
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
            onPressed: createProject,
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
