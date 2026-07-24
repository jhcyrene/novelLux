import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:novel_lux/core/widgets/snackbar.dart';

void main() {
  testWidgets('shows a floating snackbar with the requested message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  SnackBarNotif.success(context, 'Book imported');
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));

    expect(snackBar.behavior, SnackBarBehavior.floating);
    expect(find.text('Book imported'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('supports an optional action', (tester) async {
    var actionPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  SnackBarNotif.show(
                    context,
                    message: 'Book deleted',
                    actionLabel: 'Undo',
                    onAction: () {
                      actionPressed = true;
                    },
                  );
                },
                child: const Text('Show'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.tap(find.text('Undo'));

    expect(actionPressed, isTrue);
  });
}
