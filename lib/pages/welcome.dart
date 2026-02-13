import 'package:flutter/material.dart';
import 'package:todo_app/pages/register.dart';
import 'package:flutter_svg/flutter_svg.dart';
class Welcome extends StatefulWidget {
  const Welcome({super.key});
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.white,
      body: SafeArea(
        child : Padding(padding: const EdgeInsets.all(24),
          child: Column(
        children: [
          Expanded(child: SingleChildScrollView(
            child: Column(
              children: const [
                _HeaderSection(),
                SizedBox(height: 32),
                _FeaturesSection(),
              ],
            ),
          ),
          ),
           _BottomAction(),
        ],
      ))),
      )
    );
  }
}

//le header
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Logo_ToDo.svg',
          width: 157,  // largeur souhaitée
          height: 152, // hauteur souhaitée
        ),

        const SizedBox(height: 12),

        Text(
          'Boostez votre productivité avec ToDo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            color: textDark,
          ),
        ),
      ],
    );
  }
}

//les features card
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, 0), // première carte = pas décalée
          child: const _FeatureCard(
            icon: Icons.task_alt,
            title: 'Gestion des tâches & projets',
            description: 'Créez, organisez et suivez vos tâches facilement.',
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -10), // décale la carte vers le haut
          child: const _FeatureCard(
            icon: Icons.schedule,
            title: 'Deadlines & rappels',
            description: 'Suivez l’avancement en temps réel et respectez vos échéances.',
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -20), // encore plus décalée
          child: const _FeatureCard(
            icon: Icons.group_outlined,
            title: 'Travail collaboratif',
            description: 'Collaborez efficacement, seul ou en équipe.',
          ),
        ),
      ],
    );

  }
}


//declaration d'un feature card
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // légère profondeur
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.1), // noir 10% opacity
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white, // fond blanc pur pour lisibilité
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icone avec accent cyan
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA), // bleu très clair en fond de l'icône
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 28,
                color: const Color(0xFF06B6D4), // cyan
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
                      color: Color(0xFF1F2937), // texte foncé pour lisibilité
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563), // gris foncé lisible
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


class _BottomAction extends StatelessWidget {
  const _BottomAction();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ),
            );
          },
          child: const Text('Commencer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}


const Color primaryBlue = Color(0xFF21B6EC);
const Color lightBlue   = Color(0xFF5ADFF6); // fond cyan très doux
const Color lightGreen  = Color(0xFFD1FAE5);
const Color lightPurple = Color(0xFFEDE9FE);
const Color textDark = Color(0xFF161E2B);
const Color textGrey = Color(0xFF6B7280);


