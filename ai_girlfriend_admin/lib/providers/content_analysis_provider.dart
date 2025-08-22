import 'package:flutter/foundation.dart';
import '../models/conversation_model.dart';

class ContentAnalysisProvider extends ChangeNotifier {
  ContentAnalysisStats? _stats;
  List<ConversationModel> _conversations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  ContentAnalysisStats? get stats => _stats;
  List<ConversationModel> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 统计数据快捷访问
  int get totalConversations => _stats?.totalConversations ?? 0;
  int get todayConversations => _stats?.todayConversations ?? 0;
  double get averageRounds => _stats?.averageRounds ?? 0.0;
  double get positiveSentimentRate => _stats?.positiveSentimentRate ?? 0.0;
  double get averageResponseTime => _stats?.averageResponseTime ?? 0.0;
  double get userSatisfaction => _stats?.userSatisfaction ?? 0.0;
  double get conversationCompletionRate => _stats?.conversationCompletionRate ?? 0.0;
  double get aiUnderstandingRate => _stats?.aiUnderstandingRate ?? 0.0;
  double get repetitiveConversationRate => _stats?.repetitiveConversationRate ?? 0.0;
  int get currentActiveConversations => _stats?.currentActiveConversations ?? 0;
  int get messagesPerMinute => _stats?.messagesPerMinute ?? 0;
  int get abnormalConversations => _stats?.abnormalConversations ?? 0;
  int get systemLatency => _stats?.systemLatency ?? 0;
  
  List<int> get conversationTrendData => _stats?.conversationTrendData ?? [];
  List<double> get positiveSentimentTrend => _stats?.positiveSentimentTrend ?? [];
  List<double> get neutralSentimentTrend => _stats?.neutralSentimentTrend ?? [];
  List<double> get negativeSentimentTrend => _stats?.negativeSentimentTrend ?? [];
  Map<String, double> get topicDistribution => _stats?.topicDistribution ?? {};
  Map<String, double> get characterPopularity => _stats?.characterPopularity ?? {};
  Map<String, int> get topKeywords => _stats?.topKeywords ?? {};

  // Prompt模板相关数据
  int get totalTemplates => 159;
  int get activeTemplates => 142;
  double get templateGrowth => 15.8;
  int get templateUsageCount => 45680;
  double get usageTrend => 23.5;
  double get avgTemplateRating => 4.6;
  double get ratingTrend => 8.2;
  int get optimizationSuggestions => 12;
  double get optimizationTrend => 5.3;

  // 知识库相关数据
  int get totalKnowledgeItems => 28750;
  int get verifiedItems => 26420;
  double get knowledgeGrowth => 18.7;
  int get dataSources => 8;
  int get activeDataSources => 7;
  double get dataSourceTrend => 12.5;
  int get updateFrequency => 15;
  int get lastUpdateHours => 2;
  double get updateTrend => 8.9;
  double get knowledgeAccuracy => 94.2;
  double get accuracyTrend => 3.1;

  // 加载分析数据
  Future<void> loadAnalysisData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _conversations = _generateMockConversations();
      _stats = _generateMockStats();
      
    } catch (e) {
      _error = '加载分析数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载Prompt模板数据
  Future<void> loadPromptTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载模板相关的数据
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载模板数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载知识库数据
  Future<void> loadKnowledgeBase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载知识库相关的数据
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载知识库数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 按时间范围筛选数据
  Future<void> filterByTimeRange(String timeRange) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟根据时间范围筛选数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      DateTime startDate;
      switch (timeRange) {
        case '最近7天':
          startDate = DateTime.now().subtract(const Duration(days: 7));
          break;
        case '最近30天':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case '最近90天':
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        default:
          startDate = DateTime.now().subtract(const Duration(days: 7));
      }
      
      _conversations = _conversations.where((conv) => 
          conv.startTime.isAfter(startDate)).toList();
      
      // 重新计算统计数据
      _stats = _calculateStatsFromConversations(_conversations);
      
    } catch (e) {
      _error = '筛选数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 按角色筛选数据
  Future<void> filterByCharacter(String characterName) async {
    if (characterName == '全部角色') {
      await loadAnalysisData();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      _conversations = _conversations.where((conv) => 
          conv.characterName == characterName).toList();
      
      _stats = _calculateStatsFromConversations(_conversations);
      
    } catch (e) {
      _error = '筛选角色数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 按情感筛选数据
  Future<void> filterBySentiment(String sentiment) async {
    if (sentiment == '全部情感') {
      await loadAnalysisData();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      String sentimentLabel;
      switch (sentiment) {
        case '积极':
          sentimentLabel = 'positive';
          break;
        case '消极':
          sentimentLabel = 'negative';
          break;
        default:
          sentimentLabel = 'neutral';
      }
      
      _conversations = _conversations.where((conv) => 
          conv.sentimentLabel == sentimentLabel).toList();
      
      _stats = _calculateStatsFromConversations(_conversations);
      
    } catch (e) {
      _error = '筛选情感数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取对话详情
  ConversationModel? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }

  // 获取热门话题
  List<MapEntry<String, double>> getTopTopics({int limit = 10}) {
    final topics = topicDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return topics.take(limit).toList();
  }

  // 获取热门关键词
  List<MapEntry<String, int>> getTopKeywords({int limit = 20}) {
    final keywords = topKeywords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return keywords.take(limit).toList();
  }

  // 获取情感趋势
  Map<String, List<double>> getSentimentTrends() {
    return {
      'positive': positiveSentimentTrend,
      'neutral': neutralSentimentTrend,
      'negative': negativeSentimentTrend,
    };
  }

  // 导出分析报告
  Future<Map<String, dynamic>> exportAnalysisReport() async {
    try {
      return {
        'timestamp': DateTime.now().toIso8601String(),
        'stats': _stats?.toJson(),
        'conversations_count': _conversations.length,
        'top_topics': getTopTopics(),
        'top_keywords': getTopKeywords(),
        'sentiment_trends': getSentimentTrends(),
      };
    } catch (e) {
      _error = '导出报告失败: $e';
      debugPrint(_error);
      return {};
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟对话数据
  List<ConversationModel> _generateMockConversations() {
    final conversations = <ConversationModel>[];
    final characters = ['小雪', '小美', '小智', '小萌'];
    final topics = ['日常聊天', '情感咨询', '学习辅导', '娱乐互动', '生活建议'];
    final sentiments = ['positive', 'neutral', 'negative'];
    final keywords = ['开心', '学习', '工作', '生活', '爱情', '友情', '梦想', '困难', '帮助', '支持'];
    
    for (int i = 1; i <= 100; i++) {
      final startTime = DateTime.now().subtract(Duration(hours: i * 2));
      final endTime = startTime.add(Duration(minutes: 10 + (i % 30)));
      final character = characters[i % characters.length];
      final sentiment = sentiments[i % sentiments.length];
      final topic = topics[i % topics.length];
      
      conversations.add(ConversationModel(
        id: 'conv_${i.toString().padLeft(6, '0')}',
        userId: 'user_${(i % 50 + 1).toString().padLeft(6, '0')}',
        characterId: 'char_${(i % 4 + 1)}',
        characterName: character,
        messages: _generateMockMessages(i),
        startTime: startTime,
        endTime: endTime,
        status: i % 10 == 0 ? 'abandoned' : 'completed',
        sentimentScore: sentiment == 'positive' ? 0.7 + (i % 3) * 0.1 : 
                       sentiment == 'negative' ? -0.7 - (i % 3) * 0.1 : 
                       -0.2 + (i % 5) * 0.1,
        sentimentLabel: sentiment,
        topics: [topic],
        keywords: keywords.take(3 + (i % 3)).toList(),
        rounds: 5 + (i % 20),
        duration: 5.0 + (i % 25),
        satisfactionScore: 2.0 + (i % 4),
        metadata: {
          'platform': i % 2 == 0 ? 'web' : 'mobile',
          'language': 'zh-CN',
        },
      ));
    }
    
    return conversations;
  }

  // 生成模拟消息数据
  List<MessageModel> _generateMockMessages(int conversationIndex) {
    final messages = <MessageModel>[];
    final rounds = 5 + (conversationIndex % 20);
    
    for (int i = 0; i < rounds * 2; i++) {
      final isUser = i % 2 == 0;
      final timestamp = DateTime.now().subtract(
        Duration(hours: conversationIndex * 2, minutes: rounds * 2 - i),
      );
      
      messages.add(MessageModel(
        id: 'msg_${conversationIndex}_${i.toString().padLeft(3, '0')}',
        conversationId: 'conv_${conversationIndex.toString().padLeft(6, '0')}',
        senderId: isUser ? 'user_${conversationIndex % 50 + 1}' : 'ai_character',
        senderType: isUser ? 'user' : 'ai',
        content: isUser ? '用户消息内容 $i' : 'AI回复内容 $i',
        timestamp: timestamp,
        sentimentScore: isUser ? 0.1 + (i % 5) * 0.2 : 0.5,
        sentimentLabel: i % 3 == 0 ? 'positive' : i % 3 == 1 ? 'neutral' : 'negative',
        keywords: ['关键词${i % 5}', '关键词${(i + 1) % 5}'],
        intent: isUser ? '询问' : '回答',
        metadata: {},
      ));
    }
    
    return messages;
  }

  // 生成模拟统计数据
  ContentAnalysisStats _generateMockStats() {
    return ContentAnalysisStats(
      totalConversations: 15420,
      todayConversations: 1250,
      averageRounds: 12.6,
      positiveSentimentRate: 68.5,
      neutralSentimentRate: 22.3,
      negativeSentimentRate: 9.2,
      averageResponseTime: 1.2,
      userSatisfaction: 4.2,
      conversationCompletionRate: 87.5,
      aiUnderstandingRate: 92.3,
      repetitiveConversationRate: 5.8,
      currentActiveConversations: 156,
      messagesPerMinute: 245,
      abnormalConversations: 12,
      systemLatency: 120,
      conversationTrendData: [320, 380, 420, 350, 480, 520, 450],
      positiveSentimentTrend: [65.2, 67.8, 69.1, 66.5, 70.2, 68.9, 68.5],
      neutralSentimentTrend: [25.1, 23.5, 22.8, 24.2, 21.9, 22.8, 22.3],
      negativeSentimentTrend: [9.7, 8.7, 8.1, 9.3, 7.9, 8.3, 9.2],
      topicDistribution: {
        '日常聊天': 35.2,
        '情感咨询': 28.6,
        '学习辅导': 18.4,
        '娱乐互动': 12.3,
        '生活建议': 5.5,
      },
      characterPopularity: {
        '小雪': 32.5,
        '小美': 28.3,
        '小智': 22.1,
        '小萌': 17.1,
      },
      topKeywords: {
        '开心': 1250,
        '学习': 980,
        '工作': 856,
        '生活': 742,
        '爱情': 623,
        '友情': 567,
        '梦想': 445,
        '困难': 389,
        '帮助': 356,
        '支持': 298,
        '快乐': 267,
        '成长': 234,
        '未来': 198,
        '家庭': 176,
        '健康': 154,
      },
    );
  }

  // 从对话数据计算统计信息
  ContentAnalysisStats _calculateStatsFromConversations(List<ConversationModel> conversations) {
    if (conversations.isEmpty) {
      return ContentAnalysisStats(
        totalConversations: 0,
        todayConversations: 0,
        averageRounds: 0.0,
        positiveSentimentRate: 0.0,
        neutralSentimentRate: 0.0,
        negativeSentimentRate: 0.0,
        averageResponseTime: 0.0,
        userSatisfaction: 0.0,
        conversationCompletionRate: 0.0,
        aiUnderstandingRate: 0.0,
        repetitiveConversationRate: 0.0,
        currentActiveConversations: 0,
        messagesPerMinute: 0,
        abnormalConversations: 0,
        systemLatency: 0,
        conversationTrendData: [],
        positiveSentimentTrend: [],
        neutralSentimentTrend: [],
        negativeSentimentTrend: [],
        topicDistribution: {},
        characterPopularity: {},
        topKeywords: {},
      );
    }

    final total = conversations.length;
    final today = DateTime.now();
    final todayConversations = conversations.where((conv) => 
        conv.startTime.year == today.year &&
        conv.startTime.month == today.month &&
        conv.startTime.day == today.day).length;
    
    final averageRounds = conversations.map((c) => c.rounds).reduce((a, b) => a + b) / total;
    
    final positiveCount = conversations.where((c) => c.sentimentLabel == 'positive').length;
    final neutralCount = conversations.where((c) => c.sentimentLabel == 'neutral').length;
    final negativeCount = conversations.where((c) => c.sentimentLabel == 'negative').length;
    
    return ContentAnalysisStats(
      totalConversations: total,
      todayConversations: todayConversations,
      averageRounds: averageRounds,
      positiveSentimentRate: (positiveCount / total) * 100,
      neutralSentimentRate: (neutralCount / total) * 100,
      negativeSentimentRate: (negativeCount / total) * 100,
      averageResponseTime: 1.2, // 模拟值
      userSatisfaction: conversations.map((c) => c.satisfactionScore).reduce((a, b) => a + b) / total,
      conversationCompletionRate: 87.5, // 模拟值
      aiUnderstandingRate: 92.3, // 模拟值
      repetitiveConversationRate: 5.8, // 模拟值
      currentActiveConversations: conversations.where((c) => c.status == 'active').length,
      messagesPerMinute: 245, // 模拟值
      abnormalConversations: 12, // 模拟值
      systemLatency: 120, // 模拟值
      conversationTrendData: [320, 380, 420, 350, 480, 520, 450], // 模拟值
      positiveSentimentTrend: [65.2, 67.8, 69.1, 66.5, 70.2, 68.9, 68.5], // 模拟值
      neutralSentimentTrend: [25.1, 23.5, 22.8, 24.2, 21.9, 22.8, 22.3], // 模拟值
      negativeSentimentTrend: [9.7, 8.7, 8.1, 9.3, 7.9, 8.3, 9.2], // 模拟值
      topicDistribution: _calculateTopicDistribution(conversations),
      characterPopularity: _calculateCharacterPopularity(conversations),
      topKeywords: _calculateTopKeywords(conversations),
    );
  }

  Map<String, double> _calculateTopicDistribution(List<ConversationModel> conversations) {
    final topicCounts = <String, int>{};
    for (final conv in conversations) {
      for (final topic in conv.topics) {
        topicCounts[topic] = (topicCounts[topic] ?? 0) + 1;
      }
    }
    
    final total = conversations.length;
    return topicCounts.map((topic, count) => 
        MapEntry(topic, (count / total) * 100));
  }

  Map<String, double> _calculateCharacterPopularity(List<ConversationModel> conversations) {
    final characterCounts = <String, int>{};
    for (final conv in conversations) {
      characterCounts[conv.characterName] = (characterCounts[conv.characterName] ?? 0) + 1;
    }
    
    final total = conversations.length;
    return characterCounts.map((character, count) => 
        MapEntry(character, (count / total) * 100));
  }

  Map<String, int> _calculateTopKeywords(List<ConversationModel> conversations) {
    final keywordCounts = <String, int>{};
    for (final conv in conversations) {
      for (final keyword in conv.keywords) {
        keywordCounts[keyword] = (keywordCounts[keyword] ?? 0) + 1;
      }
    }
    
    return keywordCounts;
  }
}