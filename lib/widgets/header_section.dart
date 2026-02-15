import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_app/theme.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/images/Logo_ToDo.svg',
          width: 157, // largeur souhaitée
          height: 152, // hauteur souhaitée
        ),

        const SizedBox(height: 12),

        Text(
          'Boostez votre productivité avec ToDo.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: AppColors.textDark),
        ),
      ],
    );
  }
}
