import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client/components/oauthHandler.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:client/models/device.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../globals.dart';

class OCFClient {
  static final String cloudConfigurationStorageKey = "plgd.dev/cloud-configuration";
  static final MethodChannel _nativeChannel = MethodChannel('plgd.dev/client');

  static bool _isInitialized = false;
  static String _accessToken = "";
  static DateTime _tokenExpirationTime;
  static CloudConfiguration _cloudConfiguration;
  static bool isTokenExpired() => DateTime.now().isAfter(_tokenExpirationTime);

  static String get accessToken {
    return _accessToken;
  }

  static set accessToken(String accessToken) {
    _accessToken = accessToken;
    _tokenExpirationTime = JwtDecoder.getExpirationDate(accessToken).subtract(const Duration(hours: 1));
  }

  static CloudConfiguration get cloudConfiguration {
    if (_cloudConfiguration == null && Globals.localStorage.containsKey(cloudConfigurationStorageKey)) {
      var jsonConfiguration = Globals.localStorage.getString(OCFClient.cloudConfigurationStorageKey);
      _cloudConfiguration = CloudConfiguration.fromJson(jsonConfiguration);
    }
    return _cloudConfiguration;
  }

  static set cloudConfiguration(CloudConfiguration cloudConfiguration) {
    _cloudConfiguration = cloudConfiguration;
  }

  static Future<bool> initialize(String tokenResponse) async {
    accessToken = _parseAccessToken(tokenResponse);
    if (accessToken == null || cloudConfiguration == null)
      return false;
    try {
      await _nativeChannel.invokeMethod("initialize", <String, String> {
        'accessToken': accessToken,
        'cloudConfiguration': _cloudConfiguration.rawJson
      });
      _isInitialized = true;
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    if (_isInitialized)
      await _persistCloudConfiguration(cloudConfiguration);
    return _isInitialized;
  }

  static String _parseAccessToken(String tokenResponse) {
    try {
      Map<String, dynamic> jsonResponse = jsonDecode(tokenResponse);
      return jsonResponse['access_token'] as String;
    } on Exception catch (_) {
      return null;
    }
  }

  static Future _persistCloudConfiguration(CloudConfiguration cloudConfiguration) async {
    await Globals.localStorage.setString(OCFClient.cloudConfigurationStorageKey, cloudConfiguration.rawJson);
  }

  static void destroy() {
    _isInitialized = false;
  }
  
  static Future<List<Device>> discoverDevices() async {
    if (!_isInitialized) {
      throw Exception("OCF Client not initialized");
    }
    try {
      var devicesJSON = await _nativeChannel.invokeMethod('discoverDevices', 5);
      var devicesJSONObjs = jsonDecode(devicesJSON) as List;
      return devicesJSONObjs.map((deviceJson) => Device.fromJson(deviceJson)).toList();
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }
  
  static Future<String> ownDevice(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }

    try {
      return await _nativeChannel.invokeMethod<String>('ownDevice', <String, String> {
        'deviceID': deviceID,
        'accessToken': accessToken
      });
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  static Future<bool> setAccessForCloud(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }
    try {
      await _nativeChannel.invokeMethod('setAccessForCloud', <String, String> {
        'deviceID': deviceID
      });
      return true;
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  static Future<bool> onboardDevice(String deviceID, String authCode) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }
    try {
      await _nativeChannel.invokeMethod('onboardDevice', <String, String> {
        'deviceID': deviceID,
        'authCode': authCode ?? ""
      });
      return true;
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  static Future<bool> disownDevice(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }
    try {
      await _nativeChannel.invokeMethod('disownDevice', <String, String> {
        'deviceID': deviceID,
      });
      return true;
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        exception: error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }

  static Widget getTokenRequestWidget(BuildContext context, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed) =>
     _getOAuthWidget(cloudConfiguration?.accessTokenUrl, context, visible, tryInBackground, onCompleted, onLoginPromtDismissed);

  static Widget getCodeRequestWidget(BuildContext context, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed) =>
    _getOAuthWidget(cloudConfiguration?.authCodeUrl, context, visible, tryInBackground, onCompleted, onLoginPromtDismissed);

  static Widget _getOAuthWidget(String actionUrl, BuildContext context, bool visible, bool tryInBackground, Function onCompleted, Function onLoginPromtDismissed) {
    return Visibility(
      visible: visible,
      maintainState: tryInBackground,
      child: OAuthHandler(
        authUrl: actionUrl,
        promptForCredentials: () => _showLoginModal(actionUrl, context, onCompleted, onLoginPromtDismissed),
        authCompleted: onCompleted
      )
    );
  }

  static void _showLoginModal(String actionUrl, BuildContext context, Function(String) onCompleted, Function onLoginPromtDismissed) {
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
                  }
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
}