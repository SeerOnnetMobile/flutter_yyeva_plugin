import UIKit
import Flutter
import YYEVA
public class FlutterYyevaViewFactory:NSObject,FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
       private let registrar: FlutterPluginRegistrar

       public init(messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
           self.messenger = messenger
           self.registrar = registrar
           super.init()
       }


       public func create(
           withFrame frame: CGRect,
           viewIdentifier viewId: Int64,
           arguments args: Any?
       ) -> FlutterPlatformView {
           return FlutterYyevaView(frame: frame, viewId: viewId, args: args, messenger: messenger, registrar: registrar)
       }

       public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
         return FlutterStandardMessageCodec.sharedInstance()
       }
}

public class FlutterYyevaView:NSObject, FlutterPlatformView, IYYEVAPlayerDelegate {
    private var evaPlayer: YYEVAPlayer
    private var channel: FlutterMethodChannel?
    private var registrar: FlutterPluginRegistrar

    public init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {

        evaPlayer = YYEVAPlayer.init(frame:frame)
        evaPlayer.mode = .contentMode_ScaleAspectFill
        self.registrar = registrar
        super.init()
          // 创建通道
          let channelName = "flutter_yyeva_plugin_view_\(viewId)"
          channel = FlutterMethodChannel(name: channelName, binaryMessenger: messenger)

            channel?.setMethodCallHandler(handle)


          if let args = args as? [String: Any] {

          }
        evaPlayer.delegate = self

      }


    public func view() -> UIView {
        return evaPlayer
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            print(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid arguments format", details: nil))
            result(false)
            return
        }
        switch call.method {
        case "play":
            let url = args["url"] as! String
            let isLoop = args["isLoop"] as! Bool
            
            evaPlayer.loop = isLoop;
            evaPlayer.play(url)
            print("url播放了")
            result(true)
            break
        case "pause":
            evaPlayer.pause()
            print("暂停了")
            result(true)
            break
        case "resume":
            evaPlayer.resume()
            print("恢复了")
            result(true)
            break
        case "stop":
            evaPlayer.stopAnimation()
            print("停止播放了")
            result(true)
            break
        case "destroyPlayer":
            evaPlayer.stopAnimation();
            result(true)
            break

        default:
            result(FlutterMethodNotImplemented)
        }
    }


    // 播放完成回调
    public func evaPlayerDidCompleted(_ player: YYEVAPlayer) {
        channel?.invokeMethod("onVideoComplete", arguments: ["url":player.assets?.filePath ?? ""])
    }

    // 是否开始播放
    public func evaPlayerDidStart(_ player: YYEVAPlayer, isRestart: Bool) {
        channel?.invokeMethod("onVideoStart", arguments: ["url":player.assets?.filePath ?? ""])
    }

    // 是否播放失败
    public func evaPlayer(_ player: YYEVAPlayer, playFail error: any Error) {
        channel?.invokeMethod("onFailed", arguments: ["msg":error.localizedDescription])
    }
}



