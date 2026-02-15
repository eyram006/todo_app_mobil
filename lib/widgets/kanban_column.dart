import 'package:flutter/material.dart';
import 'package:todo_app/dashboard/models/project.dart';
import 'package:todo_app/theme.dart';
import 'package:todo_app/widgets/project_card.dart';

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
              color: AppColors.surface.withOpacity(0.85),
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
                    color: AppColors.textDark,
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
                      color: AppColors.textDark,
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
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
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
