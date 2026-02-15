import 'package:flutter/material.dart';

/// Design tokens pour maintenir la cohérence dans l'application
class DesignTokens {
  DesignTokens._();

  // Espacements standardisés
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Tailles de texte standardisées
  static const double fontSize12 = 12.0;
  static const double fontSize14 = 14.0;
  static const double fontSize15 = 15.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize24 = 24.0;
  static const double fontSize28 = 28.0;

  // Épaisseurs de bordure
  static const double borderWidth1 = 1.0;

  // Élévations
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;

  // Tailles d'icônes
  static const double iconSize16 = 16.0;
  static const double iconSize18 = 18.0;
  static const double iconSize20 = 20.0;
  static const double iconSize24 = 24.0;
  static const double iconSize32 = 32.0;

  // Tailles d'avatar
  static const double avatarRadius20 = 20.0;
  static const double avatarRadius24 = 24.0;

  // Padding standards
  static const EdgeInsets padding4 = EdgeInsets.all(spacing4);
  static const EdgeInsets padding8 = EdgeInsets.all(spacing8);
  static const EdgeInsets padding12 = EdgeInsets.all(spacing12);
  static const EdgeInsets padding16 = EdgeInsets.all(spacing16);
  static const EdgeInsets padding20 = EdgeInsets.all(spacing20);
  static const EdgeInsets padding24 = EdgeInsets.all(spacing24);
  static const EdgeInsets padding32 = EdgeInsets.all(spacing32);

  // Padding horizontal/vertical
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(
    horizontal: spacing16,
  );
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(
    vertical: spacing12,
  );
  static const EdgeInsets paddingH20V14 = EdgeInsets.symmetric(
    horizontal: spacing20,
    vertical: 14,
  );

  // Border radius standards
  static const BorderRadius borderRadius8 = BorderRadius.all(
    Radius.circular(8.0),
  );
  static const BorderRadius borderRadius12 = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const BorderRadius borderRadius14 = BorderRadius.all(
    Radius.circular(14.0),
  );

  // Box shadows standards
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity black
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity black
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  // Durées d'animation
  static const Duration duration150 = Duration(milliseconds: 150);
  static const Duration duration200 = Duration(milliseconds: 200);
  static const Duration duration300 = Duration(milliseconds: 300);
}
