import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bob_multi_player/bob_multi_player.dart';

void main() {
  const MethodChannel channel = MethodChannel('bob_multi_player');

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
    expect(await BobMultiPlayer.platformVersion, '42');
  });
}
