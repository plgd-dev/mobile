package dev.plgd.client

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "plgd.dev/sdk"
    private var sdkClient: ocfclient.Ocfclient_? = null;

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> this.initializeOCFClient(result)
                "discover" -> this.discoverDevices(result)
                "own" -> this.ownDevice(call.arguments(), result)
                "onboard" -> this.onboardDevice(call.arguments(), result)
                "disown" -> this.disownDevice(call.arguments(), result)
                else -> result.notImplemented()
            }
        }
    }

    private fun initializeOCFClient(@NonNull result: MethodChannel.Result) {
        try {
            if (sdkClient != null) {
                return
            }
            sdkClient = ocfclient.Ocfclient_()
            sdkClient!!.initialize()
            result.success(true)
        } catch (e: Exception) {
            sdkClient = null
            result.error("-1", e.message, "")
        }
    }

    private fun discoverDevices(@NonNull result: MethodChannel.Result) {
        try {
            var devices = sdkClient!!.discover()
            result.success(devices)
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun ownDevice(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            sdkClient!!.ownDevice(args!!["deviceID"], args!!["accessToken"])
            result.success(Any())
        } catch (e: Exception) {
            result.error("-1", e.message, "")
        }
    }

    private fun onboardDevice(args: Map<String,String>?, result: MethodChannel.Result) {
        try {
            sdkClient!!.onboardDevice(args!!["deviceID"], args!!["authorizationProvider"], args!!["cloudURL"], args!!["authCode"], args["cloudID"])
            result.success(Any())
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
