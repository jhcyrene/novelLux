import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_lux/core/widgets/loading_view.dart';

void main() {
  testWidgets('does not restart loading when the app theme changes', (
    WidgetTester tester,
  ) async {
    Widget buildApp(ThemeMode themeMode) {
      return MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeMode,
        home: const LoadingView(
          duration: Duration(milliseconds: 10),
          child: Text('Library'),
        ),
      );
    }

    await tester.pumpWidget(buildApp(ThemeMode.dark));
    await tester.pump(const Duration(milliseconds: 11));
    expect(find.text('Library'), findsOneWidget);

    await tester.pumpWidget(buildApp(ThemeMode.light));

    expect(find.text('Library'), findsOneWidget);
  });
}
