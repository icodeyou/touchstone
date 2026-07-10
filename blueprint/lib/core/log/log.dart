import 'dart:developer';

import 'package:logger/logger.dart';
import 'package:touchstone/shared/constants/app_constants.dart';

/// Getter for singleton, accessible from anywhere
Logger get logger => Log();

/// This class is used to log messages into the console.
/// It is based on the package Logger.
///
/// The class is a Singleton.
class Log extends Logger {
  /// Primary public constructor, returns instance of singleton
  factory Log() {
    return _instance;
  }

  Log._()
      : super(
          output: CustomConsoleOutput(),
          printer: CustomPrettyPrinter(),
          level: Level.debug, // This hides Level.trace logs
        );

  static final _instance = Log._();
}

/// This is where we output the logs to the console.
class CustomConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln();
    event.lines.forEach(buffer.writeln);
    log(buffer.toString(), name: '🔶', error: event.origin.error);
  }
}

class CustomPrettyPrinter extends PrettyPrinter {
  CustomPrettyPrinter()
      : super(
          dateTimeFormat: (time) {
            return '🕰️ ${DateTimeFormat.dateAndTime(time)}';
          },
          // Waiting for this : https://github.com/SourceHorizon/logger/issues/6
          methodCount: AppConstants.logStacktraceNumber,
          levelEmojis: {
            Level.trace: '🔍',
            Level.debug: '👀',
            Level.info: '🔰',
            Level.warning: '🚧',
            Level.error: '🚨',
            Level.fatal: '🧨',
          },
          lineLength: 500,
          noBoxingByDefault: true,
          levelColors: {
            Level.trace: const AnsiColor.fg(8),
            Level.debug: const AnsiColor.fg(14),
            Level.info: const AnsiColor.fg(2),
            Level.warning: const AnsiColor.fg(11),
            Level.error: const AnsiColor.fg(9),
            Level.fatal: const AnsiColor.fg(1),
          },
          /*
          0:  Black,      8:  Grey
          1:  Red,        9:  Red Ascend
          2:  Green,      10: Green Ascend
          3:  Yellow      11: Yellow Ascend
          4:  Blue        12: Blue Ascend
          5:  Purple      13: Purple Ascend
          6:  Turquoise   14: Turquoise Ascend
          7:  White       15: White Ascend
          */
        );
}
