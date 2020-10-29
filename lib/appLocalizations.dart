import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n/messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get continueToPlgdCloudButtonPart1 {
    return Intl.message('Continue to ', name: 'continueToPlgdCloudButtonPart1');
  }

  String get continueToPlgdCloudButtonPart2 {
    return Intl.message('plgd.cloud', name: 'continueToPlgdCloudButtonPart2');
  }
  
  String get configureCustomEndpointButtonPart1 {
    return Intl.message('Configure', name: 'configureCustomEndpointButtonPart1');
  }

  String get configureCustomEndpointButtonPart2 {
    return Intl.message(' custom plgd cloud endpoint', name: 'configureCustomEndpointButtonPart2');
  }
  
  String get customEndpointButtonContinue {
    return Intl.message('Continue', name: 'customEndpointButtonContinue');
  }

  String get customEndpointButtonCancel {
    return Intl.message('Cancel', name: 'customEndpointButtonCancel');
  }

  String get invalidEndpointNotification {
    return Intl.message('An invalid endpoint was specified.', name: 'invalidEndpointNotification');
  }

  String get unableToFetchConfigurationNotification {
    return Intl.message('Unable to fetch the configuration.', name: 'unableToFetchConfigurationNotification');
  }

  String get invalidConfigurationNotification {
    return Intl.message('The configuration was fetched, but was invalid.', name: 'invalidConfigurationNotification');
  }

  String get unableToInitializeClientNotification {
    return Intl.message('An error occurred during plgd client initialization.', name: 'unableToInitializeClientNotification');
  }

  String get requestApplicationSetupNotification {
    return Intl.message('Please setup your application again.', name: 'requestApplicationSetupNotification');
  }

  String get unableToDiscoverDevicesNotification {
    return Intl.message('An error occurred during device discovery.', name: 'unableToDiscoverDevicesNotification');
  }

  String get unableToSetDeviceOwnershipNotification {
    return Intl.message('Unable to set device ownership.', name: 'unableToSetDeviceOwnershipNotification');
  }

  String get unableToSetACLNotification {
    return Intl.message('An error occurred during ACL configuration.', name: 'unableToSetACLNotification');
  }

  String get unableToOnboardNotification {
    return Intl.message('An error occurred during the request to connect the device to the plgd cloud.', name: 'unableToOnboardNotification');
  }

  String get unableToDisownNotification {
    return Intl.message('Unable to set the device to factory reset mode.', name: 'unableToDisownNotification');
  }

  String get onboardButton {
    return Intl.message('ONBOARD', name: 'onboardButton');
  }

  String get factoryResetButton {
    return Intl.message('FACTORY RESET', name: 'factoryResetButton');
  }

  String get resetApplicationDialogText {
    return Intl.message('Do you want to reset the application?', name: 'resetApplicationDialogText');
  }

  String get resetApplicationDialogYesButton {
    return Intl.message('Yes', name: 'resetApplicationDialogYesButton');
  }

  String get resetApplicationDialogCancelButton {
    return Intl.message('Cancel', name: 'resetApplicationDialogCancelButton');
  }

  String get devicesScreenTitle {
    return Intl.message('DEVICEZ', name: 'devicesScreenTitle');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}