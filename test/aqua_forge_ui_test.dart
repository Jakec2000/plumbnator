import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:plumbnator/views/aqua_forge/pro_dashboard_view.dart';
import 'package:plumbnator/views/aqua_forge/homeowner_dashboard_view.dart';

void main() {
  group('AquaForge UI Tests', () {
    testWidgets('ProDashboard renders active dispatches', (WidgetTester tester) async {
      final instance = FakeFirebaseFirestore();
      
      // Add a dispatched job
      await instance.collection('jobs').add({
        'title': 'Emergency Pipe Burst',
        'location': '123 Main St',
        'urgency': 'critical',
        'status': 'dispatched',
      });

      await tester.pumpWidget(MaterialApp(
        home: ProDashboard(firestore: instance),
      ));
      
      // Wait for stream
      await tester.pumpAndSettle();

      // Check if job appears
      expect(find.text('EMERGENCY PIPE BURST'), findsOneWidget);
      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('URGENCY: CRITICAL'), findsOneWidget);

      // Tap on 'COMPLETE & VERIFY COMPLIANCE'
      await tester.tap(find.text('COMPLETE & VERIFY COMPLIANCE'));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('AS/NZS 3500 COMPLIANCE'), findsOneWidget);
      
      // Check both checkboxes
      await tester.tap(find.text('Static pressure does not exceed 500 kPa (AS/NZS 3500.1)'));
      await tester.pump();
      await tester.tap(find.text('All replaced fittings possess a valid WaterMark certification'));
      await tester.pump();

      // Submit
      await tester.tap(find.text('SIGN OFF'));
      await tester.pumpAndSettle();

      // Job should disappear from the list (status updated to 'completed')
      expect(find.text('EMERGENCY PIPE BURST'), findsNothing);
      expect(find.text('NO ACTIVE DISPATCHES'), findsOneWidget);
    });

    testWidgets('HomeownerDashboard renders live alerts', (WidgetTester tester) async {
      final instance = FakeFirebaseFirestore();
      
      // Add a system alert
      await instance.collection('alerts').add({
        'title': 'Water Usage Spike',
        'description': 'Potential hidden leak in zone 2',
        'status': 'warning',
        'probability': 85,
      });

      await tester.pumpWidget(MaterialApp(
        home: HomeownerDashboard(firestore: instance),
      ));
      
      // Wait for stream
      await tester.pumpAndSettle();

      // Check if alert appears
      expect(find.text('Water Usage Spike'), findsOneWidget);
      expect(find.text('Potential hidden leak in zone 2 (85% Prob.)'), findsOneWidget);
      
      // Button
      expect(find.text('Fix Now'), findsOneWidget);
    });

    testWidgets('HomeownerDashboard shows empty state when no alerts exist', (WidgetTester tester) async {
      final instance = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: HomeownerDashboard(firestore: instance),
      ));
      
      // Wait for stream
      await tester.pumpAndSettle();

      expect(find.text('No active alerts in the network. System Nominal.'), findsOneWidget);
    });
  });
}
