import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/knowledge_payment_model.dart';
import '../models/coin_model.dart';
// import '../models/membership_model.dart'; // 移除冲突的导入，使用knowledge_payment_model中的MembershipType

/// 知识库解锁服务
class KnowledgeUnlockService {
  static const String _unlockStatusKey = 'knowledge_unlock_status';
  static const String _advancedUnlockKey = 'advanced_content_unlock';
  static const String _membershipKey = 'user_membership';
  
  // 单例模式
  static final KnowledgeUnlockService _instance = KnowledgeUnlockService._internal();
  factory KnowledgeUnlockService() => _instance;
  KnowledgeUnlockService._internal();
  
  // 缓存数据
  Map<String, KnowledgeUnlockStatus> _unlockStatusCache = {};
  AdvancedContentUnlock? _advancedUnlockCache;
  MembershipType _currentMembershipType = MembershipType.none;
  DateTime? _membershipExpiry;
  
  /// 初始化服务
  Future<void> initialize() async {
    await _loadUnlockStatus();
    await _loadAdvancedUnlock();
    await _loadMembershipInfo();
  }
  
  /// 加载解锁状态
  Future<void> _loadUnlockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString(_unlockStatusKey);
      if (statusJson != null) {
        final Map<String, dynamic> statusMap = json.decode(statusJson);
        _unlockStatusCache = statusMap.map(
          (key, value) => MapEntry(
            key, 
            KnowledgeUnlockStatus.fromJson(value as Map<String, dynamic>)
          ),
        );
      }
    } catch (e) {
      print('加载解锁状态失败: $e');
      _unlockStatusCache = {};
    }
  }
  
  /// 保存解锁状态
  Future<void> _saveUnlockStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusMap = _unlockStatusCache.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_unlockStatusKey, json.encode(statusMap));
    } catch (e) {
      print('保存解锁状态失败: $e');
    }
  }
  
  /// 加载高阶内容解锁状态
  Future<void> _loadAdvancedUnlock() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockJson = prefs.getString(_advancedUnlockKey);
      if (unlockJson != null) {
        final Map<String, dynamic> unlockMap = json.decode(unlockJson);
        _advancedUnlockCache = AdvancedContentUnlock.fromJson(unlockMap);
      } else {
        _advancedUnlockCache = AdvancedContentUnlock(
          unlockedTags: {},
          membershipType: MembershipType.none,
        );
      }
    } catch (e) {
      print('加载高阶内容解锁状态失败: $e');
      _advancedUnlockCache = AdvancedContentUnlock(
        unlockedTags: {},
        membershipType: MembershipType.none,
      );
    }
  }
  
  /// 保存高阶内容解锁状态
  Future<void> _saveAdvancedUnlock() async {
    try {
      if (_advancedUnlockCache != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_advancedUnlockKey, json.encode(_advancedUnlockCache!.toJson()));
      }
    } catch (e) {
      print('保存高阶内容解锁状态失败: $e');
    }
  }
  
  /// 加载会员信息
  Future<void> _loadMembershipInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membershipJson = prefs.getString(_membershipKey);
      if (membershipJson != null) {
        final Map<String, dynamic> membershipMap = json.decode(membershipJson);
        _currentMembershipType = MembershipType.values[membershipMap['type'] ?? 0];
        if (membershipMap['expiry'] != null) {
          _membershipExpiry = DateTime.parse(membershipMap['expiry']);
        }
      }
    } catch (e) {
      print('加载会员信息失败: $e');
      _currentMembershipType = MembershipType.none;
      _membershipExpiry = null;
    }
  }
  
  /// 保存会员信息
  Future<void> _saveMembershipInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final membershipMap = {
        'type': _currentMembershipType.index,
        'expiry': _membershipExpiry?.toIso8601String(),
      };
      await prefs.setString(_membershipKey, json.encode(membershipMap));
    } catch (e) {
      print('保存会员信息失败: $e');
    }
  }
  
  /// 检查知识库是否已解锁
  bool isKnowledgeUnlocked(String knowledgeId) {
    final status = _unlockStatusCache[knowledgeId];
    return status?.isCurrentlyValid ?? false;
  }
  
  /// 获取知识库解锁状态
  KnowledgeUnlockStatus? getUnlockStatus(String knowledgeId) {
    return _unlockStatusCache[knowledgeId];
  }
  
  /// 获取当前会员类型
  MembershipType get currentMembershipType => _currentMembershipType;
  
  /// 获取会员过期时间
  DateTime? get membershipExpiry => _membershipExpiry;
  
  /// 检查会员是否有效
  bool get isMembershipValid {
    if (_currentMembershipType == MembershipType.lifetime || 
        _currentMembershipType == MembershipType.supreme) {
      return true;
    }
    if (_membershipExpiry != null) {
      return DateTime.now().isBefore(_membershipExpiry!);
    }
    return _currentMembershipType != MembershipType.none;
  }
  
  /// 获取高阶内容解锁状态
  AdvancedContentUnlock get advancedContentUnlock {
    return _advancedUnlockCache ?? AdvancedContentUnlock(
      unlockedTags: {},
      membershipType: _currentMembershipType,
      membershipExpiry: _membershipExpiry,
    );
  }
  
  /// 解锁知识库（单次购买）
  Future<bool> unlockKnowledge({
    required String knowledgeId,
    required int cost,
    required int userCoins,
  }) async {
    if (userCoins < cost) {
      throw Exception('金币不足，需要 $cost 金币，当前只有 $userCoins 金币');
    }
    
    try {
      // 创建解锁状态
      final unlockStatus = KnowledgeUnlockStatus(
        knowledgeId: knowledgeId,
        isUnlocked: true,
        unlockMethod: UnlockMethod.singlePurchase,
        unlockDate: DateTime.now(),
        paidAmount: cost,
      );
      
      // 保存解锁状态
      _unlockStatusCache[knowledgeId] = unlockStatus;
      await _saveUnlockStatus();
      
      return true;
    } catch (e) {
      print('解锁知识库失败: $e');
      return false;
    }
  }
  
  /// 通过会员解锁知识库
  Future<bool> unlockKnowledgeByMembership(String knowledgeId) async {
    if (!isMembershipValid) {
      throw Exception('会员已过期或无效');
    }
    
    try {
      final unlockStatus = KnowledgeUnlockStatus(
        knowledgeId: knowledgeId,
        isUnlocked: true,
        unlockMethod: UnlockMethod.membership,
        unlockDate: DateTime.now(),
        expiryDate: _membershipExpiry,
      );
      
      _unlockStatusCache[knowledgeId] = unlockStatus;
      await _saveUnlockStatus();
      
      return true;
    } catch (e) {
      print('通过会员解锁知识库失败: $e');
      return false;
    }
  }
  
  /// 购买会员
  Future<bool> purchaseMembership({
    required MembershipType membershipType,
    required int cost,
    required int userCoins,
    int? durationDays,
  }) async {
    if (userCoins < cost) {
      throw Exception('金币不足，需要 $cost 金币，当前只有 $userCoins 金币');
    }
    
    try {
      _currentMembershipType = membershipType;
      
      // 设置过期时间
      if (membershipType == MembershipType.lifetime || 
          membershipType == MembershipType.supreme) {
        _membershipExpiry = null; // 永久有效
      } else if (durationDays != null) {
        _membershipExpiry = DateTime.now().add(Duration(days: durationDays));
      } else {
        // 默认一年
        _membershipExpiry = DateTime.now().add(const Duration(days: 365));
      }
      
      await _saveMembershipInfo();
      
      // 更新高阶内容解锁状态
      _advancedUnlockCache = AdvancedContentUnlock(
        unlockedTags: _advancedUnlockCache?.unlockedTags ?? {},
        membershipType: _currentMembershipType,
        membershipExpiry: _membershipExpiry,
      );
      await _saveAdvancedUnlock();
      
      return true;
    } catch (e) {
      print('购买会员失败: $e');
      return false;
    }
  }
  
  /// 解锁高阶内容标签
  Future<bool> unlockAdvancedTag(AdvancedContentTag tag) async {
    final currentUnlock = advancedContentUnlock;
    
    if (!currentUnlock.canUnlockTag(tag)) {
      throw Exception('无法解锁此标签，请检查会员权限或已解锁标签数量');
    }
    
    try {
      final newUnlockedTags = Set<AdvancedContentTag>.from(currentUnlock.unlockedTags)
        ..add(tag);
      
      _advancedUnlockCache = AdvancedContentUnlock(
        unlockedTags: newUnlockedTags,
        membershipType: currentUnlock.membershipType,
        membershipExpiry: currentUnlock.membershipExpiry,
      );
      
      await _saveAdvancedUnlock();
      return true;
    } catch (e) {
      print('解锁高阶内容标签失败: $e');
      return false;
    }
  }
  
  /// 批量解锁所有知识库（全部解锁功能）
  Future<bool> unlockAllKnowledge({
    required List<String> knowledgeIds,
    required int cost,
    required int userCoins,
  }) async {
    if (userCoins < cost) {
      throw Exception('金币不足，需要 $cost 金币，当前只有 $userCoins 金币');
    }
    
    try {
      final unlockDate = DateTime.now();
      
      for (final knowledgeId in knowledgeIds) {
        final unlockStatus = KnowledgeUnlockStatus(
          knowledgeId: knowledgeId,
          isUnlocked: true,
          unlockMethod: UnlockMethod.singlePurchase,
          unlockDate: unlockDate,
          paidAmount: cost ~/ knowledgeIds.length, // 平均分摊费用
        );
        
        _unlockStatusCache[knowledgeId] = unlockStatus;
      }
      
      await _saveUnlockStatus();
      return true;
    } catch (e) {
      print('批量解锁知识库失败: $e');
      return false;
    }
  }
  
  /// 检查会员到期并更新状态
  Future<void> checkMembershipExpiry() async {
    if (_membershipExpiry != null && DateTime.now().isAfter(_membershipExpiry!)) {
      // 会员已过期，将会员解锁的知识库状态更新为待解锁
      final expiredUnlocks = _unlockStatusCache.entries
          .where((entry) => entry.value.unlockMethod == UnlockMethod.membership)
          .toList();
      
      for (final entry in expiredUnlocks) {
        final newStatus = KnowledgeUnlockStatus(
          knowledgeId: entry.key,
          isUnlocked: false,
          unlockMethod: UnlockMethod.membership,
          unlockDate: entry.value.unlockDate,
          expiryDate: entry.value.expiryDate,
          paidAmount: entry.value.paidAmount,
        );
        _unlockStatusCache[entry.key] = newStatus;
      }
      
      await _saveUnlockStatus();
    }
  }
  
  /// 获取解锁统计信息
  Map<String, dynamic> getUnlockStatistics() {
    final totalUnlocked = _unlockStatusCache.values
        .where((status) => status.isCurrentlyValid)
        .length;
    
    final paidUnlocked = _unlockStatusCache.values
        .where((status) => status.isCurrentlyValid && 
               status.unlockMethod == UnlockMethod.singlePurchase)
        .length;
    
    final membershipUnlocked = _unlockStatusCache.values
        .where((status) => status.isCurrentlyValid && 
               status.unlockMethod == UnlockMethod.membership)
        .length;
    
    final totalSpent = _unlockStatusCache.values
        .where((status) => status.paidAmount != null)
        .fold<int>(0, (sum, status) => sum + (status.paidAmount ?? 0));
    
    return {
      'totalUnlocked': totalUnlocked,
      'paidUnlocked': paidUnlocked,
      'membershipUnlocked': membershipUnlocked,
      'totalSpent': totalSpent,
      'membershipType': KnowledgePaymentConfig.getMembershipTypeName(_currentMembershipType),
      'membershipValid': isMembershipValid,
      'membershipExpiry': _membershipExpiry?.toIso8601String(),
      'unlockedAdvancedTags': advancedContentUnlock.unlockedTags.length,
    };
  }
  
  /// 重置所有数据（用于测试或重置功能）
  Future<void> resetAllData() async {
    _unlockStatusCache.clear();
    _advancedUnlockCache = AdvancedContentUnlock(
      unlockedTags: {},
      membershipType: MembershipType.none,
    );
    _currentMembershipType = MembershipType.none;
    _membershipExpiry = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockStatusKey);
    await prefs.remove(_advancedUnlockKey);
    await prefs.remove(_membershipKey);
  }
}