import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:touchstone/core/log/log.dart';
import 'package:touchstone/core/startup/app_startup.dart';
import 'package:touchstone/shared/constants/app_constants.dart';

/// Async dependencies eagerly initialized by [AppStartup].
class StartupFutureProviders {
  /// Stable identifier of the current install
  static final deviceId = FutureProvider<String>((ref) async {
    const prefix = kDebugMode ? AppConstants.debugPrefix : '';
    final deviceId = '$prefix${await FlutterUdid.udid}';
    'Device ID: $deviceId'.logInfo;
    return deviceId;
  }, retry: (retryCount, error) => null);
}
