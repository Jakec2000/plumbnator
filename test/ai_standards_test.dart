import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plumbnator/models/standards_registry.dart';
import 'package:plumbnator/services/gemini_service.dart';
import 'package:plumbnator/providers/state_providers.dart';

void main() {
  group('Plumbnator QLD: AI Plumbing Standards Registry Testing', () {
    test('Registry is seeded with comprehensive AS/NZS clauses', () {
      final clauses = PlumbingStandardsRegistry.clauses;
      expect(clauses.isNotEmpty, isTrue);

      // Verify presence of AS/NZS 3500 series
      final codes = clauses.map((c) => c.standardCode).toList();
      expect(codes.any((c) => c.contains('3500.1')), isTrue);
      expect(codes.any((c) => c.contains('3500.2')), isTrue);
      expect(codes.any((c) => c.contains('3500.4')), isTrue);
      expect(codes.any((c) => c.contains('2845.3')), isTrue);
    });

    test('Registry text builder formats text accurately for prompts', () {
      final registryText = PlumbingStandardsRegistry.buildRegistryText();
      expect(registryText, contains('AS/NZS 3500.1'));
      expect(registryText, contains('Maximum Static Water Pressure'));
      expect(registryText, contains('Minimum Cover Over Underground PVC Pipes'));
    });
  });

  group('Plumbnator QLD: Gemini Q&A Fallback Engine Testing', () {
    final service = GeminiService();

    test('askStandardsQuestion returns local fallback containing relevant metrics', () async {
      final response = await service.askStandardsQuestion('minimum cover for PVC drainage');
      
      expect(response, contains('AS/NZS 3500.2:2021 Clause 4.4 & Section 9'));
      expect(response, contains('Minimum Cover Over Underground PVC Pipes'));
      expect(response, contains('Domestic Yards (No traffic): 300 mm minimum cover'));
      expect(response, contains('Residential Driveways (Light traffic): 450 mm minimum cover'));
    });

    test('askStandardsQuestion returns local fallback for heated water limits', () async {
      final response = await service.askStandardsQuestion('tempering valve temperature limit');
      
      expect(response, contains('AS/NZS 3500.4:2021 Clause 1.9 & Clause 5.3'));
      expect(response, contains('Hot Water Delivery Temperature Ceilings'));
      expect(response, contains('Sanitary Outlets (Showers, Baths, Basins): 50°C maximum limit'));
    });
  });

  group('Plumbnator QLD: AI Assistant Riverpod State Provider Testing', () {
    test('AssistantState initializes with standard welcome message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(assistantProvider);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.messages.length, equals(1));
      expect(state.messages[0].isUser, isFalse);
      expect(state.messages[0].text, contains('Plumbnator compliance assistant'));
    });

    test('AssistantNotifier records user question and retrieves response', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(assistantProvider.notifier);
      
      // Send question and wait for fallback output
      await notifier.sendQuestion('What is static pressure cap?');

      final state = container.read(assistantProvider);
      expect(state.isLoading, isFalse);
      expect(state.messages.length, equals(3)); // Initial + User Question + AI Response
      expect(state.messages[1].isUser, isTrue);
      expect(state.messages[1].text, equals('What is static pressure cap?'));
      expect(state.messages[2].isUser, isFalse);
      expect(state.messages[2].text, contains('AS/NZS 3500.1:2021 Clause 3.4'));
    });
  });
}
