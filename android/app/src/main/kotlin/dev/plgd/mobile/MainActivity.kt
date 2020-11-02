package dev.plgd.client

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "plgd.dev/client"
    private var sdkClient: ocfclient.Ocfclient_? = null;

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> this.initializeOCFClient(call.arguments(), result)
                "discoverDevices" -> this.discoverDevices(call.arguments(), result)
                "ownDevice" -> this.ownDevice(call.arguments(), result)
                "setAccessForCloud" -> this.ownDevice(call.arguments(), result)
                "onboardDevice" -> this.onboardDevice(call.arguments(), result)
                "disownDevice" -> this.disownDevice(call.arguments(), result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeOCFClient(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            if (sdkClient != null) {
                return
            }
            sdkClient = ocfclient.Ocfclient_()
            sdkClient!!.initialize(args!!["accessToken"], args["cloudConfiguration"])
            result.success(true)
        } catch (e: Exception) {
            sdkClient = null
            result.error("-1", e.message, "")
        }
    }

    private fun discoverDevices(args: Long, result: MethodChannel.Result) {
        try {
            var devices = sdkClient!!.discover(args)
            result.success(devices)
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun ownDevice(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            var deviceId = sdkClient!!.ownDevice(args!!["deviceID"], args["accessToken"])
            result.success(deviceId)
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun setAccessForCloud(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            sdkClient!!.setAccessForCloud(args!!["deviceID"])
            result.success(true)
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun onboardDevice(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            sdkClient!!.onboardDevice(args!!["deviceID"], args["authCode"])
            result.success(true)
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun disownDevice(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            sdkClient!!.disownDevice(args!!["deviceID"])
            result.success(Any())
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }
}
