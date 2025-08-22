class CharacterModel {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String type; // 温柔型、活泼型、知性型、冷酷型、可爱型
  final String status; // 活跃、禁用、开发中
  final List<String> tags;
  final Map<String, dynamic> personality; // 性格参数
  final Map<String, dynamic> appearance; // 外观设定
  final Map<String, dynamic> background; // 背景故事
  final List<String> skills; // 技能列表
  final Map<String, dynamic> preferences; // 偏好设定
  final String voiceId; // 关联的语音ID
  final List<String> sceneIds; // 关联的场景ID列表
  final String modelId; // 关联的模型ID
  final int usageCount; // 使用次数
  final double rating; // 用户评分
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    this.avatar = '',
    required this.type,
    required this.status,
    this.tags = const [],
    this.personality = const {},
    this.appearance = const {},
    this.background = const {},
    this.skills = const [],
    this.preferences = const {},
    this.voiceId = '',
    this.sceneIds = const [],
    this.modelId = '',
    this.usageCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
    this.metadata = const {},
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      type: json['type'] ?? '温柔型',
      status: json['status'] ?? '开发中',
      tags: List<String>.from(json['tags'] ?? []),
      personality: json['personality'] ?? {},
      appearance: json['appearance'] ?? {},
      background: json['background'] ?? {},
      skills: List<String>.from(json['skills'] ?? []),
      preferences: json['preferences'] ?? {},
      voiceId: json['voiceId'] ?? '',
      sceneIds: List<String>.from(json['sceneIds'] ?? []),
      modelId: json['modelId'] ?? '',
      usageCount: json['usageCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'type': type,
      'status': status,
      'tags': tags,
      'personality': personality,
      'appearance': appearance,
      'background': background,
      'skills': skills,
      'preferences': preferences,
      'voiceId': voiceId,
      'sceneIds': sceneIds,
      'modelId': modelId,
      'usageCount': usageCount,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  CharacterModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    String? type,
    String? status,
    List<String>? tags,
    Map<String, dynamic>? personality,
    Map<String, dynamic>? appearance,
    Map<String, dynamic>? background,
    List<String>? skills,
    Map<String, dynamic>? preferences,
    String? voiceId,
    List<String>? sceneIds,
    String? modelId,
    int? usageCount,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      personality: personality ?? this.personality,
      appearance: appearance ?? this.appearance,
      background: background ?? this.background,
      skills: skills ?? this.skills,
      preferences: preferences ?? this.preferences,
      voiceId: voiceId ?? this.voiceId,
      sceneIds: sceneIds ?? this.sceneIds,
      modelId: modelId ?? this.modelId,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  // 是否为活跃状态
  bool get isActive => status == '活跃';

  // 是否为热门角色
  bool get isPopular => usageCount > 1000;

  // 获取性格特征描述
  String get personalityDescription {
    final traits = <String>[];
    if (personality['温柔度'] != null && personality['温柔度'] > 70) traits.add('温柔');
    if (personality['活泼度'] != null && personality['活泼度'] > 70) traits.add('活泼');
    if (personality['智慧度'] != null && personality['智慧度'] > 70) traits.add('聪明');
    if (personality['幽默感'] != null && personality['幽默感'] > 70) traits.add('幽默');
    return traits.isEmpty ? '暂无特征' : traits.join('、');
  }

  // 获取评分等级
  String get ratingLevel {
    if (rating >= 4.5) return '优秀';
    if (rating >= 4.0) return '良好';
    if (rating >= 3.0) return '一般';
    return '待改进';
  }
}

// 模型配置
class ModelConfig {
  final String id;
  final String name;
  final String description;
  final String type; // GPT-3.5, GPT-4, Claude, etc.
  final String version;
  final String endpoint;
  final Map<String, dynamic> parameters;
  final double temperature;
  final int maxTokens;
  final bool isOnline;
  final int avgResponseTime; // 毫秒
  final double successRate; // 成功率
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  ModelConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.version,
    required this.endpoint,
    this.parameters = const {},
    required this.temperature,
    required this.maxTokens,
    required this.isOnline,
    required this.avgResponseTime,
    required this.successRate,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      version: json['version'] ?? '',
      endpoint: json['endpoint'] ?? '',
      parameters: json['parameters'] ?? {},
      temperature: (json['temperature'] ?? 0.7).toDouble(),
      maxTokens: json['maxTokens'] ?? 2048,
      isOnline: json['isOnline'] ?? false,
      avgResponseTime: json['avgResponseTime'] ?? 1000,
      successRate: (json['successRate'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'version': version,
      'endpoint': endpoint,
      'parameters': parameters,
      'temperature': temperature,
      'maxTokens': maxTokens,
      'isOnline': isOnline,
      'avgResponseTime': avgResponseTime,
      'successRate': successRate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // 获取性能等级
  String get performanceLevel {
    if (avgResponseTime < 500 && successRate > 95) return '优秀';
    if (avgResponseTime < 1000 && successRate > 90) return '良好';
    if (avgResponseTime < 2000 && successRate > 80) return '一般';
    return '需优化';
  }
}

// 语音模型
class VoiceModel {
  final String id;
  final String name;
  final String description;
  final String type; // 甜美、成熟、活泼、知性
  final String gender; // 男、女
  final String language; // zh-CN, en-US, etc.
  final String audioUrl;
  final int duration; // 秒
  final int sampleRate;
  final String format; // mp3, wav, etc.
  final bool isAvailable;
  final int usageCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  VoiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.gender,
    required this.language,
    required this.audioUrl,
    required this.duration,
    required this.sampleRate,
    required this.format,
    required this.isAvailable,
    this.usageCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      gender: json['gender'] ?? '',
      language: json['language'] ?? 'zh-CN',
      audioUrl: json['audioUrl'] ?? '',
      duration: json['duration'] ?? 0,
      sampleRate: json['sampleRate'] ?? 44100,
      format: json['format'] ?? 'mp3',
      isAvailable: json['isAvailable'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'gender': gender,
      'language': language,
      'audioUrl': audioUrl,
      'duration': duration,
      'sampleRate': sampleRate,
      'format': format,
      'isAvailable': isAvailable,
      'usageCount': usageCount,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // 获取质量等级
  String get qualityLevel {
    if (sampleRate >= 44100 && rating >= 4.5) return '高品质';
    if (sampleRate >= 22050 && rating >= 4.0) return '标准';
    return '基础';
  }
}

// 场景模型
class SceneModel {
  final String id;
  final String name;
  final String description;
  final String category; // 日常、浪漫、冒险、学习等
  final String thumbnail;
  final List<String> backgrounds; // 背景图片列表
  final Map<String, dynamic> settings; // 场景设定
  final List<String> props; // 道具列表
  final Map<String, dynamic> atmosphere; // 氛围设定
  final List<String> musicIds; // 背景音乐ID列表
  final bool isEnabled;
  final int usageCount;
  final double rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  SceneModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.thumbnail = '',
    this.backgrounds = const [],
    this.settings = const {},
    this.props = const [],
    this.atmosphere = const {},
    this.musicIds = const [],
    required this.isEnabled,
    this.usageCount = 0,
    this.rating = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
    this.metadata = const {},
  });

  factory SceneModel.fromJson(Map<String, dynamic> json) {
    return SceneModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      backgrounds: List<String>.from(json['backgrounds'] ?? []),
      settings: json['settings'] ?? {},
      props: List<String>.from(json['props'] ?? []),
      atmosphere: json['atmosphere'] ?? {},
      musicIds: List<String>.from(json['musicIds'] ?? []),
      isEnabled: json['isEnabled'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      createdBy: json['createdBy'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'thumbnail': thumbnail,
      'backgrounds': backgrounds,
      'settings': settings,
      'props': props,
      'atmosphere': atmosphere,
      'musicIds': musicIds,
      'isEnabled': isEnabled,
      'usageCount': usageCount,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  // 是否为热门场景
  bool get isPopular => usageCount > 500;

  // 获取复杂度等级
  String get complexityLevel {
    final complexity = backgrounds.length + props.length + musicIds.length;
    if (complexity > 10) return '复杂';
    if (complexity > 5) return '中等';
    return '简单';
  }
}

// 角色配置统计
class CharacterConfigStats {
  final int totalCharacters;
  final int activeCharacters;
  final int totalModels;
  final int onlineModels;
  final int totalVoices;
  final int availableVoices;
  final int totalScenes;
  final int enabledScenes;
  final Map<String, int> characterTypeDistribution;
  final Map<String, int> modelTypeDistribution;
  final Map<String, int> voiceTypeDistribution;
  final Map<String, int> sceneTypeDistribution;

  CharacterConfigStats({
    required this.totalCharacters,
    required this.activeCharacters,
    required this.totalModels,
    required this.onlineModels,
    required this.totalVoices,
    required this.availableVoices,
    required this.totalScenes,
    required this.enabledScenes,
    required this.characterTypeDistribution,
    required this.modelTypeDistribution,
    required this.voiceTypeDistribution,
    required this.sceneTypeDistribution,
  });

  factory CharacterConfigStats.fromJson(Map<String, dynamic> json) {
    return CharacterConfigStats(
      totalCharacters: json['totalCharacters'] ?? 0,
      activeCharacters: json['activeCharacters'] ?? 0,
      totalModels: json['totalModels'] ?? 0,
      onlineModels: json['onlineModels'] ?? 0,
      totalVoices: json['totalVoices'] ?? 0,
      availableVoices: json['availableVoices'] ?? 0,
      totalScenes: json['totalScenes'] ?? 0,
      enabledScenes: json['enabledScenes'] ?? 0,
      characterTypeDistribution: Map<String, int>.from(json['characterTypeDistribution'] ?? {}),
      modelTypeDistribution: Map<String, int>.from(json['modelTypeDistribution'] ?? {}),
      voiceTypeDistribution: Map<String, int>.from(json['voiceTypeDistribution'] ?? {}),
      sceneTypeDistribution: Map<String, int>.from(json['sceneTypeDistribution'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCharacters': totalCharacters,
      'activeCharacters': activeCharacters,
      'totalModels': totalModels,
      'onlineModels': onlineModels,
      'totalVoices': totalVoices,
      'availableVoices': availableVoices,
      'totalScenes': totalScenes,
      'enabledScenes': enabledScenes,
      'characterTypeDistribution': characterTypeDistribution,
      'modelTypeDistribution': modelTypeDistribution,
      'voiceTypeDistribution': voiceTypeDistribution,
      'sceneTypeDistribution': sceneTypeDistribution,
    };
  }
}