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

    public func view() -> UIView {
        return _view
    }

    // Handles method calls from Dart
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            // When an update call is received, apply the new properties
            updateButtonProperties(with: call.arguments)
            result(nil)
        case "updateSize":
            updateSize(with: call.arguments)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func createNativeView(view platformRootView: UIView, arguments args: Any?){
        platformRootView.backgroundColor = UIColor.clear

        // Configure the button
        _button.backgroundColor = UIColor.clear
        _button.frame = platformRootView.bounds
        
        // Add the button to the view
        platformRootView.addSubview(_button)
        
        // Set initial properties
        updateButtonProperties(with: args)
        
        // Add target action for button tap
        _button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // A single function to configure the button's properties from a map of arguments
    private func updateButtonProperties(with args: Any?) {
        guard let arguments = args as? [String: Any] else {
            _button.backgroundColor = UIColor.clear
            _button.frame = _view.bounds
            _button.menu = nil
            _button.showsMenuAsPrimaryAction = false
            return
        }

        // The button is now just a transparent tappable area.
        // Visuals are handled entirely by the Flutter child widget.
        _button.setTitle(nil, for: .normal)
        _button.setImage(nil, for: .normal)
        _button.backgroundColor = UIColor.clear

        // --- Configure Button Frame ---
        if let sizeMap = arguments["size"] as? [String: Double],
           let width = sizeMap["width"], let height = sizeMap["height"] {
            _button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            _button.frame = _view.bounds
        }
        
        // --- Configure Menu ---
        if let itemsArray = arguments["items"] as? [[String: Any]], !itemsArray.isEmpty {
            let menuElements = createMenuItems(from: itemsArray)
            _button.menu = UIMenu(title: "", children: menuElements)
        } else {
            _button.menu = nil
        }

        _button.showsMenuAsPrimaryAction = arguments["showsMenuAsPrimaryAction"] as? Bool ?? false
    }

    @objc private func buttonTapped() {
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }
    
    // Updates the size of the button and view when the Flutter widget size changes
    private func updateSize(with args: Any?) {
        guard let arguments = args as? [String: Any],
              let sizeMap = arguments["size"] as? [String: Double],
              let width = sizeMap["width"],
              let height = sizeMap["height"] else {
            return
        }
        
        // Create a new frame with the updated size
        let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Update both the view and button frames to ensure proper sizing
        _view.frame = newFrame
        _button.frame = _view.bounds
        
        // Force layout update
        _view.setNeedsLayout()
        _view.layoutIfNeeded()
        _button.setNeedsLayout()
        _button.layoutIfNeeded()
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
