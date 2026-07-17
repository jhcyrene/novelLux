import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddPressed,
    this.navheight = 68,
    this.iconSize = 30,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddPressed;
  final double navheight;
  final double iconSize;

  static const double _raisedAmount = 14;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    // The Add button occupies navigation position 2.
    final navigationIndex =
        currentIndex >= 2 ? currentIndex + 1 : currentIndex;

    return SizedBox(
      height: navheight + safeBottom + _raisedAmount,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: _raisedAmount,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.bottomNavigationBarTheme.backgroundColor ??
                    theme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 0.6,
                  ),
                ),
              ),
              child: Theme(
                data: theme.copyWith(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: navigationIndex,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  elevation: 0,
                  onTap: (index) {
                    if (index == 2) {
                      onAddPressed();
                      return;
                    }

                    final pageIndex = index > 2 ? index - 1 : index;
                    onTap(pageIndex);
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: _AnimatedNavIcon(
                        selected: currentIndex == 0,
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home,
                        iconSize: iconSize,
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: _AnimatedNavIcon(
                        selected: currentIndex == 1,
                        icon: Icons.local_library_outlined,
                        selectedIcon: Icons.local_library,
                        iconSize: iconSize,
                      ),
                      label: 'Library',
                    ),

                    // Empty navigation space for the raised Add button.
                    const BottomNavigationBarItem(
                      icon: SizedBox(
                        width: 32,
                        height: 32,
                      ),
                      label: '',
                    ),

                    BottomNavigationBarItem(
                      icon: _AnimatedNavIcon(
                        selected: currentIndex == 2,
                        icon: Icons.menu_book_outlined,
                        selectedIcon: Icons.menu_book,
                        iconSize: iconSize,
                      ),
                      label: 'Reader',
                    ),
                    BottomNavigationBarItem(
                      icon: _AnimatedNavIcon(
                        selected: currentIndex == 3,
                        icon: Icons.person_outline,
                        selectedIcon: Icons.person,
                        iconSize: iconSize,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _AddBookButton(
                onPressed: onAddPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBookButton extends StatelessWidget {
  const _AddBookButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      elevation: 6,
      shadowColor: const Color(0x66000000),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavIcon extends StatelessWidget {
  const _AnimatedNavIcon({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.iconSize,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.18 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: Icon(
        selected ? selectedIcon : icon,
        size: iconSize,
      ),
    );
  }
}