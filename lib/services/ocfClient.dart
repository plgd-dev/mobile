import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/oauthHandler.dart';
import 'package:my_app/models/cloudConfiguration.dart';
import 'package:my_app/models/device.dart';

import '../globals.dart';

class OCFClient {
  static final String cloudConfigurationStorageKey = "plgd.dev/cloud-configuration";
  static final MethodChannel _nativeChannel = MethodChannel('plgd.dev/sdk');
  static bool _isInitialized = false;
  static String _accessToken = "";
  static CloudConfiguration _cloudConfiguration;

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
    _accessToken = _parseAccessToken(tokenResponse);
    if (_accessToken == null || cloudConfiguration == null)
      return false;
    _isInitialized = await _nativeChannel.invokeMethod("initialize", <String, String> {
      'accessToken': _accessToken,
      'cloudConfiguration': _cloudConfiguration.rawJson
    });
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
      throw("OCF Client not initialized");
    }

    var devicesJSON = await _nativeChannel.invokeMethod('discoverDevices', 5);
    var devicesJSONObjs = jsonDecode(devicesJSON) as List;
    return devicesJSONObjs.map((deviceJson) => Device.fromJson(deviceJson)).toList();
  }
  
  static Future<String> ownDevice(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }

    return await _nativeChannel.invokeMethod<String>('ownDevice', <String, String> {
      'deviceID': deviceID,
      'accessToken': _accessToken
    });
  }

  static Future setAccessForCloud(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }

    return await _nativeChannel.invokeMethod('setAccessForCloud', <String, String> {
      'deviceID': deviceID
    });
  }

  static Future onboardDevice(String deviceID, String authCode) {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }

    return _nativeChannel.invokeMethod('onboardDevice', <String, String> {
      'deviceID': deviceID,
      'authCode': authCode ?? ""
    });
  }

  static Future offboardDevice(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }

    await _nativeChannel.invokeMethod('offboardDevice', <String, String> {
      'deviceID': deviceID
    });
  }

  static Future disownDevice(String deviceID) async {
    if (!_isInitialized) {
      throw("OCF Client not initialized");
    }
    
    await _nativeChannel.invokeMethod('disownDevice', <String, String> {
      'deviceID': deviceID,
    });
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

  static void _showLoginModal(String actionUrl, BuildContext context, Function onCompleted, Function onLoginPromtDismissed) {
    showModalBottomSheet(
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
                padding: EdgeInsets.only(top: 7),
                child: OAuthHandler(
                  authUrl: actionUrl,
                  authCompleted: onCompleted
                )
              )
            ]
          )
        )
      )
    ).whenComplete(onLoginPromtDismissed);
  }
}