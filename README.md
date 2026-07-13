# imobile_ads_unofficial

> **Note:** This is an unofficial package. It is not affiliated with, endorsed by, or supported by i-mobile Co., Ltd.

An unofficial Flutter plugin for i-mobile ads on Android and iOS.

- SDK initialization
- Interstitial ad loading and display
- Banner / inline ads through a Flutter widget
- Ad lifecycle events

## Important: native SDK binaries are not bundled

`imobile_ads_unofficial` does not redistribute the proprietary i-mobile native SDK. Each user must obtain the SDK directly from i-mobile, review the applicable terms, and install it in the consuming app.

Never commit or publish these files in this plugin repository or its pub.dev archive:

- `imobileSdkAds.jar`
- `ImobileSdkAds.xcframework`
- i-mobile SDK ZIP files, samples, or other vendor archives

## Requirements

- Android: minSdk 24, Java 17, Kotlin 2.2.x
- iOS: 15.0+, CocoaPods
- Dart SDK: `^3.10.4`
- Flutter: `>=3.3.0`

Web, macOS, Windows, and Linux are not supported.

## Installation

```yaml
dependencies:
  imobile_ads_unofficial:
    git:
      url: https://github.com/infoyard-LLC/imobile_ads_unofficial.git
      ref: main
```

> Do not use the previously published pub.dev 0.0.1 archive while remediation is in progress.

```bash
flutter pub get
```

## Native SDK setup

### Android

1. Obtain the official Android SDK directly from i-mobile.
2. Copy `imobileSdkAds.jar` into the consuming Flutter app, not into this plugin:

```text
<Flutter app>/android/app/libs/imobileSdkAds.jar
```

Create the directory when necessary:

```bash
mkdir -p android/app/libs
cp /path/to/imobileSdkAds.jar android/app/libs/imobileSdkAds.jar
```

The plugin detects that path automatically. An absolute path can also be supplied with the Gradle property `imobileSdkJar` or the `IMOBILE_ANDROID_SDK_JAR` environment variable.

```bash
export IMOBILE_ANDROID_SDK_JAR=/absolute/path/imobileSdkAds.jar
flutter build apk --debug
```

If the SDK terms prohibit committing the binary, add `android/app/libs/imobileSdkAds.jar` to the app repository's `.gitignore` and distribute it through an approved internal channel.

### iOS

The consuming app must provide a local CocoaPod named `ImobileSdkAds`.

1. Obtain the official iOS SDK directly from i-mobile.
2. Copy the framework to:

```text
<Flutter app>/ios/Frameworks/ImobileSdkAds.xcframework
```

3. Copy this package's `tool/ImobileSdkAds.podspec` to:

```text
<Flutter app>/ios/ImobileSdkAds.podspec
```

To create it manually, save the following content. Adjust `s.version` to match the SDK release you installed when appropriate.

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

4. Add the local pod inside the `Runner` target in the app's `ios/Podfile`:

```ruby
target 'Runner' do
  pod 'ImobileSdkAds', :path => '.'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

5. Reinstall Pods:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

If the SDK terms prohibit committing the binary, add `ios/Frameworks/ImobileSdkAds.xcframework/` to the app repository's `.gitignore`.

## Initialize

Valid `publisherId`, `mediaId`, and `spotId` values issued by i-mobile are required.

```dart
import 'package:flutter/material.dart';
import 'package:imobile_ads_unofficial/imobile_ads_unofficial.dart';

const publisherId = 'publisherId';
const mediaId = 'mediaId';

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

## Interstitial ads

```dart
await MobileAdNetwork.loadInterstitialAd('interstitialSpotId');
await MobileAdNetwork.showInterstitialAd('interstitialSpotId');
```

## Banner / inline ads

```dart
const MobileAdWidget(spotId: 'bannerSpotId')
```

## Events

```dart
MobileAdNetwork.adEventStream.listen((AdEvent event) {
  debugPrint('event=${event.name}, spotId=${event.spotId}');
});
```

Emitted event names:

- `onAdReady`
- `onAdShow`
- `onAdClosed`
- `onAdClick`
- `onFailed`

## Publication safety check

Maintainers must run this before publishing:

```bash
bash tool/check_publish_contents.sh
```

It checks the working tree, Git index, and the file list produced by `flutter pub publish --dry-run`.

## License

The plugin source is released under the MIT License. The native i-mobile SDK is governed by separate terms supplied by i-mobile.
