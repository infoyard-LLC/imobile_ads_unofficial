## 0.0.1

* Initial release.
* i-mobile SDK initialization (`MobileAdNetwork.initialize`).
* Interstitial ad loading and display (`loadInterstitialAd` / `showInterstitialAd`).
* Banner / inline ad display via `MobileAdWidget` (platform view).
* Ad lifecycle event stream (`adEventStream`): `onAdReady`, `onAdShow`, `onAdClosed`, `onAdClick`, `onFailed`.
* Supported platforms: Android (minSdk 24) and iOS (15.0+).
