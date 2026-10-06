# imobile_ads_unofficial

> **注意:** 本パッケージは非公式です。株式会社アイモバイル（i-mobile Co., Ltd.）とは関係なく、同社による保証・承認・サポートもありません。

Flutter から i-mobile 広告を利用するための非公式プラグインです。

- SDK 初期化
- インタースティシャル広告の読み込み・表示
- バナー／インライン広告の Flutter Widget 表示
- 広告イベントの購読

## 重要: ネイティブ SDK は同梱されていません

`imobile_ads_unofficial` は i-mobile のネイティブ SDK を再配布しません。利用者自身が i-mobile の公式配布元から SDK を取得し、利用条件を確認したうえでアプリ側へ配置してください。

プラグインの GitHub リポジトリや pub.dev パッケージへ、次のファイルをコミット・同梱しないでください。

- `imobileSdkAds.jar`
- `ImobileSdkAds.xcframework`
- i-mobile SDK の ZIP、サンプル一式、その他の配布アーカイブ

## 対応環境

- Android: `minSdk 24`、Java 17、Kotlin 2.2.x
- iOS: 15.0 以上、CocoaPods
- Dart SDK: `^3.10.4`
- Flutter: `>=3.3.0`

Web、macOS、Windows、Linux には対応していません。

## インストール

```yaml
dependencies:
  imobile_ads_unofficial: ^0.0.2
```

```bash
flutter pub get
```

## ネイティブ SDK の配置

### Android

1. i-mobile の公式配布元から Android SDK を取得します。
2. SDK に含まれる `imobileSdkAds.jar` を、**このプラグイン内ではなく、利用する Flutter アプリ側**の次の場所へコピーします。

```text
<Flutterアプリ>/android/app/libs/imobileSdkAds.jar
```

`libs` フォルダがなければ作成してください。

```bash
mkdir -p android/app/libs
cp /path/to/imobileSdkAds.jar android/app/libs/imobileSdkAds.jar
```

通常は上記の場所を自動検出します。別の場所を使う場合は、Gradle プロパティまたは環境変数で絶対パスを指定できます。

環境変数で指定する場合:

```bash
export IMOBILE_ANDROID_SDK_JAR=/absolute/path/imobileSdkAds.jar
flutter build apk --debug
```

Gradle プロパティを使う場合は、ユーザー単位の `~/.gradle/gradle.properties` などへ次を設定します。

```properties
imobileSdkJar=/absolute/path/imobileSdkAds.jar
```

> SDK の利用条件上、リポジトリへの格納が認められていない場合は、アプリ側の `.gitignore` に `android/app/libs/imobileSdkAds.jar` を追加し、社内の許可された保管先から各開発環境へ配布してください。

### iOS

iOS では、アプリ側にローカル CocoaPod `ImobileSdkAds` を用意します。

1. i-mobile の公式配布元から iOS SDK を取得します。
2. `ImobileSdkAds.xcframework` を次の場所へコピーします。

```text
<Flutterアプリ>/ios/Frameworks/ImobileSdkAds.xcframework
```

3. このパッケージに含まれる `tool/ImobileSdkAds.podspec` を、Flutter アプリの `ios` 直下へコピーします。

```text
<Flutterアプリ>/ios/ImobileSdkAds.podspec
```

手作業で作成する場合は、次の内容を保存してください。`s.version` は利用する SDK のバージョンに合わせて変更できます。

```ruby
Pod::Spec.new do |s|
  s.name = 'ImobileSdkAds'
  s.version = '2.3.4'
  s.summary = 'Local wrapper for the official i-mobile iOS SDK.'
  s.description = 'References an SDK obtained directly by the app developer.'
  s.homepage = 'https://sppartner.i-mobile.co.jp/sdk_download.aspx'
  s.license = { :type => 'Proprietary' }
  s.author = { 'i-mobile Co., Ltd.' => 'https://www.i-mobile.co.jp/' }
  s.source = { :path => '.' }
  s.platform = :ios, '15.0'
  s.static_framework = true
  s.vendored_frameworks = 'Frameworks/ImobileSdkAds.xcframework'
  s.frameworks = 'AdSupport', 'SystemConfiguration', 'CoreLocation', 'WebKit', 'StoreKit'
  s.weak_frameworks = 'UIKit', 'Foundation'
  s.pod_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.user_target_xcconfig = {
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
end
```

4. Flutter アプリの `ios/Podfile` の `target 'Runner' do` 内へ、次の行を追加します。

```ruby
target 'Runner' do
  pod 'ImobileSdkAds', :path => '.'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

5. Pods を再作成します。

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

> SDK の利用条件上、リポジトリへの格納が認められていない場合は、アプリ側の `.gitignore` に `ios/Frameworks/ImobileSdkAds.xcframework/` を追加してください。

## ID の設定と初期化

利用には i-mobile から発行された `publisherId`、`mediaId`、`spotId` が必要です。

```dart
import 'package:flutter/material.dart';
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';

const publisherId = 'publisherId';
const mediaId = 'mediaId';
const interstitialSpotId = 'interstitialSpotId';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAdNetwork.initialize(
    publisherId: publisherId,
    mediaId: mediaId,
    isTest: true,
  );

  runApp(const MyApp());
}
```

## インタースティシャル広告

```dart
await MobileAdNetwork.loadInterstitialAd(interstitialSpotId);
await MobileAdNetwork.showInterstitialAd(interstitialSpotId);
```

## バナー／インライン広告

```dart
const MobileAdWidget(
  spotId: 'bannerSpotId',
)
```

## イベント購読

```dart
MobileAdNetwork.adEventStream.listen((AdEvent event) {
  debugPrint('event=${event.name}, spotId=${event.spotId}');
});
```

通知されるイベント名:

- `onAdReady`
- `onAdShow`
- `onAdClosed`
- `onAdClick`
- `onFailed`

## 公開前の安全確認

メンテナーは公開前に必ず次を実行してください。

```bash
bash tool/check_publish_contents.sh
```

この処理は、作業ツリー、Git 管理対象、および `flutter pub publish --dry-run` の公開予定一覧を検査し、i-mobile SDK バイナリが見つかった場合に失敗します。

## ライセンス

プラグイン本体は MIT License です。i-mobile のネイティブ SDK には、プラグインとは別の利用条件が適用されます。
