import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/invitation_model.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class InvitationService {
  static const String _invitationsKey = 'invitations';
  static const String _commissionsKey = 'commissions';
  
  List<InvitationModel> _invitations = [];
  List<CommissionRecord> _commissions = [];
  
  // 初始化服务
  Future<void> initialize() async {
    await _loadInvitations();
    await _loadCommissions();
  }
  
  // 生成邀请码
  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code;
    
    do {
      code = List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    } while (_isInviteCodeExists(code));
    
    return code;
  }
  
  // 检查邀请码是否已存在
  bool _isInviteCodeExists(String code) {
    return _invitations.any((invitation) => invitation.inviteCode == code);
  }
  
  // 创建邀请关系
  Future<InvitationModel> createInvitation({
    required String inviterId,
    required String inviteeId,
    required String inviteCode,
  }) async {
    final invitation = InvitationModel(
      id: const Uuid().v4(),
      inviterId: inviterId,
      inviteeId: inviteeId,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );
    
    _invitations.add(invitation);
    await _saveInvitations();
    
    return invitation;
  }
  
  // 确认注册（被邀请人注册成功时调用）
  Future<InvitationModel?> confirmRegistration(String inviteCode, String inviteeId) async {
    final invitationIndex = _invitations.indexWhere(
      (invitation) => invitation.inviteCode == inviteCode && !invitation.isRegistered,
    );
    
    if (invitationIndex == -1) return null;
    
    final invitation = _invitations[invitationIndex];
    final updatedInvitation = invitation.copyWith(
      inviteeId: inviteeId,
      isRegistered: true,
      registeredAt: DateTime.now(),
      commissionStartDate: DateTime.now(),
      commissionEndDate: DateTime.now().add(const Duration(days: 90)),
    );
    
    _invitations[invitationIndex] = updatedInvitation;
    await _saveInvitations();
    
    return updatedInvitation;
  }
  
  // 领取固定奖励（50金币）
  Future<bool> claimFixedReward(String invitationId) async {
    final invitationIndex = _invitations.indexWhere(
      (invitation) => invitation.id == invitationId && 
                     invitation.isRegistered && 
                     !invitation.fixedRewardClaimed,
    );
    
    if (invitationIndex == -1) return false;
    
    final invitation = _invitations[invitationIndex];
    final updatedInvitation = invitation.copyWith(
      fixedRewardClaimed: true,
      fixedRewardClaimedAt: DateTime.now(),
    );
    
    _invitations[invitationIndex] = updatedInvitation;
    await _saveInvitations();
    
    return true;
  }
  
  // 记录分成（被邀请人消费时调用）
  Future<CommissionRecord?> recordCommission({
    required String inviteeId,
    required int originalAmount,
    required CommissionType type,
    required String description,
  }) async {
    // 查找有效的邀请关系
    final invitation = _invitations.firstWhere(
      (inv) => inv.inviteeId == inviteeId && 
               inv.isRegistered && 
               inv.isCommissionActive,
      orElse: () => throw Exception('No active invitation found'),
    );
    
    // 计算分成金额（10%）
    final commissionAmount = (originalAmount * 0.1).round();
    
    final commission = CommissionRecord(
      id: const Uuid().v4(),
      invitationId: invitation.id,
      inviterId: invitation.inviterId,
      inviteeId: inviteeId,
      originalAmount: originalAmount,
      commissionAmount: commissionAmount,
      createdAt: DateTime.now(),
      description: description,
      type: type,
    );
    
    _commissions.add(commission);
    await _saveCommissions();
    
    // 更新邀请记录的总分成收益
    final invitationIndex = _invitations.indexWhere((inv) => inv.id == invitation.id);
    if (invitationIndex != -1) {
      final updatedInvitation = _invitations[invitationIndex].copyWith(
        totalCommissionEarned: _invitations[invitationIndex].totalCommissionEarned + commissionAmount,
      );
      _invitations[invitationIndex] = updatedInvitation;
      await _saveInvitations();
    }
    
    return commission;
  }
  
  // 获取用户的邀请列表
  List<InvitationModel> getUserInvitations(String userId) {
    return _invitations.where((invitation) => invitation.inviterId == userId).toList();
  }
  
  // 获取用户的分成记录
  List<CommissionRecord> getUserCommissions(String userId) {
    return _commissions.where((commission) => commission.inviterId == userId).toList();
  }
  
  // 获取用户的邀请统计
  Map<String, dynamic> getUserInvitationStats(String userId) {
    final userInvitations = getUserInvitations(userId);
    final userCommissions = getUserCommissions(userId);
    
    final totalInvitations = userInvitations.length;
    final registeredInvitations = userInvitations.where((inv) => inv.isRegistered).length;
    final activeCommissions = userInvitations.where((inv) => inv.isCommissionActive).length;
    final totalFixedRewards = userInvitations.where((inv) => inv.fixedRewardClaimed).length * 50;
    final totalCommissionEarned = userCommissions.fold<int>(0, (sum, comm) => sum + comm.commissionAmount);
    final pendingFixedRewards = userInvitations.where((inv) => inv.isRegistered && !inv.fixedRewardClaimed).length;
    
    return {
      'totalInvitations': totalInvitations,
      'registeredInvitations': registeredInvitations,
      'activeCommissions': activeCommissions,
      'totalFixedRewards': totalFixedRewards,
      'totalCommissionEarned': totalCommissionEarned,
      'totalEarnings': totalFixedRewards + totalCommissionEarned,
      'pendingFixedRewards': pendingFixedRewards,
      'pendingFixedRewardAmount': pendingFixedRewards * 50,
    };
  }
  
  // 获取待领取的固定奖励列表
  List<InvitationModel> getPendingFixedRewards(String userId) {
    return _invitations.where(
      (invitation) => invitation.inviterId == userId && 
                     invitation.isRegistered && 
                     !invitation.fixedRewardClaimed,
    ).toList();
  }
  
  // 验证邀请码是否有效
  bool isValidInviteCode(String inviteCode) {
    return _invitations.any((invitation) => invitation.inviteCode == inviteCode);
  }
  
  // 根据邀请码获取邀请人ID
  String? getInviterIdByCode(String inviteCode) {
    try {
      final invitation = _invitations.firstWhere(
        (invitation) => invitation.inviteCode == inviteCode,
      );
      return invitation.inviterId;
    } catch (e) {
      return null;
    }
  }
  
  // 加载邀请数据
  Future<void> _loadInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_invitationsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _invitations = jsonList.map((json) => InvitationModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('加载邀请数据失败: $e');
    }
  }
  
  // 保存邀请数据
  Future<void> _saveInvitations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_invitations.map((inv) => inv.toJson()).toList());
      await prefs.setString(_invitationsKey, jsonString);
    } catch (e) {
      print('保存邀请数据失败: $e');
    }
  }
  
  // 加载分成数据
  Future<void> _loadCommissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_commissionsKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _commissions = jsonList.map((json) => CommissionRecord.fromJson(json)).toList();
      }
    } catch (e) {
      print('加载分成数据失败: $e');
    }
  }
  
  // 保存分成数据
  Future<void> _saveCommissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_commissions.map((comm) => comm.toJson()).toList());
      await prefs.setString(_commissionsKey, jsonString);
    } catch (e) {
      print('保存分成数据失败: $e');
    }
  }
  
  // 清理过期的分成关系（可选，用于数据清理）
  Future<void> cleanupExpiredCommissions() async {
    final now = DateTime.now();
    bool hasChanges = false;
    
    // 清理过期的邀请关系
    for (int i = 0; i < _invitations.length; i++) {
      final invitation = _invitations[i];
      if (invitation.isRegistered && now.isAfter(invitation.commissionEndDate)) {
        // 可以选择删除或标记为过期，这里选择保留但不再产生分成
        // 实际应用中可能需要根据业务需求决定
      }
    }
    
    if (hasChanges) {
      await _saveInvitations();
    }
  }
}