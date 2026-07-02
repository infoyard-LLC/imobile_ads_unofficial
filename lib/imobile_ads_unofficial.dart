import 'dart:async';
import 'package:flutter/services.dart';
import 'package:imobile_ads_unofficial/ad_event.dart';

export 'package:imobile_ads_unofficial/ad_event.dart';
export 'package:imobile_ads_unofficial/mobile_ad_widget.dart';

// TODO: 現状の作り上複数広告を同時に出せない

class MobileAdNetwork {
  static const MethodChannel _method = MethodChannel(
    'jp.infoyard.imobile_ads_unofficial/channel',
  );
  static const EventChannel _events = EventChannel(
    'jp.infoyard.imobile_ads_unofficial/events',
  );

  static Future<void> initialize({
    required String publisherId,
    required String mediaId,
    bool isTest = false,
  }) async {
    await _method.invokeMethod('initialize', {
      'publisherId': publisherId,
      'mediaId': mediaId,
      'isTest': isTest,
    });
  }

  // イベント通知用のストリーム
  static Stream<AdEvent> get adEventStream {
    return _events.receiveBroadcastStream().map(
      (dynamic event) => AdEvent.fromMap(event as Map<dynamic, dynamic>),
    );
  }

  static Future<void> loadInterstitialAd(String spotId) =>
      _method.invokeMethod('loadInterstitialAd', {"spotId": spotId});
  static Future<void> showInterstitialAd(String spotId) =>
      _method.invokeMethod('showInterstitialAd', {"spotId": spotId});
}
