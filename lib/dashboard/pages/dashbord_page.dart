import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importation nécessaire pour SvgPicture
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/pages/create_project_page.dart';
import 'package:todo_app/dashboard/pages/projects_page.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/widgets/dashboard_calendar.dart';
import 'package:todo_app/widgets/dashboard_stats_card.dart';
import 'package:todo_app/widgets/kanban_column.dart';
import 'package:todo_app/widgets/sidebar_item.dart';

import '../../auth/pages/login.dart'; // Assurez-vous que cette page existe
import '../../welcome.dart'; // Import pour la page d'accueil
import '../models/project.dart';
import '../services/project_service.dart';
import 'member_details_page.dart'; // Import de la page des détails du membre

// Colors are centralized in `lib/theme.dart` (AppColors)

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ProjectService _projectService = ProjectService();
  List<Project> _projects = [];
  bool _loading = true;
  int _selectedIndex = 0; // Pour la sélection du Drawer
  Map<String, dynamic>? _currentUserProfile;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _loading = true; // Active l'indicateur de chargement
    });
    try {
      final String? userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
        return;
      }

      final projects = await _projectService.getUserProjects(userId);
      setState(() {
        _projects = projects;
        _loading = false;
      });

      // Charger le profil utilisateur associé
      await _loadUserProfile(userId);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des projets: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _currentUserProfile = Map<String, dynamic>.from(response as Map);
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Erreur lors du chargement du profil utilisateur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculer les comptes pour les statistiques (utilisés dans _buildDashboardContent)

    return Scaffold(
      backgroundColor: AppColors.background,
      // AppBar pour mobile : Logo et nom de l'app
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.8, // Ombre subtile sous l'AppBar
        title: Row(
          mainAxisSize: MainAxisSize.min, // Occupe le minimum de largeur
          children: [
            // Logo TODO - Le SVG s'affichera avec les couleurs définies dans le fichier SVG lui-même.
            // Si vous voulez une couleur spécifique ici, éditez le fichier SVG ou réactivez colorFilter.
            SvgPicture.asset(
              'assets/images/Logo_ToDo.svg', // Assurez-vous que ce chemin est correct
              height: 40,
              width: 40,
              // colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn), // Remplacé/désactivé
            ),
            const SizedBox(width: 8),
          ],
        ),
        centerTitle: true, // Centre le titre et le logo
        iconTheme: IconThemeData(
          color: AppColors.textDark,
        ), // Couleur de l'icône du Drawer
      ),
      // Drawer pour la navigation mobile (menu hamburger)
      drawer: _buildDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 4,
                // Color.withOpacity n'est pas déprécié. Utilisé pour la transparence.
                backgroundColor: AppColors.primary.withOpacity(0.2),
              ),
            )
          : _buildBodyContent(),
    );
  }

  // Méthode pour construire l'en-tête (slogan, titre, bouton)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tableau de Bord",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Gérez vos projets et suivez leur avancement",
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
        ),
        const SizedBox(height: 20), // Espacement avant le bouton
        SizedBox(
          width: double.infinity, // Bouton prend toute la largeur disponible
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProjectPage(),
                ),
              );
              if (result == true) {
                _loadProjects();
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Nouveau Projet"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0: // Dashboard
        return _buildDashboardContent();
      case 2: // Équipe
        return _buildTeamContent();
      default: // Autres pages (temporairement dashboard)
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    // Calculer les comptes pour les statistiques
    final todoCount = _projects
        .where((p) => p.status.toLowerCase() == "to do")
        .length;
    final inProgressCount = _projects
        .where((p) => p.status.toLowerCase() == "in progress")
        .length;
    final doneCount = _projects
        .where((p) => p.status.toLowerCase() == "done")
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16), // Padding global pour mobile
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(), // En-tête du tableau de bord
          const SizedBox(height: 20),

          // Statistiques - adaptées et empilées pour mobile
          DashboardStatsCard(
            title: "Tâches à Faire",
            value: "$todoCount",
            color: AppColors.lightBlue,
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 12),
          DashboardStatsCard(
            title: "Tâches En Cours",
            value: "$inProgressCount",
            color: AppColors.lightGreen,
            icon: Icons.pending_actions_outlined,
          ),
          const SizedBox(height: 12),
          DashboardStatsCard(
            title: "Tâches Terminées",
            value: "$doneCount",
            color: AppColors.lightPurple,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 24),

          Text(
            "Avancement des Projets", // Titre pour la section Kanban
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Section Kanban - empilée verticalement pour mobile
          KanbanColumn(
            title: "To Do",
            color: AppColors.lightBlue,
            projects: _projects
                .where((p) => p.status.toLowerCase() == "to do")
                .toList(),
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 16),
          KanbanColumn(
            title: "In Progress",
            color: AppColors.lightGreen,
            projects: _projects
                .where((p) => p.status.toLowerCase() == "in progress")
                .toList(),
            icon: Icons.pending_actions_outlined,
          ),
          const SizedBox(height: 16),
          KanbanColumn(
            title: "Done",
            color: AppColors.lightPurple,
            projects: _projects
                .where((p) => p.status.toLowerCase() == "done")
                .toList(),
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 24),

          const DashboardCalendar(), // Calendrier
          const SizedBox(height: 16), // Espacement pour le bas de la page
        ],
      ),
    );
  }

  Widget _buildTeamContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Équipe",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Membres de l'équipe et leurs tâches assignées",
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          const SizedBox(height: 24),

          // Liste des membres de l'équipe (simulation pour l'instant)
          _buildTeamMemberCard(
            name: "Alice Dupont",
            email: "alice@example.com",
            avatarColor: AppColors.primary,
            tasksAssigned: 5,
            tasksCompleted: 3,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Alice Dupont",
                  email: "alice@example.com",
                  avatarColor: AppColors.primary,
                  tasksAssigned: 5,
                  tasksCompleted: 3,
                  joinDate: "Janvier 2024",
                  role: "Développeur Frontend",
                  activeProjects: [
                    "Application Mobile Todo",
                    "Refonte Site Web",
                    "Dashboard Analytics",
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildTeamMemberCard(
            name: "Bob Martin",
            email: "bob@example.com",
            avatarColor: AppColors.lightGreen,
            tasksAssigned: 8,
            tasksCompleted: 6,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Bob Martin",
                  email: "bob@example.com",
                  avatarColor: AppColors.lightGreen,
                  tasksAssigned: 8,
                  tasksCompleted: 6,
                  joinDate: "Mars 2024",
                  role: "Développeur Backend",
                  activeProjects: [
                    "API Backend",
                    "Base de données",
                    "Intégration CI/CD",
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildTeamMemberCard(
            name: "Claire Bernard",
            email: "claire@example.com",
            avatarColor: AppColors.lightPurple,
            tasksAssigned: 4,
            tasksCompleted: 2,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Claire Bernard",
                  email: "claire@example.com",
                  avatarColor: AppColors.lightPurple,
                  tasksAssigned: 4,
                  tasksCompleted: 2,
                  joinDate: "Mai 2024",
                  role: "Designer UX/UI",
                  activeProjects: [
                    "Refonte Site Web",
                    "Application Mobile Todo",
                    "Design System",
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section pour inviter de nouveaux membres
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.person_add_outlined,
                  color: AppColors.primary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  "Inviter un nouveau membre",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ajoutez de nouveaux membres à votre équipe",
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implémenter l'invitation de membres
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir !'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Inviter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberCard({
    required String name,
    required String email,
    required Color avatarColor,
    required int tasksAssigned,
    required int tasksCompleted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: avatarColor.withOpacity(0.2),
              child: Text(
                name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: avatarColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$tasksAssigned tâches assignées",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$tasksCompleted terminées",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_vert,
              color: AppColors.textGrey.withOpacity(0.7),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // Color.withOpacity n'est pas déprécié.
              color: AppColors.primary.withOpacity(0.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/Logo_ToDo.svg', // Assurez-vous que ce chemin est correct
                  height: 40,
                  width: 40,
                  // colorFilter: const ColorFilter.mode(primaryBlue, BlendMode.srcIn), // Remplacé/désactivé
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding:
                  EdgeInsets.zero, // Supprime le padding par défaut du ListView
              children: [
                SidebarItem(
                  title: "Dashboard",
                  icon: Icons.dashboard_outlined,
                  isSelected: _selectedIndex == 0,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                    Navigator.pop(
                      context,
                    ); // Ferme le Drawer après la sélection
                  },
                ),
                SidebarItem(
                  title: "Mes Projets",
                  icon: Icons.folder_outlined,
                  isSelected: _selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context); // ferme le drawer

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectsPage(),
                      ),
                    );
                  },
                ),
                SidebarItem(
                  title: "Équipe",
                  icon: Icons.people_outline,
                  isSelected: _selectedIndex == 2,
                  onTap: () {
                    setState(() => _selectedIndex = 2);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Chat & Meet",
                  icon: Icons.chat_outlined,
                  isSelected: _selectedIndex == 3,
                  onTap: () {
                    setState(() => _selectedIndex = 3);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Journal & Stats",
                  icon: Icons.analytics_outlined,
                  isSelected: _selectedIndex == 4,
                  onTap: () {
                    setState(() => _selectedIndex = 4);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Paramètres",
                  icon: Icons.settings_outlined,
                  isSelected: _selectedIndex == 5,
                  onTap: () {
                    setState(() => _selectedIndex = 5);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Carte profil utilisateur en bas du Drawer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // Color.withOpacity n'est pas déprécié.
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    // Color.withOpacity n'est pas déprécié.
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentUserProfile?['username'] ?? 'Utilisateur',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentUserProfile?['email'] ?? 'En ligne',
                          style: TextStyle(
                            // Color.withOpacity n'est pas déprécié.
                            color: AppColors.textGrey.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Color.withOpacity n'est pas déprécié.
                  Icon(
                    Icons.more_vert,
                    color: AppColors.textGrey.withOpacity(0.7),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          // Bouton de déconnexion
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Fermer le drawer d'abord
                  Navigator.pop(context);

                  // Afficher une boîte de dialogue de confirmation
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                        'Voulez-vous vraiment vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    try {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        // Rediriger vers la page d'accueil
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => Welcome()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de la déconnexion: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
