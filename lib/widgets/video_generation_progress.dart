import 'package:flutter/material.dart';
import '../services/video_generation_service.dart' show VideoGenerationStatus;

class VideoGenerationProgress extends StatelessWidget {
  final VideoGenerationStatus status;
  final double progress;
  final String message;
  final VoidCallback? onCancel;

  const VideoGenerationProgress({
    Key? key,
    required this.status,
    required this.progress,
    required this.message,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (onCancel != null && status != VideoGenerationStatus.completed)
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
                  onPressed: onCancel,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (status != VideoGenerationStatus.completed &&
          status != VideoGenerationStatus.error)
            Column(
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          if (status == VideoGenerationStatus.completed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '视频生成完成！',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          if (status == VideoGenerationStatus.error)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '生成失败',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case VideoGenerationStatus.generatingImage:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.image,
            color: Colors.blue[600],
            size: 20,
          ),
        );
      case VideoGenerationStatus.convertingToVideo:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.orange[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.video_file,
            color: Colors.orange[600],
            size: 20,
          ),
        );
      case VideoGenerationStatus.addingAudio:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.audiotrack,
            color: Colors.purple[600],
            size: 20,
          ),
        );
      case VideoGenerationStatus.completed:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Colors.green[600],
            size: 20,
          ),
        );
      case VideoGenerationStatus.error:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error,
            color: Colors.red[600],
            size: 20,
          ),
        );
      default:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.hourglass_empty,
            color: Colors.grey[600],
            size: 20,
          ),
        );
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case VideoGenerationStatus.generatingImage:
        return '生成图片中';
      case VideoGenerationStatus.convertingToVideo:
        return '转换视频中';
      case VideoGenerationStatus.addingAudio:
        return '添加配音中';
      case VideoGenerationStatus.completed:
        return '生成完成';
      case VideoGenerationStatus.error:
        return '生成失败';
      default:
        return '准备中';
    }
  }

  Color _getProgressColor() {
    switch (status) {
      case VideoGenerationStatus.generatingImage:
        return Colors.blue;
      case VideoGenerationStatus.convertingToVideo:
        return Colors.orange;
      case VideoGenerationStatus.addingAudio:
        return Colors.purple;
      default:
        return Colors.pink;
    }
  }
}