import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';

/// The toast currently displayed. A new `id` means a new toast (the layer
/// restarts its pop-in animation on id change).
typedef ToastState = ({int id, String message});

extension ToastRefExtension on Ref {
  ToastController get toaster => read(ToastController.provider.notifier);
}

extension ToastWidgetRefExtension on WidgetRef {
  ToastController get toaster => read(ToastController.provider.notifier);
}

/// Single global toast: dark pill above the bottom edge, auto-dismissed. A new
/// toast replaces the current one immediately — never stacks.
class ToastController extends Notifier<ToastState?> {
  static final provider = NotifierProvider<ToastController, ToastState?>(
    ToastController.new,
  );

  static const displayDuration = ThemeDurations.m;

  Timer? _timer;
  int _lastId = 0;

  @override
  ToastState? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void show(String message) {
    _timer?.cancel();
    _lastId++;
    state = (id: _lastId, message: message);
    _timer = Timer(displayDuration, () => state = null);
  }
}
