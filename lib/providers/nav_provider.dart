import 'package:flutter_riverpod/flutter_riverpod.dart';



/// Riverpod Notifier for the global navigation index.
class NavNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}

final navProvider = NotifierProvider<NavNotifier, int>(NavNotifier.new);

