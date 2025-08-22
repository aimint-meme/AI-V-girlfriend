class GirlfriendModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String personality;
  final String description;
  final int intimacy;
  final bool isPremium;
  final Map<String, dynamic> traits;
  final DateTime? lastMessageTime;
  final String? lastMessage;
  final bool isOnline;
  final bool? isCreatedByUser;
  final DateTime? createdAt;
  final bool usePublicKnowledge;
  final String? background;
  final String? introduction;
  final String? voiceType;
  final String? chatMode;
  final String? novelCharacter;
  final String? race;
  final String? eyeColor;
  final String? hairstyle;
  final String? hairColor;
  final String? bodyType;
  final String? cupSize;
  final String? hipSize;
  final List<String>? secondaryPersonalityIds; // 第二人格ID列表
  final String? activeSecondaryPersonalityId; // 当前激活的第二人格ID
  final Map<String, dynamic>? personalityMixConfig; // 人格混合配置
  final bool isVirtual; // 是否为虚拟女友，false表示真实女友
  final List<String> tags; // 角色标签

  GirlfriendModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.personality,
    required this.description,
    this.intimacy = 0,
    this.isPremium = false,
    this.traits = const {},
    this.lastMessageTime,
    this.lastMessage,
    this.isOnline = false,
    this.isCreatedByUser,
    this.createdAt,
    this.usePublicKnowledge = false,
    this.background,
    this.introduction,
    this.voiceType,
    this.chatMode,
    this.novelCharacter,
    this.race,
    this.eyeColor,
    this.hairstyle,
    this.hairColor,
    this.bodyType,
    this.cupSize,
    this.hipSize,
    this.secondaryPersonalityIds,
    this.activeSecondaryPersonalityId,
    this.personalityMixConfig,
    this.isVirtual = true, // 默认为虚拟女友
    this.tags = const [], // 默认为空标签列表
  });

  factory GirlfriendModel.fromJson(Map<String, dynamic> json) {
    return GirlfriendModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      personality: json['personality'],
      description: json['description'],
      intimacy: json['intimacy'] ?? 0,
      isPremium: json['is_premium'] ?? false,
      traits: json['traits'] ?? {},
      lastMessageTime: json['last_message_time'] != null 
          ? DateTime.parse(json['last_message_time']) 
          : null,
      lastMessage: json['last_message'],
      isOnline: json['is_online'] ?? false,
      isCreatedByUser: json['is_created_by_user'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      usePublicKnowledge: json['use_public_knowledge'] ?? false,
      background: json['background'],
      introduction: json['introduction'],
      voiceType: json['voice_type'],
      chatMode: json['chat_mode'],
      novelCharacter: json['novel_character'],
      race: json['race'],
      eyeColor: json['eye_color'],
      hairstyle: json['hairstyle'],
      hairColor: json['hair_color'],
      bodyType: json['body_type'],
      cupSize: json['cup_size'],
      hipSize: json['hip_size'],
      secondaryPersonalityIds: json['secondary_personality_ids'] != null 
          ? List<String>.from(json['secondary_personality_ids']) 
          : null,
      activeSecondaryPersonalityId: json['active_secondary_personality_id'],
      personalityMixConfig: json['personality_mix_config'],
      isVirtual: json['is_virtual'] ?? true,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'personality': personality,
      'description': description,
      'intimacy': intimacy,
      'is_premium': isPremium,
      'traits': traits,
      'last_message_time': lastMessageTime?.toIso8601String(),
      'last_message': lastMessage,
      'is_online': isOnline,
      'is_created_by_user': isCreatedByUser,
      'created_at': createdAt?.toIso8601String(),
      'use_public_knowledge': usePublicKnowledge,
      'background': background,
      'introduction': introduction,
      'voice_type': voiceType,
      'chat_mode': chatMode,
      'novel_character': novelCharacter,
      'race': race,
      'eye_color': eyeColor,
      'hairstyle': hairstyle,
      'hair_color': hairColor,
      'body_type': bodyType,
      'cup_size': cupSize,
      'hip_size': hipSize,
      'secondary_personality_ids': secondaryPersonalityIds,
      'active_secondary_personality_id': activeSecondaryPersonalityId,
      'personality_mix_config': personalityMixConfig,
      'is_virtual': isVirtual,
      'tags': tags,
    };
  }

  GirlfriendModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? personality,
    String? description,
    int? intimacy,
    bool? isPremium,
    Map<String, dynamic>? traits,
    DateTime? lastMessageTime,
    String? lastMessage,
    bool? isOnline,
    bool? isCreatedByUser,
    DateTime? createdAt,
    bool? usePublicKnowledge,
    String? background,
    String? introduction,
    String? voiceType,
    String? chatMode,
    String? novelCharacter,
    String? race,
    String? eyeColor,
    String? hairstyle,
    String? hairColor,
    String? bodyType,
    String? cupSize,
    String? hipSize,
    List<String>? secondaryPersonalityIds,
    String? activeSecondaryPersonalityId,
    Map<String, dynamic>? personalityMixConfig,
    bool? isVirtual,
    List<String>? tags,
  }) {
    return GirlfriendModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      personality: personality ?? this.personality,
      description: description ?? this.description,
      intimacy: intimacy ?? this.intimacy,
      isPremium: isPremium ?? this.isPremium,
      traits: traits ?? this.traits,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessage: lastMessage ?? this.lastMessage,
      isOnline: isOnline ?? this.isOnline,
      isCreatedByUser: isCreatedByUser ?? this.isCreatedByUser,
      createdAt: createdAt ?? this.createdAt,
      usePublicKnowledge: usePublicKnowledge ?? this.usePublicKnowledge,
      background: background ?? this.background,
      introduction: introduction ?? this.introduction,
      voiceType: voiceType ?? this.voiceType,
      chatMode: chatMode ?? this.chatMode,
      novelCharacter: novelCharacter ?? this.novelCharacter,
      race: race ?? this.race,
      eyeColor: eyeColor ?? this.eyeColor,
      hairstyle: hairstyle ?? this.hairstyle,
      hairColor: hairColor ?? this.hairColor,
      bodyType: bodyType ?? this.bodyType,
      cupSize: cupSize ?? this.cupSize,
      hipSize: hipSize ?? this.hipSize,
      secondaryPersonalityIds: secondaryPersonalityIds ?? this.secondaryPersonalityIds,
      activeSecondaryPersonalityId: activeSecondaryPersonalityId ?? this.activeSecondaryPersonalityId,
      personalityMixConfig: personalityMixConfig ?? this.personalityMixConfig,
      isVirtual: isVirtual ?? this.isVirtual,
      tags: tags ?? this.tags,
    );
  }
}