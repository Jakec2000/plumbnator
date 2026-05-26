import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';



/// Represents a message in the AI standards assistant chat history.
class AssistantMessage {
  /// The text content of the message.
  final String text;

  /// Whether the message is sent by the user (true) or the AI assistant (false).
  final bool isUser;

  /// The timestamp of the message.
  final DateTime timestamp;

  /// Creates a new [AssistantMessage] instance.
  const AssistantMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// The Riverpod state for the AI standards Q&A assistant.
class AssistantState {
  /// The list of conversation messages.
  final List<AssistantMessage> messages;

  /// Whether the assistant is currently loading a response.
  final bool isLoading;

  /// Optional error message.
  final String? error;

  /// The currently selected AI model engine.
  final String selectedModel;

  /// Creates an [AssistantState] instance.
  const AssistantState({
    required this.messages,
    required this.isLoading,
    required this.selectedModel,
    this.error,
  });

  /// Factory for the initial state of the assistant.
  factory AssistantState.initial() {
    return AssistantState(
      messages: [
        AssistantMessage(
          text: 'Hello! I am the Plumbnator compliance assistant. Ask me anything about AS/NZS 3500 plumbing standards or Queensland QBCC notifiable work regulations.',
          isUser: false,
          timestamp: DateTime.now(),
        )
      ],
      isLoading: false,
      selectedModel: 'Grok 4.3',
    );
  }

  /// Creates a copy of the state with overridden values.
  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
    String? error,
    String? selectedModel,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      selectedModel: selectedModel ?? this.selectedModel,
      error: error,
    );
  }
}

/// Riverpod Notifier managing Q&A assistant chat sessions.
class AssistantNotifier extends Notifier<AssistantState> {
  final GeminiService _geminiService = GeminiService();

  @override
  AssistantState build() {
    return AssistantState.initial();
  }

  /// Changes the active AI model engine.
  void selectModel(String model) {
    state = state.copyWith(selectedModel: model);
  }

  /// Sends a question to the AI standards model and records the response.
  Future<void> sendQuestion(String question) async {
    if (question.trim().isEmpty) return;

    final userMsg = AssistantMessage(
      text: question,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final answer = await _geminiService.askStandardsQuestion(
        question,
        model: state.selectedModel,
      );
      final aiMsg = AssistantMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to receive a response from AI. Please try again.',
      );
    }
  }

  /// Clears the conversation history back to the initial message.
  void clearHistory() {
    state = AssistantState.initial().copyWith(selectedModel: state.selectedModel);
  }
}

/// Provider for the AI standards assistant state.
final assistantProvider = NotifierProvider<AssistantNotifier, AssistantState>(AssistantNotifier.new);

