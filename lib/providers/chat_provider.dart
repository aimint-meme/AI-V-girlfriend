import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:shared_preferences/shared_preferences.dart'; // 临时注释
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math';
import '../services/video_generation_service.dart' show VideoGenerationService, VideoGenerationStatus;
import '../services/knowledge_base_service.dart';
import '../services/rag_service.dart';
import '../services/secondary_personality_service.dart';
import '../models/girlfriend_model.dart';
import '../models/secondary_personality_model.dart';

class ChatProvider with ChangeNotifier {
  List<types.Message> _messages = [];
  String _currentGirlfriendId = 'demo_gf_001'; // 默认女友ID
  bool _isTtsEnabled = true;
  bool _isVoiceInputEnabled = true;
  bool _isAutoReplyEnabled = true;
  bool _isPushNotificationEnabled = true;
  bool _isNotificationSoundEnabled = true;
  bool _isNotificationVibrationEnabled = true;
  double _replySpeed = 0.5; // 0.0 to 1.0
  
  // RAG和知识库服务
  late KnowledgeBaseService _knowledgeBaseService;
  late RAGService _ragService;
  bool _isInitialized = false;

  // Demo user for chat
  final types.User _user = const types.User(
    id: 'user-id',
    firstName: '我',
  );

  List<types.Message> get messages => [..._messages];
  types.User get user => _user;
  bool get isTtsEnabled => _isTtsEnabled;
  bool get isVoiceInputEnabled => _isVoiceInputEnabled;
  bool get isAutoReplyEnabled => _isAutoReplyEnabled;
  bool get isPushNotificationEnabled => _isPushNotificationEnabled;
  bool get isNotificationSoundEnabled => _isNotificationSoundEnabled;
  bool get isNotificationVibrationEnabled => _isNotificationVibrationEnabled;
  double get replySpeed => _replySpeed;
  bool get isInitialized => _isInitialized;
  KnowledgeBaseService get knowledgeBaseService => _knowledgeBaseService;
  
  /// 初始化RAG和知识库服务
  Future<void> initializeServices() async {
    if (_isInitialized) return;
    
    try {
      _knowledgeBaseService = KnowledgeBaseService();
      await _knowledgeBaseService.initialize();
      
      _ragService = RAGService(_knowledgeBaseService);
      
      _isInitialized = true;
      print('RAG和知识库服务初始化成功');
    } catch (e) {
      print('初始化服务失败: $e');
      rethrow;
    }
  }

  // Load messages for a specific girlfriend
  Future<void> loadMessages(String girlfriendId) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // final messagesJson = prefs.getString('messages_$girlfriendId');
      final messagesJson = null; // 临时禁用
      
      if (messagesJson != null) {
        final List<dynamic> decodedMessages = jsonDecode(messagesJson);
        _messages = decodedMessages.map((msg) {
          if (msg['type'] == 'text') {
            return types.TextMessage.fromJson(msg);
          } else if (msg['type'] == 'image') {
            return types.ImageMessage.fromJson(msg);
          }
          // Add more message types as needed
          return types.TextMessage.fromJson(msg);
        }).toList();
      } else {
        // If no messages, add a welcome message
        final welcomeMessage = _getWelcomeMessage(girlfriendId);
        _messages = [welcomeMessage];
        await _saveMessages(girlfriendId);
      }
      
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
  
  // Add a message to the chat
  Future<void> addMessage(types.Message message) async {
    _messages.insert(0, message);
    await _saveMessages(_currentGirlfriendId);
    notifyListeners();
  }
  
  // Update a message in the chat
  Future<void> updateMessage(types.Message message, int index) async {
    if (index >= 0 && index < _messages.length) {
      _messages[index] = message;
      await _saveMessages(_currentGirlfriendId);
      notifyListeners();
    }
  }
  
  // Save messages to shared preferences - 临时禁用
  Future<void> _saveMessages(String girlfriendId) async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // final messagesJson = jsonEncode(_messages.map((msg) => msg.toJson()).toList());
      // await prefs.setString('messages_$girlfriendId', messagesJson);
      print('保存消息到SharedPreferences - 临时禁用');
    } catch (error) {
      // Handle error
      debugPrint('Error saving messages: $error');
    }
  }

  // Get AI response to user message (RAG Enhanced with Secondary Personality)
  Future<Map<String, dynamic>> getAIResponse(String message, String girlfriendId, String personality, {Map<String, dynamic>? girlfriendData}) async {
    try {
      // 确保服务已初始化
      if (!_isInitialized) {
        await initializeServices();
      }
      
      // 模拟响应延迟
      await Future.delayed(Duration(milliseconds: (2000 * (1 - _replySpeed)).toInt()));
      
      // 检查是否有第二人格数据
      Map<String, dynamic>? secondaryPersonalityConfig;
      if (girlfriendData != null) {
        final secondaryPersonalityService = SecondaryPersonalityService();
        secondaryPersonalityConfig = await secondaryPersonalityService.generateMixedResponse(
          message,
          _convertToGirlfriendModel(girlfriendData),
          'premium', // 假设用户是premium会员，实际应该从用户数据获取
        );
      }
      
      // 根据第二人格配置调整回复策略
      String effectivePersonality = personality;
      String? knowledgeBaseId;
      
      if (secondaryPersonalityConfig != null && secondaryPersonalityConfig['useSecondaryPersonality']) {
        print('使用第二人格: ${secondaryPersonalityConfig['personalityName']}');
        effectivePersonality = _blendPersonalities(
          personality, 
          secondaryPersonalityConfig['personalityType'],
          secondaryPersonalityConfig['mixConfig'],
        );
        knowledgeBaseId = secondaryPersonalityConfig['knowledgeBaseId'];
      }
      
      // 使用RAG服务生成增强回复
      final ragResponse = await _ragService.enhanceResponse(
        message,
        effectivePersonality,
        girlfriendId,
        knowledgeBaseId: knowledgeBaseId,
      );
      
      // 添加第二人格信息到回复中
      if (secondaryPersonalityConfig != null && secondaryPersonalityConfig['useSecondaryPersonality']) {
        ragResponse['secondaryPersonality'] = secondaryPersonalityConfig['personalityName'];
        ragResponse['personalityBlend'] = secondaryPersonalityConfig['mixConfig'];
      }
      
      // 添加调试信息
      if (ragResponse['usedKnowledge'].isNotEmpty) {
        print('使用了知识库: ${ragResponse['usedKnowledge']}');
        print('回复置信度: ${ragResponse['confidence']}');
      }
      
      return ragResponse;
    } catch (error) {
      print('RAG增强回复失败，使用基础回复: $error');
      // 降级到基础回复
      return _generateFallbackResponse(message, personality);
    }
  }
  
  /// 混合主人格和第二人格
  String _blendPersonalities(String primaryPersonality, String secondaryPersonality, Map<String, dynamic> mixConfig) {
    final primaryWeight = mixConfig['primaryWeight'] ?? 0.6;
    final secondaryWeight = mixConfig['secondaryWeight'] ?? 0.4;
    final blendMode = mixConfig['blendMode'] ?? 'balanced';
    
    // 根据混合模式和权重生成混合人格描述
    switch (blendMode) {
      case 'dominant':
        return secondaryWeight > primaryWeight ? secondaryPersonality : primaryPersonality;
      case 'subtle':
        return '$primaryPersonality（带有$secondaryPersonality的特质）';
      case 'balanced':
      default:
        return '$primaryPersonality与$secondaryPersonality的混合';
    }
  }
  
  /// 将Map数据转换为GirlfriendModel
  GirlfriendModel _convertToGirlfriendModel(Map<String, dynamic> data) {
    return GirlfriendModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      personality: data['personality'] ?? '',
      description: data['description'] ?? '',
      intimacy: data['intimacy'] ?? 0,
      isPremium: data['isPremium'] ?? false,
      traits: data['traits'] ?? {},
      lastMessageTime: data['lastMessageTime'] != null 
          ? DateTime.parse(data['lastMessageTime']) 
          : null,
      lastMessage: data['lastMessage'],
      isOnline: data['isOnline'] ?? false,
      isCreatedByUser: data['isCreatedByUser'],
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : null,
      usePublicKnowledge: data['usePublicKnowledge'] ?? false,
      background: data['background'],
      introduction: data['introduction'],
      voiceType: data['voiceType'],
      chatMode: data['chatMode'],
      novelCharacter: data['novelCharacter'],
      race: data['race'],
      eyeColor: data['eyeColor'],
      hairstyle: data['hairstyle'],
      hairColor: data['hairColor'],
      bodyType: data['bodyType'],
      cupSize: data['cupSize'],
      hipSize: data['hipSize'],
      secondaryPersonalityIds: data['secondaryPersonalityIds'] != null 
          ? List<String>.from(data['secondaryPersonalityIds']) 
          : null,
      activeSecondaryPersonalityId: data['activeSecondaryPersonalityId'],
      personalityMixConfig: data['personalityMixConfig'],
    );
  }
  
  /// 生成降级回复
  Map<String, dynamic> _generateFallbackResponse(String message, String personality) {
    String response = '';
    int intimacyChange = 1;
    
    // 简单的基于关键词的回复
    if (message.contains('你好') || message.contains('嗨') || message.contains('hi')) {
      response = personality == '温柔可爱' ? '你好呀～' : 
                personality == '活泼开朗' ? '嘿！你来啦！' :
                personality == '冷酷御姐' ? '嗯，你来了。' :
                personality == '知性优雅' ? '你好，很高兴见到你。' :
                personality == '俏皮可爱' ? '哇！你来啦！(*^▽^*)' : '你好。';
    } else if (message.contains('爱') || message.contains('喜欢')) {
      response = personality == '温柔可爱' ? '我也很喜欢你呀 ❤️' : 
                personality == '活泼开朗' ? '哇！我也超喜欢你的！🌈' :
                personality == '冷酷御姐' ? '...我也不讨厌你。' :
                personality == '知性优雅' ? '我很珍视我们之间的联系。' :
                personality == '俏皮可爱' ? '我也喜欢你啦，笨蛋！(/ω＼)' : '谢谢你的话。';
      intimacyChange = 3;
    } else {
      response = personality == '温柔可爱' ? '嗯嗯，我在听呢～' : 
                personality == '活泼开朗' ? '哈哈，真有趣！' :
                personality == '冷酷御姐' ? '嗯。我在听。' :
                personality == '知性优雅' ? '这很有意思。' :
                personality == '俏皮可爱' ? '诶嘿嘿～你说的好有趣！' : '我明白了。';
    }
    
    return {
      'response': response,
      'intimacyChange': intimacyChange,
      'recommendations': <Map<String, String>>[],
      'usedKnowledge': <String>[],
      'confidence': 0.5,
    };
  }
  
  /// 更新最后消息信息
  void updateLastMessage(String girlfriendId, String message) {
    // 这个方法会被外部调用来更新女友的最后消息信息
    // 实际的更新逻辑应该在GirlfriendProvider中实现
    notifyListeners();
  }

  // Get AI response to image
  Future<Map<String, dynamic>> getAIResponseToImage(String imagePath, String girlfriendId, String personality) async {
    try {
      // In a real app, we would call an AI API for image analysis
      // For demo, we'll simulate AI responses
      await Future.delayed(Duration(milliseconds: (2000 * (1 - _replySpeed)).toInt()));
      
      // Simple response based on personality
      String response = '';
      int intimacyChange = 0;
      List<Map<String, String>> recommendations = [];
      
      if (personality == '温柔可爱') {
        response = '这张照片真好看呢！谢谢你和我分享这个特别的时刻 💕';
        intimacyChange = 2;
      } else if (personality == '活泼开朗') {
        response = '哇！这张照片太棒了！我们什么时候一起去拍照片玩呀？😄';
        intimacyChange = 2;
      } else if (personality == '冷酷御姐') {
        response = '嗯，不错的照片。你的摄影技术...还可以。';
        intimacyChange = 1;
      } else if (personality == '知性优雅') {
        response = '这张照片构图很有艺术感，光影的处理也很到位。你有摄影的天赋。';
        intimacyChange = 2;
      } else if (personality == '俏皮可爱') {
        response = '哇塞！好漂亮的照片！我可以存下来做壁纸吗？(*^▽^*)';
        intimacyChange = 3;
      } else {
        // Default response
        response = '谢谢你分享这张照片，我很喜欢。';
        intimacyChange = 1;
      }
      
      // 随机添加摄影相关推荐
      if (Random().nextBool()) {
        recommendations.add({
          'title': '专业摄影服务',
          'description': '预约专业摄影师为你拍摄精美照片',
          'price': '¥399起',
          'url': 'https://example.com/photography',
        });
      }
      
      return {
        'response': response,
        'intimacyChange': intimacyChange,
        'recommendations': recommendations,
      };
    } catch (error) {
      rethrow;
    }
  }

  // Get welcome message based on girlfriend personality
  types.TextMessage _getWelcomeMessage(String girlfriendId) {
    const uuid = Uuid();
    String welcomeText = '你好，很高兴认识你！';
    
    // In a real app, we would get the girlfriend details from a provider
    // For demo, we'll use simple logic
    if (girlfriendId == 'gf-1') { // 小雪 - 温柔可爱
      welcomeText = '你好呀～我是小雪，很高兴认识你！今天天气真好呢，你有什么想和我聊的吗？💕';
    } else if (girlfriendId == 'gf-2') { // 小琳 - 活泼开朗
      welcomeText = '嘿！我是小琳！终于等到你啦！今天想做什么好玩的事情呢？我都可以奉陪哦！😄';
    } else if (girlfriendId == 'gf-3') { // 小冰 - 冷酷御姐
      welcomeText = '我是小冰。你好。有什么事吗？';
    } else if (girlfriendId == 'gf-4') { // 小樱 - 知性优雅
      welcomeText = '你好，我是小樱。很高兴能与你交流。你喜欢读书吗？或许我们可以分享一些彼此喜欢的作品。';
    } else if (girlfriendId == 'gf-5') { // 小菲 - 俏皮可爱
      welcomeText = '哇！你来啦！我是小菲！超级喜欢动漫和游戏的那种！你也喜欢吗？我们可以一起玩哦！(*^▽^*)';
    }
    
    return types.TextMessage(
      author: types.User(id: girlfriendId),
      id: uuid.v4(),
      text: welcomeText,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  // Toggle TTS
  void toggleTts() {
    _isTtsEnabled = !_isTtsEnabled;
    notifyListeners();
  }

  // Set TTS enabled
  void setTtsEnabled(bool value) {
    _isTtsEnabled = value;
    notifyListeners();
  }

  // Set voice input enabled
  void setVoiceInputEnabled(bool value) {
    _isVoiceInputEnabled = value;
    notifyListeners();
  }

  // Set auto reply enabled
  void setAutoReplyEnabled(bool value) {
    _isAutoReplyEnabled = value;
    notifyListeners();
  }

  // Set push notification enabled
  void setPushNotificationEnabled(bool value) {
    _isPushNotificationEnabled = value;
    notifyListeners();
  }

  // Set notification sound enabled
  void setNotificationSoundEnabled(bool value) {
    _isNotificationSoundEnabled = value;
    notifyListeners();
  }

  // Set notification vibration enabled
  void setNotificationVibrationEnabled(bool value) {
    _isNotificationVibrationEnabled = value;
    notifyListeners();
  }

  // Set reply speed
  void setReplySpeed(double value) {
    _replySpeed = value;
    notifyListeners();
  }

  // Clear all messages
  void clearAllMessages() async {
    _messages = [];
    notifyListeners();
    
    // Clear from shared preferences - 临时禁用
    // final prefs = await SharedPreferences.getInstance();
    // final keys = prefs.getKeys();
    // for (final key in keys) {
    //   if (key.startsWith('messages_')) {
    //     await prefs.remove(key);
    //   }
    // }
    print('清除所有消息 - 临时禁用SharedPreferences');
  }
  
  // 生成视频响应
  Future<Map<String, dynamic>> generateVideoResponse(
    String prompt, 
    String girlfriendId, 
    String personality,
    Function(VideoGenerationStatus, double, String) onProgress
  ) async {
    try {
      // 生成视频
      final videoPath = await VideoGenerationService.generateVideo(
        prompt: prompt,
        girlfriendId: girlfriendId,
        personality: personality,
        onProgress: onProgress,
      );
      
      if (videoPath != null) {
        // 根据人格生成相应的文字回复
        String textResponse = _generateVideoTextResponse(prompt, personality);
        
        return {
          'videoPath': videoPath,
          'textResponse': textResponse,
          'intimacyChange': 5, // 生成视频增加更多好感度
        };
      } else {
        return {
          'error': '视频生成失败',
          'intimacyChange': 0,
        };
      }
    } catch (e) {
      return {
        'error': '视频生成过程中出现错误: ${e.toString()}',
        'intimacyChange': 0,
      };
    }
  }
  
  // 根据人格生成视频相关的文字回复
  String _generateVideoTextResponse(String prompt, String personality) {
    switch (personality) {
      case '温柔可爱':
        return '我为你准备了一段特别的视频呢～希望你会喜欢！看到你开心我也很开心 💕';
      case '活泼开朗':
        return '哇！我给你做了一个超棒的视频！快来看看吧，我觉得你一定会喜欢的！😄';
      case '冷酷御姐':
        return '...我花了一些时间为你制作了这个。希望你满意。';
      case '知性优雅':
        return '我精心为你制作了这段视频，希望能够表达我想传达给你的情感。';
      default:
        return '我为你制作了一段特别的视频，希望你会喜欢！';
    }
  }
  
  // 检查是否为视频生成请求
  bool isVideoGenerationRequest(String message) {
    final videoKeywords = [
      '视频', '录像', '拍摄', '生成视频', '制作视频',
      'video', 'record', 'make video', 'create video',
      '你的视频', '一段视频', '看看你', '展示一下'
    ];
    
    final lowerMessage = message.toLowerCase();
    return videoKeywords.any((keyword) => 
      lowerMessage.contains(keyword.toLowerCase()));
  }
}