import 'package:flutter/material.dart';
import 'package:todo_app/widgets/feature_card.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, 0), // première carte = pas décalée
          child: const FeatureCard(
            icon: Icons.task_alt,
            title: 'Gestion des tâches & projets',
            description: 'Créez, organisez et suivez vos tâches facilement.',
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -10), // décale la carte vers le haut
          child: const FeatureCard(
            icon: Icons.schedule,
            title: 'Deadlines & rappels',
            description:
                'Suivez l’avancement en temps réel et respectez vos échéances.',
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20), // encore plus décalée
          child: const FeatureCard(
            icon: Icons.group_outlined,
            title: 'Travail collaboratif',
            description: 'Collaborez efficacement, seul ou en équipe.',
          ),
        ),
      ],
    );
  }
}
