import 'package:client/appConstants.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static SharedPreferences localStorage;
  static SentryClient sentry;

  static Future initialize() async {
    Globals.localStorage = await SharedPreferences.getInstance();
    await CloudConfiguration.verifyDefault();
    sentry = SentryClient(SentryOptions(dsn: AppConstants.sentryDSN));
  }
}