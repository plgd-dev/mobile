import 'dart:ui';

class AppConstants {
  static const Color yellowMainColor = Color.fromRGBO(234, 185, 39, 1);
  static const Color blueMainColor = Color.fromRGBO(67, 101, 167, 1);
  static const Color darkMainColor = Color.fromRGBO(30, 33, 38, 1);
  static const Color darkMainColor40 = Color.fromRGBO(30, 33, 38, 0.7);
  static const String topBarFont = 'Poppins';

  static String tryPlgdCloudEndpoint = 'try.plgd.cloud';
  static const String cloudConfigurationPath = '/.well-known/ocfcloud-configuration';
  static Uri defautPlgdCloudEndpoint = Uri.parse('https://portal.try.plgd.cloud' + cloudConfigurationPath);
  static const String sentryDSN = '';
}