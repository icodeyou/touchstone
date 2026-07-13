import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/log/log.dart';

final class RiverpodObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    //logger.d('Provider $provider was added with value $value');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    //logger.d('Provider $provider was disposed');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    //logger.d('Provider $provider updated from $previousValue to $newValue');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logger.e('''
        ⛔ ERROR IN PROVIDER : ${context.provider}
        💬 MESSAGE : $error
        📜 STACKTRACE : $stackTrace
      ''');
  }
}
