import 'dart:async';

import 'package:flutter/services.dart';

class Cnvitals {
  static const MethodChannel _channel = const MethodChannel('cnvitals');

  static Future<String> getVitals(api_key,scan_token,employee_id, language, color_code, measured_height, measured_weight, posture) async {
    final String version = await _channel.invokeMethod('getVitals', {
      "api_key": api_key,
      "scan_token": scan_token,
      "employee_id": employee_id,
      "language": language,
      "color_code": color_code,
      "measured_height": measured_height,
      "measured_weight": measured_weight,
      "posture": posture
    });
    return version;
  }
}
