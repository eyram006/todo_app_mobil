import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importation nécessaire pour SvgPicture

import '../../auth/pages/login.dart'; // Assurez-vous que cette page existe
import '../models/project.dart';
import '../services/project_service.dart';

// --- Palette de couleurs "To Do Chef" ---
const Color primaryBlue = Color(0xFF21B6EC); // Bleu Cyan Dynamique
const Color lightBlue = Color(0xFF5ADFF6);   // Aqua Pâle (To Do)
const Color lightGreen = Color(0xFFD1FAE5);  // Vert Menthe Clair (In Progress)
const Color lightPurple = Color(0xFFEDE9FE); // Lavande Douce (Done)

const Color backgroundColor = Color(0xFFF9FAFB); // Gris Très Clair (Fond principal)
const Color surfaceColor = Color(0xFFFFFFFF);    // Blanc Pur (Cartes, surfaces)
const Color textDark = Color(0xFF161E2B);      // Gris Anthracite Profond (Texte principal)
const Color textGrey = Color(0xFF6B7280);      // Gris Moyen (Texte secondaire)

// Nouveaux ajouts pour des couleurs sémantiques ou de fond améliorées
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
        // Gérer le cas où l'utilisateur n'est pas authentifié
        // Redirection vers la page de connexion, ou affichage d'un message spécifique
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Session expirée. Veuillez vous reconnecter."),
              backgroundColor: errorRed,
            ),
          );
          // Exemple de redirection, à adapter selon votre flux d'authentification
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (Route<dynamic> route) => false,
          );
        }
        return; // Sortir de la fonction
      }

      final projects = await _projectService.getUserProjects(userId);
      setState(() {
        _projects = projects;
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false); // Assurez-vous que le chargement s'arrête
        String errorMessage = "Erreur lors du chargement des projets : ${e.toString()}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorRed, // Utilisation de la couleur d'erreur
          ),
        );
        print("Erreur de chargement des projets : $e"); // Pour le débogage en console
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor, // Fond principal de l'application
      body: _loading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryBlue, // Couleur du loader
          strokeWidth: 4, // Épaississement du loader
          backgroundColor: primaryBlue.withOpacity(0.2), // Fond transparent du loader
        ),
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligner les éléments en haut
        children: [
          const DashboardSidebar(), // Votre barre latérale
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32), // Padding global pour le contenu
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(), // En-tête du tableau de bord
                  const SizedBox(height: 32),
                  DashboardStats(projects: _projects), // Statistiques
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 500, // Hauteur fixe pour le Kanban
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: KanbanColumn(
                            title: "To Do",
                            color: lightBlue,
                            projects: _projects,
                            icon: Icons.assignment_outlined,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: KanbanColumn(
                            title: "In Progress",
                            color: lightGreen,
                            projects: _projects,
                            icon: Icons.pending_actions_outlined,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: KanbanColumn(
                            title: "Done",
                            color: lightPurple,
                            projects: _projects,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const DashboardCalendar(), // Calendrier
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tableau de Bord Chef", // Titre de l'application avec touche "Chef"
              style: TextStyle(
                fontSize: 32, // Taille de police légèrement augmentée
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: -0.5, // Ajustement de l'espacement pour un look moderne
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Orchestrez vos projets et suivez vos recettes de succès", // Slogan modifié
              style: TextStyle(
                fontSize: 16,
                color: textGrey,
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implémenter l'ouverture du formulaire de nouveau projet
            print("Nouveau Projet cliqué!");
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text("Nouvelle Recette"), // Texte du bouton "Nouvelle Recette"
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18), // Padding augmenté
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Rayon plus grand
            ),
            elevation: 4, // Légère élévation pour un effet de flottement
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

// --- DashboardSidebar ---
class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: textDark.withOpacity(0.08), // Ombre subtile
            blurRadius: 25,
            offset: const Offset(4, 0), // Ombre plus prononcée sur le côté
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20), // Padding pour le logo
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/logo_todo_chef.svg',
                  height: 38, // Taille du logo
                  width: 38,
                      ),
                const SizedBox(width: 12),
                Text(
                  "To Do Chef", // Nom de l'application
                  style: TextStyle(
                    color: textDark,
                    fontSize: 26, // Taille de police
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 20), // Supprimé car le padding ci-dessus gère déjà l'espace
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20), // Padding latéral
              children: [
                SidebarItem(
                  title: "Dashboard",
                  icon: Icons.dashboard_outlined,
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                SidebarItem(
                  title: "Mes Projets",
                  icon: Icons.folder_outlined,
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                SidebarItem(
                  title: "Équipe",
                  icon: Icons.people_outline,
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                SidebarItem(
                  title: "Chat & Meet", // Nouveau nom pour le chat/visioconférence
                  icon: Icons.chat_outlined, // Icône pour le chat
                  isSelected: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                SidebarItem(
                  title: "Journal & Stats", // Nouveau nom pour le journal/statistiques
                  icon: Icons.analytics_outlined, // Icône pour les stats
                  isSelected: _selectedIndex == 4,
                  onTap: () => setState(() => _selectedIndex = 4),
                ),
                SidebarItem(
                  title: "Paramètres",
                  icon: Icons.settings_outlined,
                  isSelected: _selectedIndex == 5,
                  onTap: () => setState(() => _selectedIndex = 5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(18), // Padding augmenté
              decoration: BoxDecoration(
                color: backgroundColor, // Fond plus clair
                borderRadius: BorderRadius.circular(16), // Rayon plus grand
                border: Border.all(
                  color: primaryBlue.withOpacity(0.2), // Bordure subtile
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24, // Taille de l'avatar
                    backgroundColor: primaryBlue.withOpacity(0.15), // Fond d'avatar plus clair
                    child: Icon(Icons.person_outline, color: primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 16), // Espacement augmenté
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Chef Utilisateur", // Nom d'utilisateur dynamique à implémenter
                          style: TextStyle(
                            color: textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "En ligne",
                          style: TextStyle(
                            color: textGrey.withOpacity(0.8), // Texte plus doux
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.more_vert, color: textGrey.withOpacity(0.7), size: 20), // Icône pour options
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- SidebarItem ---
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
      padding: const EdgeInsets.only(bottom: 6), // Espacement entre les items
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14), // Rayon augmenté pour l'effet de survol
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15), // Padding ajusté
            decoration: BoxDecoration(
              color: isSelected ? primaryBlue.withOpacity(0.12) : Colors.transparent, // Effet plus doux
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? primaryBlue : textGrey.withOpacity(0.8), // Icône plus douce si inactive
                  size: 23,
                ),
                const SizedBox(width: 16), // Espacement ajusté
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? primaryBlue : textGrey,
                    fontSize: 16, // Taille de police légèrement augmentée
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, // Gras plus prononcé
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

// --- DashboardStats ---
class DashboardStats extends StatelessWidget {
  final List<Project> projects;

  const DashboardStats({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final todoCount = projects.where((p) => p.status.toLowerCase() == "to do").length;
    final inProgressCount = projects.where((p) => p.status.toLowerCase() == "in progress").length;
    final doneCount = projects.where((p) => p.status.toLowerCase() == "done").length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: "Recettes à Faire", // Titre ajusté
            value: "$todoCount",
            color: lightBlue,
            icon: Icons.assignment_outlined,
          ),
        ),
        const SizedBox(width: 24), // Espacement augmenté
        Expanded(
          child: StatCard(
            title: "En Préparation", // Titre ajusté
            value: "$inProgressCount",
            color: lightGreen,
            icon: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 24), // Espacement augmenté
        Expanded(
          child: StatCard(
            title: "Plats Servis", // Titre ajusté
            value: "$doneCount",
            color: lightPurple,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }
}

// --- StatCard ---
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28), // Padding augmenté
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20), // Rayon plus grand
        boxShadow: [
          BoxShadow(
            color: textDark.withOpacity(0.06),
            blurRadius: 20, // Blur plus prononcé
            offset: const Offset(0, 8), // Ombre plus basse
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12), // Padding icône
            decoration: BoxDecoration(
              color: color.withOpacity(0.18), // Opacité ajustée pour le fond de l'icône
              borderRadius: BorderRadius.circular(14), // Rayon icône
            ),
            child: Icon(icon, color: color, size: 26), // Taille icône
          ),
          const SizedBox(height: 24), // Espacement augmenté
          Text(
            value,
            style: TextStyle(
              fontSize: 38, // Taille de police augmentée
              fontWeight: FontWeight.bold,
              color: textDark,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8), // Espacement ajusté
          Text(
            title,
            style: TextStyle(
              color: textGrey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
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
    final filtered = projects.where((p) => p.status.toLowerCase() == title.toLowerCase()).toList();

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.25), // Fond de colonne semi-transparent (comme décrit)
        borderRadius: BorderRadius.circular(20), // Rayon augmenté
        border: Border.all(
          color: color.withOpacity(0.4), // Bordure un peu plus visible
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // En-tête de la colonne Kanban
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceColor.withOpacity(0.85), // Opacité légèrement augmentée
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(19), // Ajusté au rayon du conteneur parent
                topRight: Radius.circular(19),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24), // Taille icône
                const SizedBox(width: 12), // Espacement ajusté
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    fontSize: 17, // Taille de police
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), // Padding ajusté
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.25), // Opacité ajustée pour le compteur
                    borderRadius: BorderRadius.circular(14), // Rayon compteur
                  ),
                  child: Text(
                    "${filtered.length}",
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18), // Padding ajusté
              children: filtered.map((p) => ProjectCard(project: p)).toList(),
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
      padding: const EdgeInsets.all(20), // Padding augmenté
      margin: const EdgeInsets.only(bottom: 15), // Marge ajustée
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16), // Rayon plus grand
        boxShadow: [
          BoxShadow(
            color: textDark.withOpacity(0.07), // Opacité d'ombre ajustée
            blurRadius: 12, // Blur ajusté
            offset: const Offset(0, 6), // Ombre plus basse
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
                    fontSize: 16, // Taille de police ajustée
                    color: textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8), // Padding icône
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12), // Fond d'icône ajusté
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 18,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Espacement augmenté
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: textGrey.withOpacity(0.8)),
              const SizedBox(width: 8), // Espacement ajusté
              Text(
                "Aujourd'hui", // Date dynamique à implémenter (project.dueDate)
                style: TextStyle(
                  color: textGrey.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              // TODO: Afficher les avatars des membres assignés
              CircleAvatar(
                radius: 14, // Taille de l'avatar
                backgroundColor: primaryBlue.withOpacity(0.15),
                child: Icon(Icons.person, size: 16, color: primaryBlue),
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
      padding: const EdgeInsets.all(30), // Padding augmenté
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20), // Rayon augmenté
        boxShadow: [
          BoxShadow(
            color: textDark.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: primaryBlue, size: 26), // Taille icône
              const SizedBox(width: 14), // Espacement ajusté
              Text(
                "Agenda du Chef", // Titre ajusté
                style: TextStyle(
                  color: textDark,
                  fontSize: 20, // Taille de police
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28), // Espacement augmenté
          Center(
            child: Text(
              "Vos prochaines recettes et événements apparaîtront ici", // Texte ajusté
              style: TextStyle(
                color: textGrey,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16), // Ajout d'un petit espace en bas
          // TODO: Implémenter un calendrier interactif ici (ex: table_calendar)
        ],
      ),
    );
  }
}