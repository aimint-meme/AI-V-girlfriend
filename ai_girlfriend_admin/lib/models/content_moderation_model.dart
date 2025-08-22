class SensitiveKeyword {
  final String id;
  final String word;
  final String category; // 政治敏感、色情低俗、暴力血腥、违法犯罪、其他
  final String severity; // 高、中、低
  final bool isActive;
  final int detectionCount;
  final List<String> aliases; // 别名和变体
  final String regex; // 正则表达式
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  SensitiveKeyword({
    required this.id,
    required this.word,
    required this.category,
    required this.severity,
    required this.isActive,
    this.detectionCount = 0,
    this.aliases = const [],
    this.regex = '',
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
  });

  factory SensitiveKeyword.fromJson(Map<String, dynamic> json) {
    return SensitiveKeyword(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      category: json['category'] ?? '其他',
      severity: json['severity'] ?? '中',
      isActive: json['isActive'] ?? true,
      detectionCount: json['detectionCount'] ?? 0,
      aliases: List<String>.from(json['aliases'] ?? []),
      regex: json['regex'] ?? '',
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'category': category,
      'severity': severity,
      'isActive': isActive,
      'detectionCount': detectionCount,
      'aliases': aliases,
      'regex': regex,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  SensitiveKeyword copyWith({
    String? id,
    String? word,
    String? category,
    String? severity,
    bool? isActive,
    int? detectionCount,
    List<String>? aliases,
    String? regex,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return SensitiveKeyword(
      id: id ?? this.id,
      word: word ?? this.word,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      isActive: isActive ?? this.isActive,
      detectionCount: detectionCount ?? this.detectionCount,
      aliases: aliases ?? this.aliases,
      regex: regex ?? this.regex,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // 获取风险等级
  int get riskLevel {
    switch (severity) {
      case '高':
        return 3;
      case '中':
        return 2;
      case '低':
        return 1;
      default:
        return 0;
    }
  }

  // 是否为热门敏感词
  bool get isPopular => detectionCount > 100;

  // 获取严重程度描述
  String get severityDescription {
    switch (severity) {
      case '高':
        return '严重违规，立即处理';
      case '中':
        return '中等风险，需要关注';
      case '低':
        return '轻微风险，记录备案';
      default:
        return '未知风险等级';
    }
  }
}

// 违规记录
class ViolationRecord {
  final String id;
  final String userId;
  final String content;
  final String contentType; // text, image, video, audio
  final List<String> matchedKeywords;
  final String category;
  final String severity;
  final int riskScore; // 0-100
  final String status; // 待处理、已处理、已忽略
  final String action; // 警告、禁言、封号、删除内容
  final String handledBy;
  final DateTime detectedAt;
  final DateTime? handledAt;
  final Map<String, dynamic> context; // 上下文信息
  final Map<String, dynamic> metadata;

  ViolationRecord({
    required this.id,
    required this.userId,
    required this.content,
    required this.contentType,
    required this.matchedKeywords,
    required this.category,
    required this.severity,
    required this.riskScore,
    required this.status,
    this.action = '',
    this.handledBy = '',
    required this.detectedAt,
    this.handledAt,
    this.context = const {},
    this.metadata = const {},
  });

  factory ViolationRecord.fromJson(Map<String, dynamic> json) {
    return ViolationRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      content: json['content'] ?? '',
      contentType: json['contentType'] ?? 'text',
      matchedKeywords: List<String>.from(json['matchedKeywords'] ?? []),
      category: json['category'] ?? '其他',
      severity: json['severity'] ?? '中',
      riskScore: json['riskScore'] ?? 0,
      status: json['status'] ?? '待处理',
      action: json['action'] ?? '',
      handledBy: json['handledBy'] ?? '',
      detectedAt: DateTime.parse(json['detectedAt'] ?? DateTime.now().toIso8601String()),
      handledAt: json['handledAt'] != null ? DateTime.parse(json['handledAt']) : null,
      context: json['context'] ?? {},
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'contentType': contentType,
      'matchedKeywords': matchedKeywords,
      'category': category,
      'severity': severity,
      'riskScore': riskScore,
      'status': status,
      'action': action,
      'handledBy': handledBy,
      'detectedAt': detectedAt.toIso8601String(),
      'handledAt': handledAt?.toIso8601String(),
      'context': context,
      'metadata': metadata,
    };
  }

  ViolationRecord copyWith({
    String? id,
    String? userId,
    String? content,
    String? contentType,
    List<String>? matchedKeywords,
    String? category,
    String? severity,
    int? riskScore,
    String? status,
    String? action,
    String? handledBy,
    DateTime? detectedAt,
    DateTime? handledAt,
    Map<String, dynamic>? context,
    Map<String, dynamic>? metadata,
  }) {
    return ViolationRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      matchedKeywords: matchedKeywords ?? this.matchedKeywords,
      category: category ?? this.category,
      severity: severity ?? this.severity,
      riskScore: riskScore ?? this.riskScore,
      status: status ?? this.status,
      action: action ?? this.action,
      handledBy: handledBy ?? this.handledBy,
      detectedAt: detectedAt ?? this.detectedAt,
      handledAt: handledAt ?? this.handledAt,
      context: context ?? this.context,
      metadata: metadata ?? this.metadata,
    );
  }

  // 是否已处理
  bool get isHandled => status == '已处理';

  // 是否为高风险
  bool get isHighRisk => riskScore >= 80;

  // 获取处理时长
  Duration? get handlingDuration {
    if (handledAt == null) return null;
    return handledAt!.difference(detectedAt);
  }

  // 获取风险等级描述
  String get riskLevelDescription {
    if (riskScore >= 90) return '极高风险';
    if (riskScore >= 80) return '高风险';
    if (riskScore >= 60) return '中等风险';
    if (riskScore >= 40) return '低风险';
    return '极低风险';
  }
}

// 检测规则
class DetectionRule {
  final String id;
  final String name;
  final String description;
  final String type; // keyword, regex, ai, custom
  final bool isEnabled;
  final int priority; // 优先级，数字越大优先级越高
  final double threshold; // 阈值
  final String action; // block, warn, log, review
  final Map<String, dynamic> conditions; // 规则条件
  final Map<String, dynamic> config; // 规则配置
  final int matchCount; // 匹配次数
  final double accuracy; // 准确率
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  DetectionRule({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isEnabled,
    required this.priority,
    required this.threshold,
    required this.action,
    this.conditions = const {},
    this.config = const {},
    this.matchCount = 0,
    this.accuracy = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
  });

  factory DetectionRule.fromJson(Map<String, dynamic> json) {
    return DetectionRule(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'keyword',
      isEnabled: json['isEnabled'] ?? true,
      priority: json['priority'] ?? 1,
      threshold: (json['threshold'] ?? 0.5).toDouble(),
      action: json['action'] ?? 'log',
      conditions: json['conditions'] ?? {},
      config: json['config'] ?? {},
      matchCount: json['matchCount'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'isEnabled': isEnabled,
      'priority': priority,
      'threshold': threshold,
      'action': action,
      'conditions': conditions,
      'config': config,
      'matchCount': matchCount,
      'accuracy': accuracy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  DetectionRule copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    bool? isEnabled,
    int? priority,
    double? threshold,
    String? action,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? config,
    int? matchCount,
    double? accuracy,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return DetectionRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isEnabled: isEnabled ?? this.isEnabled,
      priority: priority ?? this.priority,
      threshold: threshold ?? this.threshold,
      action: action ?? this.action,
      conditions: conditions ?? this.conditions,
      config: config ?? this.config,
      matchCount: matchCount ?? this.matchCount,
      accuracy: accuracy ?? this.accuracy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  // 获取效率评分
  double get efficiencyScore {
    if (matchCount == 0) return 0.0;
    return accuracy * (matchCount / 100.0).clamp(0.0, 1.0);
  }

  // 是否为高效规则
  bool get isEfficient => efficiencyScore > 0.8;

  // 获取动作描述
  String get actionDescription {
    switch (action) {
      case 'block':
        return '阻止发布';
      case 'warn':
        return '警告用户';
      case 'log':
        return '记录日志';
      case 'review':
        return '人工审核';
      default:
        return '未知动作';
    }
  }
}

// 活动记录
class ActivityRecord {
  final String id;
  final String action;
  final String target;
  final String operator;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  ActivityRecord({
    required this.id,
    required this.action,
    required this.target,
    required this.operator,
    required this.timestamp,
    this.details = const {},
  });

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      target: json['target'] ?? '',
      operator: json['operator'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'target': target,
      'operator': operator,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }
}

// 内容审核统计
class ContentModerationStats {
  final int totalKeywords;
  final int activeKeywords;
  final int totalDetections;
  final int todayDetections;
  final int totalViolations;
  final int todayViolations;
  final double blockRate;
  final double falsePositiveRate;
  final int avgResponseTime;
  final Map<String, int> categoryDistribution;
  final Map<String, int> severityDistribution;
  final List<SensitiveKeyword> topKeywords;
  final List<ActivityRecord> recentActivities;

  ContentModerationStats({
    required this.totalKeywords,
    required this.activeKeywords,
    required this.totalDetections,
    required this.todayDetections,
    required this.totalViolations,
    required this.todayViolations,
    required this.blockRate,
    required this.falsePositiveRate,
    required this.avgResponseTime,
    required this.categoryDistribution,
    required this.severityDistribution,
    required this.topKeywords,
    required this.recentActivities,
  });

  factory ContentModerationStats.fromJson(Map<String, dynamic> json) {
    return ContentModerationStats(
      totalKeywords: json['totalKeywords'] ?? 0,
      activeKeywords: json['activeKeywords'] ?? 0,
      totalDetections: json['totalDetections'] ?? 0,
      todayDetections: json['todayDetections'] ?? 0,
      totalViolations: json['totalViolations'] ?? 0,
      todayViolations: json['todayViolations'] ?? 0,
      blockRate: (json['blockRate'] ?? 0.0).toDouble(),
      falsePositiveRate: (json['falsePositiveRate'] ?? 0.0).toDouble(),
      avgResponseTime: json['avgResponseTime'] ?? 0,
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
      severityDistribution: Map<String, int>.from(json['severityDistribution'] ?? {}),
      topKeywords: (json['topKeywords'] as List<dynamic>? ?? [])
          .map((e) => SensitiveKeyword.fromJson(e))
          .toList(),
      recentActivities: (json['recentActivities'] as List<dynamic>? ?? [])
          .map((e) => ActivityRecord.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalKeywords': totalKeywords,
      'activeKeywords': activeKeywords,
      'totalDetections': totalDetections,
      'todayDetections': todayDetections,
      'totalViolations': totalViolations,
      'todayViolations': todayViolations,
      'blockRate': blockRate,
      'falsePositiveRate': falsePositiveRate,
      'avgResponseTime': avgResponseTime,
      'categoryDistribution': categoryDistribution,
      'severityDistribution': severityDistribution,
      'topKeywords': topKeywords.map((e) => e.toJson()).toList(),
      'recentActivities': recentActivities.map((e) => e.toJson()).toList(),
    };
  }

  // 获取检测效率
  double get detectionEfficiency {
    if (totalDetections == 0) return 0.0;
    return (totalViolations / totalDetections) * 100;
  }

  // 获取系统健康度
  String get systemHealth {
    if (falsePositiveRate > 20) return '需要优化';
    if (falsePositiveRate > 10) return '一般';
    if (falsePositiveRate > 5) return '良好';
    return '优秀';
  }

  // 获取响应速度等级
  String get responseSpeedLevel {
    if (avgResponseTime < 100) return '极快';
    if (avgResponseTime < 500) return '快速';
    if (avgResponseTime < 1000) return '正常';
    return '较慢';
  }
}