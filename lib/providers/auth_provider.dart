import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // 临时注释

import '../models/user_model.dart';
import '../models/membership_model.dart';
import '../models/invitation_model.dart';
import '../services/invitation_service.dart';
import 'dart:math';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  final InvitationService _invitationService = InvitationService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  int get coinBalance => _user?.coinBalance ?? 0;
  bool get isMembershipActive => _user?.isPremium ?? false;
  bool get isDataCollectionEnabled => true; // 默认启用数据收集
  UserStats get stats => _user?.stats ?? UserStats();
  InvitationService get invitationService => _invitationService;
  String? get userInviteCode => _user?.inviteCode;
  int get totalInvitations => _user?.totalInvitations ?? 0;
  int get totalCommissionEarned => _user?.totalCommissionEarned ?? 0;

  // Demo user for testing
  final UserModel _demoUser = UserModel(
    id: 'demo_user_001',
    email: 'demo@example.com',
    displayName: '演示用户',
    photoUrl: null,
    isPremium: false,
    coinBalance: 100,
    membershipId: null,
    membershipStartDate: null,
    membershipEndDate: null,
    inviteCode: 'DEMO1234',
    invitedBy: null,
    totalInvitations: 3,
    totalCommissionEarned: 150,
    stats: UserStats(
      totalMessages: 42,
      daysActive: 7,
      favoriteGirlfriends: ['gf_001', 'gf_002'],
    ),
  );
  
  // 初始化服务
  Future<void> initialize() async {
    await _invitationService.initialize();
  }

  // Check if user is already logged in - 简化版本
  Future<bool> checkLoginStatus() async {
    // 临时直接返回true，使用演示用户
    _user = _demoUser;
    notifyListeners();
    return true;
  }

  // Login with email and password - 简化版本
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      await _invitationService.initialize();
      
      // 如果用户没有邀请码，生成一个
      String inviteCode = _demoUser.inviteCode ?? _invitationService.generateInviteCode();
      
      // 简化登录逻辑
      _user = _demoUser.copyWith(inviteCode: inviteCode);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register new user - 简化版本
  Future<bool> register(String email, String password, String displayName, {String? inviteCode}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      await _invitationService.initialize();
      
      final userId = 'new_user_${DateTime.now().millisecondsSinceEpoch}';
      final userInviteCode = _invitationService.generateInviteCode();
      
      _user = UserModel(
        id: userId,
        email: email,
        displayName: displayName,
        photoUrl: null,
        isPremium: false,
        coinBalance: 50, // 新用户赠送50金币
        membershipId: null,
        membershipStartDate: null,
        membershipEndDate: null,
        inviteCode: userInviteCode,
        invitedBy: inviteCode,
        totalInvitations: 0,
        totalCommissionEarned: 0,
      );
      
      // 如果有邀请码，处理邀请关系
      if (inviteCode != null && inviteCode.isNotEmpty) {
        await _handleInviteCodeRegistration(inviteCode, userId);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout - 简化版本
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  // Update user profile - 简化版本
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    if (_user == null) return false;

    try {
      _user = _user!.copyWith(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Purchase membership - 简化版本
  Future<bool> purchaseMembership(MembershipModel membership, [String? paymentMethod, double? price]) async {
    if (_user == null) return false;

    try {
      final now = DateTime.now();
      final endDate = now.add(Duration(days: membership.durationDays));
      
      _user = _user!.copyWith(
        isPremium: true,
        membershipId: membership.id,
        membershipStartDate: now,
        membershipEndDate: endDate,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Add coins - 简化版本
  Future<bool> addCoins(int amount) async {
    if (_user == null) return false;

    try {
      _user = _user!.copyWith(
        coinBalance: _user!.coinBalance + amount,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Spend coins - 简化版本
  Future<bool> spendCoins(int amount) async {
    if (_user == null || _user!.coinBalance < amount) return false;

    try {
      _user = _user!.copyWith(
        coinBalance: _user!.coinBalance - amount,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Cancel membership - 简化版本
  Future<bool> cancelMembership() async {
    if (_user == null) return false;

    try {
      _user = _user!.copyWith(
        isPremium: false,
        membershipId: null,
        membershipStartDate: null,
        membershipEndDate: null,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Purchase coins - 简化版本
  Future<bool> purchaseCoins(String packageId, int amount, double price) async {
    if (_user == null) return false;

    try {
      // 模拟支付延迟
      await Future.delayed(const Duration(seconds: 2));
      
      _user = _user!.copyWith(
        coinBalance: _user!.coinBalance + amount,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Deduct coins - 扣除金币
  Future<bool> deductCoins(int amount) async {
    if (_user == null || _user!.coinBalance < amount) {
      return false;
    }
    
    try {
      _user = _user!.copyWith(
        coinBalance: _user!.coinBalance - amount,
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }

  // Activate membership - 开通会员
  Future<bool> activateMembership() async {
    if (_user == null || _user!.coinBalance < 9999) {
      return false;
    }
    
    try {
      // 扣除9999金币并开通会员
      _user = _user!.copyWith(
        coinBalance: _user!.coinBalance - 9999,
        isPremium: true,
        membershipStartDate: DateTime.now(),
        membershipEndDate: DateTime.now().add(const Duration(days: 365)), // 一年会员
      );
      
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
  
  // Check if membership is still valid - 检查会员是否有效
  bool get isMembershipValid {
    if (!isMembershipActive) return false;
    if (_user?.membershipEndDate == null) return false;
    return DateTime.now().isBefore(_user!.membershipEndDate!);
  }
  
  // Get membership remaining days - 获取会员剩余天数
  int get membershipRemainingDays {
    if (!isMembershipValid) return 0;
    final endDate = _user!.membershipEndDate!;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }
  
  // 处理邀请码注册
  Future<void> _handleInviteCodeRegistration(String inviteCode, String userId) async {
    try {
      final invitation = await _invitationService.confirmRegistration(inviteCode, userId);
      if (invitation != null) {
        // 注册成功，邀请人可以获得固定奖励
        print('邀请注册成功: ${invitation.inviterId} 邀请了 $userId');
      }
    } catch (e) {
      print('处理邀请码注册失败: $e');
    }
  }
  
  // 验证邀请码
  bool validateInviteCode(String inviteCode) {
    return _invitationService.isValidInviteCode(inviteCode);
  }
  
  // 获取邀请统计
  Map<String, dynamic> getInvitationStats() {
    if (_user == null) return {};
    return _invitationService.getUserInvitationStats(_user!.id);
  }
  
  // 获取邀请列表
  List<InvitationModel> getUserInvitations() {
    if (_user == null) return [];
    return _invitationService.getUserInvitations(_user!.id);
  }
  
  // 获取分成记录
  List<CommissionRecord> getUserCommissions() {
    if (_user == null) return [];
    return _invitationService.getUserCommissions(_user!.id);
  }
  
  // 领取固定奖励
  Future<bool> claimFixedReward(String invitationId) async {
    if (_user == null) return false;
    
    final success = await _invitationService.claimFixedReward(invitationId);
    if (success) {
      // 增加用户金币
      await addCoins(50);
      return true;
    }
    return false;
  }
  
  // 记录消费分成（在用户消费时调用）
  Future<void> recordConsumptionCommission({
    required int amount,
    required CommissionType type,
    required String description,
  }) async {
    if (_user == null) return;
    
    try {
      await _invitationService.recordCommission(
        inviteeId: _user!.id,
        originalAmount: amount,
        type: type,
        description: description,
      );
    } catch (e) {
      // 如果用户不是被邀请的，或者分成期已过，会抛出异常，这是正常的
      print('记录分成失败（可能用户不是被邀请的）: $e');
    }
  }
  
  // 重写消费方法，添加分成记录
  Future<bool> spendCoinsWithCommission(int amount) async {
    final success = await spendCoins(amount);
    if (success) {
      // 记录分成
      await recordConsumptionCommission(
        amount: amount,
        type: CommissionType.chatConsumption,
        description: '聊天消费 $amount 金币',
      );
    }
    return success;
  }
  
  // 重写购买金币方法，添加分成记录
  Future<bool> purchaseCoinsWithCommission(String packageId, int amount, double price) async {
    final success = await purchaseCoins(packageId, amount, price);
    if (success) {
      // 记录分成（基于购买金额）
      final coinValue = (price * 100).round(); // 假设1元=100金币用于分成计算
      await recordConsumptionCommission(
        amount: coinValue,
        type: CommissionType.coinPurchase,
        description: '购买金币 $amount 个，价值 ¥$price',
      );
    }
    return success;
  }
  
  // 重写会员激活方法，添加分成记录
  Future<bool> activateMembershipWithCommission() async {
    final success = await activateMembership();
    if (success) {
      // 记录分成
      await recordConsumptionCommission(
        amount: 9999,
        type: CommissionType.premiumUpgrade,
        description: '开通会员服务',
      );
    }
    return success;
  }

  // 签到相关功能
  DateTime? _lastCheckinDate;
  int _consecutiveCheckinDays = 0;
  List<int> _checkinHistory = []; // 存储本周签到记录
  
  // 检查今日是否可以签到
  bool canCheckinToday() {
    if (_lastCheckinDate == null) return true;
    final today = DateTime.now();
    final lastCheckin = _lastCheckinDate!;
    return !_isSameDay(today, lastCheckin);
  }
  
  // 执行签到
  Future<Map<String, dynamic>> performCheckin() async {
    if (!canCheckinToday()) {
      return {'success': false, 'message': '今日已签到，明天再来吧！'};
    }
    
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    // 检查是否连续签到
    if (_lastCheckinDate != null && _isSameDay(yesterday, _lastCheckinDate!)) {
      _consecutiveCheckinDays++;
    } else if (_lastCheckinDate == null || !_isSameDay(yesterday, _lastCheckinDate!)) {
      _consecutiveCheckinDays = 1;
    }
    
    _lastCheckinDate = today;
    
    // 更新本周签到记录
    final dayOfWeek = today.weekday;
    if (!_checkinHistory.contains(dayOfWeek)) {
      _checkinHistory.add(dayOfWeek);
    }
    
    // 基础签到奖励
    int coinsEarned = 2;
    String message = '签到成功！获得 2 金币';
    
    // 连续签到7天额外奖励
    if (_consecutiveCheckinDays >= 7) {
      coinsEarned += 10;
      message = '连续签到7天！获得 12 金币（基础2+奖励10）';
      // 重置连续签到天数
      _consecutiveCheckinDays = 0;
      _checkinHistory.clear();
    }
    
    // 添加金币
    await addCoins(coinsEarned);
    
    return {'success': true, 'message': message, 'coins': coinsEarned};
  }
  
  // 获取连续签到天数
  int getConsecutiveCheckinDays() {
    return _consecutiveCheckinDays;
  }
  
  // 获取本周签到记录
  List<int> getCheckinHistory() {
    return List.from(_checkinHistory);
  }
  
  // 检查两个日期是否为同一天
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Set data collection enabled - 简化版本
  Future<void> setDataCollectionEnabled(bool enabled) async {
    // 这里可以保存到本地存储或发送到服务器
    // 目前只是一个占位符方法
    notifyListeners();
  }

  // Update user stats - 简化版本
  void updateStats({
    int? totalMessages,
    int? daysActive,
    List<String>? favoriteGirlfriends,
  }) {
    if (_user == null) return;

    final currentStats = _user!.stats;
    final newStats = UserStats(
      totalMessages: totalMessages ?? currentStats.totalMessages,
      daysActive: daysActive ?? currentStats.daysActive,
      favoriteGirlfriends: favoriteGirlfriends ?? currentStats.favoriteGirlfriends,
    );

    _user = _user!.copyWith(stats: newStats);
    notifyListeners();
  }
}