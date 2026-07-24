import 'package:flutter/material.dart';

import '../theme/app_font.dart';
import '../theme/app_theme.dart';

enum SideMenuDestination {
  home,
  library,
  reader,
  favorites,
  folders,
  readingGoals,
  settings,
  help,
  logout,
}

class NovelLuxSideMenu extends StatelessWidget {
  const NovelLuxSideMenu({
    super.key,
    required this.selectedDestination,
    required this.isDarkMode,
    required this.onDestinationSelected,
    required this.onDarkModeChanged,
    required this.onOpenFolder,
  });

  final SideMenuDestination selectedDestination;
  final bool isDarkMode;
  final ValueChanged<SideMenuDestination> onDestinationSelected;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onOpenFolder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF171717)
        : const Color(0xFFFFFCF7);

    void select(SideMenuDestination destination) {
      Navigator.of(context).pop();
      onDestinationSelected(destination);
    }

    void openFolder() {
      Navigator.of(context).pop();
      onOpenFolder();
    }

    return Drawer(
      width: MediaQuery.sizeOf(context).width.clamp(260.0, 310.0).toDouble(),
      elevation: 18,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _DrawerHeader(isDark: isDark),
              ),
              const SizedBox(height: 17),
              _GoldDivider(isDark: isDark),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _SideMenuTile(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      selected: selectedDestination == SideMenuDestination.home,
                      onTap: () => select(SideMenuDestination.home),
                    ),
                    _SideMenuTile(
                      icon: Icons.local_library_outlined,
                      label: 'My Library',
                      selected:
                          selectedDestination == SideMenuDestination.library,
                      onTap: () => select(SideMenuDestination.library),
                    ),
                    _SideMenuTile(
                      icon: Icons.menu_book_rounded,
                      label: 'Reader',
                      selected:
                          selectedDestination == SideMenuDestination.reader,
                      onTap: () => select(SideMenuDestination.reader),
                    ),
                    // _SideMenuTile(
                    //   icon: Icons.favorite_border_rounded,
                    //   label: 'Favorites',
                    //   selected:
                    //       selectedDestination == SideMenuDestination.favorites,
                    //   onTap: () => select(SideMenuDestination.favorites),
                    // ),
                    _SideMenuTile(
                      icon: Icons.folder_shared,
                      label: 'Folder',
                      selected:
                          selectedDestination == SideMenuDestination.folders,
                      onTap: openFolder,
                    ),
                    // _SideMenuTile(
                    //   icon: Icons.track_changes_rounded,
                    //   label: 'Reading Goals',
                    //   selected:
                    //       selectedDestination ==
                    //       SideMenuDestination.readingGoals,
                    //   onTap: () => select(SideMenuDestination.readingGoals),
                    // ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 9),
                      child: Divider(height: 1),
                    ),
                    _SideMenuTile(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      selected:
                          selectedDestination == SideMenuDestination.settings,
                      onTap: () => select(SideMenuDestination.settings),
                    ),
                    _SideMenuTile(
                      icon: Icons.help_outline_rounded,
                      label: 'Help',
                      selected: selectedDestination == SideMenuDestination.help,
                      onTap: () => select(SideMenuDestination.help),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 9),
                      child: Divider(height: 1),
                    ),
                    _DarkModeTile(
                      value: isDarkMode,
                      onChanged: onDarkModeChanged,
                    ),
                    // _SideMenuTile(
                    //   icon: Icons.logout_rounded,
                    //   label: 'Log out',
                    //   selected: false,
                    //   onTap: () => select(SideMenuDestination.logout),
                    // ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 11, color: AppColors.gold),
                    SizedBox(width: 18),
                    Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    SizedBox(width: 18),
                    Icon(Icons.auto_awesome, size: 11, color: AppColors.gold),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.ivory,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/bookMoon1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 13),
        Text('NoveLux', style: AppFonts.brand(context, fontSize: 26)),
        const SizedBox(height: 2),
        Text(
          'Welcome back, Reader!',
          style: AppFonts.metadata(context, fontSize: 11),
        ),
      ],
    );
  }
}

class _GoldDivider extends StatelessWidget {
  const _GoldDivider({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 7),
          child: Icon(Icons.auto_awesome, size: 12, color: AppColors.gold),
        ),
        Expanded(
          child: Divider(
            color: AppColors.gold.withValues(alpha: isDark ? 0.35 : 0.5),
          ),
        ),
      ],
    );
  }
}

class _SideMenuTile extends StatelessWidget {
  const _SideMenuTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? AppColors.gold.withValues(alpha: 0.14)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                  color: selected ? AppColors.cream : colors.onSurface,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style:
                        AppFonts.navigationLabel(
                          context,
                          fontSize: 12,
                          color: selected ? AppColors.cream : colors.onSurface,
                        ).copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkModeTile extends StatelessWidget {
  const _DarkModeTile({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.dark_mode_outlined,
            size: 21,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Dark Mode',
              style: AppFonts.navigationLabel(context, fontSize: 12),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.gold,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
