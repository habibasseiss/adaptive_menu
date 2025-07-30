import Flutter
import UIKit

class NativeMenuView: NSObject, FlutterPlatformView {
    // MARK: - Constants
    private static let channelPrefix = "app.digizorg/native_menu_channel_"
    
    // MARK: - Properties
    private var _view: UIView
    private var _methodChannel: FlutterMethodChannel
    private let _button: UIButton = UIButton(type: .system)
    private let _viewId: Int64

    // MARK: - Initialization
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        guard let messenger = messenger else {
            fatalError("Binary messenger is nil in NativeMenuView init")
        }
        
        self._viewId = viewId
        self._view = UIView(frame: frame)
        self._methodChannel = FlutterMethodChannel(
            name: Self.channelPrefix + "\(viewId)",
            binaryMessenger: messenger
        )
        
        super.init()
        
        _setupMethodChannel()
        _createNativeView(arguments: args)
    }

    // MARK: - FlutterPlatformView Protocol
    func view() -> UIView {
        return _view
    }
    
    // MARK: - Private Setup Methods
    private func _setupMethodChannel() {
        _methodChannel.setMethodCallHandler(handle)
    }
    
    private func _createNativeView(arguments args: Any?) {
        _setupView()
        _setupButton()
        updateButtonProperties(with: args)
        _view.addSubview(_button)
    }
    
    private func _setupView() {
        _view.backgroundColor = UIColor.clear
    }
    
    private func _setupButton() {
        _button.contentMode = .scaleToFill
        _button.contentHorizontalAlignment = .fill
        _button.contentVerticalAlignment = .fill
        _button.imageView?.contentMode = .scaleAspectFit
        _button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // MARK: - Method Call Handling
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            _handleUpdate(arguments: call.arguments, result: result)
        case "updateImage":
            _handleUpdateImage(arguments: call.arguments, result: result)
        case "updateSize":
            _handleUpdateSize(arguments: call.arguments, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func _handleUpdate(arguments: Any?, result: @escaping FlutterResult) {
        updateButtonProperties(with: arguments)
        _scheduleLayoutUpdate()
        result(nil)
    }
    
    private func _handleUpdateImage(arguments: Any?, result: @escaping FlutterResult) {
        updateImage(with: arguments)
        result(nil)
    }
    
    private func _handleUpdateSize(arguments: Any?, result: @escaping FlutterResult) {
        updateSize(with: arguments)
        result(nil)
    }
    
    private func _scheduleLayoutUpdate() {
        DispatchQueue.main.async {
            self._enableButton()
            self._forceLayout()
        }
    }
    
    private func _enableButton() {
        _button.isEnabled = true
        _button.isUserInteractionEnabled = true
    }
    
    private func _forceLayout() {
        _view.setNeedsLayout()
        _view.layoutIfNeeded()
    }

    @objc private func buttonTapped() {
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }

    // MARK: - Button Configuration
    private func updateButtonProperties(with args: Any?) {
        guard let arguments = args as? [String: Any] else {
            _applyDefaultButtonProperties()
            return
        }
        
        _resetButtonContent()
        _configureButtonFrame(from: arguments)
        _configureButtonContent(from: arguments)
        _configureButtonMenu(from: arguments)
        _configureMenuBehavior(from: arguments)
        _enableButton()
    }
    
    private func _applyDefaultButtonProperties() {
        _button.setTitle("Default Native Title", for: .normal)
        _button.backgroundColor = UIColor.clear
        _button.frame = _view.bounds
        _button.menu = nil
        _button.showsMenuAsPrimaryAction = false
        _button.isEnabled = true
    }
    
    private func _resetButtonContent() {
        _button.setTitle(nil, for: .normal)
        _button.setImage(nil, for: .normal)
    }
    
    private func _configureButtonFrame(from arguments: [String: Any]) {
        if let sizeMap = arguments["size"] as? [String: Double],
           let width = sizeMap["width"],
           let height = sizeMap["height"] {
            _button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        } else {
            _button.frame = _view.bounds
        }
    }
    
    private func _configureButtonContent(from arguments: [String: Any]) {
        guard let childMap = arguments["child"] as? [String: Any],
              let type = childMap["type"] as? String else {
            _button.setTitle("Invalid Content", for: .normal)
            return
        }
        
        switch type {
        case "image":
            _handleImageContent(from: childMap)
        case "empty":
            _handleEmptyContent()
        default:
            _button.setTitle("Unknown Content Type", for: .normal)
        }
    }
    
    private func _handleImageContent(from childMap: [String: Any]) {
        guard let flutterData = childMap["imageBytes"] as? FlutterStandardTypedData,
              let image = UIImage(data: flutterData.data) else { return }
        
        _setButtonImage(image)
    }
    
    private func _handleEmptyContent() {
        _button.setImage(nil, for: .normal)
        _button.setTitle(nil, for: .normal)
    }
    
    private func _setButtonImage(_ image: UIImage) {
        _button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        _button.imageView?.contentMode = .scaleAspectFit
        _button.contentHorizontalAlignment = .fill
        _button.contentVerticalAlignment = .fill
        _button.imageEdgeInsets = UIEdgeInsets.zero
        _button.setNeedsDisplay()
    }
    
    private func _configureButtonMenu(from arguments: [String: Any]) {
        if let itemsArray = arguments["items"] as? [[String: Any]], !itemsArray.isEmpty {
            let menuElements = createMenuItems(from: itemsArray)
            _button.menu = UIMenu(title: "", children: menuElements)
        } else {
            _button.menu = nil
        }
    }
    
    private func _configureMenuBehavior(from arguments: [String: Any]) {
        let showsMenuAsPrimaryAction = arguments["showsMenuAsPrimaryAction"] as? Bool ?? true
        _button.showsMenuAsPrimaryAction = showsMenuAsPrimaryAction
    }

    // Updates the image in the button
    private func updateImage(with args: Any?) {
        guard let arguments = args as? [String: Any],
              let imageData = arguments["image"] as? FlutterStandardTypedData else {
            return
        }
        
        // Convert the image data to a UIImage
        if let image = UIImage(data: imageData.data) {
            // Set the image on the button
            _button.setImage(image, for: .normal)
            _button.imageView?.contentMode = .scaleAspectFit
            
            // Ensure button is enabled and interactive
            _button.isEnabled = true
            _button.isUserInteractionEnabled = true
            
            // Force redraw of the button
            _button.setNeedsDisplay()
            
            // Force layout update to ensure proper rendering
            DispatchQueue.main.async {
                self._view.setNeedsLayout()
                self._view.layoutIfNeeded()
            }
        }
    }

    // Updates the size of the button and view when the Flutter widget size changes
    private func updateSize(with args: Any?) {
        guard let arguments = args as? [String: Any],
              let sizeMap = arguments["size"] as? [String: Double],
              let width = sizeMap["width"],
              let height = sizeMap["height"] else {
            return
        }
        
        // Create a new frame with the updated size - use exact dimensions
        let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Update both the view and button frames to ensure proper sizing
        _view.frame = newFrame
        _button.frame = CGRect(origin: .zero, size: newFrame.size)
        
        // Ensure image view is properly sized
        _button.imageView?.frame = _button.bounds
        
        // Force layout update with animation to ensure smooth transitions
        UIView.animate(withDuration: 0.0) {
            self._view.setNeedsLayout()
            self._view.layoutIfNeeded()
            self._button.setNeedsLayout()
            self._button.layoutIfNeeded()
            self._button.setNeedsDisplay()
        }
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
                   let imageData = iconData["imageData"] as? FlutterStandardTypedData {
                    if let image = UIImage(data: imageData.data) {
                        // Resize the high-resolution image to the correct display size (20x20 points)
                        let targetSize = CGSize(width: 20.0, height: 20.0)
                        if let resizedImage = resizeImage(image, to: targetSize) {
                            // For destructive actions, we want to tint the image red
                            if actionStyle == "destructive" {
                                actionImage = resizedImage.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
                            } else {
                                // For normal actions, use template images that will adapt to system appearance
                                actionImage = resizedImage.withRenderingMode(.alwaysTemplate)
                            }
                        }
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
                   let imageData = iconData["imageData"] as? FlutterStandardTypedData {
                    if let image = UIImage(data: imageData.data) {
                        // Resize the high-resolution image to the correct display size (20x20 points)
                        let targetSize = CGSize(width: 20.0, height: 20.0)
                        if let resizedImage = resizeImage(image, to: targetSize) {
                            // Use template images for group icons that will adapt to system appearance
                            groupImage = resizedImage.withRenderingMode(.alwaysTemplate)
                        }
                    }
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
    
    // Helper function to resize a high-resolution image to the correct display size
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

}
