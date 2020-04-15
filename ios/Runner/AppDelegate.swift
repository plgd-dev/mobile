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
        case "initialize": self.initializeOCFClient(result: result)
        case "discover": self.discoverDevices(result: result)
        case "own": self.ownDevice(args: call.arguments, result: result)
        case "onboard": self.onboardDevice(args: call.arguments, result: result)
        case "offboard": self.offboardDevice(args: call.arguments, result: result)
        case "disown": self.disownDevice(args: call.arguments, result: result)
        default: result(FlutterMethodNotImplemented)
        }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    let ocfClient = OcfclientOCFClient();
    private func initializeOCFClient(result: FlutterResult) {
        do {
            try ocfClient.initialize()
        } catch {
            result(error)
        }
    }

    private func discoverDevices(result: FlutterResult) {
        var err : NSError?
        let devices = ocfClient.discover(&err)
        if (err != nil) {
            result(err)
            return;
        }
        result(devices)
    }
    
    private func ownDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.ownDevice(args["deviceID"], token: args["accessToken"])
        } catch {
            result(error)
        }
    }
    
    private func onboardDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.onboardDevice(args["deviceID"], authorizationProvider: args["authorizationProvider"], cloudURL: args["cloudURL"], authCode: args["authCode"], cloudID: args["cloudID"])
        } catch {
            result(error)
        }
    }
    
    private func offboardDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.offboardDevice(args["deviceID"])
        } catch {
            result(error)
        }
    }
    
    private func disownDevice(args: Any?, result: FlutterResult) {
        let args = args as! [String: String]
        do {
            try ocfClient.disownDevice(args["deviceID"])
        } catch {
            result(error)
        }
    }
}


