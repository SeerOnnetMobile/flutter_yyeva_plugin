import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';

class VideoDownloadManager {
  static VideoDownloadManager? _instance;

  String _directPath = "";

  factory VideoDownloadManager.getInstance() {
    _instance ??= VideoDownloadManager._();
    return _instance!;
  }

  VideoDownloadManager._();

  // 获取保存路径
  Future<String> _getCachePath(String url) async {
    final cacheDirPath = await getCacheDirPath();
    final directPath = "$cacheDirPath/giftVideo";

    Directory directory = Directory(directPath);
    await directory.create(recursive: true);

    _directPath = directPath;
    final fileName = generateMd5(url);
    final fileType = url.split("/").last;
    return "$_directPath/$fileName$fileType";
  }

  // 获取文件，如果没有就去下载
  Future<Uint8List> getFileData(String url) async {
    final cacheData = await _getCacheData(url);
    if (cacheData != null) {
      debugPrint("缓存过了$url");
      return cacheData;
    }

    final response = await get(Uri.parse(url));
    final file = File((await _getCachePath(url)));
    file.writeAsBytes(response.bodyBytes);
    return response.bodyBytes;
  }

  // 获取Assets本地路径，没有就复制到指定路径
  Future<String> getAssetsPathAfterData(String assetPath) async {
    final filePath = await _getCachePath(assetPath);
    final cacheData = await _getCacheData(assetPath);
    if (cacheData != null) {
      return filePath;
    }
    final byteData = await rootBundle.load(assetPath);
    final file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path; // 返回本地物理路径
  }

  // 获取文件，如果没有就去下载
  Future<String> getFilePathAfterData(String url) async {
    final filePath = await _getCachePath(url);
    final cacheData = await _getCacheData(url);
    if (cacheData != null) {
      debugPrint("缓存过了$url");
      return filePath;
    }

    final response = await get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // 获取缓存
  Future<Uint8List?> _getCacheData(String url) async {
    final file = File((await _getCachePath(url)));
    if (file.existsSync()) {
      debugPrint("有这个文件");
      return file.readAsBytes();
    } else {
      debugPrint("没有这个文件");
      return null;
    }
  }

  // 获取缓存路径
  Future<String> cachePath(String url) async {
    return await _getCachePath(url);
  }

  // 获取缓存文件夹路径
  Future<String> getCacheDirPath() async {
    final tempDir = await getTemporaryDirectory();
    String cacheDirPath = tempDir.path;
    // return cacheDirPath;
    if (Platform.isAndroid) {
      cacheDirPath = (await getExternalStorageDirectory())?.path ?? "";
    } else if (Platform.isIOS) {
      cacheDirPath = (await getApplicationDocumentsDirectory())?.path ?? "";
    }
    return cacheDirPath;
  }

  // 删除缓存
  Future<void> deleteCache() async {
    final cacheDirPath = await getCacheDirPath();
    final directPath = "$cacheDirPath/giftVideo";
    await _deleteFolderContents(directPath);
  }

  // 删除文件夹内容
  Future<void> _deleteFolderContents(String folderPath) async {
    final directory = Directory(folderPath);

    // 检查文件夹是否存在
    if (!await directory.exists()) {
      debugPrint("文件夹不存在");
      return;
    }

    try {
      // 遍历文件夹内容
      await for (final entity in directory.list()) {
        if (entity is File) {
          await entity.delete(); // 删除文件
        } else if (entity is Directory) {
          await _deleteFolderContents(entity.path); // 递归删除子目录内容
          await entity.delete(); // 删除空目录
        }
      }
      debugPrint("文件夹内容已删除");
    } catch (e) {
      debugPrint("删除失败: $e");
    }
  }

  // 预下载视频
  Future preDownloadVideos(List<String> urls) async {
    for (var url in urls) {
      final filePath = await getFilePathAfterData(url);
      debugPrint("已下载视频到本地，视频地址为$filePath");
    }
  }

  // 生成MD5
  String generateMd5(String input) {
    // 将字符串转换为 UTF-8 字节数据
    final bytes = utf8.encode(input);
    // 生成 MD5 哈希
    final digest = md5.convert(bytes);
    // 返回十六进制字符串
    return digest.toString();
  }
}
