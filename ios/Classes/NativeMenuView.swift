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

        // Apply initial properties
        updateButtonProperties(with: args)

        _button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
                    
                    // For the button icon, we have two options:
                    // 1. If a specific color is provided, use that color directly
                    // 2. Otherwise, use a template image that will adapt to the button's tint color
                    if let colorMap = childMap["color"] as? [String: Double],
                       let red = colorMap["red"], let green = colorMap["green"], let blue = colorMap["blue"], let alpha = colorMap["alpha"] {
                        if let iconImage = imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize, color: iconColor) {
                            _button.setImage(iconImage.withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                    } else {
                        // No specific color provided, use template image that will adapt to tint color
                        if let iconImage = imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize) {
                            _button.setImage(iconImage, for: .normal)
                        }
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
        } else {
            _button.menu = nil
        }

        let showsMenuAsPrimaryAction = arguments["showsMenuAsPrimaryAction"] as? Bool ?? true
        _button.showsMenuAsPrimaryAction = showsMenuAsPrimaryAction

        // These can also be made configurable
        // Use system blue color which adapts to light/dark mode
        _button.setTitleColor(UIColor.systemBlue, for: .normal)
        _button.tintColor = UIColor.systemBlue // Set tint color for template images
        _button.layer.cornerRadius = 8
    }

    @objc private func buttonTapped() {
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }

    private func createMenuItems(from itemsData: [[String: Any]]) -> [UIMenuElement] {
        return itemsData.compactMap { itemDict -> UIMenuElement? in
            guard let type = itemDict["type"] as? String else { return nil }

            if type == "action" {
                let actionId = itemDict["id"] as? String ?? ""
                let actionTitle = itemDict["title"] as? String ?? "Action"
                let actionDescription = itemDict["description"] as? String
                var actionImage: UIImage? = nil
                let actionStyle = itemDict["style"] as? String ?? "normal"

                if let iconData = itemDict["icon"] as? [String: Any],
                   let codePoint = iconData["codePoint"] as? Int,
                   let fontFamily = iconData["fontFamily"] as? String {
                    let iconSize: CGFloat = 20.0
                    
                    // For destructive actions, we still want to use a specific color
                    if actionStyle == "destructive" {
                        actionImage = self.imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize, color: .systemRed)
                    } else {
                        // For normal actions, use template images that will adapt to system appearance
                        actionImage = self.imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize)
                    }
                }

                let uiAction = UIAction(title: actionTitle, image: actionImage, handler: { [weak self] _ in
                    self?._methodChannel.invokeMethod("actionSelected", arguments: ["id": actionId])
                })

                if #available(iOS 15.0, *) {
                    uiAction.subtitle = actionDescription
                }

                if actionStyle == "destructive" {
                    uiAction.attributes = .destructive
                }

                if let checked = itemDict["checked"] as? Bool {
                    if #available(iOS 13.0, *) {
                        uiAction.state = checked ? .on : .off
                    }
                }

                return uiAction
            } else if type == "group" {
                let groupTitle = itemDict["title"] as? String ?? ""
                let groupItems = itemDict["items"] as? [[String: Any]] ?? []
                let subMenuItems = createMenuItems(from: groupItems)

                var groupImage: UIImage? = nil
                if let iconData = itemDict["icon"] as? [String: Any],
                   let codePoint = iconData["codePoint"] as? Int,
                   let fontFamily = iconData["fontFamily"] as? String {
                    let iconSize: CGFloat = 20.0
                    // Use template images for group icons that will adapt to system appearance
                    groupImage = self.imageFromIconFont(codePoint: codePoint, fontFamily: fontFamily, size: iconSize)
                }

                let groupStyle = itemDict["style"] as? String ?? "normal"
                var menuOptions: UIMenu.Options = []
                if #available(iOS 13.0, *), groupStyle == "inline" {
                    menuOptions = .displayInline
                }

                return UIMenu(title: groupTitle, image: groupImage, identifier: nil, options: menuOptions, children: subMenuItems)
            }

            return nil
        }
    }

    // Helper function to create a UIImage from an icon font character
    // Returns a template image that can adapt to system appearance changes
    private func imageFromIconFont(codePoint: Int, fontFamily: String, size: CGFloat, color: UIColor? = nil) -> UIImage? {
        var effectiveFontFamily = fontFamily
        if fontFamily == "MaterialIcons" {
            effectiveFontFamily = "MaterialIcons-Regular"
        }

        guard let font = UIFont(name: effectiveFontFamily, size: size) else {
            return nil
        }
        
        let character = String(format: "%C", codePoint)
        
        // Use black color for template images
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color ?? UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: character, attributes: attributes)
        let imageSize = attributedString.size()
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        attributedString.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // If no specific color is provided, return a template image that will use the system's tint color
        if color == nil {
            return image?.withRenderingMode(.alwaysTemplate)
        }
        
        return image
    }

}
