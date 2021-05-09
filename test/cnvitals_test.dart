import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cnvitals/cnvitals.dart';

void main() {
  const MethodChannel channel = MethodChannel('cnvitals');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Cnvitals.getVitals("api_key", "scan_token", "user_id"), '42');
  });
}
