import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importation nécessaire pour SvgPicture
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/dashboard/pages/projects_page.dart';

import '../../auth/pages/login.dart'; // Assurez-vous que cette page existe
import '../../welcome.dart'; // Import pour la page d'accueil
import '../models/project.dart';
import '../services/project_service.dart';
import 'member_details_page.dart'; // Import de la page des détails du membre

// --- Palette de couleurs "TODO" ---
const Color primaryBlue = Color(0xFF21B6EC); // Bleu Cyan Dynamique
const Color lightBlue = Color(0xFF5ADFF6); // Aqua Pâle (To Do)
const Color lightGreen = Color(0xFFD1FAE5); // Vert Menthe Clair (In Progress)
const Color lightPurple = Color(0xFFEDE9FE); // Lavande Douce (Done)

const Color backgroundColor = Color(
  0xFFF9FAFB,
); // Gris Très Clair (Fond principal)
const Color surfaceColor = Color(0xFFFFFFFF); // Blanc Pur (Cartes, surfaces)
const Color textDark = Color(
  0xFF161E2B,
); // Gris Anthracite Profond (Texte principal)
const Color textGrey = Color(0xFF6B7280); // Gris Moyen (Texte secondaire)

// Couleurs sémantiques (pour messages d'état)
const Color successGreen = Color(0xFF4CAF50); // Vert pour succès
const Color warningOrange = Color(0xFFFFC107); // Orange pour avertissement
const Color errorRed = Color(0xFFF44336); // Rouge pour erreur

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expirée. Veuillez vous reconnecter."),
              backgroundColor: errorRed,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
        return;
      }

      // Charger le profil utilisateur
      await _loadUserProfile(userId);

      final projects = await _projectService.getUserProjects(userId);
      setState(() {
        _projects = projects;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        String errorMessage =
            "Erreur lors du chargement des projets : ${e.toString()}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: errorRed),
        );
        print("Erreur de chargement des projets : $e");
      }
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      setState(() {
        _currentUserProfile = response;
      });
    } catch (e) {
      print("Erreur lors du chargement du profil utilisateur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar pour mobile : Logo et nom de l'app
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0.8, // Ombre subtile sous l'AppBar
        title: Row(
          mainAxisSize: MainAxisSize.min, // Occupe le minimum de largeur
          children: [
            // Logo TODO - Le SVG s'affichera avec les couleurs définies dans le fichier SVG lui-même.
            // Si vous voulez une couleur spécifique ici, éditez le fichier SVG ou réactivez colorFilter.
            SvgPicture.asset(
              'assets/images/Logo_ToDo.svg', // Assurez-vous que ce chemin est correct
              height: 28,
              width: 28,
              // colorFilter: const ColorFilter.mode(primaryBlue, BlendMode.srcIn), // Remplacé/désactivé
            ),
            const SizedBox(width: 8),
          ],
        ),
        centerTitle: true, // Centre le titre et le logo
        iconTheme: const IconThemeData(
          color: textDark,
        ), // Couleur de l'icône du Drawer
      ),
      // Drawer pour la navigation mobile (menu hamburger)
      drawer: _buildDrawer(),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryBlue,
                strokeWidth: 4,
                // Color.withOpacity n'est pas déprécié. Utilisé pour la transparence.
                backgroundColor: primaryBlue.withOpacity(0.2),
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
            color: textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Gérez vos projets et suivez leur avancement",
          style: TextStyle(fontSize: 14, color: textGrey),
        ),
        const SizedBox(height: 20), // Espacement avant le bouton
        SizedBox(
          width: double.infinity, // Bouton prend toute la largeur disponible
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implémenter l'ouverture du formulaire de nouveau projet
              print("Nouveau Projet cliqué!");
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Nouveau Projet"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
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
            color: lightBlue,
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 12),
          DashboardStatsCard(
            title: "Tâches En Cours",
            value: "$inProgressCount",
            color: lightGreen,
            icon: Icons.pending_actions_outlined,
          ),
          const SizedBox(height: 12),
          DashboardStatsCard(
            title: "Tâches Terminées",
            value: "$doneCount",
            color: lightPurple,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 24),

          Text(
            "Avancement des Projets", // Titre pour la section Kanban
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Section Kanban - empilée verticalement pour mobile
          KanbanColumn(
            title: "To Do",
            color: lightBlue,
            projects: _projects
                .where((p) => p.status.toLowerCase() == "to do")
                .toList(),
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 16),
          KanbanColumn(
            title: "In Progress",
            color: lightGreen,
            projects: _projects
                .where((p) => p.status.toLowerCase() == "in progress")
                .toList(),
            icon: Icons.pending_actions_outlined,
          ),
          const SizedBox(height: 16),
          KanbanColumn(
            title: "Done",
            color: lightPurple,
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
              color: textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Membres de l'équipe et leurs tâches assignées",
            style: TextStyle(fontSize: 14, color: textGrey),
          ),
          const SizedBox(height: 24),

          // Liste des membres de l'équipe (simulation pour l'instant)
          _buildTeamMemberCard(
            name: "Alice Dupont",
            email: "alice@example.com",
            avatarColor: primaryBlue,
            tasksAssigned: 5,
            tasksCompleted: 3,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Alice Dupont",
                  email: "alice@example.com",
                  avatarColor: primaryBlue,
                  tasksAssigned: 5,
                  tasksCompleted: 3,
                  joinDate: "Janvier 2024",
                  role: "Développeur Frontend",
                  activeProjects: [
                    "Application Mobile Todo",
                    "Refonte Site Web",
                    "Dashboard Analytics"
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildTeamMemberCard(
            name: "Bob Martin",
            email: "bob@example.com",
            avatarColor: lightGreen,
            tasksAssigned: 8,
            tasksCompleted: 6,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Bob Martin",
                  email: "bob@example.com",
                  avatarColor: lightGreen,
                  tasksAssigned: 8,
                  tasksCompleted: 6,
                  joinDate: "Mars 2024",
                  role: "Développeur Backend",
                  activeProjects: [
                    "API Backend",
                    "Base de données",
                    "Intégration CI/CD"
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _buildTeamMemberCard(
            name: "Claire Bernard",
            email: "claire@example.com",
            avatarColor: lightPurple,
            tasksAssigned: 4,
            tasksCompleted: 2,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => MemberDetailsPage(
                  name: "Claire Bernard",
                  email: "claire@example.com",
                  avatarColor: lightPurple,
                  tasksAssigned: 4,
                  tasksCompleted: 2,
                  joinDate: "Mai 2024",
                  role: "Designer UX/UI",
                  activeProjects: [
                    "Refonte Site Web",
                    "Application Mobile Todo",
                    "Design System"
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
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primaryBlue.withOpacity(0.2), width: 1),
            ),
            child: Column(
              children: [
                Icon(Icons.person_add_outlined, color: primaryBlue, size: 32),
                const SizedBox(height: 8),
                Text(
                  "Inviter un nouveau membre",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Ajoutez de nouveaux membres à votre équipe",
                  style: TextStyle(fontSize: 14, color: textGrey),
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
                      backgroundColor: primaryBlue,
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
          color: surfaceColor,
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
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(email, style: TextStyle(fontSize: 14, color: textGrey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 16,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$tasksAssigned tâches assignées",
                        style: TextStyle(fontSize: 12, color: textGrey),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: successGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$tasksCompleted terminées",
                        style: TextStyle(fontSize: 12, color: textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: textGrey.withOpacity(0.7), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              // Color.withOpacity n'est pas déprécié.
              color: primaryBlue.withOpacity(0.1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                // Logo TODO dans le Drawer - Le SVG s'affichera avec ses couleurs internes.
                SvgPicture.asset(
                  'assets/images/Logo_ToDo.svg', // Assurez-vous que ce chemin est correct
                  height: 40,
                  width: 40,
                  // colorFilter: const ColorFilter.mode(primaryBlue, BlendMode.srcIn), // Remplacé/désactivé
                ),
                const SizedBox(width: 12),
                Text(
                  "TODO", // Nom de l'application
                  style: TextStyle(
                    color: textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),
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
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  // Color.withOpacity n'est pas déprécié.
                  color: primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    // Color.withOpacity n'est pas déprécié.
                    backgroundColor: primaryBlue.withOpacity(0.15),
                    child: Icon(
                      Icons.person_outline,
                      color: primaryBlue,
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
                            color: textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentUserProfile?['email'] ?? 'En ligne',
                          style: TextStyle(
                            // Color.withOpacity n'est pas déprécié.
                            color: textGrey.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Color.withOpacity n'est pas déprécié.
                  Icon(
                    Icons.more_vert,
                    color: textGrey.withOpacity(0.7),
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
                            foregroundColor: errorRed,
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
                            backgroundColor: errorRed,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
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

// --- SidebarItem (Utilisé dans le Drawer) ---
class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.title,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              // Color.withOpacity n'est pas déprécié.
              color: isSelected
                  ? primaryBlue.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  // Color.withOpacity n'est pas déprécié.
                  color: isSelected ? primaryBlue : textGrey.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? primaryBlue : textGrey,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- DashboardStatsCard (Adapté pour mobile) ---
class DashboardStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // Color.withOpacity n'est pas déprécié.
            color: textDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        // Affichage en Row pour mobile : icône et texte/valeur côte à côte
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // Color.withOpacity n'est pas déprécié.
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16), // Espacement entre icône et texte
          Expanded(
            // Pour que le texte prenne l'espace restant
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- KanbanColumn ---
class KanbanColumn extends StatelessWidget {
  final String title;
  final Color color;
  final List<Project> projects;
  final IconData icon;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.color,
    required this.projects,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = projects
        .where((p) => p.status.toLowerCase() == title.toLowerCase())
        .toList();

    return Container(
      decoration: BoxDecoration(
        // Color.withOpacity n'est pas déprécié.
        color: color.withOpacity(0.25), // Fond de colonne semi-transparent
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Color.withOpacity n'est pas déprécié.
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alignement à gauche
        children: [
          // En-tête de la colonne Kanban
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // Color.withOpacity n'est pas déprécié.
              color: surfaceColor.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Color.withOpacity n'est pas déprécié.
                    color: color.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${filtered.length}",
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Liste des ProjectCards
          SizedBox(
            // Hauteur fixe pour le ListView interne des tâches Kanban sur mobile
            // Ceci assure que chaque colonne Kanban prend une hauteur raisonnable
            // et que l'ensemble du dashboard reste scrollable.
            height:
                MediaQuery.of(context).size.height *
                0.22, // Ajusté à 22% pour un bon équilibre
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: filtered.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Aucune tâche à ${title.toLowerCase()}",
                          style: TextStyle(color: textGrey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]
                  : filtered.map((p) => ProjectCard(project: p)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// --- ProjectCard ---
class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // Color.withOpacity n'est pas déprécié.
            color: textDark.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // Color.withOpacity n'est pas déprécié.
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_horiz, size: 16, color: primaryBlue),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Color.withOpacity n'est pas déprécié.
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: textGrey.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                "Aujourd'hui", // Date dynamique à implémenter (project.dueDate)
                style: TextStyle(
                  // Color.withOpacity n'est pas déprécié.
                  color: textGrey.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              // TODO: Afficher les avatars des membres assignés
              CircleAvatar(
                radius: 12,
                // Color.withOpacity n'est pas déprécié.
                backgroundColor: primaryBlue.withOpacity(0.15),
                child: Icon(Icons.person, size: 14, color: primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- DashboardCalendar ---
class DashboardCalendar extends StatelessWidget {
  const DashboardCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // Color.withOpacity n'est pas déprécié.
            color: textDark.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: primaryBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                "Mon Agenda", // Titre adapté
                style: TextStyle(
                  color: textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Vos prochains projets et événements apparaîtront ici",
              style: TextStyle(color: textGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // TODO: Implémenter un calendrier interactif ici (ex: table_calendar)
        ],
      ),
    );
  }
}
