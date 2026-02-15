import 'package:flutter/material.dart';
import 'package:todo_app/theme.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // légère profondeur
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.1), // noir 10% opacity
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white, // fond blanc pur pour lisibilité
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icone avec accent cyan
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent, // bleu très clair en fond de l'icône
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.accentCyan, // cyan
              ),
            ),
            const SizedBox(width: 16),
            // Texte
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark, // texte foncé pour lisibilité
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey, // gris foncé lisible
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}