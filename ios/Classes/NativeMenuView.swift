import Flutter
import UIKit

class NativeMenuView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _methodChannel: FlutterMethodChannel
    private let _button: UIButton = UIButton(type: .system)
    private let _viewId: Int64

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        self._viewId = viewId
        _view = UIView(frame: frame)
        // Construct a unique channel name using the viewId
        let channelName = "app.digizorg/native_menu_channel_\(viewId)"
        _methodChannel = FlutterMethodChannel(name: channelName,
                                              binaryMessenger: messenger!)
        super.init()

        if messenger == nil {
            fatalError("Binary messenger is nil in NativeMenuView init")
        }

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
            _button.backgroundColor = UIColor.clear
            _button.frame = _view.bounds
            _button.menu = nil
            _button.showsMenuAsPrimaryAction = false
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
                        // Error creating icon image, perhaps log or set a default
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
            _button.backgroundColor = UIColor.clear
        }
        
        // Set the frame from the 'size' argument
        if let sizeMap = arguments["size"] as? [String: Double],
           let width = sizeMap["width"],
           let height = sizeMap["height"] {
            _button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            _button.frame = _view.bounds
        }
        
        // Handle actions for pull-down menu
        if let itemsArray = arguments["items"] as? [[String: Any]], !itemsArray.isEmpty {
            let menuElements = createMenuItems(from: itemsArray)
            _button.menu = UIMenu(title: "", children: menuElements)
            _button.showsMenuAsPrimaryAction = true
        } else {
            _button.menu = nil
            _button.showsMenuAsPrimaryAction = false
        }

        // These can also be made configurable
        _button.setTitleColor(UIColor.blue, for: .normal)
        _button.layer.cornerRadius = 8
    }

    private func createMenuItems(from itemsData: [[String: Any]]) -> [UIMenuElement] {
        return itemsData.compactMap { itemDict -> UIMenuElement? in
            guard let type = itemDict["type"] as? String else { return nil }

            if type == "action" {
                let actionId = itemDict["id"] as? String ?? ""
                let actionTitle = itemDict["title"] as? String ?? "Action"
                var actionImage: UIImage? = nil
                let actionStyle = itemDict["style"] as? String ?? "normal"

                if let iconData = itemDict["icon"] as? [String: Any],
                   let codePoint = iconData["codePoint"] as? Int,
                   let fontFamily = iconData["fontFamily"] as? String {
                    let iconSize: CGFloat = 20.0
                    let iconColor: UIColor = actionStyle == "destructive" ? .systemRed : .label
                    actionImage = self.imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize, color: iconColor)
                }

                let uiAction = UIAction(title: actionTitle, image: actionImage, handler: { [weak self] _ in
                    self?._methodChannel.invokeMethod("actionSelected", arguments: ["id": actionId])
                })

                if actionStyle == "destructive" {
                    uiAction.attributes = .destructive
                }
                return uiAction
            } else if type == "group" {
                let groupTitle = itemDict["title"] as? String ?? ""
                let groupItems = itemDict["items"] as? [[String: Any]] ?? []
                let subMenuItems = createMenuItems(from: groupItems)

                let groupStyle = itemDict["style"] as? String ?? "normal"
                var menuOptions: UIMenu.Options = []
                if #available(iOS 13.0, *), groupStyle == "inline" {
                    menuOptions = .displayInline
                }

                return UIMenu(title: groupTitle, options: menuOptions, children: subMenuItems)
            }

            return nil
        }
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
