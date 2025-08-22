import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userInfo;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthState();
  }

  // 加载认证状态
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final userInfoJson = prefs.getString('user_info');
      
      if (_token != null && userInfoJson != null) {
        _isAuthenticated = true;
        // 这里可以解析用户信息JSON
        _userInfo = {
          'id': '1',
          'username': 'admin',
          'email': 'admin@example.com',
          'role': 'super_admin',
          'avatar': '',
        };
      }
    } catch (e) {
      debugPrint('加载认证状态失败: $e');
    }
    notifyListeners();
  }

  // 登录
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      // 简单的用户名密码验证（实际项目中应该调用API）
      if (username == 'admin' && password == 'admin123') {
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
        _userInfo = {
          'id': '1',
          'username': username,
          'email': 'admin@example.com',
          'role': 'super_admin',
          'avatar': '',
          'permissions': [
            'user_management',
            'content_management',
            'character_management',
            'data_monitoring',
            'activity_config',
            'risk_control',
            'payment_management',
            'service_management',
            'system_settings',
          ],
        };
        _isAuthenticated = true;
        
        // 保存到本地存储
        await _saveAuthState();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('登录失败: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 登出
  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _userInfo = null;
    
    // 清除本地存储
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_info');
    
    notifyListeners();
  }

  // 保存认证状态
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('auth_token', _token!);
      }
      if (_userInfo != null) {
        // 实际项目中应该序列化为JSON
        await prefs.setString('user_info', 'user_info_json');
      }
    } catch (e) {
      debugPrint('保存认证状态失败: $e');
    }
  }

  // 检查权限
  bool hasPermission(String permission) {
    if (_userInfo == null) return false;
    final permissions = _userInfo!['permissions'] as List<String>?;
    return permissions?.contains(permission) ?? false;
  }

  // 获取用户角色
  String get userRole => _userInfo?['role'] ?? 'guest';

  // 获取用户名
  String get username => _userInfo?['username'] ?? 'Unknown';

  // 获取用户邮箱
  String get userEmail => _userInfo?['email'] ?? '';

  // 获取用户头像
  String get userAvatar => _userInfo?['avatar'] ?? '';

  // 刷新token
  Future<bool> refreshToken() async {
    try {
      // 模拟刷新token的API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _token = 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}';
      await _saveAuthState();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('刷新token失败: $e');
      return false;
    }
  }

  // 更新用户信息
  Future<bool> updateUserInfo(Map<String, dynamic> newUserInfo) async {
    try {
      // 模拟更新用户信息的API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _userInfo = {..._userInfo!, ...newUserInfo};
      await _saveAuthState();
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('更新用户信息失败: $e');
      return false;
    }
  }
}