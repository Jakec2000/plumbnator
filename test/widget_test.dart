import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plumbnator/main.dart';

void main() {
  testWidgets('Plumbnator smoke test: App boots up and displays navigation shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that our brand and main title are rendered in the shell.
    expect(find.text('PLUMBNATOR QLD'), findsOneWidget);
  });
}
