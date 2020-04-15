import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:my_app/models/deviceDetails.dart';

class OCFClient {
  static final MethodChannel _nativeChannel = MethodChannel('gocf.dev/sdk');
  static bool _isInitialized = false;

  static Future<bool> initialize() async {
    try {
      _isInitialized = await _nativeChannel.invokeMethod("initialize");
      return _isInitialized;
    } catch (err) {
      print(err);
    }
    return false;
  }
  
  static Future<List<DeviceDetails>> getDevices() async {
    if (!_isInitialized) {
      print("OCF Client is not initialized");
      return null;
    }
      var devicesJSON = await _nativeChannel.invokeMethod('discover');
      var devicesJSONObjs = jsonDecode(devicesJSON) as List;
      try {
        return devicesJSONObjs.map((deviceJson) => DeviceDetails.fromJson(deviceJson)).toList();
      } catch (err) {
        print(err);
      }
      return [];
  }
}