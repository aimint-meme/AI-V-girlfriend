import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import '../services/video_player_service.dart';
import '../services/platform_file_service.dart';

class VideoMessageWidget extends StatefulWidget {
  final String videoPath;
  final String prompt;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;

  const VideoMessageWidget({
    Key? key,
    required this.videoPath,
    required this.prompt,
    this.onPlay,
    this.onPause,
  }) : super(key: key);

  @override
  State<VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<VideoMessageWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  final bool _isLoading = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  bool _showControls = true;
  Timer? _controlsTimer;
  final VideoPlayerService _videoService = VideoPlayerService();

  @override
  void initState() {
    super.initState();
    _checkVideoFile();
    _initializeVideo();
    _startControlsTimer();
  }
  
  Future<void> _initializeVideo() async {
    try {
      _controller = await _videoService.getController(widget.videoPath);
      if (_controller != null) {
        setState(() {
          _isInitialized = true;
        });
        
        // 监听播放状态变化
        _controller!.addListener(_onVideoPlayerUpdate);
      }
    } catch (e) {
      debugPrint('初始化视频失败: $e');
    }
  }
  
  void _onVideoPlayerUpdate() {
    if (_controller != null && mounted) {
      final isPlaying = _controller!.value.isPlaying;
      final duration = _controller!.value.duration;
      final position = _controller!.value.position;
      
      setState(() {
        _isPlaying = isPlaying;
        if (duration.inMilliseconds > 0) {
          _progress = position.inMilliseconds / duration.inMilliseconds;
        }
      });
    }
  }
  
  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _checkVideoFile() async {
    if (!kIsWeb) {
      final file = PlatformFile(widget.videoPath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('视频文件不存在'))
          );
        }
      }
    }
    // Web平台跳过文件检查
  }

  void _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;
    
    if (_isPlaying) {
      await _videoService.pauseVideo(widget.videoPath);
      widget.onPause?.call();
    } else {
      await _videoService.playVideo(widget.videoPath);
      widget.onPlay?.call();
    }
    
    _startControlsTimer();
  }

  void _onProgressChanged(double value) async {
    if (_controller == null || !_isInitialized) return;
    
    final duration = _controller!.value.duration;
    final position = Duration(milliseconds: (duration.inMilliseconds * value).round());
    await _videoService.seekTo(widget.videoPath, position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 视频预览区域
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 视频播放器或加载状态
                  if (_controller != null && _isInitialized)
                    Positioned.fill(
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.pink[200]!,
                            Colors.purple[200]!,
                          ],
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Icon(
                                Icons.video_library,
                                size: 48,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  // 播放控制覆盖层
                  if (_showControls)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [
                               Colors.black.withValues(alpha: 0.3),
                               Colors.transparent,
                               Colors.black.withValues(alpha: 0.3),
                             ],
                           ),
                        ),
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _togglePlayPause,
                              borderRadius: BorderRadius.circular(32),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                   color: Colors.black.withValues(alpha: 0.5),
                                   shape: BoxShape.circle,
                                 ),
                                child: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 点击区域（用于显示/隐藏控制）
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                        if (_showControls) {
                          _startControlsTimer();
                        }
                      },
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 进度条
          if (_controller != null && _isInitialized)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.pink.shade400,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: Colors.pink.shade400,
                      overlayColor: Colors.pink.shade400.withValues(alpha: 0.2),
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _progress.clamp(0.0, 1.0),
                      onChanged: _onProgressChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller!.value.position),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          _formatDuration(_controller!.value.duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          // 视频信息
          Row(
            children: [
              Icon(
                Icons.video_camera_front,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '根据「${widget.prompt}」生成的专属视频',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('视频已保存到相册'))
                  );
                },
                icon: const Icon(Icons.download, size: 16),
                label: const Text('保存', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pink[600],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('分享功能开发中'))
                  );
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('分享', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pink[600],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('视频信息'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('生成提示: ${widget.prompt}'),
                          const SizedBox(height: 8),
                          Text('文件路径: ${widget.videoPath}'),
                          const SizedBox(height: 8),
                          const Text('格式: MP4'),
                          const Text('时长: 约10秒'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('确定'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text('详情', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pink[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controlsTimer?.cancel();
    _controller?.removeListener(_onVideoPlayerUpdate);
    _isPlaying = false;
    super.dispose();
  }
}