
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/main.dart'; // Ensure the correct import path

void main() {
  testWidgets('Restaurant Menu test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: const MyApp(),
      ),
    );

    // Verify that the title 'Restaurant Menu' is displayed.
    expect(find.text('Restaurant Menu'), findsOneWidget);

    // Add further tests to simulate user interactions, e.g., tapping a menu item.
  });
}
