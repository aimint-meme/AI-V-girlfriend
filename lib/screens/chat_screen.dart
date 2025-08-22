import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../providers/chat_provider.dart';
import '../providers/girlfriend_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/video_generation_progress.dart';
import '../widgets/video_message_widget.dart';
import '../services/video_generation_service.dart' show VideoGenerationService, VideoGenerationStatus;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _uuid = const Uuid();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeaking = false;
  bool _isTyping = false;
  bool _isListening = false;
  String _recognizedText = '';
  final TextEditingController _textController = TextEditingController();
  bool _isGeneratingAIHelp = false;
  bool _isGeneratingVideo = false;
  VideoGenerationStatus _videoStatus = VideoGenerationStatus.idle;
  double _videoProgress = 0.0;
  String _videoMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeSpeech();
    _loadMessages();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize();
  }

  Future<void> _loadMessages() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    
    if (girlfriendProvider.currentGirlfriend == null) {
      // If no girlfriend is selected, redirect to home
      // Navigator.of(context).pushReplacementNamed('/home');
      return;
    }
    
    try {
      await chatProvider.loadMessages(girlfriendProvider.currentGirlfriend!.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载消息失败: ${error.toString()}'))
        );
      }
    }
  }

  void _handleSendPressed(types.PartialText message) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    
    final textMessage = types.TextMessage(
      author: chatProvider.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );
    
    chatProvider.addMessage(textMessage);
    
    // Update last message in girlfriend provider for user message
    await girlfriendProvider.updateLastMessage(
      girlfriendProvider.currentGirlfriend!.id,
      message.text,
    );
    
    // 检查是否为视频生成请求
    if (chatProvider.isVideoGenerationRequest(message.text)) {
      _handleVideoGenerationRequest(message.text, chatProvider, girlfriendProvider);
      return;
    }
    
    // Show typing indicator
    setState(() {
      _isTyping = true;
    });
    
    try {
      // Get AI response with secondary personality support
      final responseData = await chatProvider.getAIResponse(
        message.text,
        girlfriendProvider.currentGirlfriend!.id,
        girlfriendProvider.currentGirlfriend!.personality,
        girlfriendData: girlfriendProvider.currentGirlfriend!.toJson(),
      );
      
      final String response = responseData['response'];
      final int intimacyChange = responseData['intimacyChange'];
      final List<String> usedKnowledge = responseData['usedKnowledge'] ?? [];
      final double confidence = responseData['confidence'] ?? 0.5;
      
      // 更新好感度
      if (intimacyChange != 0) {
        await girlfriendProvider.updateIntimacy(
          girlfriendProvider.currentGirlfriend!.id,
          intimacyChange
        );
        
        // 显示好感度变化提示
        if (mounted && intimacyChange > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('好感度 +$intimacyChange'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.pink[100],
            )
          );
        }
      }
      
      // 显示RAG功能使用提示
      if (mounted && usedKnowledge.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('💡 使用了知识库: ${usedKnowledge.join(', ')} (置信度: ${(confidence * 100).toInt()}%)'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.blue[100],
            behavior: SnackBarBehavior.floating,
          )
        );
      }
      
      final responseMessage = types.TextMessage(
        author: types.User(
          id: girlfriendProvider.currentGirlfriend!.id,
          firstName: girlfriendProvider.currentGirlfriend!.name,
          imageUrl: girlfriendProvider.currentGirlfriend!.avatarUrl,
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: response,
      );
      
      await chatProvider.addMessage(responseMessage);
      
      // Update last message in girlfriend provider
      await girlfriendProvider.updateLastMessage(
        girlfriendProvider.currentGirlfriend!.id,
        response,
      );
      
      // Speak the response if TTS is enabled
      if (chatProvider.isTtsEnabled) {
        _speakText(response);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取回复失败: ${error.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('照片'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleCameraSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('相机'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('取消'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      _setAttachmentMessage(result);
    }
  }

  void _handleCameraSelection() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1440,
    );

    if (result != null) {
      _setAttachmentMessage(result);
    }
  }

  void _setAttachmentMessage(XFile file) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);

    final message = types.ImageMessage(
      author: chatProvider.user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: image.height.toDouble(),
      id: _uuid.v4(),
      name: file.name,
      size: bytes.length,
      uri: file.path,
      width: image.width.toDouble(),
    );

    await chatProvider.addMessage(message);
    
    // Show typing indicator
    setState(() {
      _isTyping = true;
    });
    
    try {
      // Get AI response to image
      final responseData = await chatProvider.getAIResponseToImage(
        file.path,
        girlfriendProvider.currentGirlfriend!.id,
        girlfriendProvider.currentGirlfriend!.personality,
      );
      
      final String response = responseData['response'];
      final int intimacyChange = responseData['intimacyChange'];
      
      // 更新好感度
      if (intimacyChange != 0) {
        await girlfriendProvider.updateIntimacy(
          girlfriendProvider.currentGirlfriend!.id,
          intimacyChange
        );
        
        // 显示好感度变化提示
        if (mounted && intimacyChange > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('好感度 +$intimacyChange'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.pink[100],
            )
          );
        }
      }
      
      final responseMessage = types.TextMessage(
        author: types.User(
          id: girlfriendProvider.currentGirlfriend!.id,
          firstName: girlfriendProvider.currentGirlfriend!.name,
          imageUrl: girlfriendProvider.currentGirlfriend!.avatarUrl,
        ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: _uuid.v4(),
        text: response,
      );
      
      await chatProvider.addMessage(responseMessage);
      
      // Speak the response if TTS is enabled
      if (chatProvider.isTtsEnabled) {
        _speakText(response);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取回复失败: ${error.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  Future<void> _speakText(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      return;
    }
    
    setState(() {
      _isSpeaking = true;
    });
    
    await _flutterTts.speak(text);
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _recognizedText = '';
        });
        
        _speech.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
          localeId: 'zh_CN',
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
      
      if (_recognizedText.isNotEmpty) {
        _handleSendPressed(types.PartialText(text: _recognizedText));
      }
    }
  }
  
  // 处理视频生成请求
  void _handleVideoGenerationRequest(
    String prompt, 
    ChatProvider chatProvider, 
    GirlfriendProvider girlfriendProvider
  ) async {
    setState(() {
      _isGeneratingVideo = true;
      _videoStatus = VideoGenerationStatus.idle;
      _videoProgress = 0.0;
      _videoMessage = '准备生成视频...';
    });
    
    try {
      final responseData = await chatProvider.generateVideoResponse(
        prompt,
        girlfriendProvider.currentGirlfriend!.id,
        girlfriendProvider.currentGirlfriend!.personality,
        (status, progress, message) {
          if (mounted) {
            setState(() {
              _videoStatus = status;
              _videoProgress = progress;
              _videoMessage = message;
            });
          }
        },
      );
      
      if (responseData.containsKey('error')) {
        // 显示错误消息
        final errorMessage = types.TextMessage(
          author: types.User(
            id: girlfriendProvider.currentGirlfriend!.id,
            firstName: girlfriendProvider.currentGirlfriend!.name,
            imageUrl: girlfriendProvider.currentGirlfriend!.avatarUrl,
          ),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          text: '抱歉，${responseData['error']}，请稍后再试。',
        );
        
        await chatProvider.addMessage(errorMessage);
      } else {
        // 添加文字回复
        final textResponse = types.TextMessage(
          author: types.User(
            id: girlfriendProvider.currentGirlfriend!.id,
            firstName: girlfriendProvider.currentGirlfriend!.name,
            imageUrl: girlfriendProvider.currentGirlfriend!.avatarUrl,
          ),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          text: responseData['textResponse'],
        );
        
        await chatProvider.addMessage(textResponse);
        
        // 添加视频消息（使用自定义消息类型）
        final videoMessage = types.CustomMessage(
          author: types.User(
            id: girlfriendProvider.currentGirlfriend!.id,
            firstName: girlfriendProvider.currentGirlfriend!.name,
            imageUrl: girlfriendProvider.currentGirlfriend!.avatarUrl,
          ),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          metadata: {
            'type': 'video',
            'videoPath': responseData['videoPath'],
            'prompt': prompt,
          },
        );
        
        await chatProvider.addMessage(videoMessage);
        
        // 更新好感度
        final intimacyChange = responseData['intimacyChange'] ?? 0;
        if (intimacyChange > 0) {
          await girlfriendProvider.updateIntimacy(
            girlfriendProvider.currentGirlfriend!.id,
            intimacyChange
          );
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('好感度 +$intimacyChange'),
                duration: const Duration(seconds: 2),
                backgroundColor: Colors.pink[100],
              )
            );
          }
        }
        
        // 播放文字回复（如果启用TTS）
        if (chatProvider.isTtsEnabled) {
          _speakText(responseData['textResponse']);
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频生成失败: ${error.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingVideo = false;
          _videoStatus = VideoGenerationStatus.idle;
        });
      }
    }
  }
  
  // 取消视频生成
   void _cancelVideoGeneration() {
     setState(() {
       _isGeneratingVideo = false;
       _videoStatus = VideoGenerationStatus.idle;
     });
     
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('视频生成已取消'))
     );
   }
   
   // 自定义消息构建器
   Widget _customMessageBuilder(
     types.CustomMessage message, {
     required int messageWidth,
   }) {
     final metadata = message.metadata ?? {};
     
     if (metadata['type'] == 'video') {
       return Container(
         constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
         child: VideoMessageWidget(
           videoPath: metadata['videoPath'] ?? '',
           prompt: metadata['prompt'] ?? '',
           onPlay: () {
             // 可以在这里添加视频播放的统计或其他逻辑
             debugPrint('开始播放视频: ${metadata['videoPath']}');
           },
           onPause: () {
             // 可以在这里添加视频暂停的统计或其他逻辑
             debugPrint('暂停播放视频: ${metadata['videoPath']}');
           },
         ),
       );
     }
     
     // 如果不是视频消息，返回默认的文本显示
     return Container(
       constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
       padding: const EdgeInsets.all(12),
       decoration: BoxDecoration(
         color: Colors.grey[100],
         borderRadius: BorderRadius.circular(12),
       ),
       child: Text(
         '未知消息类型: ${metadata['type'] ?? 'unknown'}',
         style: const TextStyle(color: Colors.grey),
       ),
     );
   }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context);
    
    if (girlfriendProvider.currentGirlfriend == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ChatAppBar(
          girlfriend: girlfriendProvider.currentGirlfriend!,
          isSpeaking: _isSpeaking,
          onTtsToggle: () {
            if (_isSpeaking) {
              _flutterTts.stop();
              setState(() {
                _isSpeaking = false;
              });
            }
            chatProvider.toggleTts();
          },
          isTtsEnabled: chatProvider.isTtsEnabled,
        ),
      ),
      body: Column(
        children: [
          // 视频生成进度显示
          if (_isGeneratingVideo)
            VideoGenerationProgress(
              status: _videoStatus,
              progress: _videoProgress,
              message: _videoMessage,
              onCancel: _cancelVideoGeneration,
            ),
          // 聊天界面
          Expanded(
            child: Chat(
               messages: chatProvider.messages,
               onSendPressed: _handleSendPressed,
               user: chatProvider.user,
               customMessageBuilder: _customMessageBuilder,
              theme: DefaultChatTheme(
                primaryColor: Colors.pink.shade400,
                secondaryColor: Colors.grey.shade200,
                backgroundColor: Colors.white,
                inputBackgroundColor: Colors.grey.shade100,
                inputTextColor: Colors.black87,
                inputTextCursorColor: Colors.pink.shade400,
                sentMessageBodyTextStyle: const TextStyle(color: Colors.white),
                receivedMessageBodyTextStyle: const TextStyle(color: Colors.black87),
              ),
              showUserAvatars: true,
              showUserNames: true,
              // enablePreviewUrlsInMessage: true, // 参数可能不存在，先注释掉
              onPreviewDataFetched: (types.TextMessage message, types.PreviewData previewData) {
                final index = chatProvider.messages.indexWhere((element) => element.id == message.id);
                if (index != -1) {
                  chatProvider.updateMessage(message.copyWith(previewData: previewData), index);
                }
              },
              typingIndicatorOptions: TypingIndicatorOptions(
                typingUsers: _isTyping ? [types.User(
                  id: girlfriendProvider.currentGirlfriend!.id,
                  firstName: girlfriendProvider.currentGirlfriend!.name,
                )] : [],
              ),
               customBottomWidget: _buildCustomInputWidget(),
               // customBottomWidgetBuilder 参数可能不存在，先注释掉
               // customBottomWidgetBuilder: (_) => _isListening ? null : Padding(
               //   padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
               //   child: Row(
               //     children: [
               //       VoiceInputButton(
               //         onPressed: _startListening,
               //       ),
               //       const SizedBox(width: 16),
               //       Expanded(
               //         child: Container(),
               //       ),
               //     ],
               //   ),
               // ),
               onAttachmentPressed: _handleAttachmentPressed,
             ),
           ),
         ],
       ),
    );
  }
  
  Widget _buildCustomInputWidget() {
    if (_isListening) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.grey.shade100,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _recognizedText.isEmpty ? '正在聆听...' : _recognizedText,
                style: TextStyle(
                  color: _recognizedText.isEmpty ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: Colors.pink.shade400,
              onPressed: _stopListening,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              color: Colors.grey,
              onPressed: () {
                _speech.stop();
                setState(() {
                  _isListening = false;
                  _recognizedText = '';
                });
              },
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // AI辅助对话按钮
          IconButton(
            icon: _isGeneratingAIHelp 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                    ),
                  )
                : Icon(
                    Icons.psychology,
                    color: Colors.blue.shade400,
                  ),
            onPressed: _isGeneratingAIHelp ? null : _handleAIAssist,
            tooltip: 'AI辅助对话',
          ),
          // 输入框
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: '输入消息...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _sendMessage(text.trim());
                  }
                },
              ),
            ),
          ),
          // 语音输入按钮
          IconButton(
            icon: Icon(
              Icons.mic,
              color: Colors.grey.shade600,
            ),
            onPressed: _startListening,
            tooltip: '语音输入',
          ),
          // 发送按钮
          IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.pink.shade400,
            ),
            onPressed: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                _sendMessage(text);
              }
            },
            tooltip: '发送',
          ),
        ],
      ),
    );
  }
  
  void _sendMessage(String text) {
    final message = types.PartialText(text: text);
    _handleSendPressed(message);
    _textController.clear();
  }
  
  Future<void> _handleAIAssist() async {
    if (!mounted) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // 检查金币余额
    const aiAssistCost = 5; // AI辅助对话消耗5金币
    if (authProvider.coinBalance < aiAssistCost) {
       if (mounted) {
         scaffoldMessenger.showSnackBar(
           const SnackBar(
             content: Text('金币不足，无法使用AI辅助对话功能'),
             backgroundColor: Colors.orange,
           ),
         );
       }
       return;
     }
    
    setState(() {
      _isGeneratingAIHelp = true;
    });
    
    try {
      // 获取最近的聊天记录作为上下文
      final recentMessages = chatProvider.messages.take(5).toList();
      String context = '';
      for (final message in recentMessages.reversed) {
        if (message is types.TextMessage) {
          final isUser = message.author.id == chatProvider.user.id;
          context += '${isUser ? "用户" : girlfriendProvider.currentGirlfriend?.name ?? "AI"}: ${message.text}\n';
        }
      }
      
      // 生成AI建议的回复
      final responseData = await chatProvider.getAIResponse(
        '请根据以下对话上下文，为用户生成一个合适的回复建议：\n$context\n请生成一个自然、有趣的回复建议。',
        girlfriendProvider.currentGirlfriend!.id,
        girlfriendProvider.currentGirlfriend!.personality,
      );
      
      final suggestion = responseData['response'] as String;
      
      // 扣除金币
      await authProvider.deductCoins(aiAssistCost);
      
      if (mounted) {
         // 将建议填入输入框
         _textController.text = _cleanAISuggestion(suggestion);
         
         scaffoldMessenger.showSnackBar(
           SnackBar(
             content: Text('AI建议已生成，消耗 $aiAssistCost 金币'),
             backgroundColor: Colors.green,
             duration: const Duration(seconds: 2),
           ),
         );
       }
    } catch (error) {
       if (mounted) {
         scaffoldMessenger.showSnackBar(
           SnackBar(
             content: Text('AI辅助生成失败: ${error.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
       }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAIHelp = false;
        });
      }
    }
  }
  
  String _cleanAISuggestion(String suggestion) {
    // 清理AI生成的建议，移除不必要的前缀和格式
    String cleaned = suggestion;
    
    // 移除常见的AI回复前缀
    final prefixes = [
      '根据对话上下文，我建议你可以回复：',
      '你可以这样回复：',
      '建议回复：',
      '回复建议：',
      '你可以说：',
      '建议你说：',
    ];
    
    for (final prefix in prefixes) {
      if (cleaned.startsWith(prefix)) {
        cleaned = cleaned.substring(prefix.length).trim();
        break;
      }
    }
    
    // 移除引号
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    
    return cleaned.trim();
  }
}