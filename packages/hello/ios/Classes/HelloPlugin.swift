import Flutter
import UIKit

public class HelloPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "hello", binaryMessenger: registrar.messenger())
    let instance = HelloPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Register the NativeButtonFactory
    let buttonFactory = NativeButtonFactory(messenger: registrar.messenger())
    // Ensure this ID EXACTLY matches viewType in NativeButtonWidget.dart
    registrar.register(buttonFactory, withId: "com.example/native_button") 
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
