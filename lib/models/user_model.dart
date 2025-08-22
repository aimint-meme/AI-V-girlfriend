class UserModel {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isPremium;
  final UserStats stats;
  final int coinBalance;
  final String? membershipId; // 对应MembershipModel的类型
  final DateTime? membershipStartDate;
  final DateTime? membershipEndDate;
  final String? inviteCode; // 用户的邀请码
  final String? invitedBy; // 邀请人的邀请码
  final int totalInvitations; // 总邀请人数
  final int totalCommissionEarned; // 总分成收益

  UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isPremium = false,
    UserStats? stats,
    this.coinBalance = 0,
    this.membershipId,
    this.membershipStartDate,
    this.membershipEndDate,
    this.inviteCode,
    this.invitedBy,
    this.totalInvitations = 0,
    this.totalCommissionEarned = 0,
  }) : stats = stats ?? UserStats();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['display_name'],
      photoUrl: json['photo_url'],
      isPremium: json['is_premium'] ?? false,
      stats: json['stats'] != null ? UserStats.fromJson(json['stats']) : null,
      coinBalance: json['coin_balance'] ?? 0,
      membershipId: json['membership_id'],
      membershipStartDate: json['membership_start_date'] != null 
          ? DateTime.parse(json['membership_start_date']) 
          : null,
      membershipEndDate: json['membership_end_date'] != null 
          ? DateTime.parse(json['membership_end_date']) 
          : null,
      inviteCode: json['invite_code'],
      invitedBy: json['invited_by'],
      totalInvitations: json['total_invitations'] ?? 0,
      totalCommissionEarned: json['total_commission_earned'] ?? 0,
    );
  }
  
  bool get isMembershipActive {
    if (membershipId == null || membershipEndDate == null) return false;
    return DateTime.now().isBefore(membershipEndDate!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'is_premium': isPremium,
      'stats': stats.toJson(),
      'coin_balance': coinBalance,
      'membership_id': membershipId,
      'membership_start_date': membershipStartDate?.toIso8601String(),
      'membership_end_date': membershipEndDate?.toIso8601String(),
      'invite_code': inviteCode,
      'invited_by': invitedBy,
      'total_invitations': totalInvitations,
      'total_commission_earned': totalCommissionEarned,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isPremium,
    UserStats? stats,
    int? coinBalance,
    String? membershipId,
    DateTime? membershipStartDate,
    DateTime? membershipEndDate,
    String? inviteCode,
    String? invitedBy,
    int? totalInvitations,
    int? totalCommissionEarned,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
      stats: stats ?? this.stats,
      coinBalance: coinBalance ?? this.coinBalance,
      membershipId: membershipId ?? this.membershipId,
      membershipStartDate: membershipStartDate ?? this.membershipStartDate,
      membershipEndDate: membershipEndDate ?? this.membershipEndDate,
      inviteCode: inviteCode ?? this.inviteCode,
      invitedBy: invitedBy ?? this.invitedBy,
      totalInvitations: totalInvitations ?? this.totalInvitations,
      totalCommissionEarned: totalCommissionEarned ?? this.totalCommissionEarned,
    );
  }
}

class UserStats {
  final int totalMessages;
  final int daysActive;
  final int likesReceived;
  final int moodScore; // 0-100, representing positive mood percentage
  final List<String> favoriteGirlfriends;

  UserStats({
    this.totalMessages = 0,
    this.daysActive = 1,
    this.likesReceived = 0,
    this.moodScore = 75,
    this.favoriteGirlfriends = const [],
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalMessages: json['total_messages'] ?? 0,
      daysActive: json['days_active'] ?? 1,
      likesReceived: json['likes_received'] ?? 0,
      moodScore: json['mood_score'] ?? 75,
      favoriteGirlfriends: List<String>.from(json['favorite_girlfriends'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_messages': totalMessages,
      'days_active': daysActive,
      'likes_received': likesReceived,
      'mood_score': moodScore,
      'favorite_girlfriends': favoriteGirlfriends,
    };
  }

  UserStats copyWith({
    int? totalMessages,
    int? daysActive,
    int? likesReceived,
    int? moodScore,
    List<String>? favoriteGirlfriends,
  }) {
    return UserStats(
      totalMessages: totalMessages ?? this.totalMessages,
      daysActive: daysActive ?? this.daysActive,
      likesReceived: likesReceived ?? this.likesReceived,
      moodScore: moodScore ?? this.moodScore,
      favoriteGirlfriends: favoriteGirlfriends ?? this.favoriteGirlfriends,
    );
  }
}