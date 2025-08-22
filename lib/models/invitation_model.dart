class InvitationModel {
  final String id;
  final String inviterId; // 邀请人ID
  final String inviteeId; // 被邀请人ID
  final String inviteCode; // 邀请码
  final DateTime createdAt; // 邀请创建时间
  final DateTime? registeredAt; // 被邀请人注册时间
  final bool isRegistered; // 是否已注册
  final int fixedRewardAmount; // 固定奖励金额（50金币）
  final bool fixedRewardClaimed; // 固定奖励是否已领取
  final DateTime? fixedRewardClaimedAt; // 固定奖励领取时间
  final int totalCommissionEarned; // 总分成收益
  final DateTime commissionStartDate; // 分成开始时间
  final DateTime commissionEndDate; // 分成结束时间（90天后）

  InvitationModel({
    required this.id,
    required this.inviterId,
    required this.inviteeId,
    required this.inviteCode,
    required this.createdAt,
    this.registeredAt,
    this.isRegistered = false,
    this.fixedRewardAmount = 50,
    this.fixedRewardClaimed = false,
    this.fixedRewardClaimedAt,
    this.totalCommissionEarned = 0,
    DateTime? commissionStartDate,
    DateTime? commissionEndDate,
  }) : commissionStartDate = commissionStartDate ?? createdAt,
       commissionEndDate = commissionEndDate ?? createdAt.add(const Duration(days: 90));

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      inviterId: json['inviter_id'],
      inviteeId: json['invitee_id'],
      inviteCode: json['invite_code'],
      createdAt: DateTime.parse(json['created_at']),
      registeredAt: json['registered_at'] != null 
          ? DateTime.parse(json['registered_at']) 
          : null,
      isRegistered: json['is_registered'] ?? false,
      fixedRewardAmount: json['fixed_reward_amount'] ?? 50,
      fixedRewardClaimed: json['fixed_reward_claimed'] ?? false,
      fixedRewardClaimedAt: json['fixed_reward_claimed_at'] != null 
          ? DateTime.parse(json['fixed_reward_claimed_at']) 
          : null,
      totalCommissionEarned: json['total_commission_earned'] ?? 0,
      commissionStartDate: json['commission_start_date'] != null 
          ? DateTime.parse(json['commission_start_date']) 
          : null,
      commissionEndDate: json['commission_end_date'] != null 
          ? DateTime.parse(json['commission_end_date']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'invite_code': inviteCode,
      'created_at': createdAt.toIso8601String(),
      'registered_at': registeredAt?.toIso8601String(),
      'is_registered': isRegistered,
      'fixed_reward_amount': fixedRewardAmount,
      'fixed_reward_claimed': fixedRewardClaimed,
      'fixed_reward_claimed_at': fixedRewardClaimedAt?.toIso8601String(),
      'total_commission_earned': totalCommissionEarned,
      'commission_start_date': commissionStartDate.toIso8601String(),
      'commission_end_date': commissionEndDate.toIso8601String(),
    };
  }

  InvitationModel copyWith({
    String? id,
    String? inviterId,
    String? inviteeId,
    String? inviteCode,
    DateTime? createdAt,
    DateTime? registeredAt,
    bool? isRegistered,
    int? fixedRewardAmount,
    bool? fixedRewardClaimed,
    DateTime? fixedRewardClaimedAt,
    int? totalCommissionEarned,
    DateTime? commissionStartDate,
    DateTime? commissionEndDate,
  }) {
    return InvitationModel(
      id: id ?? this.id,
      inviterId: inviterId ?? this.inviterId,
      inviteeId: inviteeId ?? this.inviteeId,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
      registeredAt: registeredAt ?? this.registeredAt,
      isRegistered: isRegistered ?? this.isRegistered,
      fixedRewardAmount: fixedRewardAmount ?? this.fixedRewardAmount,
      fixedRewardClaimed: fixedRewardClaimed ?? this.fixedRewardClaimed,
      fixedRewardClaimedAt: fixedRewardClaimedAt ?? this.fixedRewardClaimedAt,
      totalCommissionEarned: totalCommissionEarned ?? this.totalCommissionEarned,
      commissionStartDate: commissionStartDate ?? this.commissionStartDate,
      commissionEndDate: commissionEndDate ?? this.commissionEndDate,
    );
  }

  // 检查分成是否仍然有效（90天内）
  bool get isCommissionActive {
    final now = DateTime.now();
    return now.isBefore(commissionEndDate) && isRegistered;
  }

  // 获取分成剩余天数
  int get commissionRemainingDays {
    if (!isCommissionActive) return 0;
    final now = DateTime.now();
    return commissionEndDate.difference(now).inDays;
  }
}

// 分成记录模型
class CommissionRecord {
  final String id;
  final String invitationId; // 关联的邀请ID
  final String inviterId; // 邀请人ID
  final String inviteeId; // 被邀请人ID
  final int originalAmount; // 原始消费金额
  final int commissionAmount; // 分成金额（10%）
  final DateTime createdAt; // 分成产生时间
  final String description; // 分成描述
  final CommissionType type; // 分成类型

  CommissionRecord({
    required this.id,
    required this.invitationId,
    required this.inviterId,
    required this.inviteeId,
    required this.originalAmount,
    required this.commissionAmount,
    required this.createdAt,
    required this.description,
    required this.type,
  });

  factory CommissionRecord.fromJson(Map<String, dynamic> json) {
    return CommissionRecord(
      id: json['id'],
      invitationId: json['invitation_id'],
      inviterId: json['inviter_id'],
      inviteeId: json['invitee_id'],
      originalAmount: json['original_amount'],
      commissionAmount: json['commission_amount'],
      createdAt: DateTime.parse(json['created_at']),
      description: json['description'],
      type: CommissionType.values.firstWhere(
        (e) => e.toString() == 'CommissionType.${json['type']}',
        orElse: () => CommissionType.other,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invitation_id': invitationId,
      'inviter_id': inviterId,
      'invitee_id': inviteeId,
      'original_amount': originalAmount,
      'commission_amount': commissionAmount,
      'created_at': createdAt.toIso8601String(),
      'description': description,
      'type': type.toString().split('.').last,
    };
  }
}

// 分成类型枚举
enum CommissionType {
  coinPurchase, // 金币购买
  premiumUpgrade, // 会员升级
  chatConsumption, // 聊天消费
  voiceMessage, // 语音消息
  imageMessage, // 图片消息
  customization, // 定制服务
  other, // 其他
}

// 分成类型扩展
extension CommissionTypeExtension on CommissionType {
  String get displayName {
    switch (this) {
      case CommissionType.coinPurchase:
        return '金币购买';
      case CommissionType.premiumUpgrade:
        return '会员升级';
      case CommissionType.chatConsumption:
        return '聊天消费';
      case CommissionType.voiceMessage:
        return '语音消息';
      case CommissionType.imageMessage:
        return '图片消息';
      case CommissionType.customization:
        return '定制服务';
      case CommissionType.other:
        return '其他';
    }
  }

  String get description {
    switch (this) {
      case CommissionType.coinPurchase:
        return '被邀请用户购买金币产生的分成';
      case CommissionType.premiumUpgrade:
        return '被邀请用户升级会员产生的分成';
      case CommissionType.chatConsumption:
        return '被邀请用户聊天消费产生的分成';
      case CommissionType.voiceMessage:
        return '被邀请用户发送语音消息产生的分成';
      case CommissionType.imageMessage:
        return '被邀请用户发送图片消息产生的分成';
      case CommissionType.customization:
        return '被邀请用户使用定制服务产生的分成';
      case CommissionType.other:
        return '其他消费产生的分成';
    }
  }
}