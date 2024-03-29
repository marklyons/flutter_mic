import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMic {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mic');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  void startRecording {
    print("Recording is being started.");
    _channel.invokeMethod("startRecording");
  }
}
