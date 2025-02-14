package com.example.flutter_yyeva_plugin

import android.app.Activity
import android.content.Context
import com.example.flutter_yyeva_plugin.FlutterYyevaView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterYyevaViewFactory(private val binaryMessenger: BinaryMessenger,private val activity: Activity?) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return FlutterYyevaView(context, binaryMessenger, viewId, args,activity)
    }
}