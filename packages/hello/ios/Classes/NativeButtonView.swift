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

        // Reset button content before setting new content
        _button.setTitle(nil, for: .normal)
        _button.setImage(nil, for: .normal)

        // Set content from the 'child' parameter
        if let childMap = arguments["child"] as? [String: Any],
           let type = childMap["type"] as? String {
            
            if type == "text" {
                let text = childMap["text"] as? String ?? ""
                _button.setTitle(text, for: .normal)
            } else if type == "icon" {
                if let iconData = childMap["icon"] as? [String: Any],
                   let codePoint = iconData["codePoint"] as? Int,
                   let fontFamily = iconData["fontFamily"] as? String {
                    
                    let iconSize = childMap["size"] as? CGFloat ?? 24.0
                    var iconColor = _button.tintColor ?? .blue
                    
                    if let colorMap = childMap["color"] as? [String: Double],
                       let red = colorMap["red"], let green = colorMap["green"], let blue = colorMap["blue"], let alpha = colorMap["alpha"] {
                        iconColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    }
                    
                    if let iconImage = imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize, color: iconColor) {
                        _button.setImage(iconImage.withRenderingMode(.alwaysOriginal), for: .normal)
                    } else {
                    }
                }
            }
        } else {
            // Fallback if 'child' is not provided correctly
            _button.setTitle("Invalid Content", for: .normal)
        }

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

    // Helper function to create a UIImage from an icon font character
    private func imageFromIconFont(codePoint: Int, fontFamily: String, size: CGFloat, color: UIColor) -> UIImage? {
        var effectiveFontFamily = fontFamily
        if fontFamily == "MaterialIcons" {
            effectiveFontFamily = "MaterialIcons-Regular"
        }

        guard let font = UIFont(name: effectiveFontFamily, size: size) else {
            return nil
        }
        
        let character = String(format: "%C", codePoint)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let attributedString = NSAttributedString(string: character, attributes: attributes)
        let imageSize = attributedString.size()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        attributedString.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    @objc func onButtonTapped() {
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }
}
