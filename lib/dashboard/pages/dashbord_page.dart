import 'package:flutter/material.dart';

// Palette de couleurs
const Color primaryBlue = Color(0xFF21B6EC);
const Color lightBlue   = Color(0xFF5ADFF6);
const Color lightGreen  = Color(0xFFD1FAE5);
const Color lightPurple = Color(0xFFEDE9FE);
const Color textDark    = Color(0xFF161E2B);
const Color textGrey    = Color(0xFF6B7280);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DashboardStats(),
                  SizedBox(height: 24),
                  Expanded(child: KanbanBoard()),
                  SizedBox(height: 24),
                  DashboardCalendar(),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFB),
    );
  }
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: primaryBlue,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Project Manager",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 40),
          SidebarItem(title: "Dashboard", icon: Icons.dashboard),
          SidebarItem(title: "Mes Projets", icon: Icons.folder),
          SidebarItem(title: "Équipe", icon: Icons.people),
          SidebarItem(title: "Paramètres", icon: Icons.settings),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const SidebarItem({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatCard(title: "Projets", value: "5", color: lightBlue)),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: "Tâches en cours", value: "12", color: lightGreen)),
        SizedBox(width: 16),
        Expanded(child: StatCard(title: "Terminées", value: "24", color: lightPurple)),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({super.key, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textGrey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: KanbanColumn(title: "To Do", color: lightBlue)),
        SizedBox(width: 16),
        Expanded(child: KanbanColumn(title: "In Progress", color: lightGreen)),
        SizedBox(width: 16),
        Expanded(child: KanbanColumn(title: "Done", color: lightPurple)),
      ],
    );
  }
}

class KanbanColumn extends StatelessWidget {
  final String title;
  final Color color;

  const KanbanColumn({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          const ProjectCard(),
        ],
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "App Mobile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text("5 tâches"),
        ],
      ),
    );
  }
}

class DashboardCalendar extends StatelessWidget {
  const DashboardCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
          )
        ],
      ),
      child: const Center(
        child: Text(
          "Calendrier ici",
          style: TextStyle(color: textDark),
        ),
      ),
    );
  }
}
