import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('jp.infoyard.imobile_ads_unofficial/channel');

  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      log.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize sends correct arguments', () async {
    await MobileAdNetwork.initialize(
      publisherId: 'pub',
      mediaId: 'media',
      isTest: true,
    );
    expect(log, hasLength(1));
    expect(log.first.method, 'initialize');
    expect(log.first.arguments, {
      'publisherId': 'pub',
      'mediaId': 'media',
      'isTest': true,
    });
  });

  test('loadInterstitialAd sends spotId', () async {
    await MobileAdNetwork.loadInterstitialAd('spot1');
    expect(log.first.method, 'loadInterstitialAd');
    expect(log.first.arguments, {'spotId': 'spot1'});
  });

  test('showInterstitialAd sends spotId', () async {
    await MobileAdNetwork.showInterstitialAd('spot1');
    expect(log.first.method, 'showInterstitialAd');
    expect(log.first.arguments, {'spotId': 'spot1'});
  });

  test('AdEvent.fromMap parses map', () {
    final event = AdEvent.fromMap({'event': 'onAdReady', 'spotId': '123'});
    expect(event.name, 'onAdReady');
    expect(event.spotId, '123');
  });
}
