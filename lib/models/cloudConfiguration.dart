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

    accessTokenUrl = json['access_token_url'];
    authCodeUrl = json['auth_code_url'];
    authorizationProvider = json['cloud_authorization_provider'];
    certificateAutorities = json['cloud_certificate_authorities'];
    cloudID = json['cloud_id'];
    cloudUrl = json['cloud_url'];
    jwtClaimOwnerId = json['jwt_claim_owner_id'];
    signingServerAddress = json['signing_server_address'];
  }

  static bool isValid(String jsonString) {
    try {
      Map<String, dynamic> configuration = jsonDecode(jsonString);
      return 
        configuration.containsKey('access_token_url') && Uri.parse(configuration['access_token_url']).isAbsolute &&
        configuration.containsKey('auth_code_url') && Uri.parse(configuration['auth_code_url']).isAbsolute &&
        configuration.containsKey('cloud_authorization_provider') &&
        configuration.containsKey('cloud_certificate_authorities') &&
        configuration.containsKey('cloud_id') &&
        configuration.containsKey('cloud_url') &&
        configuration.containsKey('jwt_claim_owner_id') &&
        configuration.containsKey('signing_server_address');
    } on Exception catch (_) {
      return false;
    }
    
  }
}
