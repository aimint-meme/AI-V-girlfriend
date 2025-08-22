/// 知识库付费层级
enum KnowledgePaymentTier {
  free,      // 免费
  premium,   // 付费 (99金币/文档，全部解锁99,999)
  advanced,  // 高阶 (9,999金币--订阅年度会员)
}

/// 解锁方式
enum UnlockMethod {
  free,           // 免费
  singlePurchase, // 单个购买
  membership,     // 会员解锁
  lifetimeMember, // 终身会员
  supremeMember,  // 至尊版
}

/// 会员类型
enum MembershipType {
  none,           // 无会员
  basic,          // 基础会员
  premium,        // 高级会员
  lifetime,       // 终身会员
  supreme,        // 至尊版
}

/// 高阶内容标签
enum AdvancedContentTag {
  psychology,     // 心理学
  communication,  // 沟通技巧
  emotion,        // 情感分析
  relationship,   // 关系管理
  personality,    // 人格心理
  therapy,        // 心理治疗
  assessment,     // 心理评估
  leadership,     // 领导力
}

/// 知识库解锁状态
class KnowledgeUnlockStatus {
  final String knowledgeId;
  final bool isUnlocked;
  final UnlockMethod unlockMethod;
  final DateTime? unlockDate;
  final DateTime? expiryDate; // 会员解锁的过期时间
  final int? paidAmount;      // 支付的金币数量
  
  KnowledgeUnlockStatus({
    required this.knowledgeId,
    required this.isUnlocked,
    required this.unlockMethod,
    this.unlockDate,
    this.expiryDate,
    this.paidAmount,
  });
  
  /// 检查是否仍然有效（考虑会员过期）
  bool get isCurrentlyValid {
    if (!isUnlocked) return false;
    if (unlockMethod == UnlockMethod.singlePurchase || 
        unlockMethod == UnlockMethod.lifetimeMember ||
        unlockMethod == UnlockMethod.supremeMember) {
      return true; // 永久有效
    }
    if (expiryDate != null) {
      return DateTime.now().isBefore(expiryDate!);
    }
    return true;
  }
  
  Map<String, dynamic> toJson() => {
    'knowledgeId': knowledgeId,
    'isUnlocked': isUnlocked,
    'unlockMethod': unlockMethod.index,
    'unlockDate': unlockDate?.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'paidAmount': paidAmount,
  };
  
  factory KnowledgeUnlockStatus.fromJson(Map<String, dynamic> json) {
    return KnowledgeUnlockStatus(
      knowledgeId: json['knowledgeId'],
      isUnlocked: json['isUnlocked'],
      unlockMethod: UnlockMethod.values[json['unlockMethod']],
      unlockDate: json['unlockDate'] != null ? DateTime.parse(json['unlockDate']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      paidAmount: json['paidAmount'],
    );
  }
}

/// 高阶内容解锁状态
class AdvancedContentUnlock {
  final Set<AdvancedContentTag> unlockedTags;
  final MembershipType membershipType;
  final DateTime? membershipExpiry;
  
  AdvancedContentUnlock({
    required this.unlockedTags,
    required this.membershipType,
    this.membershipExpiry,
  });
  
  /// 检查是否可以解锁指定标签
  bool canUnlockTag(AdvancedContentTag tag) {
    // 终身会员和至尊版可以解锁所有标签
    if (membershipType == MembershipType.lifetime || 
        membershipType == MembershipType.supreme) {
      return true;
    }
    
    // 高级会员可以解锁8个标签
    if (membershipType == MembershipType.premium) {
      return unlockedTags.length < 8 || unlockedTags.contains(tag);
    }
    
    return false;
  }
  
  /// 检查会员是否有效
  bool get isMembershipValid {
    if (membershipType == MembershipType.lifetime || 
        membershipType == MembershipType.supreme) {
      return true;
    }
    if (membershipExpiry != null) {
      return DateTime.now().isBefore(membershipExpiry!);
    }
    return membershipType != MembershipType.none;
  }
  
  Map<String, dynamic> toJson() => {
    'unlockedTags': unlockedTags.map((tag) => tag.index).toList(),
    'membershipType': membershipType.index,
    'membershipExpiry': membershipExpiry?.toIso8601String(),
  };
  
  factory AdvancedContentUnlock.fromJson(Map<String, dynamic> json) {
    return AdvancedContentUnlock(
      unlockedTags: (json['unlockedTags'] as List<dynamic>)
          .map((index) => AdvancedContentTag.values[index])
          .toSet(),
      membershipType: MembershipType.values[json['membershipType']],
      membershipExpiry: json['membershipExpiry'] != null 
          ? DateTime.parse(json['membershipExpiry']) 
          : null,
    );
  }
}

/// 知识库付费配置
class KnowledgePaymentConfig {
  static const int singleDocumentCost = 99;        // 单个文档解锁费用
  static const int allDocumentsUnlockCost = 99999; // 全部解锁费用
  static const int advancedMembershipCost = 9999;  // 高阶会员年费
  
  /// 获取付费层级的显示名称
  static String getPaymentTierName(KnowledgePaymentTier tier) {
    switch (tier) {
      case KnowledgePaymentTier.free:
        return '免费';
      case KnowledgePaymentTier.premium:
        return '付费';
      case KnowledgePaymentTier.advanced:
        return '高阶';
    }
  }
  
  /// 获取解锁方式的显示名称
  static String getUnlockMethodName(UnlockMethod method) {
    switch (method) {
      case UnlockMethod.free:
        return '免费';
      case UnlockMethod.singlePurchase:
        return '单次购买';
      case UnlockMethod.membership:
        return '会员解锁';
      case UnlockMethod.lifetimeMember:
        return '终身会员';
      case UnlockMethod.supremeMember:
        return '至尊版';
    }
  }
  
  /// 获取会员类型的显示名称
  static String getMembershipTypeName(MembershipType type) {
    switch (type) {
      case MembershipType.none:
        return '无会员';
      case MembershipType.basic:
        return '基础会员';
      case MembershipType.premium:
        return '高级会员';
      case MembershipType.lifetime:
        return '终身会员';
      case MembershipType.supreme:
        return '至尊版';
    }
  }
  
  /// 获取高阶内容标签的显示名称
  static String getAdvancedTagName(AdvancedContentTag tag) {
    switch (tag) {
      case AdvancedContentTag.psychology:
        return '心理学';
      case AdvancedContentTag.communication:
        return '沟通技巧';
      case AdvancedContentTag.emotion:
        return '情感分析';
      case AdvancedContentTag.relationship:
        return '关系管理';
      case AdvancedContentTag.personality:
        return '人格心理';
      case AdvancedContentTag.therapy:
        return '心理治疗';
      case AdvancedContentTag.assessment:
        return '心理评估';
      case AdvancedContentTag.leadership:
        return '领导力';
    }
  }
}