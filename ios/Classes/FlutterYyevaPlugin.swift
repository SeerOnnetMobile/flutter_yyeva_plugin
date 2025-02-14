import Flutter
import UIKit

public class FlutterYyevaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_yyeva_plugin", binaryMessenger: registrar.messenger())
    let instance = FlutterYyevaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)


      let factory = FlutterYyevaViewFactory(messenger: registrar.messenger(),registrar: registrar)
      registrar.register(factory, withId: "flutter_yyeva_plugin_view")
  }
}
