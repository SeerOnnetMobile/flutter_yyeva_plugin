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
      if (filePath != null) {
        if (mode == VideoPlayMode.onQueue) {
          _queue.add(VideoModel(filePath, VideoSource.remote));
          if (isPlaying == false) {
            playNext();
          }
        } else {
          if (isPlaying) {
            stop();
          }
          Future.delayed(const Duration(milliseconds: 200), () {
            if (disposed) {return;}
            _queue.add(VideoModel(filePath, VideoSource.remote));
            playNext();
          });
        }
      }
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to play url: ${e.message}');
      return false;
    }
  }

  /// 播放远端视频
  Future<bool?> playAssetFile(String path) async {
    try {
      final filePath = await VideoDownloadManager.getInstance().getAssetsPathAfterData(path);
      if (filePath != null) {

        if (mode == VideoPlayMode.onQueue) {
          _queue.add(VideoModel(filePath, VideoSource.asset));
          if (isPlaying == false) {
            playNext();
          }
        } else {
          if (isPlaying) {
            stop();
          }
          Future.delayed(const Duration(milliseconds: 200), () {
            if (disposed) {return;}
            _queue.add(VideoModel(filePath, VideoSource.asset));
            playNext();
          });
        }
      }
      return true;
    } on PlatformException catch (e) {
      debugPrint('Failed to play url: ${e.message}');
      return false;
    }
  }

  /// 暂停
  Future<bool?> pause() async {
    try {
      return await _channel.invokeMethod<bool>('pause', {});
    } on PlatformException catch (e) {
      debugPrint('Failed to pause');
      return false;
    }
  }

  /// 恢复播放
  Future<bool?> resume() async {
    try {
      return await _channel.invokeMethod<bool>('resume', {});
    } on PlatformException catch (e) {
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
    } on PlatformException catch (e) {
      print('Failed to stop');
      return false;
    }
  }


  /// 调用销毁
  Future<bool?> destroyPlayer() async {
    try {
      return await _channel.invokeMethod<bool>('destroyPlayer', {});
    } on PlatformException catch (e) {
      debugPrint('Failed to destroyPlayer');
      return false;
    }
  }


  /// 播放下一个
  playNext() async {
    if (_queue.isNotEmpty && !disposed) {
      final fileModel = _queue.first;
      _queue.removeAt(0);
      return await _channel.invokeMethod<bool>('play', {'url': fileModel.path,'isLoop': isLoop});
    }
  }
}
