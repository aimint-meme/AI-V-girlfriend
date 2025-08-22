class ThemeModel {
  final String id;
  final String name;
  final String description;
  final String category; // 节日、季节、特殊活动、常规主题
  final String status; // 活跃、禁用、草稿、已过期
  final String previewImage;
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final Map<String, String> colorScheme;
  final List<String> assets; // 资源文件列表
  final Map<String, dynamic> config; // 主题配置
  final DateTime startDate;
  final DateTime endDate;
  final bool isLimited; // 是否限时主题
  final int usageCount;
  final double rating;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final Map<String, dynamic> metadata;

  ThemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    this.previewImage = '',
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.colorScheme = const {},
    this.assets = const [],
    this.config = const {},
    required this.startDate,
    required this.endDate,
    this.isLimited = false,
    this.usageCount = 0,
    this.rating = 0.0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
    this.metadata = const {},
  });

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '常规主题',
      status: json['status'] ?? '草稿',
      previewImage: json['previewImage'] ?? '',
      primaryColor: json['primaryColor'] ?? '#6366F1',
      secondaryColor: json['secondaryColor'] ?? '#8B5CF6',
      accentColor: json['accentColor'] ?? '#F59E0B',
      colorScheme: Map<String, String>.from(json['colorScheme'] ?? {}),
      assets: List<String>.from(json['assets'] ?? []),
      config: json['config'] ?? {},
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String()),
      isLimited: json['isLimited'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
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
      'status': status,
      'previewImage': previewImage,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'colorScheme': colorScheme,
      'assets': assets,
      'config': config,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isLimited': isLimited,
      'usageCount': usageCount,
      'rating': rating,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'metadata': metadata,
    };
  }

  ThemeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? status,
    String? previewImage,
    String? primaryColor,
    String? secondaryColor,
    String? accentColor,
    Map<String, String>? colorScheme,
    List<String>? assets,
    Map<String, dynamic>? config,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLimited,
    int? usageCount,
    double? rating,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    Map<String, dynamic>? metadata,
  }) {
    return ThemeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      previewImage: previewImage ?? this.previewImage,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      colorScheme: colorScheme ?? this.colorScheme,
      assets: assets ?? this.assets,
      config: config ?? this.config,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLimited: isLimited ?? this.isLimited,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
    );
  }

  // 是否为活跃状态
  bool get isActive => status == '活跃';

  // 是否已过期
  bool get isExpired => DateTime.now().isAfter(endDate);

  // 是否即将过期（7天内）
  bool get isExpiringSoon => DateTime.now().add(const Duration(days: 7)).isAfter(endDate);

  // 是否为热门主题
  bool get isPopular => usageCount > 1000;

  // 获取主题持续时间
  Duration get duration => endDate.difference(startDate);

  // 获取剩余时间
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }

  // 获取评分等级
  String get ratingLevel {
    if (rating >= 4.5) return '优秀';
    if (rating >= 4.0) return '良好';
    if (rating >= 3.0) return '一般';
    return '待改进';
  }
}

// 节日活动模型
class FestivalModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String bannerImage;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // upcoming, active, ended, cancelled, draft
  final List<String> themes; // 关联的主题ID列表
  final List<String> rewards; // 奖励列表
  final Map<String, dynamic> rules; // 活动规则
  final int participantCount;
  final int maxParticipants;
  final bool isPublic;
  final Map<String, dynamic> config;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  FestivalModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '',
    this.bannerImage = '',
    required this.startDate,
    required this.endDate,
    required this.status,
    this.themes = const [],
    this.rewards = const [],
    this.rules = const {},
    this.participantCount = 0,
    this.maxParticipants = 0,
    this.isPublic = true,
    this.config = const {},
    required this.createdAt,
    required this.updatedAt,
    this.createdBy = '',
  });

  factory FestivalModel.fromJson(Map<String, dynamic> json) {
    return FestivalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      bannerImage: json['bannerImage'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
      status: json['status'] ?? 'draft',
      themes: List<String>.from(json['themes'] ?? []),
      rewards: List<String>.from(json['rewards'] ?? []),
      rules: json['rules'] ?? {},
      participantCount: json['participantCount'] ?? 0,
      maxParticipants: json['maxParticipants'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      config: json['config'] ?? {},
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
      'icon': icon,
      'bannerImage': bannerImage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'themes': themes,
      'rewards': rewards,
      'rules': rules,
      'participantCount': participantCount,
      'maxParticipants': maxParticipants,
      'isPublic': isPublic,
      'config': config,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  // 是否正在进行
  bool get isActive => status == 'active';

  // 是否即将开始
  bool get isUpcoming => status == 'upcoming';

  // 是否已结束
  bool get isEnded => status == 'ended';

  // 是否已取消
  bool get isCancelled => status == 'cancelled';

  // 是否为草稿
  bool get isDraft => status == 'draft';

  // 获取活动进度（0-1）
  double get progress {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;
    
    final total = endDate.difference(startDate).inMilliseconds;
    final elapsed = now.difference(startDate).inMilliseconds;
    return elapsed / total;
  }

  // 获取剩余时间
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return Duration.zero;
    return endDate.difference(now);
  }

  // 获取参与率
  double get participationRate {
    if (maxParticipants == 0) return 0.0;
    return participantCount / maxParticipants;
  }

  // 是否已满员
  bool get isFull => maxParticipants > 0 && participantCount >= maxParticipants;
}

// 皮肤模型
class SkinModel {
  final String id;
  final String name;
  final String description;
  final String category; // 背景、按钮、图标、字体、动效
  final String previewUrl;
  final String downloadUrl;
  final String thumbnailUrl;
  final List<String> tags;
  final String format; // png, svg, gif, css, json
  final int fileSize; // 字节
  final String resolution;
  final bool isPremium;
  final double price;
  final int downloadCount;
  final double rating;
  final String author;
  final String license;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  SkinModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.previewUrl,
    required this.downloadUrl,
    this.thumbnailUrl = '',
    this.tags = const [],
    required this.format,
    required this.fileSize,
    this.resolution = '',
    this.isPremium = false,
    this.price = 0.0,
    this.downloadCount = 0,
    this.rating = 0.0,
    this.author = '',
    this.license = '',
    required this.createdAt,
    required this.updatedAt,
    this.metadata = const {},
  });

  factory SkinModel.fromJson(Map<String, dynamic> json) {
    return SkinModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '背景',
      previewUrl: json['previewUrl'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      format: json['format'] ?? 'png',
      fileSize: json['fileSize'] ?? 0,
      resolution: json['resolution'] ?? '',
      isPremium: json['isPremium'] ?? false,
      price: (json['price'] ?? 0.0).toDouble(),
      downloadCount: json['downloadCount'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      author: json['author'] ?? '',
      license: json['license'] ?? '',
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
      'category': category,
      'previewUrl': previewUrl,
      'downloadUrl': downloadUrl,
      'thumbnailUrl': thumbnailUrl,
      'tags': tags,
      'format': format,
      'fileSize': fileSize,
      'resolution': resolution,
      'isPremium': isPremium,
      'price': price,
      'downloadCount': downloadCount,
      'rating': rating,
      'author': author,
      'license': license,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // 获取文件大小描述
  String get fileSizeDescription {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  // 是否为热门皮肤
  bool get isPopular => downloadCount > 500;

  // 是否为高质量皮肤
  bool get isHighQuality => rating >= 4.5;

  // 获取评分等级
  String get ratingLevel {
    if (rating >= 4.5) return '优秀';
    if (rating >= 4.0) return '良好';
    if (rating >= 3.0) return '一般';
    return '待改进';
  }
}

// 主题管理统计
class ThemeManagementStats {
  final int totalThemes;
  final int activeThemes;
  final int festivalThemes;
  final int activeFestivals;
  final int totalSkins;
  final int availableSkins;
  final double usageRate;
  final Map<String, int> themesByCategory;
  final Map<String, int> skinsByCategory;
  final Map<String, int> festivalsByStatus;
  final List<ThemeModel> popularThemes;
  final List<SkinModel> popularSkins;

  ThemeManagementStats({
    required this.totalThemes,
    required this.activeThemes,
    required this.festivalThemes,
    required this.activeFestivals,
    required this.totalSkins,
    required this.availableSkins,
    required this.usageRate,
    required this.themesByCategory,
    required this.skinsByCategory,
    required this.festivalsByStatus,
    required this.popularThemes,
    required this.popularSkins,
  });

  factory ThemeManagementStats.fromJson(Map<String, dynamic> json) {
    return ThemeManagementStats(
      totalThemes: json['totalThemes'] ?? 0,
      activeThemes: json['activeThemes'] ?? 0,
      festivalThemes: json['festivalThemes'] ?? 0,
      activeFestivals: json['activeFestivals'] ?? 0,
      totalSkins: json['totalSkins'] ?? 0,
      availableSkins: json['availableSkins'] ?? 0,
      usageRate: (json['usageRate'] ?? 0.0).toDouble(),
      themesByCategory: Map<String, int>.from(json['themesByCategory'] ?? {}),
      skinsByCategory: Map<String, int>.from(json['skinsByCategory'] ?? {}),
      festivalsByStatus: Map<String, int>.from(json['festivalsByStatus'] ?? {}),
      popularThemes: (json['popularThemes'] as List<dynamic>? ?? [])
          .map((e) => ThemeModel.fromJson(e))
          .toList(),
      popularSkins: (json['popularSkins'] as List<dynamic>? ?? [])
          .map((e) => SkinModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalThemes': totalThemes,
      'activeThemes': activeThemes,
      'festivalThemes': festivalThemes,
      'activeFestivals': activeFestivals,
      'totalSkins': totalSkins,
      'availableSkins': availableSkins,
      'usageRate': usageRate,
      'themesByCategory': themesByCategory,
      'skinsByCategory': skinsByCategory,
      'festivalsByStatus': festivalsByStatus,
      'popularThemes': popularThemes.map((e) => e.toJson()).toList(),
      'popularSkins': popularSkins.map((e) => e.toJson()).toList(),
    };
  }
}