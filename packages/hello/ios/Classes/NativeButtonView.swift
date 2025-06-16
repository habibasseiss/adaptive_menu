import Flutter
import UIKit

class NativeButtonView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _methodChannel: FlutterMethodChannel
    private let _button: UIButton = UIButton(type: .system)

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView(frame: frame)
        _methodChannel = FlutterMethodChannel(name: "com.example/native_button_channel",
                                              binaryMessenger: messenger!)
        super.init()

        // Set the method call handler before creating the view
        _methodChannel.setMethodCallHandler(handle)
        
        createNativeView(view: _view, arguments: args)
    }

    func view() -> UIView {
        return _view
    }

    // Handles method calls from Dart
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            // When an update call is received, apply the new properties
            updateButtonProperties(with: call.arguments)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func createNativeView(view platformRootView: UIView, arguments args: Any?){
        platformRootView.backgroundColor = UIColor.clear

        // Set up the button's target action once
        _button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)

        // Apply initial properties
        updateButtonProperties(with: args)

        platformRootView.addSubview(_button)
    }

    // A single function to configure the button's properties from a map of arguments
    private func updateButtonProperties(with args: Any?) {
        guard let arguments = args as? [String: Any] else {
            // Handle case where there are no arguments
            _button.setTitle("Default Native Title", for: .normal)
            _button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
            _button.frame = _view.bounds
            return
        }

        // Set title
        _button.setTitle(arguments["title"] as? String ?? "Native iOS Button", for: .normal)

        // Set background color
        if let bgColorMap = arguments["backgroundColor"] as? [String: Double],
           let red = bgColorMap["red"],
           let green = bgColorMap["green"],
           let blue = bgColorMap["blue"],
           let alpha = bgColorMap["alpha"] {
            _button.backgroundColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        } else {
            _button.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        
        // Set the frame from the 'size' argument
        if let sizeMap = arguments["size"] as? [String: Double],
           let width = sizeMap["width"],
           let height = sizeMap["height"] {
            _button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            _button.frame = _view.bounds
        }
        
        // These can also be made configurable
        _button.setTitleColor(UIColor.blue, for: .normal)
        _button.layer.cornerRadius = 8
    }

    @objc func onButtonTapped() {
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }
}
