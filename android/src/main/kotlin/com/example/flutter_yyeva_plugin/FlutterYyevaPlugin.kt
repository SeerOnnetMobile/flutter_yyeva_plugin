package com.example.flutter_yyeva_plugin
import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/** AppMapPlugin */
class FlutterYyevaPlugin : FlutterPlugin, ActivityAware,
  PlatformViewFactory(StandardMessageCodec.INSTANCE) {

  private lateinit var activity: Activity

  private lateinit var binaryMessenger: BinaryMessenger

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    binaryMessenger = flutterPluginBinding.binaryMessenger
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "flutter_yyeva_plugin_view",
      this
    )
  }


  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {

  }

  override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
    return FlutterYyevaView(context, binaryMessenger, viewId, args, activity)
  }
}
