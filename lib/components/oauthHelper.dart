

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:client/appConstants.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:client/components/oauthHandler.dart';
import 'package:http/io_client.dart';
import 'package:uuid/uuid.dart';

class OAuthHelper {
  static final Random _random = Random.secure();

  static String base64UrlEncode(List<int> data) {
    return base64Url.encode(data)
      .replaceAll('+', '-')
      .replaceAll('/', '\_')
      .replaceAll('=', '');
  }

  static Widget getApplicationTokenRequestWidget(BuildContext context, CloudConfiguration cloudConfiguration, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed, Function onError) {
    if (!tryInBackground && !visible) {
      return SizedBox.shrink();
    }
    var verifier = base64UrlEncode(List<int>.generate(32, (i) => _random.nextInt(256)));
    var challenge = base64UrlEncode(sha256.convert(utf8.encode(verifier)).bytes);
    var state = Uuid().v4();
    var codeUrl = '${cloudConfiguration.authorizationEndpoint}?response_type=code&code_challenge=$challenge&code_challenge_method=S256&client_id=${cloudConfiguration.mobileAppAuthClientId}&redirect_uri=${AppConstants.authRedirectUri}&audience=${cloudConfiguration.mobileAppAudience}&state=$state';

    // handling PKCE OAuth flow on our own; flutter_appauth has issues with self-signed certificates
    return _getOAuthWidget(codeUrl, context, visible, tryInBackground, (String code) async {
      var httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
      var ioClient = new IOClient(httpClient);  
      try {
        var response = await ioClient.post(
          Uri.parse(cloudConfiguration.tokenEndpoint), 
          body: {
            'grant_type': 'authorization_code',
            'client_id': cloudConfiguration.mobileAppAuthClientId,
            'code_verifier': verifier,
            'code': code,
            'redirect_uri': AppConstants.authRedirectUri
          }
        ).timeout(const Duration(seconds: 10));
        onCompleted(_parseAccessToken(response.body));
      } on Exception catch (_) {
        onError();
      }
    }, onLoginPromtDismissed, onError);
  }

  static Widget getOnboardingCodeRequestWidget(BuildContext context, CloudConfiguration cloudConfiguration, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed, Function onError) {
    var state = Uuid().v4();
    var codeUrl = '${cloudConfiguration.authorizationEndpoint}?response_type=code&client_id=${cloudConfiguration.deviceAuthClientId}&redirect_uri=${AppConstants.authRedirectUri}&audience=${cloudConfiguration.deviceAuthAudience}&state=$state';
    return _getOAuthWidget(codeUrl, context, visible, tryInBackground, onCompleted, onLoginPromtDismissed, onError);
  }

  static Widget _getOAuthWidget(String actionUrl, BuildContext context, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed, Function onError) {
    return Visibility(
      visible: visible,
      maintainState: tryInBackground,
      child: OAuthHandler(
        authUrl: actionUrl,
        promptForCredentials: () => _showLoginModal(actionUrl, context, onCompleted, onLoginPromtDismissed, onError),
        authCompleted: onCompleted,
        errorOccured: onError
      )
    );
  }

  static void _showLoginModal(String actionUrl, BuildContext context, Function(String) onCompleted, Function onLoginPromtDismissed, Function onError) {
    showModalBottomSheet<String> (
      isScrollControlled: true,
      context: context,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
          child: Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                height: 3,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.all(Radius.circular(50))
                )
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: OAuthHandler(
                  authUrl: actionUrl,
                  authCompleted: (data) {
                    onCompleted(data);
                    Navigator.of(context).pop('true'); // nullable boolean available only as an experimental feature
                  },
                  errorOccured: onError
                )
              )
            ]
          )
        )
      )
    ).then((String isAutoClosed) {
      if (isAutoClosed != 'true') {
        onLoginPromtDismissed();
      }
    });
  }

  static String _parseAccessToken(String tokenResponse) {
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(tokenResponse);
      return jsonResponse['access_token'] as String;
    } on Exception catch (_) {
      return null;
    }
  }
}