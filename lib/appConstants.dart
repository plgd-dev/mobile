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
  static const String unableToInitializeClient = 'Error occured during initialization';
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
  static const Color darkMainColor = Color.fromRGBO(30, 33, 38, 1);
  static const Color darkMainColor40 = Color.fromRGBO(30, 33, 38, 0.7);
  static const String topBarFont = 'Poppins';

  static const String cloudConfigurationPath = '/.well-known/ocfcloud-configuration';
  static Uri defautPlgdCloudEndpoint = Uri.parse('https://portal.try.plgd.cloud' + cloudConfigurationPath);
  static const String noDeviceOwner = '00000000-0000-0000-0000-000000000000';
}