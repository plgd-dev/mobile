import UIKit
import Flutter
import Ocfclient

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let goChannel = FlutterMethodChannel(name: "gocf.dev/sdk", binaryMessenger: controller.binaryMessenger)

    goChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        switch (call.method) {
        case "initialize": self.initializeOCFClient(args: call.arguments, result: result)
        case "discoverDevices": self.discoverDevices(args: call.arguments, result: result)
        case "ownDevice": self.ownDevice(args: call.arguments, result: result)
        case "onboardDevice": self.onboardDevice(args: call.arguments, result: result)
        case "offboardDevice": self.offboardDevice(args: call.arguments, result: result)
        case "disownDevice": self.disownDevice(args: call.arguments, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    let ocfClient = OcfclientOCFClient();
    private func initializeOCFClient(args: Any?,
                                     result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.initialize(args["accessToken"])
        } catch {
            result(error)
        }
        result(true)
    }

    private func discoverDevices(args: Any?, result: FlutterResult) {
        var error : NSError?
        let devices = ocfClient.discover(args as! Int, error: &error)
        if (error != nil) {
            result(FlutterError(code: "FAILED", message: error!.localizedDescription, details: nil))
            return;
        }
        result(devices)
    }
    
    private func ownDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.ownDevice(args["deviceID"], accessToken: args["accessToken"])
        } catch {
            result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    private func onboardDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.onboardDevice(args["deviceID"], authorizationProvider: args["authorizationProvider"], cloudURL: args["cloudURL"], authCode: args["authCode"], cloudID: args["cloudID"])
        } catch {
            result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    private func offboardDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.offboardDevice(args["deviceID"])
        } catch {
            result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    private func disownDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.disownDevice(args["deviceID"])
        } catch {
            result(FlutterError(code: "FAILED", message: error.localizedDescription, details: nil))
        }
    }
}


