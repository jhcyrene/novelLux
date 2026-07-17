import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.duration = const Duration(milliseconds: 1600),
    required this.child,
  });

  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: Future<void>.delayed(duration),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }

        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: SizedBox.expand(
            child: Image.asset(
              isDark
                  ? 'assets/images/splash/splash_dark.png'
                  : 'assets/images/splash/splash_light.png',
                  
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }
}