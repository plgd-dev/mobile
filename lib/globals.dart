import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appConstants.dart';

class Globals {
  static SharedPreferences localStorage;
  static final sentry = SentryClient(dsn: AppConstants.sentryEndpoint);
}