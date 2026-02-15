import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importation nécessaire pour SvgPicture
// import 'package:provider/provider.dart'; // Temporairement commenté
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/core/app_state.dart';
import 'package:todo_app/core/design_tokens.dart';
import 'package:todo_app/dashboard/pages/create_project_page.dart';
import 'package:todo_app/dashboard/pages/profile_page.dart';
import 'package:todo_app/dashboard/pages/projects_page.dart';
import 'package:todo_app/dashboard/pages/statistics_page.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/widgets/reusable_components.dart';

import '../../welcome.dart'; // Import pour la page d'accueil
import '../../widgets/dashboard_calendar.dart';
import '../../widgets/project_card.dart';
import '../../widgets/sidebar_item.dart';
import '../pages/chat_page.dart';
import 'member_details_page.dart'; // Import de la page des détails du membre

// Colors are centralized in `lib/theme.dart` (AppColors)

enum DashboardTab { overview, projects, team, chat, stats, settings }

class DashboardPage extends StatefulWidget {
  final DashboardTab initialTab;

  const DashboardPage({super.key, this.initialTab = DashboardTab.overview});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardTab _selectedTab;
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _appState = AppState();
    // Charger les données initiales
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _appState.loadInitialData();
    setState(() {}); // Forcer la reconstruction après le chargement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.8,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/Logo_ToDo.svg',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: DesignTokens.spacing8),
          ],
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      drawer: _buildDrawer(context, _appState),
      body: LoadingOverlay(
        isLoading: _appState.isLoading,
        loadingText: "Chargement des données...",
        child: _buildBodyContent(_appState),
      ),
    );
  }

  Widget _buildHeader(AppState appState) {
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProjectPage(),
                ),
              );
              // Les données seront automatiquement mises à jour via Provider
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

  Widget _buildBodyContent(AppState appState) {
    switch (_selectedTab) {
      case DashboardTab.overview:
        return _buildDashboardContent(appState);
      case DashboardTab.projects:
        return const ProjectsPage();
      case DashboardTab.team:
        return _buildTeamContent(appState);
      case DashboardTab.chat:
        return const ChatPage();
      case DashboardTab.stats:
        return const StatisticsPage();
      case DashboardTab.settings:
        return _buildSettingsContent();
    }
  }

  Widget _buildDashboardContent(AppState appState) {
    // Calculer les comptes pour les statistiques
    final todoCount = appState.projects
        .where((p) => p.status.toLowerCase() == "to do")
        .length;
    final inProgressCount = appState.projects
        .where((p) => p.status.toLowerCase() == "in progress")
        .length;
    final doneCount = appState.projects
        .where((p) => p.status.toLowerCase() == "done")
        .length;

    return SingleChildScrollView(
      padding: DesignTokens.padding16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(appState),
          const SizedBox(height: DesignTokens.spacing24),

          // Section Statistiques
          Section(
            title: "Statistiques",
            subtitle: "Aperçu de vos tâches",
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: "À Faire",
                      value: "$todoCount",
                      color: AppColors.lightBlue,
                      icon: Icons.assignment_outlined,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spacing12),
                  Expanded(
                    child: StatsCard(
                      title: "En Cours",
                      value: "$inProgressCount",
                      color: AppColors.lightGreen,
                      icon: Icons.pending_actions_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.spacing12),
              StatsCard(
                title: "Terminées",
                value: "$doneCount",
                color: AppColors.lightPurple,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),

          // Section Projets Récents
          Section(
            title: "Projets Récents",
            subtitle: "Vos derniers projets actifs",
            children: [
              if (appState.projects.isEmpty)
                EmptyState(
                  title: "Aucun projet trouvé",
                  subtitle: "Créez votre premier projet pour commencer",
                  icon: Icons.folder_open_outlined,
                  actionText: "Créer un projet",
                  onActionPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateProjectPage(),
                      ),
                    );
                    if (result == true) {
                      appState.refreshData();
                    }
                  },
                )
              else
                ...appState.projects
                    .take(3)
                    .map(
                      (project) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: DesignTokens.spacing12,
                        ),
                        child: ProjectCard(project: project),
                      ),
                    ),
            ],
          ),

          // Section Calendrier
          Section(
            title: "Calendrier",
            subtitle: "Vos échéances importantes",
            children: [const DashboardCalendar()],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamContent(AppState appState) {
    return SingleChildScrollView(
      padding: DesignTokens.padding16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Section(
            title: "Équipe",
            subtitle: "Membres de l'équipe et leurs tâches assignées",
            children: [
              if (appState.teamMembers.isEmpty)
                EmptyState(
                  title: "Aucun membre trouvé",
                  subtitle: "Invitez des membres à rejoindre votre équipe",
                  icon: Icons.people_outline,
                  actionText: "Inviter un membre",
                  onActionPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité d\'invitation à venir !'),
                      ),
                    );
                  },
                )
              else
                ...appState.teamMembers.map((member) {
                  final stats = appState.calculateMemberStats(member['id']);
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: DesignTokens.spacing12,
                    ),
                    child: _buildTeamMemberCard(
                      name:
                          member['full_name'] ??
                          'Utilisateur ${member['id'].substring(0, 8)}',
                      email: member['email'] ?? '',
                      avatarColor: AppColors.primary,
                      tasksAssigned: stats['tasksAssigned'],
                      tasksCompleted: stats['tasksCompleted'],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MemberDetailsPage(
                            name: member['full_name'] ?? 'Utilisateur',
                            email: member['email'] ?? '',
                            avatarColor: AppColors.primary,
                            tasksAssigned: stats['tasksAssigned'],
                            tasksCompleted: stats['tasksCompleted'],
                            joinDate: member['created_at'] != null
                                ? DateTime.parse(
                                    member['created_at'],
                                  ).toString().split(' ')[0]
                                : 'N/A',
                            role: 'Membre',
                            activeProjects: appState.projects
                                .where(
                                  (p) => p.memberIds.contains(member['id']),
                                )
                                .map((p) => p.name)
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Section pour inviter de nouveaux membres
              Container(
                padding: DesignTokens.padding16,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: DesignTokens.borderRadius12,
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
                      size: DesignTokens.iconSize32,
                    ),
                    const SizedBox(height: DesignTokens.spacing8),
                    Text(
                      "Inviter un nouveau membre",
                      style: TextStyle(
                        fontSize: DesignTokens.fontSize16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spacing4),
                    Text(
                      "Ajoutez de nouveaux membres à votre équipe",
                      style: TextStyle(
                        fontSize: DesignTokens.fontSize14,
                        color: AppColors.textGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: DesignTokens.spacing16),
                    PrimaryButton(
                      text: "Inviter",
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fonctionnalité à venir !'),
                          ),
                        );
                      },
                      isFullWidth: true,
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
            ],
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

  Widget _buildDrawer(BuildContext context, AppState appState) {
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
                  isSelected: _selectedTab == DashboardTab.overview,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.overview);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Mes Projets",
                  icon: Icons.folder_outlined,
                  isSelected: _selectedTab == DashboardTab.projects,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.projects);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Équipe",
                  icon: Icons.people_outline,
                  isSelected: _selectedTab == DashboardTab.team,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.team);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Chat & Meet",
                  icon: Icons.chat_outlined,
                  isSelected: _selectedTab == DashboardTab.chat,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.chat);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Journal & Stats",
                  icon: Icons.analytics_outlined,
                  isSelected: _selectedTab == DashboardTab.stats,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.stats);
                    Navigator.pop(context);
                  },
                ),
                SidebarItem(
                  title: "Paramètres",
                  icon: Icons.settings_outlined,
                  isSelected: _selectedTab == DashboardTab.settings,
                  onTap: () {
                    setState(() => _selectedTab = DashboardTab.settings);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          // Carte profil utilisateur en bas du Drawer
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // ferme le drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
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
                            appState.currentUserProfile?['username'] ??
                                'Utilisateur',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appState.currentUserProfile?['email'] ?? 'En ligne',
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

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: DesignTokens.padding16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Section(
            title: "Paramètres",
            subtitle: "Configurez votre application",
            children: [
              // Section Profil
              SettingsCard(
                title: "Profil",
                children: [
                  SettingsItem(
                    icon: Icons.person_outline,
                    title: "Mon Profil",
                    subtitle: "Gérer mes informations personnelles",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: "Notifications",
                    subtitle: "Préférences de notification",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: DesignTokens.spacing24),

              // Section Application
              SettingsCard(
                title: "Application",
                children: [
                  SettingsItem(
                    icon: Icons.palette_outlined,
                    title: "Thème",
                    subtitle: "Mode sombre/clair",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.language_outlined,
                    title: "Langue",
                    subtitle: "Français",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.info_outline,
                    title: "À propos",
                    subtitle: "Version 1.0.0",
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Todo App',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Todo App',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: DesignTokens.spacing24),

              // Section Support
              SettingsCard(
                title: "Support",
                children: [
                  SettingsItem(
                    icon: Icons.help_outline,
                    title: "Aide & FAQ",
                    subtitle: "Questions fréquentes",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                  SettingsItem(
                    icon: Icons.feedback_outlined,
                    title: "Feedback",
                    subtitle: "Envoyez-nous vos suggestions",
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
