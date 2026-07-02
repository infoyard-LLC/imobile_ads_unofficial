package jp.infoyard.imobile_ads_unofficial

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

import jp.co.imobile.sdkads.android.ImobileSdkAd
import jp.co.imobile.sdkads.android.ImobileSdkAdListener
import jp.co.imobile.sdkads.android.FailNotificationReason;

object AdListenerFactory {
    fun create(spotId: String): ImobileSdkAdListener {
        return object : ImobileSdkAdListener() {
            override fun onAdReadyCompleted() = MobileAdNetworkPlugin.emit("onAdReady", spotId)
            override fun onAdShowCompleted() = MobileAdNetworkPlugin.emit("onAdShow", spotId)
            override fun onAdCloseCompleted() = MobileAdNetworkPlugin.emit("onAdClosed", spotId)
            override fun onAdCliclkCompleted()  = MobileAdNetworkPlugin.emit("onAdClick", spotId)
            override fun onFailed(reason: FailNotificationReason) {
                MobileAdNetworkPlugin.emit("onFailed", spotId)
                Log.e("AdDebug", "onAdFail: $spotId, reason: ${reason.name}")
            }
        }
    }
}

class MobileAdNetworkPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    // 外部からアクセスできるように static 保持 (AdPlatformViewで使用)
    companion object {
        var activity: Activity? = null
        var publisherId: String? = null
        var mediaId: String? = null
        private var eventSink: EventChannel.EventSink? = null

        fun emit(event: String, spotId: String) {
            Handler(Looper.getMainLooper()).post {
                eventSink?.success(mapOf("event" to event, "spotId" to spotId))
            }
        }

        fun setSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    // private var eventSink: EventChannel.EventSink? = null
    private val tag = "AdDebug"

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "jp.infoyard.imobile_ads_unofficial/channel")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "jp.infoyard.imobile_ads_unofficial/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink) { setSink(sink) }
            override fun onCancel(args: Any?) { setSink(null) }
        })

        // Factoryに messenger を渡して引数(args)を受け取れるようにする
        binding.platformViewRegistry.registerViewFactory(
            "mobile-ad-network-view",
            AdViewFactory(binding.binaryMessenger)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val argMap = call.arguments as? Map<*, *>

        when (call.method) {
            "initialize" -> {
                publisherId = argMap?.get("publisherId") as? String
                mediaId = argMap?.get("mediaId") as? String
                val isTest = argMap?.get("isTest") as? Boolean ?: false
                ImobileSdkAd.setTestMode(isTest)
                result.success(true)
            }
            "loadInterstitialAd" -> {
                val spotId = argMap?.get("spotId") as? String ?: ""
                loadInterstitialAd(spotId)
                result.success(true)
            }
            "showInterstitialAd" -> {
                val spotId = argMap?.get("spotId") as? String ?: ""
                val isReady = showInterstitialAd(spotId)
                result.success(isReady)
            }
            else -> result.notImplemented()
        }
    }

    private fun loadInterstitialAd(spotId: String) {
        val act = activity ?: return

        ImobileSdkAd.registerSpotFullScreen(act, publisherId, mediaId, spotId)
        ImobileSdkAd.setImobileSdkAdListener(spotId, AdListenerFactory.create(spotId))
        ImobileSdkAd.start(spotId)
    }

    private fun showInterstitialAd(spotId: String): Boolean {
        val act = activity ?: return false
        ImobileSdkAd.showAd(act, spotId)
        return true
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) { activity = binding.activity }
    override fun onDetachedFromActivity() {
        ImobileSdkAd.activityDestroy()
        activity = null
    }
    override fun onDetachedFromActivityForConfigChanges() { activity = null }
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { activity = binding.activity }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}

// --- PlatformView 実装 ---
class AdViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any?>
        return AdPlatformView(context, params)
    }
}

class AdPlatformView(context: Context, params: Map<String, Any?>?) : PlatformView {
    // Flutterの画面に埋め込まれる実体
    // private val container = FrameLayout(context).apply {
    //     layoutParams = FrameLayout.LayoutParams(
    //         FrameLayout.LayoutParams.MATCH_PARENT,
    //         FrameLayout.LayoutParams.MATCH_PARENT
    //     )
    //     // foregroundGravity = Gravity.CENTER
    // }
    private val container = LinearLayout(context).apply {
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        gravity = Gravity.CENTER
    }

    init {
        val spotId = params?.get("spotId") as? String ?: ""
        val act = MobileAdNetworkPlugin.activity
        val pubId = MobileAdNetworkPlugin.publisherId
        val medId = MobileAdNetworkPlugin.mediaId

        if (act != null && spotId.isNotEmpty()) {
            ImobileSdkAd.registerSpotInline(act, pubId, medId, spotId)
            ImobileSdkAd.setImobileSdkAdListener(spotId, AdListenerFactory.create(spotId))

            ImobileSdkAd.start(spotId)

            container.postDelayed({
                ImobileSdkAd.showAd(act, spotId, container)

                container.requestLayout()
                container.invalidate()
            }, 1000)
        } else {
            Log.e("AdDebug", "Activity or SpotID is null. act: $act, spotId: $spotId")
        }
    }

    override fun getView(): View = container
    override fun dispose() {
        // インスタンス破棄時にクリア
        container.removeAllViews()
    }
}
