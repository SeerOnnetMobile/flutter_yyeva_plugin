import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyeva_plugin/flutter_yyeva_controller.dart';

class YyEvaPlayerWidget extends StatefulWidget {
  final Function(FlutterYyevaController liveGiftController)? onViewCreated;

  final VideoPlayMode mode;

  const YyEvaPlayerWidget({super.key, this.onViewCreated, this.mode = VideoPlayMode.onQueue});

  @override
  State<YyEvaPlayerWidget> createState() => _YyEvaPlayerWidgetState();
}

class _YyEvaPlayerWidgetState extends State<YyEvaPlayerWidget> {
  final String _viewType = 'flutter_yyeva_plugin_view';

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return UiKitView(viewType: _viewType, onPlatformViewCreated: _onPlatformViewCreated);
    } else if (Platform.isAndroid) {
      return AndroidView(viewType: _viewType, onPlatformViewCreated: _onPlatformViewCreated);
    } else {
      return const SizedBox();
    }
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('${_viewType}_$id');
    FlutterYyevaController liveGiftController = FlutterYyevaController(mode: widget.mode);
    liveGiftController.attachChannel(channel);

    if (widget.onViewCreated != null) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          widget.onViewCreated!(liveGiftController);
        }
      });
    }

    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "onVideoStart":
          final map = call.arguments as Map;
          liveGiftController.isPlaying = true;
          liveGiftController.onVideoStart?.call(map["url"]);
          break;
        case "onFailed":
          final map = call.arguments as Map;
          liveGiftController.isPlaying = false;
          liveGiftController.onVideoFailed?.call(map["msg"]);
          break;
        case "onVideoComplete":
          final map = call.arguments as Map;
          liveGiftController.isPlaying = false;
          liveGiftController.onVideoCompleted?.call(map["url"]);
          Future.delayed(const Duration(milliseconds: 200), () {
            liveGiftController.playNext();
          });
        default:
          break;
      }
    });
  }
}
