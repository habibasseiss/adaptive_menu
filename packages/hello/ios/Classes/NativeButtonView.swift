import Flutter
import UIKit

class NativeButtonView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        // Establish a method channel for communication with Dart
        _methodChannel = FlutterMethodChannel(name: "com.example/native_button_channel",
                                              binaryMessenger: messenger!)
        super.init()
        createNativeView(view: _view, arguments: args)
    }

    func view() -> UIView {
        return _view
    }

    func createNativeView(view _view: UIView, arguments args: Any?){
        _view.backgroundColor = UIColor.clear // Or any other background color

        let nativeButton = UIButton(type: .system)
        nativeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50) // Match SizedBox in Dart
        nativeButton.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)

        if let arguments = args as? [String: Any],
           let title = arguments["title"] as? String {
            nativeButton.setTitle(title, for: .normal)
        } else {
            nativeButton.setTitle("Native Button", for: .normal)
        }
        
        nativeButton.setTitleColor(UIColor.blue, for: .normal) // Example styling
        nativeButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5) // Example styling
        nativeButton.layer.cornerRadius = 8 // Example styling

        _view.addSubview(nativeButton)
    }

    @objc func onButtonTapped() {
        // Send a message to Dart when the button is tapped
        _methodChannel.invokeMethod("buttonTapped", arguments: nil)
    }
}
