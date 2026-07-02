# imobile_ads_unofficial

> **注意:** 本パッケージは非公式です。株式会社アイモバイル(i-mobile Co., Ltd.)とは一切関係ありません。

i-mobile 広告を Flutter から利用するための**非公式** Plugin です。  
Android / iOS の両方で、以下の機能を提供します。

- SDK 初期化
- インタースティシャル広告の読み込み / 表示
- バナー広告の Flutter Widget 表示
- 広告イベントの購読

> この Plugin は i-mobile のネイティブ SDK をラップする実装です。  
> 利用するには、i-mobile 側で発行される `publisherId` / `mediaId` / `spotId` が必要です。

## 対応プラットフォーム

- Android
- iOS

Web / macOS / Windows / Linux には対応していません。

## 主なAPI

- `MobileAdNetwork.initialize(...)`
- `MobileAdNetwork.loadInterstitialAd(...)`
- `MobileAdNetwork.showInterstitialAd(...)`
- `MobileAdWidget(spotId: ...)`
- `MobileAdNetwork.adEventStream`

## 前提条件

### Flutter / Dart

- Dart SDK: `^3.10.4`
- Flutter: `>=3.3.0`

### Android

- `minSdk = 24`
- Java 17
- Kotlin 2.2.x

### iOS

- iOS 15.0 以上
- CocoaPods
- i-mobile iOS SDK (`ios/Frameworks/*.xcframework`) を利用できること

## インストール

### GitHub から利用する場合

```yaml
dependencies:
  imobile_ads_unofficial:
    git:
      url: https://github.com/infoyard-LLC/imobile_ads_unofficial.git
```

### pub.dev に公開した場合

```yaml
dependencies:
  imobile_ads_unofficial: ^0.0.1
```

その後、依存関係を取得します。

```bash
flutter pub get
```

## ネイティブSDKについて

### Android

Android 側は以下のフォルダにi-mobileから入手したSDKのimobileSdkAds.jarを配置します

```text
android/libs/imobileSdkAds.jar
```

また、Plugin 側で以下の権限を宣言しています。

- `android.permission.INTERNET`
- `android.permission.ACCESS_NETWORK_STATE`
- `com.google.android.gms.permission.AD_ID`

### iOS

iOS 側は以下の vendored framework を前提にしています。

```text
ios/Frameworks/*.xcframework
```

## 使い方

### 1. 設定

`example/lib/main.dart` の以下を書き換えます。

```dart
String publisherId = 'publisherId';
String mediaId = 'mediaId';
String interstitialAdSpotId = 'interstitialAdSpotId';
String bannerAdSpotId = 'bannerAdSpotId';
```

必要に応じてテストモードを切り替えます。

```dart
bool isTest = true;
```

### 2. 初期化

`runApp()` の前に初期化します。

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAdNetwork.initialize(
    publisherId: publisherId,
    mediaId: mediaId,
    isTest: isTest,
  );

  runApp(const MyApp());
}
```

### 3. 実行方法

```bash
cd example
flutter run
```

## 実装例

### import

```dart
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';
```

### インタースティシャル広告 + バナー広告

```dart
import 'package:flutter/material.dart';
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';

String publisherId = 'publisherId';
String mediaId = 'mediaId';
String interstitialAdSpotId = 'interstitialAdSpotId';
String bannerAdSpotId = 'bannerAdSpotId';
bool isTest = true;

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
    super.initState();

    MobileAdNetwork.loadInterstitialAd(interstitialAdSpotId);

    MobileAdNetwork.adEventStream.listen((AdEvent event) {
      debugPrint('MobileAdNetwork event: $event');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Column(
          children: [
            const Text('広告表示'),
            ElevatedButton(
              onPressed: () {
                MobileAdNetwork.showInterstitialAd(interstitialAdSpotId);
              },
              child: const Text('インタースティシャル広告表示'),
            ),
            Expanded(
              child: MobileAdWidget(
                spotId: bannerAdSpotId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## イベント購読

広告イベントは `adEventStream` で受け取れます。

```dart
MobileAdNetwork.adEventStream.listen((AdEvent event) {
  debugPrint('event=${event.name}, spotId=${event.spotId}');
});
```

現状の実装で通知されるイベント名は以下です。

- `onAdReady`
- `onAdShow`
- `onAdClosed`
- `onAdClick`
- `onFailed`

## API

### `MobileAdNetwork.initialize`

```dart
static Future<void> initialize({
  required String publisherId,
  required String mediaId,
  bool isTest = false,
})
```

- `publisherId`: i-mobile の publisher ID
- `mediaId`: i-mobile の media ID
- `isTest`: テストモード有効化

### `MobileAdNetwork.loadInterstitialAd`

```dart
static Future<void> loadInterstitialAd(String spotId)
```

インタースティシャル広告を事前読み込みします。

### `MobileAdNetwork.showInterstitialAd`

```dart
static Future<void> showInterstitialAd(String spotId)
```

インタースティシャル広告を表示します。

### `MobileAdWidget`

```dart
const MobileAdWidget({
  Key? key,
  required String spotId,
})
```

Flutter 画面上にバナー広告を表示します。

## 注意事項

- `initialize()` は広告表示前に一度だけ呼んでください。
- `loadInterstitialAd()` の後に `showInterstitialAd()` を呼ぶ構成を推奨します。
- iOS 側は `xcframework` が存在しないとビルドできません。
- 現状ソース内のコメントにもある通り、**複数広告の同時表示には未対応の可能性** があります。
- Android / iOS ともに Spot ID ごとにネイティブ側へ登録しているため、同時利用時は実機で十分に確認してください。

## example の実行

```bash
cd example
flutter pub get
flutter run
```

## ライセンス

MIT License
