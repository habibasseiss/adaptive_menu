import Flutter
import UIKit

public class NativeMenuPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "native_menu", binaryMessenger: registrar.messenger())
    let instance = NativeMenuPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    // Register the NativeMenuFactory
    let menuFactory = NativeMenuFactory(messenger: registrar.messenger())
    registrar.register(menuFactory, withId: "app.digizorg/native_menu") 
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
