import 'dart:io';

import 'package:client/appConstants.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static SharedPreferences localStorage;
  static final sentry = SentryClient(dsn: AppConstants.sentryDSN, environmentAttributes: Event(environment: _getEnvironmentName()));
  
  static String _getEnvironmentName() {
    if (Platform.isIOS)
      return 'mobile-ios';
    else if (Platform.isAndroid)
      return 'mobile-android';
    return 'mobile';
  }
}