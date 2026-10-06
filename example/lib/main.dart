import 'package:flutter/material.dart';
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';

String publisherId = 'publisherId';
String mediaId = 'mediaId';
String interstitialAdSpotId = 'interstitialAdSpotId';
String bannerAdSpotId = 'bannerAdSpotId';
bool isTest = true; // テストモード

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAdNetwork.initialize(
    publisherId: publisherId,
    mediaId: mediaId,
    isTest: isTest,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    MobileAdNetwork.loadInterstitialAd(interstitialAdSpotId);

    MobileAdNetwork.adEventStream.listen((AdEvent event) {
        debugPrint('MobileAdNetworkイベント: $event');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            Text('広告表示'),
            ElevatedButton(
              onPressed: () =>
                  MobileAdNetwork.showInterstitialAd(interstitialAdSpotId),
              child: Text('インタースティシャル広告表示'),
            ),
            Expanded(child: MobileAdWidget(spotId: bannerAdSpotId)),
          ],
        ),
      ),
    );
  }
}
