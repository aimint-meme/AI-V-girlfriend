import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserManagementProvider extends ChangeNotifier {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  UserStatistics? _statistics;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  UserStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 统计数据快捷访问
  int get totalUsers => _statistics?.totalUsers ?? 0;
  int get activeUsers => _statistics?.activeUsers ?? 0;
  int get memberUsers => _statistics?.memberUsers ?? 0;
  int get todayNewUsers => _statistics?.todayNewUsers ?? 0;
  int get onlineUsers => _statistics?.onlineUsers ?? 0;

  // 行为分析数据
  int get dailyActiveUsers => 8520;
  double get dauTrend => 12.5;
  double get avgSessionDuration => 25.8;
  double get sessionTrend => 8.3;
  double get retentionRate => 78.5;
  double get retentionTrend => 5.2;
  double get bounceRate => 15.3;
  double get bounceTrend => -2.1;

  // 加载用户数据
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _users = _generateMockUsers();
      _filteredUsers = List.from(_users);
      _statistics = _generateMockStatistics();
      
    } catch (e) {
      _error = '加载用户数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 应用筛选条件
  void applyFilters({
    String? searchQuery,
    String? status,
    String? membershipType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    _filteredUsers = _users.where((user) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!user.id.toLowerCase().contains(query) &&
            !user.username.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态筛选
      if (status != null && user.status != status) {
        return false;
      }

      // 会员类型筛选
      if (membershipType != null && user.membershipType != membershipType) {
        return false;
      }

      // 日期范围筛选
      if (startDate != null && user.createdAt.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && user.createdAt.isAfter(endDate.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 排序用户
  void sortUsers(int columnIndex, bool ascending) {
    _filteredUsers.sort((a, b) {
      int result = 0;
      
      switch (columnIndex) {
        case 0: // 用户ID
          result = a.id.compareTo(b.id);
          break;
        case 1: // 用户名
          result = a.username.compareTo(b.username);
          break;
        case 6: // 注册时间
          result = a.createdAt.compareTo(b.createdAt);
          break;
        default:
          result = 0;
      }
      
      return ascending ? result : -result;
    });
    
    notifyListeners();
  }

  // 添加用户
  Future<bool> addUser(UserModel user) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _users.add(user);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '添加用户失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新用户
  Future<bool> updateUser(UserModel user) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        applyFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '更新用户失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除用户
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _users.removeWhere((user) => user.id == userId);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '删除用户失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 批量删除用户
  Future<bool> batchDeleteUsers(List<String> userIds) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      _users.removeWhere((user) => userIds.contains(user.id));
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '批量删除用户失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换用户状态
  Future<bool> toggleUserStatus(String userId) async {
    try {
      final userIndex = _users.indexWhere((user) => user.id == userId);
      if (userIndex == -1) return false;
      
      final user = _users[userIndex];
      final newStatus = user.status == '正常' ? '禁用' : '正常';
      
      _users[userIndex] = user.copyWith(status: newStatus);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '切换用户状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 重置用户密码
  Future<bool> resetUserPassword(String userId) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里应该调用实际的重置密码API
      debugPrint('重置用户 $userId 的密码');
      
      return true;
    } catch (e) {
      _error = '重置密码失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 获取用户详情
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // 导出用户数据
  Future<List<Map<String, dynamic>>> exportUsers(List<String>? userIds) async {
    try {
      final usersToExport = userIds != null
          ? _users.where((user) => userIds.contains(user.id)).toList()
          : _filteredUsers;
      
      return usersToExport.map((user) => user.toJson()).toList();
    } catch (e) {
      _error = '导出用户数据失败: $e';
      debugPrint(_error);
      return [];
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟用户数据
  List<UserModel> _generateMockUsers() {
    final users = <UserModel>[];
    final statuses = ['正常', '禁用', '待验证'];
    final membershipTypes = ['普通用户', '会员', '高级会员', '终身会员'];
    final names = ['张三', '李四', '王五', '赵六', '钱七', '孙八', '周九', '吴十'];
    
    for (int i = 1; i <= 50; i++) {
      final createdAt = DateTime.now().subtract(Duration(days: i * 2));
      final lastLoginAt = DateTime.now().subtract(Duration(hours: i));
      
      users.add(UserModel(
        id: 'user_${i.toString().padLeft(6, '0')}',
        username: '${names[i % names.length]}$i',
        email: 'user$i@example.com',
        phone: '138${(1000000000 + i).toString().substring(1)}',
        status: statuses[i % statuses.length],
        membershipType: membershipTypes[i % membershipTypes.length],
        balance: (i * 10.5) % 1000,
        coins: (i * 100) % 10000,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt,
        profile: {
          'age': 18 + (i % 50),
          'gender': i % 2 == 0 ? '男' : '女',
          'location': '北京市',
        },
        tags: ['活跃用户', '付费用户'].take(i % 3).toList(),
        intimacyLevel: i % 100,
        totalSpent: (i * 25.8) % 2000,
        conversationCount: i * 15,
        isOnline: i % 5 == 0,
        lastActiveCharacter: i % 3 == 0 ? '小雪' : null,
      ));
    }
    
    return users;
  }

  // 生成模拟统计数据
  UserStatistics _generateMockStatistics() {
    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => 
        DateTime.now().difference(u.lastLoginAt).inDays <= 7).length;
    final memberUsers = _users.where((u) => u.isMember).length;
    final todayNewUsers = _users.where((u) => 
        DateTime.now().difference(u.createdAt).inDays == 0).length;
    final onlineUsers = _users.where((u) => u.isOnline).length;
    
    return UserStatistics(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      memberUsers: memberUsers,
      todayNewUsers: todayNewUsers,
      onlineUsers: onlineUsers,
      averageBalance: _users.isEmpty ? 0 : 
          _users.map((u) => u.balance).reduce((a, b) => a + b) / _users.length,
      totalRevenue: _users.map((u) => u.totalSpent).fold(0.0, (a, b) => a + b),
      membershipDistribution: {
        '普通用户': _users.where((u) => u.membershipType == '普通用户').length,
        '会员': _users.where((u) => u.membershipType == '会员').length,
        '高级会员': _users.where((u) => u.membershipType == '高级会员').length,
        '终身会员': _users.where((u) => u.membershipType == '终身会员').length,
      },
      statusDistribution: {
        '正常': _users.where((u) => u.status == '正常').length,
        '禁用': _users.where((u) => u.status == '禁用').length,
        '待验证': _users.where((u) => u.status == '待验证').length,
      },
      registrationTrend: {
        '今日': todayNewUsers,
        '昨日': _users.where((u) => 
            DateTime.now().difference(u.createdAt).inDays == 1).length,
        '本周': _users.where((u) => 
            DateTime.now().difference(u.createdAt).inDays <= 7).length,
        '本月': _users.where((u) => 
            DateTime.now().difference(u.createdAt).inDays <= 30).length,
      },
    );
  }

  // 加载用户行为数据
  Future<void> loadUserBehaviorData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载行为分析相关的数据
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载行为数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}