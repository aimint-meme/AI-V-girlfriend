import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API客户端类，用于与后端API通信
class ApiClient {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _adminBaseUrl = 'http://localhost:3000/api/admin';
  
  // 单例模式
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();
  
  String? _authToken;
  String? _refreshToken;
  
  /// 初始化客户端，加载保存的token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
  }
  
  /// 设置认证token
  Future<void> setAuthTokens(String authToken, String refreshToken) async {
    _authToken = authToken;
    _refreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', authToken);
    await prefs.setString('refresh_token', refreshToken);
  }
  
  /// 清除认证token
  Future<void> clearAuthTokens() async {
    _authToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }
  
  /// 获取请求头
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// 处理HTTP响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data['message'] ?? 'Unknown error occurred',
        errors: data['errors'],
      );
    }
  }
  
  /// 刷新访问token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      return false;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: _getHeaders(includeAuth: false),
        body: json.encode({'refreshToken': _refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await setAuthTokens(
          data['data']['token'],
          data['data']['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    
    return false;
  }
  
  /// 执行带自动token刷新的请求
  Future<Map<String, dynamic>> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request();
      return _handleResponse(response);
    } on ApiException catch (e) {
      // 如果是401错误，尝试刷新token
      if (e.statusCode == 401 && await _refreshAccessToken()) {
        final response = await request();
        return _handleResponse(response);
      }
      rethrow;
    }
  }
  
  /// GET请求
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool isAdmin = false,
  }) async {
    final baseUrl = isAdmin ? _adminBaseUrl : _baseUrl;
    var uri = Uri.parse('$baseUrl$endpoint');
    
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }
    
    return _executeWithRetry(() => http.get(uri, headers: _getHeaders()));
  }
  
  /// POST请求
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool isAdmin = false,
  }) async {
    final baseUrl = isAdmin ? _adminBaseUrl : _baseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return _executeWithRetry(() => http.post(
      uri,
      headers: _getHeaders(),
      body: json.encode(data),
    ));
  }
  
  /// PUT请求
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool isAdmin = false,
  }) async {
    final baseUrl = isAdmin ? _adminBaseUrl : _baseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return _executeWithRetry(() => http.put(
      uri,
      headers: _getHeaders(),
      body: json.encode(data),
    ));
  }
  
  /// DELETE请求
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool isAdmin = false,
  }) async {
    final baseUrl = isAdmin ? _adminBaseUrl : _baseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    
    return _executeWithRetry(() => http.delete(uri, headers: _getHeaders()));
  }
  
  /// 上传文件
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool isAdmin = false,
  }) async {
    final baseUrl = isAdmin ? _adminBaseUrl : _baseUrl;
    final uri = Uri.parse('$baseUrl$endpoint');
    
    final request = http.MultipartRequest('POST', uri);
    
    // 添加认证头
    if (_authToken != null) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }
    
    // 添加文件
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    
    // 添加额外字段
    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }
  
  /// 检查网络连接
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/../health'),
        headers: _getHeaders(includeAuth: false),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取当前用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await get('/auth/me');
  }
  
  /// 用户登录
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    // 保存token
    if (response['success'] == true && response['data'] != null) {
      await setAuthTokens(
        response['data']['token'],
        response['data']['refreshToken'],
      );
    }
    
    return response;
  }
  
  /// 用户注册
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await post('/auth/register', {
      'username': username,
      'email': email,
      'password': password,
    });
    
    // 保存token
    if (response['success'] == true && response['data'] != null) {
      await setAuthTokens(
        response['data']['token'],
        response['data']['refreshToken'],
      );
    }
    
    return response;
  }
  
  /// 用户登出
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await post('/auth/logout', {
        'refreshToken': _refreshToken,
      });
      
      await clearAuthTokens();
      return response;
    } catch (e) {
      // 即使请求失败也要清除本地token
      await clearAuthTokens();
      rethrow;
    }
  }
  
  /// 发送聊天消息
  Future<Map<String, dynamic>> sendMessage(
    String message,
    String characterId, {
    String? conversationId,
  }) async {
    return await post('/chat/send', {
      'message': message,
      'characterId': characterId,
      if (conversationId != null) 'conversationId': conversationId,
    });
  }
  
  /// 获取聊天历史
  Future<Map<String, dynamic>> getChatHistory(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    return await get('/chat/history/$conversationId', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }
  
  /// 获取对话列表
  Future<Map<String, dynamic>> getConversations({
    int page = 1,
    int limit = 20,
    bool archived = false,
  }) async {
    return await get('/chat/conversations', queryParams: {
      'page': page.toString(),
      'limit': limit.toString(),
      'archived': archived.toString(),
    });
  }
  
  /// 获取用户角色列表
  Future<Map<String, dynamic>> getUserCharacters({
    int page = 1,
    int limit = 10,
    bool? active,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (active != null) {
      queryParams['active'] = active.toString();
    }
    
    return await get('/user/characters', queryParams: queryParams);
  }
  
  /// 获取用户统计信息
  Future<Map<String, dynamic>> getUserStatistics() async {
    return await get('/user/statistics');
  }
  
  /// 更新用户资料
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    return await put('/user/profile', profileData);
  }
  
  /// 上传头像
  Future<Map<String, dynamic>> uploadAvatar(File avatarFile) async {
    return await uploadFile('/user/avatar', avatarFile, fieldName: 'avatar');
  }
}

/// API异常类
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<dynamic>? errors;
  
  ApiException({
    required this.statusCode,
    required this.message,
    this.errors,
  });
  
  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
  
  /// 是否为网络错误
  bool get isNetworkError => statusCode == 0;
  
  /// 是否为认证错误
  bool get isAuthError => statusCode == 401;
  
  /// 是否为权限错误
  bool get isForbiddenError => statusCode == 403;
  
  /// 是否为服务器错误
  bool get isServerError => statusCode >= 500;
  
  /// 是否为客户端错误
  bool get isClientError => statusCode >= 400 && statusCode < 500;
}

/// API响应包装类
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<dynamic>? errors;
  
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      errors: json['errors'],
    );
  }
}