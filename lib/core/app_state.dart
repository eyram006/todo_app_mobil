import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/models/project.dart';
import 'package:todo_app/dashboard/services/member_service.dart';
import 'package:todo_app/dashboard/services/project_service.dart';

/// État global de l'application utilisant Provider
class AppState extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();
  final MemberService _memberService = MemberService();

  // État des données
  List<Project> _projects = [];
  List<Map<String, dynamic>> _teamMembers = [];
  Map<String, dynamic>? _currentUserProfile;
  bool _isLoading = true;

  // Getters
  List<Project> get projects => _projects;
  List<Map<String, dynamic>> get teamMembers => _teamMembers;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;

  // Computed properties
  int get totalProjects => _projects.length;
  int get completedTasks =>
      _projects.where((p) => p.status.toLowerCase() == "done").length;
  int get inProgressTasks =>
      _projects.where((p) => p.status.toLowerCase() == "in progress").length;
  int get todoTasks =>
      _projects.where((p) => p.status.toLowerCase() == "to do").length;

  /// Charge toutes les données initiales
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([_loadProjects(), _loadTeamMembers()]);
    } catch (e) {
      debugPrint('Erreur chargement données: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charge les projets de l'utilisateur
  Future<void> _loadProjects() async {
    final String? userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final projects = await _projectService.getUserProjects(userId);
    _projects = projects;

    // Charger le profil utilisateur
    await _loadUserProfile(userId);
  }

  /// Charge les membres de l'équipe
  Future<void> _loadTeamMembers() async {
    final members = await _memberService.getTeamMembers();
    _teamMembers = members;
  }

  /// Charge le profil utilisateur
  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _currentUserProfile = Map<String, dynamic>.from(response as Map);
      }
    } catch (e) {
      debugPrint('Erreur chargement profil: $e');
    }
  }

  /// Actualise les données
  Future<void> refreshData() async {
    await loadInitialData();
  }

  /// Calcule les statistiques d'un membre
  Map<String, dynamic> calculateMemberStats(String memberId) {
    int tasksAssigned = 0;
    int tasksCompleted = 0;

    // Parcourir tous les projets pour compter les tâches
    for (final project in _projects) {
      if (project.memberIds.contains(memberId)) {
        // Simulation des statistiques (à remplacer par vraie logique)
        tasksAssigned += (project.name.length % 5) + 1;
        tasksCompleted += (project.name.length % 3);
      }
    }

    return {'tasksAssigned': tasksAssigned, 'tasksCompleted': tasksCompleted};
  }

  /// Ajoute un nouveau projet
  Future<void> addProject(Project project) async {
    await _projectService.createProject(project);
    await _loadProjects(); // Recharger la liste
  }

  /// Supprime un projet
  Future<void> deleteProject(String projectId) async {
    await _projectService.deleteProject(projectId);
    await _loadProjects(); // Recharger la liste
  }
}
