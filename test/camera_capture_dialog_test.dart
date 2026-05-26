import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plumbnator/widgets/ai_compliance/camera_capture_dialog.dart';

void main() {
  testWidgets('CameraCaptureDialog renders HUD overlays and responds to user interaction', (WidgetTester tester) async {
    String? capturedCategory;
    String? capturedDeviation;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  CameraCaptureDialog.show(context, (category, deviation) {
                    capturedCategory = category;
                    capturedDeviation = deviation;
                  });
                },
                child: const Text('Show Camera'),
              );
            },
          ),
        ),
      ),
    );

    // Open the dialog
    await tester.tap(find.text('Show Camera'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // wait for dialog route transition

    // Verify Title and default HWS preset
    expect(find.text('PLUMB-SCANNER VIEWFINDER'), findsOneWidget);
    expect(find.text('HWS Cylinder'), findsOneWidget);
    
    // Tap on Drain Grade overlay category
    await tester.tap(find.text('Drain Grade'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Change slider value to simulate alignment
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    await tester.drag(sliderFinder, const Offset(-100.0, 0.0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap capture button
    final captureButtonFinder = find.text('Check Compliance');
    expect(captureButtonFinder, findsOneWidget);
    await tester.tap(captureButtonFinder);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // wait for dialog route pop transition

    // Dialog should be closed, and callback should be fired
    expect(find.byType(CameraCaptureDialog), findsNothing);
    expect(capturedCategory, equals('Drain Gradient'));
    expect(capturedDeviation, isNotNull);
  });
}
