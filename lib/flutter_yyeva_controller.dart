import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyeva_plugin/utils/video_download_manager.dart';

import 'model/video_model.dart';


enum VideoPlayMode {
  onQueue, // 以队列形式顺序播放
  onCover, // 覆盖播放
}

class FlutterYyevaController {
  late MethodChannel _channel;

  Function(String)? onVideoCompleted;

  Function(String)? onVideoStart;

  Function(String)? onVideoFailed;

  VideoPlayMode mode;

  List<VideoModel> _queue = [];

  bool isPlaying = false;

  bool isLoop = false;

  bool isStayLastFrame = false;

  FlutterYyevaController({required this.mode, this.isLoop = false});

  bool disposed = false;

  dispose() {
    disposed = true;
    _queue = [];
  }

  /// 绑定channel
  void attachChannel(MethodChannel channel) {
    _channel = channel;
  }

  /// 添加监听
  addListener({Function(String)? onVideoCompleted, Function(String)? onVideoStart, Function(String)? onVideoFailed}) {
    this.onVideoCompleted = onVideoCompleted;
    this.onVideoStart = onVideoStart;
    this.onVideoFailed = onVideoFailed;
  }

  /// 播放远端视频
  Future<bool?> play(String url) async {
    try {
      final filePath = await VideoDownloadManager.getInstance().getFilePathAfterData(url);
      _enqueue(VideoModel(filePath, VideoSource.remote));
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to play url: ${e.message}');
      return false;
    }
  }

  /// 播放本地视频文件（传入文件路径）
  Future<bool?> playFile(String filePath) async {
    try {
      _enqueue(VideoModel(filePath, VideoSource.local));
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to play file: ${e.message}');
      return false;
    }
  }

  /// 播放Assets里的视频
  Future<bool?> playAssetFile(String path) async {
    try {
      final filePath = await VideoDownloadManager.getInstance().getAssetsPathAfterData(path);
      _enqueue(VideoModel(filePath, VideoSource.asset));
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to play asset: ${e.message}');
      return false;
    }
  }

  /// 将视频加入播放队列
  ///
  /// 队列模式下直接入队，如果当前没有在播放则立即播放下一个；
  /// 覆盖模式下先停止当前播放，延迟一小段时间后再入队播放。
  void _enqueue(VideoModel model) {
    if (mode == VideoPlayMode.onQueue) {
      _queue.add(model);
      if (!isPlaying) {
        playNext();
      }
    } else {
      Duration delay = Duration.zero;
      if (isPlaying) {
        stop();
        delay = const Duration(milliseconds: 200);
      }
      Future.delayed(delay, () {
        if (disposed) return;
        _queue.add(model);
        playNext();
      });
    }
  }

  /// 暂停
  Future<bool?> pause() async {
    try {
      return await _channel.invokeMethod<bool>('pause', {});
    } on PlatformException {
      debugPrint('Failed to pause');
      return false;
    }
  }

  /// 恢复播放
  Future<bool?> resume() async {
    try {
      return await _channel.invokeMethod<bool>('resume', {});
    } on PlatformException {
      debugPrint('Failed to resume');
      return false;
    }
  }

  /// 停止
  Future<bool?> stop() async {
    try {
      final result = await _channel.invokeMethod<bool>('stop', {});
      if (result == true) {
        isPlaying = false;
      }
      return result;
    } on PlatformException {
      debugPrint('Failed to stop');
      return false;
    }
  }


  /// 调用销毁
  Future<bool?> destroyPlayer() async {
    try {
      return await _channel.invokeMethod<bool>('destroyPlayer', {});
    } on PlatformException {
      debugPrint('Failed to destroyPlayer');
      return false;
    }
  }


  /// 播放下一个
  playNext() async {
    if (_queue.isNotEmpty && !disposed) {
      final fileModel = _queue.first;
      _queue.removeAt(0);
      return await _channel.invokeMethod<bool>('play', {'url': fileModel.path,'isLoop': isLoop,'isStayLastFrame': isStayLastFrame});
    }
  }
}
