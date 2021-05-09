import 'dart:async';

import 'package:flutter/services.dart';

class Cnvitals {
  static const MethodChannel _channel = const MethodChannel('cnvitals');

  static Future<String> getVitals(api_key, scan_token, user_id) async {
    final String version = await _channel.invokeMethod('getVitals', {
      "api_key": api_key,
      "scan_token": scan_token,
      "user_id": user_id,
    });
    return version;
  }
}
