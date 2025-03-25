package com.example.flutter_yyeva_plugin

import android.app.Activity
import android.content.Context
import android.view.View
import android.widget.Toast
import com.yy.yyeva.EvaAnimConfig
import com.yy.yyeva.inter.IEvaAnimListener
import com.yy.yyeva.util.ScaleType
import com.yy.yyeva.view.EvaAnimViewV3
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.io.File


class FlutterYyevaView(
    context: Context,
    binaryMessenger: BinaryMessenger,
    viewId: Int,
    args: Any?,
    private val activity: Activity?
) : PlatformView, MethodChannel.MethodCallHandler {
    private var animView: EvaAnimViewV3 = EvaAnimViewV3(context)
    private var methodChannel: MethodChannel =
        MethodChannel(binaryMessenger, "flutter_yyeva_plugin_view_${viewId}")
    private var currentUrl: String? = null

    init {
        methodChannel.setMethodCallHandler(this)
        animView.setScaleType(ScaleType.CENTER_CROP)
        animView.setAnimListener(object : IEvaAnimListener {

            override fun onVideoStart(isRestart: Boolean) {
                methodChannel.invokeMethod("onVideoStart", mapOf("url" to currentUrl))
            }

            override fun onVideoRestart() {

            }

            override fun onVideoRender(frameIndex: Int, config: EvaAnimConfig?) {
            }

            override fun onVideoComplete(lastFrame: Boolean) {
                methodChannel.invokeMethod("onVideoComplete", mapOf("url" to currentUrl))
                currentUrl = null
            }

            override fun onVideoDestroy() {
                currentUrl = null
            }

            override fun onFailed(errorType: Int, errorMsg: String?) {
                methodChannel.invokeMethod("onFailed", mapOf("msg" to errorMsg))
                currentUrl = null
            }
        })
    }

    override fun getView(): View {
        return animView
    }

    override fun dispose() {
        animView.stopPlay()
        methodChannel.setMethodCallHandler(null)
    }

    // android -> flutter
    /**
     * @param method 方法名称，唯一关系绑定，
     * @param arguments 参数或者数据 目前默认json
     */
    private fun _onFlutterMethodCall(method: String, arguments: Any) {
        activity?.runOnUiThread {
            methodChannel.invokeMethod(method, arguments)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "play" -> {
                val url: String? = call.argument("url")
                val isLoop: Boolean? = call.argument("isLoop")
                url?.apply {
                    currentUrl = url
                    animView.setLoop(if (isLoop == true) 99999 else 1);
                    animView.startPlay(File(url))
                }
                result.success(true)
            }

            "pause" -> {
                animView.pause()
                result.success(true)
            }

            "resume" -> {
                animView.resume()
                result.success(true)
            }

            "destroyPlayer" -> {
                animView.stopPlay()
                currentUrl = null
                result.success(true)
            }

            "stop" -> {
                animView.stopPlay()
                currentUrl = null
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }
}