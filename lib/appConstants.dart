import 'dart:ui';

class AppConstants {
  static const String continueToPlgdCloudButtonPart1 = 'Continue to ';
  static const String continueToPlgdCloudButtonPart2 = 'plgd.cloud';
  static const String configureCustomEndpointButtonPart1 = 'Configure';
  static const String configureCustomEndpointButtonPart2 = ' custom plgd cloud endpoint';
  static const String customEndpointButtonContinue = 'Continue';
  static const String customEndpointButtonCancel = 'Cancel';
  static const String invalidEndpoint = 'Invalid endpoint';
  static const String unableToFetchConfiguration = 'Unable to fetch configuration';
  static const String invalidConfiguration = 'Fetched configuration is invalid';
  static const String unableToInitializeClient = 'Error occured during initialization';
  static const String unableToInitializeClientSetupRedirect = 'Error occured during initialization. Please setup your application again.';
  static const String unableToDiscoverDevices = 'Error occured during device discovery';
  static const String unableToSetDeviceOwnership = 'Unable to set device ownership';
  static const String unableToSetCloudACL = 'Unable to set ACL for cloud';
  static const String unableToOnboard = 'Unable to onboard device to the cloud';
  static const String unableToDisown = 'Unable to set device to factory reset mode';
  static const String messageUnableToPersistConfiguration = 'Unable to persist configuration';
  static const String buttonOnboard = 'ONBOARD';
  static const String buttonFactoryReset = 'FACTORY RESET';
  static const String resetApplicationDialogText = 'Do you want to reset application?';
  static const String resetApplicationDialogOkButton = 'OK';
  static const String resetApplicationDialogCancelButton = 'Cancel';
  static const String devicesScreenTitle = 'DEVICES';
  
  static const String messageUnknownError = 'Unknown error occured: ';

  static const Color yellowMainColor = Color.fromRGBO(234, 185, 39, 1);
  static const Color blueMainColor = Color.fromRGBO(67, 101, 167, 1);
  static const Color lightBlueMainColor = Color.fromRGBO(143, 199, 225, 1);
  static const Color darkMainColor = Color.fromRGBO(30, 33, 38, 1);
  static const Color darkMainColor40 = Color.fromRGBO(30, 33, 38, 0.7);
  static const String topBarFont = 'Poppins';

  static const String cloudConfigurationPath = '/.well-known/ocfcloud-configuration';
  static Uri defautPlgdCloudEndpoint = Uri.parse('https://portal.try.plgd.cloud' + cloudConfigurationPath);
  static const String sentryEndpoint = 'https://3dab0aeaa28942e8964c0d8f90d493d9@o466634.ingest.sentry.io/5481099';
}