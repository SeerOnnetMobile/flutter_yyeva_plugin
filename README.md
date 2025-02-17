# flutter_yyeva_plugin

基于YYEVA进行插件封装(非官方)

## 添加依赖
命令行输入：
`flutter pub add flutter_yyeva_plugin`

## 用法
视频播放有两个模式：1、队列播放（VideoPlayMode.onQueue）2、覆盖播放（VideoPlayMode.onCover）

1、需要先声明一个变量 `late FlutterYyevaController _yyevaController;`
并在`YyEvaPlayerWidget`的`onViewCreated`回调中对_liveGiftController进行赋值。

```
YyEvaPlayerWidget(
	mode: VideoPlayMode.onCover,
	onViewCreated: (controller) {
		_yyevaController = controller;
	},
)
```

2、通过 `FlutterYyevaController ` 的 `addListener`进行监听视频播放状态
```
_yyevaController.addListener(onVideoCompleted: (url) {
                        debugPrint("onVideoCompleted $url");
                      }, onVideoStart: (url) {
                        debugPrint("onVideoStart $url");
                      }, onVideoFailed: (msg) {
                        debugPrint("onVideoFailed $msg");
                      });
```


3、需要对视频进行操作时调用`play`、`pause`、`resume`、`stop`等方法控制视频播放。
```
播放本地视频：
_yyevaController.playAssetFile('asset/mp4/liwuzhonggao.mp4');

播放远端视频：
_yyevaController.play("https://raw.githubusercontent.com/SeerOnnetMobile/flutter_yyeva_plugin/refs/heads/main/liwuzhonggao.mp4");

暂停：
_yyevaController.pause();

恢复播放：
_yyevaController.resume();

停止：
_yyevaController.stop();
```

4、在界面消失不再使用时调动controller的`dispose`方法
```
  // 销毁
  @override
  dispose() {
    _yyevaController.dispose();
    super.dispose();
  }
```

5、清理缓存，调用`Future<void> deleteCache()`清理缓存
```
await VideoDownloadManager.getInstance().deleteCache();
```

6、预下载
```
如果想在播放之前就先完成预下载缓存视频的工作，可以先调用
VideoDownloadManager.getInstance.preDownloadVideos(["https://raw.githubusercontent.com/SeerOnnetMobile/flutter_yyeva_plugin/refs/heads/main/liwuzhonggao.mp4","https://lxcode.bs2cdn.yy.com/92d5a19f-4288-41e6-835a-e092880c4af7.mp4"])
```

