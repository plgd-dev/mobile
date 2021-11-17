import 'dart:convert';
import 'dart:io';

import 'package:client/appConstants.dart';
import 'package:client/globals.dart';
import 'package:http/io_client.dart';
import 'package:uuid/uuid.dart';

class CloudConfiguration {
  static final defaultId = 'b044eece-3b0f-4206-a481-7802ed9c4a5d';

  String id;
  String customName;
  String plgdAPIEndpoint;
  String authorizationServer;
  String mobileAppAuthClientId;
  String mobileAppAudience;
  String mobileAuthScopes;
  String deviceAuthProvider;
  String deviceAuthClientId;
  String deviceAuthAudience;
  String deviceAuthScopes;
  String authorizationEndpoint;
  String tokenEndpoint;

   CloudConfiguration(
      {this.customName,
      this.plgdAPIEndpoint,
      this.authorizationServer,
      this.mobileAppAuthClientId,
      this.mobileAppAudience,
      this.mobileAuthScopes,
      this.deviceAuthProvider,
      this.deviceAuthClientId,
      this.deviceAuthAudience,
      this.deviceAuthScopes}) {
        this.id = Uuid().v4();
      }
  
  CloudConfiguration.fromJson(Map<String, dynamic> json)
      : id = json['id'],
      customName = json['customName'],
      plgdAPIEndpoint = json['plgdAPIEndpoint'],
      authorizationServer = json['authorizationServer'],
      mobileAppAuthClientId = json['mobileAppAuthClientId'],
      mobileAppAudience = json['mobileAppAudience'],
      mobileAuthScopes = json['mobileAuthScopes'],
      deviceAuthProvider = json['deviceAuthProvider'],
      deviceAuthClientId = json['deviceAuthClientId'],
      deviceAuthAudience = json['deviceAuthAudience'],
      deviceAuthScopes = json['deviceAuthScopes'],
      authorizationEndpoint = json['authorizationEndpoint'],
      tokenEndpoint = json['tokenEndpoint'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customName': customName,
      'plgdAPIEndpoint': plgdAPIEndpoint,
      'authorizationServer': authorizationServer,
      'mobileAppAuthClientId': mobileAppAuthClientId,
      'mobileAppAudience': mobileAppAudience,
      'mobileAuthScopes': mobileAuthScopes,
      'deviceAuthProvider': deviceAuthProvider,
      'deviceAuthClientId': deviceAuthClientId,
      'deviceAuthAudience': deviceAuthAudience,
      'deviceAuthScopes': deviceAuthScopes,
      'authorizationEndpoint': authorizationEndpoint,
      'tokenEndpoint': tokenEndpoint
    };
  }

  static String loadSelectedConfigurationId() {
    return Globals.localStorage.getString(AppConstants.selectedCloudConfigurationStorageKey);
  }

  static Future<bool> saveSelectedConfigurationId(String selectedCloudConfigurationId) {
    return Globals.localStorage.setString(AppConstants.selectedCloudConfigurationStorageKey, selectedCloudConfigurationId);
  }

  static List<CloudConfiguration> load() {
    var configs = Globals.localStorage.getString(AppConstants.cloudConfigurationStorageKey);
    if (configs == null) {
      return new List<CloudConfiguration>();
    }
    Iterable l = json.decode(configs);
    return List<CloudConfiguration>.from(l.map((model)=> CloudConfiguration.fromJson(model)));
  }

  static Future<bool> save(List<CloudConfiguration> cloudConfigurations) {
    var json = jsonEncode(cloudConfigurations);
    return Globals.localStorage.setString(AppConstants.cloudConfigurationStorageKey, json);
  }

  static Future<List<CloudConfiguration>> addOrUpdate(CloudConfiguration cloudConfiguration) async {
    var cloudConfigurations = CloudConfiguration.load();
    for (var i = 0; i < cloudConfigurations.length; i++) {
      if (cloudConfigurations[i].id == cloudConfiguration.id) {
        cloudConfigurations[i] = cloudConfiguration;
        await save(cloudConfigurations);
        return cloudConfigurations;
      }
    }
    cloudConfigurations.add(cloudConfiguration);
    await CloudConfiguration.save(cloudConfigurations);
    return cloudConfigurations;
  }

  static CloudConfiguration getSelected(List<CloudConfiguration> cloudConfigurations) {
    var selectedConfigurationId = loadSelectedConfigurationId();
    return cloudConfigurations.singleWhere((configuration) => configuration.id == selectedConfigurationId, orElse: () { return null; });
  }

  static CloudConfiguration getDefault(List<CloudConfiguration> cloudConfigurations) {
    return cloudConfigurations.singleWhere((configuration) => configuration.id == defaultId, orElse: () { return null; });
  }

  static Future<void> setDefault() async {
    var defaultConfiguration = CloudConfiguration(
      customName: 'try.plgd.cloud',
      plgdAPIEndpoint: AppConstants.defautPlgdCloudAPIEndpoint,
      authorizationServer: AppConstants.authServer,
      mobileAppAuthClientId: AppConstants.mobileAppAuthClientId,
      mobileAppAudience: AppConstants.mobileAppAudience,
      deviceAuthProvider: AppConstants.deviceAuthProvider,
      deviceAuthClientId: AppConstants.deviceAuthClientId,
      deviceAuthAudience: AppConstants.deviceAuthAudience,
      deviceAuthScopes: AppConstants.deviceAuthScopes
    );
    defaultConfiguration.id = defaultId;
    defaultConfiguration.authorizationEndpoint = 'https://${defaultConfiguration.authorizationServer}/authorize';
    defaultConfiguration.tokenEndpoint = 'https://${defaultConfiguration.authorizationServer}/oauth/token';

    var cloudConfigurations = await addOrUpdate(defaultConfiguration);
    var selected = getSelected(cloudConfigurations);
    if (selected == null) {
      await Globals.localStorage.setString(AppConstants.selectedCloudConfigurationStorageKey, defaultConfiguration.id);
    }
  }

    Future<bool> setOpenIdConfiguration() async {
    var httpClient = HttpClient()..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    var ioClient = new IOClient(httpClient);

    Map<String, dynamic> oidcConfigurationResponse;
    try {
      var response = await ioClient
        .get(Uri.parse('https://${this.authorizationServer}${AppConstants.cloudOIDCPath}'))
        .timeout(const Duration(seconds: 10));
      oidcConfigurationResponse = jsonDecode(response.body);
    } on Exception catch (error, stackTrace) {
      await Globals.sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
      return false;
    }

    if (!oidcConfigurationResponse.containsKey('authorization_endpoint') || !oidcConfigurationResponse.containsKey('token_endpoint')) {
      return false;
    }

    this.authorizationEndpoint = oidcConfigurationResponse['authorization_endpoint'];
    this.tokenEndpoint = oidcConfigurationResponse['token_endpoint'];
    return true;
  }
}
