import 'package:flutter/material.dart';
import 'package:novel_lux/core/theme/app_theme.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    required this.child,
  });

  final Duration duration;
  final Widget child;

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  late Future<void> _loading;

  @override
  void initState() {
    super.initState();
    _loading = Future<void>.delayed(widget.duration);
  }

  @override
  void didUpdateWidget(covariant LoadingView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _loading = Future<void>.delayed(widget.duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loading,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.child;
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppColors.deepBlack : AppColors.white,
          body: SizedBox.expand(
            child: Image.asset(
              isDark
                  ? 'assets/images/splash/splash2_dark.png'
                  : 'assets/images/splash/splash2_light.png',

              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }
}

