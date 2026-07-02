import Flutter
import UIKit

open class MobileAdBaseDelegate: NSObject, IMobileSdkAdsDelegate {
  public func imobileSdkAdsSpot(_ spotId: String!, didReadyWithValue value: ImobileSdkAdsReadyResult) {
    print("onAdReady")
    MobileAdNetworkPlugin.emit(event: "onAdReady", spotId: spotId)
  }

  public func imobileSdkAdsSpotDidShow(_ spotId: String!) {
    print("onAdShow")
    MobileAdNetworkPlugin.emit(event: "onAdShow", spotId: spotId)
  }

  public func imobileSdkAdsSpotDidClose(_ spotId: String!) {
    print("onAdClosed")
    MobileAdNetworkPlugin.emit(event: "onAdClosed", spotId: spotId)
  }

  public func imobileSdkAdsSpot(_ spotId: String!, didFailWithValue value: ImobileSdkAdsFailResult) {
    print("onFailed")
    print(value)
    MobileAdNetworkPlugin.emit(event: "onFailed", spotId: spotId)
  }

  public func imobileSdkAdsSpotDidClick(_ spotId: String!){
    print("onAdClick")
    MobileAdNetworkPlugin.emit(event: "onAdClick", spotId: spotId)
  }
}

public class MobileAdNetworkPlugin: MobileAdBaseDelegate, FlutterPlugin, FlutterStreamHandler {
  static var publisherId: String?
  static var mediaId: String?
  static var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let methodChannel = FlutterMethodChannel(name: "jp.infoyard.imobile_ads_unofficial/channel", binaryMessenger: registrar.messenger())
    let instance = MobileAdNetworkPlugin()
    registrar.addMethodCallDelegate(instance, channel: methodChannel)

    let eventChannel = FlutterEventChannel(name: "jp.infoyard.imobile_ads_unofficial/events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)

    let factory = AdViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "mobile-ad-network-view")
  }

  static func emit(event: String, spotId: String) {
    DispatchQueue.main.async {
      self.eventSink?(["event": event, "spotId": spotId])
    }
  }

  // --- MethodChannel の処理 ---
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let argMap = call.arguments as? [String: Any]

    switch call.method {
    case "initialize":
      MobileAdNetworkPlugin.publisherId = argMap?["publisherId"] as? String
      MobileAdNetworkPlugin.mediaId = argMap?["mediaId"] as? String
      let isTest = argMap?["isTest"] as? Bool ?? false
      ImobileSdkAds.setTestMode(isTest)
      print("AdDebug: Initialized with \(MobileAdNetworkPlugin.publisherId ?? ""), \(MobileAdNetworkPlugin.mediaId ?? "")")
      result(true)

    case "loadInterstitialAd":
      let spotId = argMap?["spotId"] as? String ?? ""
      loadInterstitialAd(spotId: spotId)
      result(true)

    case "showInterstitialAd":
      let spotId = argMap?["spotId"] as? String ?? ""
      showInterstitialAd(spotId: spotId)
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // --- EventChannel (FlutterStreamHandler) の実装 ---
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    MobileAdNetworkPlugin.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    MobileAdNetworkPlugin.eventSink = nil
    return nil
  }

  private func loadInterstitialAd(spotId: String) {
    let pubId = MobileAdNetworkPlugin.publisherId ?? ""
    let medId = MobileAdNetworkPlugin.mediaId ?? ""

    ImobileSdkAds.register(withPublisherID: pubId, mediaID: medId, spotID: spotId)
    ImobileSdkAds.setSpotDelegate(spotId, delegate: self)
    ImobileSdkAds.start(bySpotID: spotId)
  }

  private func showInterstitialAd(spotId: String) {
    ImobileSdkAds.show(bySpotID: spotId)
  }
}

class AdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    // Dart側の creationParams を解析するために StandardMessageCodec を指定
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        // Dart側から渡された arguments (spotIdなど) を取得
        let params = args as? [String: Any]
        return AdPlatformView(frame: frame, params: params)
    }
}

class CenterContainerView: UIView {
  override func layoutSubviews() {
    super.layoutSubviews()
    for subview in subviews {
      subview.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
  }
}

class AdPlatformView: MobileAdBaseDelegate, FlutterPlatformView {
  private var _container: UIView
  private var _spotId: String

  init(frame: CGRect, params: [String: Any]?) {
    _container = CenterContainerView(frame: frame)
    _spotId = params?["spotId"] as? String ?? ""

    super.init()
    setupAd(spotId: _spotId)
  }

  func view() -> UIView {
    return _container
  }

  private func setupAd(spotId: String) {
    let pubId = MobileAdNetworkPlugin.publisherId ?? ""
    let medId = MobileAdNetworkPlugin.mediaId ?? ""

    guard !spotId.isEmpty else { return }

    // i-mobile SDK の呼び出し
    ImobileSdkAds.register(withPublisherID: pubId, mediaID: medId, spotID: spotId)
    ImobileSdkAds.setSpotDelegate(spotId, delegate: self)
    ImobileSdkAds.start(bySpotID: spotId)
    ImobileSdkAds.show(bySpotID: spotId, view: _container, sizeAdjust: false)
  }
}
