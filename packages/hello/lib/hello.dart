import 'hello_platform_interface.dart';

export 'native_button_widget.dart';

class Hello {
  Future<String?> getPlatformVersion() {
    return HelloPlatform.instance.getPlatformVersion();
  }
}
