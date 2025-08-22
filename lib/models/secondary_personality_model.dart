class SecondaryPersonalityModel {
  final String id;
  final String name;
  final String description;
  final String personalityType; // 人格类型：温柔、冷酷、知性等
  final String knowledgeBaseId; // 绑定的知识库ID
  final String membershipLevel; // 会员等级要求：free, premium, vip
  final bool isActive; // 是否激活
  final double influenceWeight; // 影响权重 0.0-1.0
  final Map<String, dynamic> personalityTraits; // 人格特征
  final List<String> triggerKeywords; // 触发关键词
  final String responseStyle; // 回复风格
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SecondaryPersonalityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.personalityType,
    required this.knowledgeBaseId,
    this.membershipLevel = 'free',
    this.isActive = true,
    this.influenceWeight = 0.5,
    this.personalityTraits = const {},
    this.triggerKeywords = const [],
    this.responseStyle = 'balanced',
    this.createdAt,
    this.updatedAt,
  });

  factory SecondaryPersonalityModel.fromJson(Map<String, dynamic> json) {
    return SecondaryPersonalityModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      personalityType: json['personality_type'],
      knowledgeBaseId: json['knowledge_base_id'],
      membershipLevel: json['membership_level'] ?? 'free',
      isActive: json['is_active'] ?? true,
      influenceWeight: (json['influence_weight'] ?? 0.5).toDouble(),
      personalityTraits: json['personality_traits'] ?? {},
      triggerKeywords: List<String>.from(json['trigger_keywords'] ?? []),
      responseStyle: json['response_style'] ?? 'balanced',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'personality_type': personalityType,
      'knowledge_base_id': knowledgeBaseId,
      'membership_level': membershipLevel,
      'is_active': isActive,
      'influence_weight': influenceWeight,
      'personality_traits': personalityTraits,
      'trigger_keywords': triggerKeywords,
      'response_style': responseStyle,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  SecondaryPersonalityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? personalityType,
    String? knowledgeBaseId,
    String? membershipLevel,
    bool? isActive,
    double? influenceWeight,
    Map<String, dynamic>? personalityTraits,
    List<String>? triggerKeywords,
    String? responseStyle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SecondaryPersonalityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personalityType: personalityType ?? this.personalityType,
      knowledgeBaseId: knowledgeBaseId ?? this.knowledgeBaseId,
      membershipLevel: membershipLevel ?? this.membershipLevel,
      isActive: isActive ?? this.isActive,
      influenceWeight: influenceWeight ?? this.influenceWeight,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      triggerKeywords: triggerKeywords ?? this.triggerKeywords,
      responseStyle: responseStyle ?? this.responseStyle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // 检查是否满足会员等级要求
  bool checkMembershipRequirement(String userMembershipLevel) {
    const levelHierarchy = {
      'free': 0,
      'premium': 1,
      'vip': 2,
    };
    
    final requiredLevel = levelHierarchy[membershipLevel] ?? 0;
    final userLevel = levelHierarchy[userMembershipLevel] ?? 0;
    
    return userLevel >= requiredLevel;
  }

  // 检查是否应该被触发
  bool shouldTrigger(String message) {
    if (!isActive) return false;
    
    final lowerMessage = message.toLowerCase();
    return triggerKeywords.any((keyword) => 
        lowerMessage.contains(keyword.toLowerCase()));
  }
}

// 预设的第二人格模板
class SecondaryPersonalityTemplates {
  static final Map<String, Map<String, dynamic>> templates = {
    '知性学者': {
      'name': '知性学者',
      'description': '拥有丰富学识的理性人格，善于分析和解答复杂问题',
      'personalityType': '知性',
      'membershipLevel': 'premium',
      'personalityTraits': {
        'intelligence': 0.9,
        'rationality': 0.8,
        'patience': 0.7,
        'curiosity': 0.8,
      },
      'triggerKeywords': ['学习', '知识', '研究', '分析', '解释', '原理', '理论'],
      'responseStyle': 'analytical',
    },
    '温柔治愈': {
      'name': '温柔治愈',
      'description': '温暖贴心的治愈系人格，专注于情感支持和心理安慰',
      'personalityType': '温柔',
      'membershipLevel': 'free',
      'personalityTraits': {
        'empathy': 0.9,
        'gentleness': 0.9,
        'supportiveness': 0.8,
        'patience': 0.8,
      },
      'triggerKeywords': ['难过', '伤心', '安慰', '支持', '理解', '倾听'],
      'responseStyle': 'supportive',
    },
    '活泼开朗': {
      'name': '活泼开朗',
      'description': '充满活力的阳光人格，带来快乐和正能量',
      'personalityType': '活泼',
      'membershipLevel': 'free',
      'personalityTraits': {
        'energy': 0.9,
        'optimism': 0.9,
        'humor': 0.8,
        'enthusiasm': 0.8,
      },
      'triggerKeywords': ['开心', '快乐', '有趣', '好玩', '兴奋', '惊喜'],
      'responseStyle': 'energetic',
    },
    '冷酷御姐': {
      'name': '冷酷御姐',
      'description': '高冷强势的御姐人格，理性冷静且具有领导力',
      'personalityType': '冷酷',
      'membershipLevel': 'vip',
      'personalityTraits': {
        'dominance': 0.8,
        'confidence': 0.9,
        'independence': 0.8,
        'rationality': 0.8,
      },
      'triggerKeywords': ['决定', '选择', '建议', '意见', '判断', '分析'],
      'responseStyle': 'authoritative',
    },
    '神秘魅惑': {
      'name': '神秘魅惑',
      'description': '充满神秘感的魅惑人格，善于营造氛围和情调',
      'personalityType': '神秘',
      'membershipLevel': 'vip',
      'personalityTraits': {
        'mystery': 0.9,
        'charm': 0.8,
        'intuition': 0.8,
        'creativity': 0.7,
      },
      'triggerKeywords': ['秘密', '神秘', '想象', '梦想', '浪漫', '诗意'],
      'responseStyle': 'mysterious',
    },
  };

  static SecondaryPersonalityModel createFromTemplate(
    String templateName, 
    String knowledgeBaseId
  ) {
    final template = templates[templateName];
    if (template == null) {
      throw ArgumentError('Unknown template: $templateName');
    }

    return SecondaryPersonalityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: template['name'],
      description: template['description'],
      personalityType: template['personalityType'],
      knowledgeBaseId: knowledgeBaseId,
      membershipLevel: template['membershipLevel'],
      personalityTraits: Map<String, dynamic>.from(template['personalityTraits']),
      triggerKeywords: List<String>.from(template['triggerKeywords']),
      responseStyle: template['responseStyle'],
      createdAt: DateTime.now(),
    );
  }
}