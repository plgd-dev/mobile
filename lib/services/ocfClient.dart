import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:my_app/models/device.dart';

class OCFClient {
  static final String cloudConfigurationStorageKey = "plgd.dev/cloud-configuration";
  static final MethodChannel _nativeChannel = MethodChannel('gocf.dev/sdk');
  static bool _isInitialized = false;
  static String _accessToken = "";

  static void setTokenResponse(String tokenResponse) {
    Map<String, dynamic> jsonResponse = jsonDecode(tokenResponse);
    _accessToken = jsonResponse['access_token'];
  }

  static Future initialize() async {
    try {
      await _nativeChannel.invokeMethod("initialize", <String, String> {
        'accessToken': _accessToken
      });
      _isInitialized = true;
    } catch (err) { 
      print(err);
    }
  }

  static bool isInitialized() {
    return _isInitialized;
  }

  static void destroy() {
    _isInitialized = false;
  }
  
  static Future<List<Device>> discoverDevices() async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      var devices = new List<Device>();
      devices.add(Device(id: '6416e890-b919-4d64-b966-51cefab527a7', cloudConfiguration: CloudConfiguration(provisioningStatus: 'Registered'), modelNumber: '1-312iond', name: 'Haier AI Speaker', manufacturerName: 'Haier', resourceTypes: ['x.com.kistler.a', 'oic.wk.d'], isSecured: true, ownership: Ownership(owned: true, deviceOwner: "123")));
      devices.add(Device(id: 'f8d7b4df-b254-4275-bd66-dcacbd5cb05e', name: 'Lynx MiND', isSecured: false, ownership: Ownership(owned: false)));
      devices.add(Device(id: '1c6a7ddd-1b6b-420b-9495-127ff0a43663', name: 'Alegro 100', isSecured: true, ownership: Ownership(owned: false)));
      devices.add(Device(id: '4d106c12-e19b-421a-961b-304387baf7fd', name: 'Legrand Light Dimmer', isSecured: true, ownership: Ownership(owned: true, deviceOwner: "")));
      devices.add(Device(id: '99920fc4-ea81-4b38-9cc6-adda68ffda5c', name: 'LG InstaView ThinQ', isSecured: true, ownership: Ownership(owned: false)));
      return devices;
    }

    try {
      int timeoutSeconds = 15;
      var devicesJSON = await _nativeChannel.invokeMethod('discoverDevices', timeoutSeconds);
      var devicesJSONObjs = jsonDecode(devicesJSON) as List;
      return devicesJSONObjs.map((deviceJson) => Device.fromJson(deviceJson)).toList();
    } catch (err) {
      print(err);
    }
    return [];
  }
  
  static Future ownDevice(String deviceID) async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      return null;
    }
    try {
      var res = await _nativeChannel.invokeMethod('ownDevice', <String, String> {
        'deviceID': deviceID,
        'accessToken': _accessToken
      });
    } catch (err) {
      print(err);
    }
  }

  static Future onboardDevice(String deviceID, String authorizationProvider, String cloudURL, String authCode, String cloudID) async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      return null;
    }
    try {
      await _nativeChannel.invokeMethod('onboardDevice', <String, String> {
        'deviceID': deviceID,
        'authorizationProvider': authorizationProvider,
        'cloudURL': cloudURL,
        'authCode': authCode ?? "",
        'cloudID': cloudID
      });
    } catch (err) {
      print(err);
    }
  }

  static Future offboardDevice(String deviceID) async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      return null;
    }
    try {
      await _nativeChannel.invokeMethod('offboardDevice', <String, String> {
        'deviceID': deviceID
      });
    } catch (err) {
      print(err);
    }
  }

  static Future disownDevice(String deviceID) async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      return null;
    }
    try {
      await _nativeChannel.invokeMethod('disownDevice', <String, String> {
        'deviceID': deviceID,
      });
    } catch (err) {
      print(err);
    }
  }
}