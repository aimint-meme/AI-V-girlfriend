import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'platform_file_service.dart';

// 视频生成状态
enum VideoGenerationStatus {
  idle,
  generatingImage,
  convertingToVideo,
  addingAudio,
  completed,
  error
}

// 视频生成进度回调
typedef ProgressCallback = void Function(VideoGenerationStatus status, double progress, String message);

class VideoGenerationService {
  static const _uuid = Uuid();
  
  // 生成视频的主要方法
  static Future<String?> generateVideo({
    required String prompt,
    required String girlfriendId,
    required String personality,
    required ProgressCallback onProgress,
  }) async {
    try {
      onProgress(VideoGenerationStatus.generatingImage, 0.0, '正在生成图片...');
      
      // 步骤1: 生成图片
      final imagePath = await _generateImage(prompt, girlfriendId, personality, (progress) {
        onProgress(VideoGenerationStatus.generatingImage, progress * 0.4, '正在生成图片...');
      });
      
      if (imagePath == null) {
        onProgress(VideoGenerationStatus.error, 0.0, '图片生成失败');
        return null;
      }
      
      onProgress(VideoGenerationStatus.convertingToVideo, 0.4, '正在转换为视频...');
      
      // 步骤2: 将图片转换为视频
      final videoPath = await _convertImageToVideo(imagePath, (progress) {
        onProgress(VideoGenerationStatus.convertingToVideo, 0.4 + progress * 0.4, '正在转换为视频...');
      });
      
      if (videoPath == null) {
        onProgress(VideoGenerationStatus.error, 0.0, '视频转换失败');
        return null;
      }
      
      onProgress(VideoGenerationStatus.addingAudio, 0.8, '正在添加配音...');
      
      // 步骤3: 生成并添加配音
      final finalVideoPath = await _addAudioToVideo(videoPath, prompt, personality, (progress) {
        onProgress(VideoGenerationStatus.addingAudio, 0.8 + progress * 0.2, '正在添加配音...');
      });
      
      if (finalVideoPath == null) {
        onProgress(VideoGenerationStatus.error, 0.0, '配音添加失败');
        return null;
      }
      
      onProgress(VideoGenerationStatus.completed, 1.0, '视频生成完成！');
      return finalVideoPath;
      
    } catch (e) {
      onProgress(VideoGenerationStatus.error, 0.0, '生成过程中出现错误: ${e.toString()}');
      return null;
    }
  }
  
  // 生成图片（模拟AI图片生成）
  static Future<String?> _generateImage(
    String prompt, 
    String girlfriendId, 
    String personality,
    Function(double) onProgress
  ) async {
    try {
      // 模拟图片生成过程
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        onProgress(i / 100.0);
      }
      
      // 在实际应用中，这里会调用AI图片生成API
      // 现在我们创建一个模拟的图片文件
      final directory = await getApplicationDocumentsDirectory();
      final imageDir = PlatformDirectory('${directory.path}/generated_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      
      final imagePath = '${imageDir.path}/image_${_uuid.v4()}.png';
      
      if (kIsWeb) {
        // Web平台不支持文件操作，返回模拟路径
        debugPrint('Web平台图片生成模拟: $imagePath');
        return imagePath;
      } else {
        // 创建一个简单的彩色图片作为演示
        final imageFile = PlatformFile(imagePath);
        final imageData = _createDemoImage();
        await imageFile.writeAsBytes(imageData);
        
        // 验证文件是否成功创建
        if (await imageFile.exists() && await imageFile.length() > 0) {
          debugPrint('图片生成成功: $imagePath, 大小: ${await imageFile.length()} bytes');
          return imagePath;
        } else {
          debugPrint('图片文件创建失败或为空');
          return null;
        }
      }
    } catch (e) {
      debugPrint('图片生成错误: $e');
      return null;
    }
  }
  
  // 将图片转换为视频
  static Future<String?> _convertImageToVideo(
    String imagePath,
    Function(double) onProgress
  ) async {
    try {
      // 模拟视频转换过程
      for (int i = 0; i <= 100; i += 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        onProgress(i / 100.0);
      }
      
      // 在实际应用中，这里会使用FFmpeg或类似工具将图片转换为视频
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = PlatformDirectory('${directory.path}/generated_videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }
      
      final videoPath = '${videoDir.path}/video_${_uuid.v4()}.mp4';
      
      if (kIsWeb) {
        // Web平台不支持文件操作，返回模拟路径
        debugPrint('Web平台视频转换模拟: $videoPath');
        return videoPath;
      } else {
        // 创建一个模拟的视频文件
        final videoFile = PlatformFile(videoPath);
        final videoData = _createDemoVideo();
        await videoFile.writeAsBytes(videoData);
        
        // 验证文件是否成功创建
        if (await videoFile.exists() && await videoFile.length() > 0) {
          debugPrint('视频转换成功: $videoPath, 大小: ${await videoFile.length()} bytes');
          return videoPath;
        } else {
          debugPrint('视频文件创建失败或为空');
          return null;
        }
      }
    } catch (e) {
      debugPrint('视频转换错误: $e');
      return null;
    }
  }
  
  // 为视频添加配音
  static Future<String?> _addAudioToVideo(
    String videoPath,
    String prompt,
    String personality,
    Function(double) onProgress
  ) async {
    try {
      // 模拟配音生成和合成过程
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 150));
        onProgress(i / 100.0);
      }
      
      // 在实际应用中，这里会:
      // 1. 使用TTS生成音频
      // 2. 使用FFmpeg将音频合成到视频中
      
      final directory = await getApplicationDocumentsDirectory();
      final finalVideoDir = PlatformDirectory('${directory.path}/final_videos');
      if (!await finalVideoDir.exists()) {
        await finalVideoDir.create(recursive: true);
      }
      
      final finalVideoPath = '${finalVideoDir.path}/final_video_${_uuid.v4()}.mp4';
      
      // 复制原视频文件作为最终结果（在实际应用中这里是合成后的视频）
      final originalFile = PlatformFile(videoPath);
      if (!await originalFile.exists()) {
        debugPrint('原视频文件不存在: $videoPath');
        return null;
      }
      
      await originalFile.copy(finalVideoPath);
      
      // 验证最终文件是否成功创建
      final finalFile = PlatformFile(finalVideoPath);
      if (await finalFile.exists() && await finalFile.length() > 0) {
        debugPrint('配音添加成功: $finalVideoPath, 大小: ${await finalFile.length()} bytes');
        return finalVideoPath;
      } else {
        debugPrint('最终视频文件创建失败或为空');
        return null;
      }
    } catch (e) {
      debugPrint('配音添加错误: $e');
      return null;
    }
  }
  
  // 创建演示用的图片数据
  static Uint8List _createDemoImage() {
    // 创建一个最小的有效PNG图片 (1x1像素，红色)
    final List<int> pngData = [
      // PNG文件签名
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      // IHDR chunk (13 bytes)
      0x00, 0x00, 0x00, 0x0D, // chunk长度
      0x49, 0x48, 0x44, 0x52, // "IHDR"
      0x00, 0x00, 0x00, 0x01, // 宽度: 1
      0x00, 0x00, 0x00, 0x01, // 高度: 1
      0x08, // 位深度: 8
      0x02, // 颜色类型: RGB
      0x00, // 压缩方法
      0x00, // 过滤方法
      0x00, // 交错方法
      0x90, 0x77, 0x53, 0xDE, // CRC
      // IDAT chunk (12 bytes)
      0x00, 0x00, 0x00, 0x0C, // chunk长度
      0x49, 0x44, 0x41, 0x54, // "IDAT"
      0x78, 0x9C, 0x62, 0xF8, 0x0F, 0x00, 0x01, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB4, // 压缩的图像数据
      // IEND chunk (0 bytes)
      0x00, 0x00, 0x00, 0x00, // chunk长度
      0x49, 0x45, 0x4E, 0x44, // "IEND"
      0xAE, 0x42, 0x60, 0x82  // CRC
    ];
    
    return Uint8List.fromList(pngData);
  }
  
  // 创建演示用的视频数据
  static Uint8List _createDemoVideo() {
    // 创建一个最小的有效MP4文件
    final List<int> mp4Data = [
      // ftyp box (文件类型)
      0x00, 0x00, 0x00, 0x20, // box大小: 32字节
      0x66, 0x74, 0x79, 0x70, // "ftyp"
      0x69, 0x73, 0x6F, 0x6D, // 主品牌: "isom"
      0x00, 0x00, 0x02, 0x00, // 次版本
      0x69, 0x73, 0x6F, 0x6D, // 兼容品牌: "isom"
      0x69, 0x73, 0x6F, 0x32, // 兼容品牌: "iso2"
      0x61, 0x76, 0x63, 0x31, // 兼容品牌: "avc1"
      0x6D, 0x70, 0x34, 0x31, // 兼容品牌: "mp41"
      
      // mdat box (媒体数据) - 最小化
       0x00, 0x00, 0x00, 0x08, // box大小: 8字节
       0x6D, 0x64, 0x61, 0x74, // "mdat"
     ];
     
     return Uint8List.fromList(mp4Data);
   }
  
  // 清理临时文件
  static Future<void> cleanupTempFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final tempDirs = [
        '${directory.path}/generated_images',
        '${directory.path}/generated_videos',
      ];
      
      for (final dirPath in tempDirs) {
        final dir = PlatformDirectory(dirPath);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('清理临时文件错误: $e');
    }
  }
  
  // 获取视频文件大小
  static Future<int> getVideoFileSize(String videoPath) async {
    try {
      final file = PlatformFile(videoPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('获取视频文件大小错误: $e');
      return 0;
    }
  }
}