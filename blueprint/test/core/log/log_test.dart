import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/core/log/log.dart';

List<String> capturePrint(void Function() body) {
  final lines = <String>[];
  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (self, parent, zone, line) => lines.add(line),
    ),
  );
  return lines;
}

void main() {
  group('LogStringExtension', () {
    test('logTrace prints nothing because trace is below the minimum level',
        () {
      final lines = capturePrint(() => 'invisible'.logTrace);

      expect(lines, isEmpty);
    });

    test('logDebug prints the message with the DEBUG label', () {
      final lines = capturePrint(() => 'hello'.logDebug);

      expect(lines, hasLength(1));
      expect(lines.first, contains('DEBUG'));
      expect(lines.first, contains('hello'));
    });

    test('logInfo prints the message with the INFO label', () {
      final lines = capturePrint(() => 'hello'.logInfo);

      expect(lines, hasLength(1));
      expect(lines.first, contains('INFO'));
      expect(lines.first, contains('hello'));
    });

    test('logWarning prints the message with the WARN label', () {
      final lines = capturePrint(() => 'careful'.logWarning());

      expect(lines, hasLength(1));
      expect(lines.first, contains('WARN'));
      expect(lines.first, contains('careful'));
    });

    test('logError prints the message with the ERROR label', () {
      final lines = capturePrint(() => 'toto'.logError());

      expect(lines, hasLength(1));
      expect(lines.first, contains('ERROR'));
      expect(lines.first, contains('toto'));
    });

    test('logError includes the error and stack trace on extra lines', () {
      final error = StateError('boom');
      final stackTrace = StackTrace.current;

      final lines = capturePrint(
        () => 'toto'.logError(error: error, stackTrace: stackTrace),
      );

      expect(lines, hasLength(1));
      final output = lines.first.split('\n');
      expect(output.first, contains('toto'));
      expect(output.skip(1).join('\n'), contains('Bad state: boom'));
      expect(output.skip(1).join('\n'), contains('log_test.dart'));
    });

    test('logFatal prints the message uppercased with the FATAL label', () {
      final lines = capturePrint(() => 'meltdown'.logFatal());

      expect(lines, hasLength(1));
      expect(lines.first, contains('FATAL'));
      expect(lines.first, contains('MELTDOWN'));
    });
  });
}
