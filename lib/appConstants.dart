import 'dart:ui';

class AppConstants {
  static const Color yellowMainColor = Color.fromRGBO(234, 185, 39, 1);
  static const Color darkMainColor = Color.fromRGBO(30, 33, 38, 1);
  static const Color mainColor = Color.fromRGBO(37, 88, 151, 1);

  static final String cloudConfigurationStorageKey = 'plgd.dev/cloud-configuration';
  static final String selectedCloudConfigurationStorageKey = 'plgd.dev/selected-cloud-configuration';

  static String tryPlgdCloudEndpoint = 'try.plgd.cloud';
  static String authServer = 'auth.plgd.cloud';
  static String defautPlgdCloudAPIEndpoint = 'api.try.plgd.cloud';
  static String cloudConfigurationPath = '/.well-known/cloud-configuration';
  static String cloudOIDCPath = '/.well-known/openid-configuration';
  
  static String authRedirectUri = 'cloud.plgd.mobile://login-callback';
  static String mobileAppAuthClientId = 'dcgNAXqB9RTyPXh5ExCqWCeJsw5YpMqL';
  static String mobileAppAudience = 'https://try.plgd.cloud';
  static String deviceAuthProvider = 'plgd';
  static String deviceAuthClientId = 'cYN3p6lwNcNlOvvUhz55KvDZLQbJeDr5';
  static String deviceAuthAudience = mobileAppAudience;

  static String sentryDSN = '';
}