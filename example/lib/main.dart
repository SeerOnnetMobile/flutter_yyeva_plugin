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
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.play("https://media.seeronnet.com/video/gift/liwuzhonggao.mp4");
                      },
                      child: const Text(
                        'start',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.pause();
                      },
                      child: const Text('pause', textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.resume();
                      },
                      child: const Text('resume', textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _yyevaController.stop();
                      },
                      child: const Text('stop', textAlign: TextAlign.center),
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
