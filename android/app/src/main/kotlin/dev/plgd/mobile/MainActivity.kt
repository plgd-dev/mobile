package dev.plgd.client

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class MainActivity: FlutterActivity() {
    private val CHANNEL = "plgd.dev/client"
    private var sdkClient: Ocfclient.Ocfclient_? = null;
    private val _mainScope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> this.initializeOCFClient(call, result)
                "getOwnerId" -> this.getOwnerId(result)
                "discoverDevices" -> this.discoverDevices(call, result)
                "getResource" -> this.getResource(call, result)
                "ownDevice" -> this.ownDevice(call, result)
                "setAccessForCloud" -> this.setAccessForCloud(call, result)
                "onboardDevice" -> this.onboardDevice(call, result)
                "disownDevice" -> this.disownDevice(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeOCFClient(call: MethodCall, result: MethodChannel.Result) {
        var accessToken = call.argument<String>("accessToken");
        var cloudConfiguration = call.argument<String>("cloudConfiguration")
        _mainScope.launch {
            try {
                sdkClient = Ocfclient.Ocfclient_()
                withContext(Dispatchers.IO) {
                    sdkClient!!.initialize(accessToken, cloudConfiguration)
                }
                result.success(true)
            } catch (e: Exception) {
                sdkClient = null
                result.error("-1", e.message, "")
            }
        }
    }

    private fun getOwnerId(result: MethodChannel.Result) {
        _mainScope.launch {
            try {
                var ownerId = withContext(Dispatchers.IO) {
                    sdkClient!!.getOwnerID()
                }
                result.success(ownerId)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun discoverDevices(call: MethodCall, result: MethodChannel.Result) {
        var discoveryTimeout = call.arguments<Int>()
        _mainScope.launch {
            try {
                var devices = withContext(Dispatchers.IO) {
                    sdkClient!!.discover(discoveryTimeout.toLong())
                }
                result.success(devices)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun getResource(call: MethodCall, result: MethodChannel.Result) {
        var deviceId = call.argument<String>("deviceID")
        var href = call.argument<String>("href")
        _mainScope.launch {
            try {
                var resourceContent = withContext(Dispatchers.IO) {
                    sdkClient!!.getResource(deviceId, href)
                }
                result.success(resourceContent)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun ownDevice(call: MethodCall, result: MethodChannel.Result) {
        var deviceId = call.argument<String>("deviceID")
        var accessToken = call.argument<String>("accessToken")
        _mainScope.launch {
            try {
                var newDeviceId = withContext(Dispatchers.IO) {
                    sdkClient!!.ownDevice(deviceId, accessToken)
                }
                result.success(newDeviceId)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun setAccessForCloud(call: MethodCall, result: MethodChannel.Result) {
        var deviceId = call.argument<String>("deviceID")
        _mainScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    sdkClient!!.setAccessForCloud(deviceId)
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun onboardDevice(call: MethodCall, result: MethodChannel.Result) {
        var deviceId = call.argument<String>("deviceID")
        var authCode = call.argument<String>("authCode")
        _mainScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    sdkClient!!.onboardDevice(deviceId, authCode)
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }

    private fun disownDevice(call: MethodCall, result: MethodChannel.Result) {
        var deviceId = call.argument<String>("deviceID")
        _mainScope.launch {
            try {
                withContext(Dispatchers.IO) {
                    sdkClient!!.disownDevice(deviceId)
                }
                result.success(true)
            } catch (e: Exception) {
                result.error("-1", e.message, "")
            }
        }
    }
}
