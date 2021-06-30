import 'dart:convert';

class CloudConfiguration {
  String rawJson;
  String accessTokenUrl;
  String authCodeUrl;
  String authorizationProvider;
  String certificateAutorities;
  String cloudID;
  String cloudUrl;
  String jwtClaimOwnerId;
  String signingServerAddress;

  CloudConfiguration(
      {this.accessTokenUrl,
      this.authCodeUrl,
      this.authorizationProvider,
      this.certificateAutorities,
      this.cloudID,
      this.cloudUrl,
      this.jwtClaimOwnerId,
      this.signingServerAddress});

  CloudConfiguration.fromJson(String jsonString) {
    rawJson = jsonString;
    Map<String, dynamic> json = jsonDecode(jsonString);

    accessTokenUrl = json['accessTokenUrl'];
    authCodeUrl = json['authCodeUrl'];
    authorizationProvider = json['cloudAuthorizationProvider'];
    certificateAutorities = json['cloudCertificateAuthorities'];
    cloudID = json['cloudId'];
    cloudUrl = json['cloudUrl'];
    jwtClaimOwnerId = json['jwtClaimOwnerId'];
    signingServerAddress = json['signingServerAddress'];
  }

  static bool isValid(String jsonString) {
    try {
      Map<String, dynamic> configuration = jsonDecode(jsonString);
      return 
        configuration.containsKey('accessTokenUrl') && Uri.parse(configuration['accessTokenUrl']).isAbsolute &&
        configuration.containsKey('authCodeUrl') && Uri.parse(configuration['authCodeUrl']).isAbsolute &&
        configuration.containsKey('cloudAuthorizationProvider') &&
        configuration.containsKey('cloudCertificateAuthorities') &&
        configuration.containsKey('cloudId') &&
        configuration.containsKey('cloudUrl') &&
        configuration.containsKey('jwtClaimOwnerId') &&
        configuration.containsKey('signingServerAddress');
    } on Exception catch (_) {
      return false;
    }
    
  }
}
