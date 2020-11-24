import 'dart:io';

import 'package:client/appConstants.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Globals {
  static SharedPreferences localStorage;
  static SentryClient sentry;

  static Future initialize() async {
    Globals.localStorage = await SharedPreferences.getInstance();
    var packageInfo = await PackageInfo.fromPlatform();
    var version = packageInfo.version + '+' + packageInfo.buildNumber;
    sentry = SentryClient(
    dsn: AppConstants.sentryDSN,
    environmentAttributes: Event(
        environment: _getEnvironmentName(),
        release: version
      )
    );
  }
  
  static String _getEnvironmentName() {
    if (Platform.isIOS)
      return 'mobile-ios';
    else if (Platform.isAndroid)
      return 'mobile-android';
    return 'mobile';
  }
}