import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class MenuMenu extends StatelessWidget {
  const MenuMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: const [
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            title: 'Favorites',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.bookmark_border_rounded,
            title: 'Bookmarks',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.download_rounded,
            title: 'Downloads',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.history_rounded,
            title: 'Reading History',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
          ),
          Divider(height: 1),
          _MenuTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            isLogout: true,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    this.isLogout = false,
  });

  final IconData icon;
  final String title;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    final Color color = isLogout ? Colors.red : AppColors.gold;

    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title tapped'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}