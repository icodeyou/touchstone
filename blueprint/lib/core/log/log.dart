import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:touchstone/core/log/sentry_reporter.dart';

/// Getter for singleton, accessible from anywhere
Log get logger => Log();

/// Severity of a log entry, ordered from least to most severe
enum _Level {
  trace('🔍', 'TRACE', _AnsiCode.gray),
  debug('👀', 'DEBUG', _AnsiCode.blue),
  info('🔰', 'INFO', _AnsiCode.green),
  warning('🚧', 'WARN', _AnsiCode.yellow),
  error('🚨', 'ERROR', _AnsiCode.red),
  fatal('🧨', 'FATAL', _AnsiCode.red);

  const _Level(this.emoji, this.label, this.color);

  final String emoji;
  final String label;
  final _AnsiCode color;
}

/// This class is used to log messages into the console.
///
/// The class is a Singleton.
class Log {
  factory Log() => _instance;

  Log._();

  static final _instance = Log._();

  /// Minimum level displayed, everything below is skipped
  static const _minLevel = _Level.debug;

  /// iOS logging doesn't interpret ANSI escapes; they show as noise, not colors
  static final _useColors =
      kIsWeb || defaultTargetPlatform != TargetPlatform.iOS;

  void t(Object? message) => _log(_Level.trace, message);

  void d(Object? message) => _log(_Level.debug, message);

  void i(Object? message) => _log(_Level.info, message);

  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log(_Level.warning, message, error: error, stackTrace: stackTrace);

  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log(_Level.error, message, error: error, stackTrace: stackTrace);

  void f(Object? message, {Object? error, StackTrace? stackTrace}) => _log(
    _Level.fatal,
    message.toString().toUpperCase(),
    error: error,
    stackTrace: stackTrace,
  );

  void _log(
    _Level level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLevel.index) {
      return;
    }

    final buffer = StringBuffer(
      '${_colorize('[${_timestamp()}]', _AnsiCode.gray)} '
      '${_colorize('${level.emoji} ${level.label}', level.color, bold: true)} '
      '$message',
    );
    if (error != null) {
      buffer.write('\n${_colorize(error, level.color)}');
    }
    if (stackTrace != null) {
      buffer.write('\n${_colorize(stackTrace, _AnsiCode.gray)}');
    }
    // ignore: avoid_print
    print(buffer);

    SentryReporter.report(
      level.sentryLevel,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _colorize(Object? text, _AnsiCode color, {bool bold = false}) {
    if (!_useColors) {
      return '$text';
    }
    return '$color${bold ? _AnsiCode.bold : ''}$text${_AnsiCode.reset}';
  }

  static String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}';
  }
}

extension on _Level {
  SentryLevel get sentryLevel => switch (this) {
    _Level.trace || _Level.debug => SentryLevel.debug,
    _Level.info => SentryLevel.info,
    _Level.warning => SentryLevel.warning,
    _Level.error => SentryLevel.error,
    _Level.fatal => SentryLevel.fatal,
  };
}

extension LogStringExtension on String {
  void get logTrace => logger.t(this);

  void get logDebug => logger.d(this);

  void get logInfo => logger.i(this);

  void logWarning({Object? error, StackTrace? stackTrace}) =>
      logger.w(this, error: error, stackTrace: stackTrace);

  void logError({Object? error, StackTrace? stackTrace}) =>
      logger.e(this, error: error, stackTrace: stackTrace);

  void logFatal({Object? error, StackTrace? stackTrace}) =>
      logger.f(this, error: error, stackTrace: stackTrace);
}

enum _AnsiCode {
  reset(0),
  bold(1),
  red(31),
  green(32),
  yellow(33),
  blue(34),
  gray(90);

  const _AnsiCode(this._value);

  final int _value;

  @override
  String toString() => '\x1B[${_value}m';
}
