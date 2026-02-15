import 'package:flutter/material.dart';
import 'package:todo_app/core/design_tokens.dart';
import 'package:todo_app/theme.dart';

/// Carte de paramètres réutilisable
class SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: DesignTokens.fontSize18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: DesignTokens.spacing12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: DesignTokens.borderRadius12,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
              width: DesignTokens.borderWidth1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// Élément de paramètre réutilisable
class SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showChevron;

  const SettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: DesignTokens.borderRadius8,
      child: Padding(
        padding: DesignTokens.padding16,
        child: Row(
          children: [
            Container(
              padding: DesignTokens.padding8,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: DesignTokens.borderRadius8,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: DesignTokens.iconSize20,
              ),
            ),
            const SizedBox(width: DesignTokens.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSize16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spacing4 / 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSize14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right,
                color: AppColors.textGrey.withOpacity(0.7),
                size: DesignTokens.iconSize20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Carte de statistique améliorée
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: DesignTokens.padding16,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: DesignTokens.borderRadius12,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: DesignTokens.borderWidth1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: DesignTokens.padding8,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: DesignTokens.borderRadius8,
            ),
            child: Icon(icon, color: color, size: DesignTokens.iconSize24),
          ),
          const SizedBox(width: DesignTokens.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSize24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSize14,
                    color: AppColors.textGrey,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: DesignTokens.spacing4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: DesignTokens.fontSize12,
                      color: AppColors.textGrey.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action principal
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? SizedBox(
              width: DesignTokens.iconSize16,
              height: DesignTokens.iconSize16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : (icon != null
                ? Icon(icon, size: DesignTokens.iconSize18)
                : const SizedBox()),
      label: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: DesignTokens.fontSize15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: DesignTokens.paddingH20V14,
        shape: RoundedRectangleBorder(
          borderRadius: DesignTokens.borderRadius12,
        ),
        elevation: DesignTokens.elevation3,
        minimumSize: isFullWidth ? const Size(double.infinity, 48) : null,
      ),
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Section avec titre et contenu
class Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const Section({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.padding = DesignTokens.padding16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: DesignTokens.fontSize28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: DesignTokens.spacing4 / 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: DesignTokens.fontSize14,
                color: AppColors.textGrey,
              ),
            ),
          ],
          const SizedBox(height: DesignTokens.spacing24),
          ...children,
        ],
      ),
    );
  }
}

/// État vide réutilisable
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsetsGeometry? padding;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionText,
    this.onActionPressed,
    this.padding = DesignTokens.padding32,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: DesignTokens.padding20,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: DesignTokens.borderRadius12,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: DesignTokens.iconSize32,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTokens.fontSize18,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: DesignTokens.spacing8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: DesignTokens.fontSize14,
                color: AppColors.textGrey,
              ),
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: DesignTokens.spacing24),
              PrimaryButton(
                text: actionText!,
                onPressed: onActionPressed!,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Overlay de chargement réutilisable
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingText;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.background.withOpacity(0.8),
            child: Center(
              child: Container(
                padding: DesignTokens.padding24,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: DesignTokens.borderRadius12,
                  boxShadow: DesignTokens.shadowMedium,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3,
                    ),
                    if (loadingText != null) ...[
                      const SizedBox(height: DesignTokens.spacing16),
                      Text(
                        loadingText!,
                        style: TextStyle(
                          fontSize: DesignTokens.fontSize14,
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
