class ConversationModel {
  final String id;
  final String userId;
  final String characterId;
  final String characterName;
  final List<MessageModel> messages;
  final DateTime startTime;
  final DateTime? endTime;
  final String status; // active, completed, abandoned
  final double sentimentScore; // -1.0 to 1.0
  final String sentimentLabel; // positive, neutral, negative
  final List<String> topics;
  final List<String> keywords;
  final int rounds;
  final double duration; // in minutes
  final double satisfactionScore; // 0.0 to 5.0
  final Map<String, dynamic> metadata;

  ConversationModel({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.characterName,
    required this.messages,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.sentimentScore,
    required this.sentimentLabel,
    required this.topics,
    required this.keywords,
    required this.rounds,
    required this.duration,
    required this.satisfactionScore,
    this.metadata = const {},
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      characterId: json['characterId'] ?? '',
      characterName: json['characterName'] ?? '',
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((m) => MessageModel.fromJson(m))
          .toList(),
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      status: json['status'] ?? 'active',
      sentimentScore: (json['sentimentScore'] ?? 0.0).toDouble(),
      sentimentLabel: json['sentimentLabel'] ?? 'neutral',
      topics: List<String>.from(json['topics'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
      rounds: json['rounds'] ?? 0,
      duration: (json['duration'] ?? 0.0).toDouble(),
      satisfactionScore: (json['satisfactionScore'] ?? 0.0).toDouble(),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'characterId': characterId,
      'characterName': characterName,
      'messages': messages.map((m) => m.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'sentimentScore': sentimentScore,
      'sentimentLabel': sentimentLabel,
      'topics': topics,
      'keywords': keywords,
      'rounds': rounds,
      'duration': duration,
      'satisfactionScore': satisfactionScore,
      'metadata': metadata,
    };
  }

  // 获取情感倾向描述
  String get sentimentDescription {
    switch (sentimentLabel) {
      case 'positive':
        return '积极';
      case 'negative':
        return '消极';
      default:
        return '中性';
    }
  }

  // 获取对话质量等级
  String get qualityLevel {
    if (satisfactionScore >= 4.5) return '优秀';
    if (satisfactionScore >= 3.5) return '良好';
    if (satisfactionScore >= 2.5) return '一般';
    return '较差';
  }

  // 是否为长对话
  bool get isLongConversation => rounds >= 10;

  // 是否为深度对话
  bool get isDeepConversation => duration >= 15.0;

  // 获取主要话题
  String get primaryTopic => topics.isNotEmpty ? topics.first : '未分类';
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderType; // user, ai
  final String content;
  final DateTime timestamp;
  final double sentimentScore;
  final String sentimentLabel;
  final List<String> keywords;
  final String? intent; // 意图识别
  final Map<String, dynamic> metadata;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.content,
    required this.timestamp,
    required this.sentimentScore,
    required this.sentimentLabel,
    required this.keywords,
    this.intent,
    this.metadata = const {},
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderType: json['senderType'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      sentimentScore: (json['sentimentScore'] ?? 0.0).toDouble(),
      sentimentLabel: json['sentimentLabel'] ?? 'neutral',
      keywords: List<String>.from(json['keywords'] ?? []),
      intent: json['intent'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': senderType,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sentimentScore': sentimentScore,
      'sentimentLabel': sentimentLabel,
      'keywords': keywords,
      'intent': intent,
      'metadata': metadata,
    };
  }

  // 是否为用户消息
  bool get isUserMessage => senderType == 'user';

  // 是否为AI消息
  bool get isAiMessage => senderType == 'ai';

  // 消息长度
  int get length => content.length;
}

// 内容分析统计模型
class ContentAnalysisStats {
  final int totalConversations;
  final int todayConversations;
  final double averageRounds;
  final double positiveSentimentRate;
  final double neutralSentimentRate;
  final double negativeSentimentRate;
  final double averageResponseTime;
  final double userSatisfaction;
  final double conversationCompletionRate;
  final double aiUnderstandingRate;
  final double repetitiveConversationRate;
  final int currentActiveConversations;
  final int messagesPerMinute;
  final int abnormalConversations;
  final int systemLatency;
  final List<int> conversationTrendData;
  final List<double> positiveSentimentTrend;
  final List<double> neutralSentimentTrend;
  final List<double> negativeSentimentTrend;
  final Map<String, double> topicDistribution;
  final Map<String, double> characterPopularity;
  final Map<String, int> topKeywords;

  ContentAnalysisStats({
    required this.totalConversations,
    required this.todayConversations,
    required this.averageRounds,
    required this.positiveSentimentRate,
    required this.neutralSentimentRate,
    required this.negativeSentimentRate,
    required this.averageResponseTime,
    required this.userSatisfaction,
    required this.conversationCompletionRate,
    required this.aiUnderstandingRate,
    required this.repetitiveConversationRate,
    required this.currentActiveConversations,
    required this.messagesPerMinute,
    required this.abnormalConversations,
    required this.systemLatency,
    required this.conversationTrendData,
    required this.positiveSentimentTrend,
    required this.neutralSentimentTrend,
    required this.negativeSentimentTrend,
    required this.topicDistribution,
    required this.characterPopularity,
    required this.topKeywords,
  });

  factory ContentAnalysisStats.fromJson(Map<String, dynamic> json) {
    return ContentAnalysisStats(
      totalConversations: json['totalConversations'] ?? 0,
      todayConversations: json['todayConversations'] ?? 0,
      averageRounds: (json['averageRounds'] ?? 0.0).toDouble(),
      positiveSentimentRate: (json['positiveSentimentRate'] ?? 0.0).toDouble(),
      neutralSentimentRate: (json['neutralSentimentRate'] ?? 0.0).toDouble(),
      negativeSentimentRate: (json['negativeSentimentRate'] ?? 0.0).toDouble(),
      averageResponseTime: (json['averageResponseTime'] ?? 0.0).toDouble(),
      userSatisfaction: (json['userSatisfaction'] ?? 0.0).toDouble(),
      conversationCompletionRate: (json['conversationCompletionRate'] ?? 0.0).toDouble(),
      aiUnderstandingRate: (json['aiUnderstandingRate'] ?? 0.0).toDouble(),
      repetitiveConversationRate: (json['repetitiveConversationRate'] ?? 0.0).toDouble(),
      currentActiveConversations: json['currentActiveConversations'] ?? 0,
      messagesPerMinute: json['messagesPerMinute'] ?? 0,
      abnormalConversations: json['abnormalConversations'] ?? 0,
      systemLatency: json['systemLatency'] ?? 0,
      conversationTrendData: List<int>.from(json['conversationTrendData'] ?? []),
      positiveSentimentTrend: List<double>.from(json['positiveSentimentTrend'] ?? []),
      neutralSentimentTrend: List<double>.from(json['neutralSentimentTrend'] ?? []),
      negativeSentimentTrend: List<double>.from(json['negativeSentimentTrend'] ?? []),
      topicDistribution: Map<String, double>.from(json['topicDistribution'] ?? {}),
      characterPopularity: Map<String, double>.from(json['characterPopularity'] ?? {}),
      topKeywords: Map<String, int>.from(json['topKeywords'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConversations': totalConversations,
      'todayConversations': todayConversations,
      'averageRounds': averageRounds,
      'positiveSentimentRate': positiveSentimentRate,
      'neutralSentimentRate': neutralSentimentRate,
      'negativeSentimentRate': negativeSentimentRate,
      'averageResponseTime': averageResponseTime,
      'userSatisfaction': userSatisfaction,
      'conversationCompletionRate': conversationCompletionRate,
      'aiUnderstandingRate': aiUnderstandingRate,
      'repetitiveConversationRate': repetitiveConversationRate,
      'currentActiveConversations': currentActiveConversations,
      'messagesPerMinute': messagesPerMinute,
      'abnormalConversations': abnormalConversations,
      'systemLatency': systemLatency,
      'conversationTrendData': conversationTrendData,
      'positiveSentimentTrend': positiveSentimentTrend,
      'neutralSentimentTrend': neutralSentimentTrend,
      'negativeSentimentTrend': negativeSentimentTrend,
      'topicDistribution': topicDistribution,
      'characterPopularity': characterPopularity,
      'topKeywords': topKeywords,
    };
  }
}