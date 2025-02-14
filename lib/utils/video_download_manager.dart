import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
    final fileName = url.split("/").last;
    return "$_directPath/$fileName";
  }

  // 获取 Svga文件，如果没有就去下载
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

  // 获取 Svga文件，如果没有就去下载
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

  Future<String> cachePath(String url) async {
    return await _getCachePath(url);
  }

  Future<String> getCacheDirPath() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDirPath = tempDir.path;
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
      print("文件夹不存在");
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
      print("文件夹内容已删除");
    } catch (e) {
      print("删除失败: $e");
    }
  }
}