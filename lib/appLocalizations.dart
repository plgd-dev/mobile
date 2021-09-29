import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'appConstants.dart';
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

  String get continueToPlgdCloudButton {
    return Intl.message('Continue to ', name: 'continueToPlgdCloudButton');
  }
  
  String get configureCustomEndpointButton {
    return Intl.message('Configure', name: 'configureCustomEndpointButton');
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
  
  String get unableToFetchOpenIdConfigurationNotification {
    return Intl.message('Unable to fetch the OpenId configuration.', name: 'unableToFetchOpenIdConfigurationNotification');
  }

  String get invalidConfigurationNotification {
    return Intl.message('The configuration was fetched, but was invalid.', name: 'invalidConfigurationNotification');
  }

  String get unableToInitializeClientNotification {
    return Intl.message('An error occurred during plgd client initialization.', name: 'unableToInitializeClientNotification');
  }

  String get unableToAuthenticateNotification {
    return Intl.message('An error occurred during authentication.', name: 'unableToAuthenticateNotification');
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
    return Intl.message('Onboard', name: 'onboardButton');
  }

  String get factoryResetButton {
    return Intl.message('Factory reset', name: 'factoryResetButton');
  }
  
  String get ownedByOtherButtonHint {
    return Intl.message('Owned by other', name: 'ownedByOtherButtonHint');
  }

  String get switchPlgdInstanceDialogText {
    return Intl.message('Do you want to switch to different plgd instance?', name: 'switchPlgdInstanceDialogText');
  }

  String get resetApplicationDialogYesButton {
    return Intl.message('Yes', name: 'resetApplicationDialogYesButton');
  }

  String get resetApplicationDialogCancelButton {
    return Intl.message('Cancel', name: 'resetApplicationDialogCancelButton');
  }

  String get devicesScreenTitle {
    return Intl.message('Devices', name: 'devicesScreenTitle');
  }

  String get setDefaultRedirectUrlHint {
    return Intl.message('Set \'${AppConstants.authRedirectUri}\' as allowed redirect url.', name: 'setDefaultRedirectUrlHint');
  }

  String get saveConfigurationButton {
    return Intl.message('Save Configuration', name: 'saveConfigurationButton');
  }

  String get deviceOAuthClientConfigurationGroupName {
    return Intl.message('Device Client', name: 'deviceOAuthClientConfigurationGroupName');
  }

  String get mobileAppOAuthClientConfigurationGroupName {
    return Intl.message('Mobile Application Client', name: 'mobileAppOAuthClientConfigurationGroupName');
  }

  String get skipOAuthConfigurationHint {
    return Intl.message('* Skip if using plgd bundle with default OAuth configuration', name: 'skipOAuthConfigurationHint');
  }

  String get authorizationConfigurationGroupName {
    return Intl.message('Authorization', name: 'authorizationConfigurationGroupName');
  }

  String get missingConfigurationNameNotification {
    return Intl.message('Configuration name is required.', name: 'missingConfigurationNameNotification');
  }

  String get generalConfigurationGroupName {
    return Intl.message('General', name: 'generalConfigurationGroupName');
  }
  
  String get configurationDetailsScreenTitle {
    return Intl.message('Details', name: 'configurationDetailsScreenTitle');
  }
  
  String get configurationScreenTitle {
    return Intl.message('Configuration', name: 'configurationScreenTitle');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'de', 'ko', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}