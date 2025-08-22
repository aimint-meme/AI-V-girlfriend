class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String avatar;
  final String status; // 正常、禁用、待验证
  final String membershipType; // 普通用户、会员、高级会员、终身会员
  final double balance;
  final int coins;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> profile;
  final Map<String, dynamic> preferences;
  final List<String> tags;
  final int intimacyLevel;
  final double totalSpent;
  final int conversationCount;
  final bool isOnline;
  final String? lastActiveCharacter;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone = '',
    this.avatar = '',
    required this.status,
    required this.membershipType,
    required this.balance,
    required this.coins,
    required this.createdAt,
    required this.lastLoginAt,
    this.profile = const {},
    this.preferences = const {},
    this.tags = const [],
    this.intimacyLevel = 0,
    this.totalSpent = 0.0,
    this.conversationCount = 0,
    this.isOnline = false,
    this.lastActiveCharacter,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      status: json['status'] ?? '正常',
      membershipType: json['membershipType'] ?? '普通用户',
      balance: (json['balance'] ?? 0.0).toDouble(),
      coins: json['coins'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      profile: json['profile'] ?? {},
      preferences: json['preferences'] ?? {},
      tags: List<String>.from(json['tags'] ?? []),
      intimacyLevel: json['intimacyLevel'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
      conversationCount: json['conversationCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
      lastActiveCharacter: json['lastActiveCharacter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'status': status,
      'membershipType': membershipType,
      'balance': balance,
      'coins': coins,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'profile': profile,
      'preferences': preferences,
      'tags': tags,
      'intimacyLevel': intimacyLevel,
      'totalSpent': totalSpent,
      'conversationCount': conversationCount,
      'isOnline': isOnline,
      'lastActiveCharacter': lastActiveCharacter,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? avatar,
    String? status,
    String? membershipType,
    double? balance,
    int? coins,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? profile,
    Map<String, dynamic>? preferences,
    List<String>? tags,
    int? intimacyLevel,
    double? totalSpent,
    int? conversationCount,
    bool? isOnline,
    String? lastActiveCharacter,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      membershipType: membershipType ?? this.membershipType,
      balance: balance ?? this.balance,
      coins: coins ?? this.coins,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      profile: profile ?? this.profile,
      preferences: preferences ?? this.preferences,
      tags: tags ?? this.tags,
      intimacyLevel: intimacyLevel ?? this.intimacyLevel,
      totalSpent: totalSpent ?? this.totalSpent,
      conversationCount: conversationCount ?? this.conversationCount,
      isOnline: isOnline ?? this.isOnline,
      lastActiveCharacter: lastActiveCharacter ?? this.lastActiveCharacter,
    );
  }

  // 获取用户等级
  String get userLevel {
    if (intimacyLevel >= 100) return '挚友';
    if (intimacyLevel >= 80) return '密友';
    if (intimacyLevel >= 60) return '好友';
    if (intimacyLevel >= 40) return '朋友';
    if (intimacyLevel >= 20) return '熟人';
    return '陌生人';
  }

  // 获取会员等级颜色
  String get membershipColor {
    switch (membershipType) {
      case '终身会员':
        return '#6366F1';
      case '高级会员':
        return '#8B5CF6';
      case '会员':
        return '#F59E0B';
      default:
        return '#6B7280';
    }
  }

  // 是否为会员
  bool get isMember => membershipType != '普通用户';

  // 获取用户活跃度
  String get activityLevel {
    final daysSinceLastLogin = DateTime.now().difference(lastLoginAt).inDays;
    if (daysSinceLastLogin == 0) return '今日活跃';
    if (daysSinceLastLogin <= 3) return '近期活跃';
    if (daysSinceLastLogin <= 7) return '一周内活跃';
    if (daysSinceLastLogin <= 30) return '一月内活跃';
    return '不活跃';
  }

  // 获取消费等级
  String get spendingLevel {
    if (totalSpent >= 1000) return '高消费用户';
    if (totalSpent >= 500) return '中等消费用户';
    if (totalSpent >= 100) return '低消费用户';
    return '免费用户';
  }
}

// 用户统计模型
class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int memberUsers;
  final int todayNewUsers;
  final int onlineUsers;
  final double averageBalance;
  final double totalRevenue;
  final Map<String, int> membershipDistribution;
  final Map<String, int> statusDistribution;
  final Map<String, int> registrationTrend;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.memberUsers,
    required this.todayNewUsers,
    required this.onlineUsers,
    required this.averageBalance,
    required this.totalRevenue,
    required this.membershipDistribution,
    required this.statusDistribution,
    required this.registrationTrend,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      memberUsers: json['memberUsers'] ?? 0,
      todayNewUsers: json['todayNewUsers'] ?? 0,
      onlineUsers: json['onlineUsers'] ?? 0,
      averageBalance: (json['averageBalance'] ?? 0.0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      membershipDistribution: Map<String, int>.from(json['membershipDistribution'] ?? {}),
      statusDistribution: Map<String, int>.from(json['statusDistribution'] ?? {}),
      registrationTrend: Map<String, int>.from(json['registrationTrend'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'activeUsers': activeUsers,
      'memberUsers': memberUsers,
      'todayNewUsers': todayNewUsers,
      'onlineUsers': onlineUsers,
      'averageBalance': averageBalance,
      'totalRevenue': totalRevenue,
      'membershipDistribution': membershipDistribution,
      'statusDistribution': statusDistribution,
      'registrationTrend': registrationTrend,
    };
  }
}