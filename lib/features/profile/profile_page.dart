import 'package:flutter/material.dart';

import '../library/widgets/menu_menu.dart';
import '../library/widgets/reading_stats.dart';
import '../library/widgets/top_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        24,
      ),
      children: const [
        TopProfile(),
        SizedBox(height: 24),
        ReadingStats(),
        SizedBox(height: 24),
        MenuMenu(),
      ],
    );
  }
}