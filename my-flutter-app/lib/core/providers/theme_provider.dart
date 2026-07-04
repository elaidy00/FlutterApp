import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier() : super(false);

  void toggle() => state = !state;
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>(
  (ref) => ThemeModeNotifier(),
);
