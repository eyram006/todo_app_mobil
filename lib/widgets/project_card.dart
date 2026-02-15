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
              // Afficher les avatars des membres assignés
              Row(
                children: [
                  if (project.memberIds.isNotEmpty) ...[
                    // Afficher jusqu'à 3 avatars
                    for (
                      int i = 0;
                      i < project.memberIds.length && i < 3;
                      i++
                    ) ...[
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          project.memberIds[i].substring(0, 1).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (i < project.memberIds.length - 1 && i < 2)
                        const SizedBox(width: 4),
                    ],
                    // Si plus de 3 membres, afficher un indicateur
                    if (project.memberIds.length > 3) ...[
                      const SizedBox(width: 4),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.textGrey.withOpacity(0.2),
                        child: Text(
                          '+${project.memberIds.length - 3}',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ] else ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.person,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
