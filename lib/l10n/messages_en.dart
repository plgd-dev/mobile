// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "configureCustomEndpointButton" : MessageLookupByLibrary.simpleMessage("Configure custom plgd cloud endpoint"),
    "continueToPlgdCloudButton" : MessageLookupByLibrary.simpleMessage("Continue to "),
    "customEndpointButtonCancel" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "customEndpointButtonContinue" : MessageLookupByLibrary.simpleMessage("Continue"),
    "devicesScreenTitle" : MessageLookupByLibrary.simpleMessage("DEVICES"),
    "factoryResetButton" : MessageLookupByLibrary.simpleMessage("FACTORY RESET"),
    "invalidConfigurationNotification" : MessageLookupByLibrary.simpleMessage("The configuration was fetched, but was invalid."),
    "invalidEndpointNotification" : MessageLookupByLibrary.simpleMessage("An invalid endpoint was specified."),
    "onboardButton" : MessageLookupByLibrary.simpleMessage("ONBOARD"),
    "requestApplicationSetupNotification" : MessageLookupByLibrary.simpleMessage("Please setup your application again."),
    "resetApplicationDialogCancelButton" : MessageLookupByLibrary.simpleMessage("Cancel"),
    "resetApplicationDialogText" : MessageLookupByLibrary.simpleMessage("Do you want to reset the application?"),
    "resetApplicationDialogYesButton" : MessageLookupByLibrary.simpleMessage("Yes"),
    "unableToAuthenticateNotification" : MessageLookupByLibrary.simpleMessage("An error occurred during authentication."),
    "unableToDiscoverDevicesNotification" : MessageLookupByLibrary.simpleMessage("An error occurred during device discovery."),
    "unableToDisownNotification" : MessageLookupByLibrary.simpleMessage("Unable to set the device to factory reset mode."),
    "unableToFetchConfigurationNotification" : MessageLookupByLibrary.simpleMessage("Unable to fetch the configuration."),
    "unableToInitializeClientNotification" : MessageLookupByLibrary.simpleMessage("An error occurred during plgd client initialization."),
    "unableToOnboardNotification" : MessageLookupByLibrary.simpleMessage("An error occurred during the request to connect the device to the plgd cloud."),
    "unableToSetACLNotification" : MessageLookupByLibrary.simpleMessage("An error occurred during ACL configuration."),
    "unableToSetDeviceOwnershipNotification" : MessageLookupByLibrary.simpleMessage("Unable to set device ownership.")
  };
}
