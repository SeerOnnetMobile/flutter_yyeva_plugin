import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import 'package:flutter/services.dart';
import 'package:flutter_yyeva_plugin/eva_player_widget.dart';
import 'package:flutter_yyeva_plugin/flutter_yyeva_controller.dart';
import 'package:flutter_yyeva_plugin/utils/video_download_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterYyevaController _yyevaController;

  bool _isQueue = true;

  bool _isLoop = true;

  final TextEditingController _controller =
      TextEditingController(text: "https://raw.githubusercontent.com/SeerOnnetMobile/flutter_yyeva_plugin/refs/heads/main/liwuzhonggao.mp4");

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // 销毁
  @override
  dispose() {
    _yyevaController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FlutterSmartDialog.init(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  const Text("播放模式: "),
                  Text(_isQueue ? "顺序播放" : "覆盖播放"),
                  Switch(
                      value: _isQueue,
                      onChanged: (isTrue) {
                        setState(() {
                          _isQueue = isTrue;
                          _yyevaController.mode = _isQueue ? VideoPlayMode.onQueue : VideoPlayMode.onCover;
                        });
                      }),
                  const Expanded(child: SizedBox()),
                  GestureDetector(
                    onTap: () async {
                      await VideoDownloadManager.getInstance().deleteCache();

                      SmartDialog.showToast("清理成功", alignment: Alignment.center);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.blue),
                      child: const Text(
                        '清理缓存',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  const Text("是否循环: "),
                  Switch(
                      value: _isLoop,
                      onChanged: (isTrue) {
                        setState(() {
                          _isLoop = isTrue;
                          _yyevaController.isLoop = _isLoop;
                          _yyevaController.stop();
                        });
                      }),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                children: [
                  const Text("播放地址"),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '請輸入远端视频地址',
                      ),
                      controller: _controller,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.playAssetFile('asset/mp4/liwuzhonggao.mp4');
                      },
                      child: const Text(
                        '播放Assets文件',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.play(_controller.text);
                      },
                      child: const Text(
                        '播放远端视频',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      VideoDownloadManager.getInstance().preDownloadVideos([
                        "https://raw.githubusercontent.com/SeerOnnetMobile/flutter_yyeva_plugin/refs/heads/main/liwuzhonggao.mp4",
                        "https://lxcode.bs2cdn.yy.com/92d5a19f-4288-41e6-835a-e092880c4af7.mp4"
                      ]);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                      child: const Text(
                        '预加载',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                      child: GestureDetector(
                        onTap: () {
                          _yyevaController.pause();
                        },
                        child: const Text('pause', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                      child: GestureDetector(
                        onTap: () {
                          _yyevaController.resume();
                        },
                        child: const Text('resume', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.black, width: 1)),
                      child: GestureDetector(
                        onTap: () {
                          _yyevaController.stop();
                        },
                        child: const Text('stop', textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SizedBox(
                      child: YyEvaPlayerWidget(
                    mode: _isQueue ? VideoPlayMode.onQueue : VideoPlayMode.onCover,
                    isLoop: _isLoop,
                    onViewCreated: (controller) {
                      _yyevaController = controller;

                      _yyevaController.addListener(onVideoCompleted: (url) {
                        debugPrint("onVideoCompleted $url");
                      }, onVideoStart: (url) {
                        debugPrint("onVideoStart $url");
                      }, onVideoFailed: (msg) {
                        debugPrint("onVideoFailed $msg");
                      });
                    },
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
