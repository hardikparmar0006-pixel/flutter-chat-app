import 'package:flutter/services.dart';

class NativeService {
  static const platform = MethodChannel("notification_channel");

  static Future<void> show(String msg) async {
    await platform.invokeMethod("showNotification", {"msg": msg});
  }
}