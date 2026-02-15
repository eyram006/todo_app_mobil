import 'package:flutter/material.dart';
import 'package:todo_app/dashboard/models/project.dart';
import 'package:todo_app/theme.dart';

class ProjectCard extends StatelessWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // Color.withOpacity n'est pas déprécié.
            color: AppColors.textDark.withOpacity(0.06),
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
                    color: AppColors.textDark,
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
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: AppColors.primary,
                ),
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
                color: AppColors.textGrey.withOpacity(0.8),
              ),
              const SizedBox(width: 6),
              Text(
                "Aujourd'hui", // Date dynamique à implémenter (project.dueDate)
                style: TextStyle(
                  // Color.withOpacity n'est pas déprécié.
                  color: AppColors.textGrey.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              // TODO: Afficher les avatars des membres assignés
              CircleAvatar(
                radius: 12,
                // Color.withOpacity n'est pas déprécié.
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Icon(Icons.person, size: 14, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}