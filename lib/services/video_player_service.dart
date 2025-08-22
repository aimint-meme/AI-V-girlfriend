import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'platform_file_service.dart';

class VideoPlayerService {
  static final VideoPlayerService _instance = VideoPlayerService._internal();
  factory VideoPlayerService() => _instance;
  VideoPlayerService._internal();

  final Map<String, VideoPlayerController> _controllers = {};

  /// 获取或创建视频播放器控制器
  Future<VideoPlayerController?> getController(String videoPath) async {
    try {
      // 如果控制器已存在，直接返回
      if (_controllers.containsKey(videoPath)) {
        return _controllers[videoPath];
      }

      VideoPlayerController controller;
      
      if (kIsWeb) {
        // Web平台使用网络URL
        controller = VideoPlayerController.network(videoPath);
      } else {
        if (kIsWeb) {
          // Web平台使用网络URL
          controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
        } else {
          // 移动平台检查文件是否存在
          final file = PlatformFile(videoPath);
          if (!await file.exists()) {
            debugPrint('视频文件不存在: $videoPath');
            return null;
          }
          
          // 注意：这里在实际项目中需要使用真正的dart:io File
          // 现在我们使用网络URL作为替代方案
          controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
        }
      }
      
      await controller.initialize();
      
      _controllers[videoPath] = controller;
      return controller;
    } catch (e) {
      debugPrint('创建视频播放器控制器失败: $e');
      return null;
    }
  }

  /// 播放视频
  Future<void> playVideo(String videoPath) async {
    final controller = await getController(videoPath);
    if (controller != null && !controller.value.isPlaying) {
      await controller.play();
    }
  }

  /// 暂停视频
  Future<void> pauseVideo(String videoPath) async {
    final controller = _controllers[videoPath];
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
    }
  }

  /// 停止视频
  Future<void> stopVideo(String videoPath) async {
    final controller = _controllers[videoPath];
    if (controller != null) {
      await controller.pause();
      await controller.seekTo(Duration.zero);
    }
  }

  /// 设置视频位置
  Future<void> seekTo(String videoPath, Duration position) async {
    final controller = _controllers[videoPath];
    if (controller != null) {
      await controller.seekTo(position);
    }
  }

  /// 获取视频时长
  Duration? getVideoDuration(String videoPath) {
    final controller = _controllers[videoPath];
    return controller?.value.duration;
  }

  /// 获取当前播放位置
  Duration? getCurrentPosition(String videoPath) {
    final controller = _controllers[videoPath];
    return controller?.value.position;
  }

  /// 检查视频是否正在播放
  bool isPlaying(String videoPath) {
    final controller = _controllers[videoPath];
    return controller?.value.isPlaying ?? false;
  }

  /// 释放指定视频的控制器
  Future<void> disposeController(String videoPath) async {
    final controller = _controllers.remove(videoPath);
    if (controller != null) {
      await controller.dispose();
    }
  }

  /// 释放所有控制器
  Future<void> disposeAll() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
  }

  /// 保存视频到相册
  Future<bool> saveVideoToGallery(String videoPath) async {
    try {
      final file = PlatformFile(videoPath);
      if (!await file.exists()) {
        return false;
      }

      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'girlfriend_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedPath = '${directory.path}/$fileName';

      // 复制文件
      await file.copy(savedPath);
      
      debugPrint('视频已保存到: $savedPath');
      return true;
    } catch (e) {
      debugPrint('保存视频失败: $e');
      return false;
    }
  }

  /// 分享视频
  Future<void> shareVideo(String videoPath) async {
    try {
      final file = PlatformFile(videoPath);
      if (await file.exists()) {
        // 这里可以集成分享插件，如 share_plus
        debugPrint('分享视频: $videoPath');
        // Share.shareFiles([videoPath], text: '来自AI女友的视频');
      }
    } catch (e) {
      debugPrint('分享视频失败: $e');
    }
  }

  /// 获取视频文件大小
  Future<String> getVideoFileSize(String videoPath) async {
    try {
      final file = PlatformFile(videoPath);
      if (await file.exists()) {
        final bytes = await file.length();
        if (bytes < 1024) {
          return '${bytes}B';
        } else if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(1)}KB';
        } else {
          return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
        }
      }
      return '未知';
    } catch (e) {
      return '未知';
    }
  }

  /// 获取视频信息
  Future<Map<String, dynamic>> getVideoInfo(String videoPath) async {
    final controller = await getController(videoPath);
    if (controller == null) {
      return {};
    }

    final size = await getVideoFileSize(videoPath);
    final duration = controller.value.duration;
    final resolution = controller.value.size;

    return {
      'duration': duration,
      'size': size,
      'resolution': '${resolution.width.toInt()}x${resolution.height.toInt()}',
      'aspectRatio': resolution.aspectRatio,
    };
  }
}