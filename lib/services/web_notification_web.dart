import 'dart:js_interop';

@JS('Notification')
extension type _JSNotification._(JSObject _) implements JSObject {
  external factory _JSNotification(String title, [JSAny? options]);
  external static String get permission;
  external static JSPromise<JSString> requestPermission();
}

Future<bool> initWebNotifications() async {
  if (_JSNotification.permission == 'granted') return true;
  final result = await _JSNotification.requestPermission().toDart;
  return result.toDart == 'granted';
}

Future<void> showWebNotification({
  required String title,
  required String body,
}) async {
  if (_JSNotification.permission != 'granted') {
    await _JSNotification.requestPermission().toDart;
  }
  if (_JSNotification.permission == 'granted') {
    _JSNotification(title, {'body': body}.jsify());
  }
}
