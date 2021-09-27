import 'dart:convert';
import 'dart:io';
import 'package:client/appConstants.dart';
import 'package:client/globals.dart';
import 'package:flutter/services.dart';
import 'package:client/models/cloudConfiguration.dart';
import 'package:client/models/device.dart';
import 'package:http/io_client.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OCFClient {
  static final String cloudConfigurationStorageKey = "plgd.dev/cloud-configuration";
  static final MethodChannel _nativeChannel = MethodChannel('plgd.dev/client');

  static bool _isInitialized = false;
  static String _accessToken = '';
  static DateTime _tokenExpirationTime;
  static bool isTokenExpired() => DateTime.now().isAfter(_tokenExpirationTime);

  static Future<bool> initialize(CloudConfiguration cloudConfiguration, String accessToken) async {
    if (accessToken == null || cloudConfiguration == null) {
      return false;
    }

    var publicConfiguration = await _fetchPublicConfiguration('https://'+cloudConfiguration.plgdAPIEndpoint);
    if (publicConfiguration == null) {
      return false;
    }

    try {
      await _nativeChannel.invokeMethod("initialize", <String, String> {
        'accessToken': accessToken,
        'cloudConfiguration': publicConfiguration
      });
      _isInitialized = true;
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
    if (_isInitialized) {
      _accessToken = accessToken;
      _tokenExpirationTime = JwtDecoder.getExpirationDate(accessToken).subtract(const Duration(hours: 1));
    }
    return _isInitialized;
  }

  static void destroy() {
    _isInitialized = false;
  }

  static Future<String> _fetchPublicConfiguration(String plgdApiEndpoint) async {
    var httpClient = HttpClient()..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    var ioClient = new IOClient(httpClient);

    try {
      var response = await ioClient
        .get(Uri.parse(plgdApiEndpoint + AppConstants.cloudConfigurationPath))
        .timeout(const Duration(seconds: 10));
      return response.body;
    } on Exception catch (error, stackTrace) {
      await Globals.sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    }
    return null;
  }
  
  static Future<List<Device>> discoverDevices() async {
    if (!_isInitialized) {
      throw Exception("OCF Client not initialized");
    }
    try {
      var devicesJSON = await _nativeChannel.invokeMethod('discoverDevices', 10);
      var devicesJSONObjs = jsonDecode(devicesJSON) as List;
      return devicesJSONObjs.map((deviceJson) => Device.fromJson(deviceJson)).toList();
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        error,
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
        'accessToken': _accessToken
      });
    } on PlatformException catch (error, stackTrace) {
      await Globals.sentry.captureException(
        error,
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
        error,
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
        error,
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
        error,
        stackTrace: stackTrace,
      );
    }
    return false;
  }
}