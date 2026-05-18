import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../state/locale_controller.dart';

class DecorativeBackground extends StatelessWidget {
  const DecorativeBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Soft gradients add depth without distracting from content.
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE2F3EE), Color(0x00E2F3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -140,
          left: -70,
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFFE6D6), Color(0x00FFE6D6)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1E2D2B),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5C6B68),
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withAlpha(22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6D7573),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: accent),
        ],
      ),
    );
  }
}

enum _MenuAction { languageEnglish, languageVietnamese, signOut }

class AppMenuButton extends StatelessWidget {
  const AppMenuButton({super.key, this.showSignOut = true});

  final bool showSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeController = LocaleScope.of(context);

    return PopupMenuButton<_MenuAction>(
      onSelected: (value) async {
        switch (value) {
          case _MenuAction.languageEnglish:
            localeController.setLocale(const Locale('en'));
            break;
          case _MenuAction.languageVietnamese:
            localeController.setLocale(const Locale('vi'));
            break;
          case _MenuAction.signOut:
            await FirebaseAuth.instance.signOut();
            break;
        }
      },
      itemBuilder: (context) {
        final currentCode = localeController.locale.languageCode;
        final items = <PopupMenuEntry<_MenuAction>>[
          PopupMenuItem<_MenuAction>(
            value: _MenuAction.languageEnglish,
            child: Row(
              children: [
                if (currentCode == 'en')
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(l10n.languageEnglish),
              ],
            ),
          ),
          PopupMenuItem<_MenuAction>(
            value: _MenuAction.languageVietnamese,
            child: Row(
              children: [
                if (currentCode == 'vi')
                  const Icon(Icons.check, size: 18)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(l10n.languageVietnamese),
              ],
            ),
          ),
        ];

        if (showSignOut) {
          items.add(const PopupMenuDivider());
          items.add(
            PopupMenuItem<_MenuAction>(
              value: _MenuAction.signOut,
              child: Text(l10n.signOut),
            ),
          );
        }

        return items;
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.language, color: Color(0xFF1E2D2B)),
      ),
    );
  }
}
