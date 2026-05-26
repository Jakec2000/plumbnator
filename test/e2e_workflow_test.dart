import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plumbnator/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('E2E Workflow: AI Audit to Form 4 Lodgement', (WidgetTester tester) async {
    // 1. Initialize the app with Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // 2. Navigate to AI Vision Audit (Index 3 of Bottom Nav, Tab 0 is active by default)
    await tester.tap(find.text('Compliance').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Verify we are on the AI Compliance view
    expect(find.text('AI VISION COMPLIANCE CHECKER'), findsOneWidget);

    // 4. Trigger the mock image upload flow
    final uploadButton = find.text('Upload Photo');
    await tester.ensureVisible(uploadButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(uploadButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Select the dummy image
    expect(find.text('Water_Pipe_Lagging_Check.jpg'), findsOneWidget);
    await tester.tap(find.text('Water_Pipe_Lagging_Check.jpg'));
    
    // The dialog closes and audit runs, wait for the AI audit to complete
    await tester.pump(const Duration(milliseconds: 500)); // allow state to update
    await tester.pump(const Duration(seconds: 3)); // wait for the dummy future delay

    // 5. Check if the AI results are displayed
    expect(find.textContaining('Confidence Rating:'), findsOneWidget);
    expect(find.text('Verification image uploaded successfully.'), findsOneWidget);

    // 6. Navigate to QBCC Form 4 (Index 2 of Bottom Nav, Tab 0 is active by default)
    await tester.tap(find.text('Field Docs').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 7. Verify we are on the Form 4 view
    expect(find.text('QBCC FORM 4 REGISTER'), findsOneWidget);

    // 8. Find an unlodged job and select it
    expect(find.text('Select Completed Job to Lodge'), findsOneWidget);
    
    // There should be default seed jobs in the jobsProvider. We tap the first one.
    // 'Hot Water System Replacement' is one of the seeds.
    expect(find.text('Hot Water System Replacement'), findsOneWidget);
    final jobTile = find.text('Hot Water System Replacement');
    await tester.ensureVisible(jobTile);
    await tester.tap(jobTile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 9. Lodge Form 4
    final lodgeButton = find.text('Lodge Form 4 Now');
    await tester.ensureVisible(lodgeButton);
    await tester.tap(lodgeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 10. Verify Lodgement Success via Snackbar and UI update
    expect(find.textContaining('Successfully Lodged Form 4 for "Hot Water System Replacement"'), findsOneWidget);

    // Job should no longer be in the unlodged list
    expect(find.text('Hot Water System Replacement'), findsNothing);
  });
}
