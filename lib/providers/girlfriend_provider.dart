import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/girlfriend_model.dart';

class GirlfriendProvider with ChangeNotifier {
  List<GirlfriendModel> _girlfriends = [];
  GirlfriendModel? _currentGirlfriend;
  bool _isInitialized = false;

  List<GirlfriendModel> get girlfriends => [..._girlfriends];
  GirlfriendModel? get currentGirlfriend => _currentGirlfriend;
  bool get isInitialized => _isInitialized;
  
  // 构造函数中初始化数据
  GirlfriendProvider() {
    _initializeProvider();
  }
  
  // 初始化Provider
  Future<void> _initializeProvider() async {
    try {
      debugPrint('=== GirlfriendProvider 初始化开始 ===');
      await loadGirlfriends();
      _isInitialized = true;
      debugPrint('=== GirlfriendProvider 初始化完成 ===');
      notifyListeners();
    } catch (e) {
      debugPrint('GirlfriendProvider 初始化失败: $e');
      // 即使初始化失败，也要设置为已初始化状态，避免阻塞应用
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  // 添加新女友
  Future<void> addGirlfriend(GirlfriendModel girlfriend) async {
    try {
      debugPrint('=== GirlfriendProvider.addGirlfriend 开始 ===');
      debugPrint('接收到的女友信息: ${girlfriend.name}, ID: ${girlfriend.id}');
      debugPrint('当前女友列表长度: ${_girlfriends.length}');
      
      // 在实际应用中，这里应该调用API保存到服务器
      // 这里我们只是添加到本地列表
      debugPrint('开始模拟网络延迟');
      await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟
      debugPrint('网络延迟结束');
      
      debugPrint('添加女友到列表');
      _girlfriends.add(girlfriend);
      debugPrint('女友已添加，新的列表长度: ${_girlfriends.length}');
      
      // 保存到本地存储
      debugPrint('开始保存到本地存储');
      await _saveGirlfriends();
      debugPrint('本地存储保存完成');
      
      debugPrint('通知监听器');
      notifyListeners();
      debugPrint('=== GirlfriendProvider.addGirlfriend 完成 ===');
    } catch (error) {
      debugPrint('GirlfriendProvider.addGirlfriend 发生错误: $error');
      debugPrint('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  // Demo girlfriends for testing - 包含虚拟和真实女友
  final List<GirlfriendModel> _demoGirlfriends = [
    // 虚拟女友 - 已沟通过，显示亲密度
    GirlfriendModel(
      id: 'gf-1',
      name: '小雪',
      avatarUrl: 'https://i.pravatar.cc/300?img=1',
      personality: '温柔可爱',
      description: '温柔体贴的女孩，喜欢烹饪和阅读，总是能给你带来温暖的感觉。',
      intimacy: 75,
      isPremium: false,
      isVirtual: true,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      lastMessage: '今天过得怎么样？',
      traits: {
        'interests': ['烹饪', '阅读', '旅行'],
        'personality_traits': ['温柔', '体贴', '善解人意'],
        'communication_style': '温和',
        'age': 24,
        'height': 165,
        'price': 800,
        'region': '北京',
      },
      tags: ['温柔', '甜美', '邻家', '书香'],
    ),
    // 真实女友
    GirlfriendModel(
      id: 'gf-2',
      name: '小琳',
      avatarUrl: 'https://i.pravatar.cc/300?img=9',
      personality: '活泼开朗',
      description: '充满活力的女孩，喜欢运动和户外活动，总是能带给你快乐和惊喜。',
      intimacy: 60,
      isPremium: false,
      isVirtual: false,
      traits: {
        'interests': ['运动', '旅行', '摄影'],
        'personality_traits': ['活泼', '开朗', '幽默'],
        'communication_style': '直接',
        'age': 26,
        'height': 168,
        'price': 600,
        'region': '上海',
        'services': ['可飞', '可口'],
      },
      tags: ['活泼', '开朗', '运动', '阳光'],
    ),
    // 虚拟女友 - 未沟通过，不显示亲密度
    GirlfriendModel(
      id: 'gf-3',
      name: '小冰',
      avatarUrl: 'https://i.pravatar.cc/300?img=3',
      personality: '冷酷御姐',
      description: '外表冷酷内心温柔的女孩，喜欢音乐和艺术，需要时间才能敞开心扉。',
      intimacy: 45,
      isPremium: false,
      isVirtual: true,
      // lastMessageTime: null, // 未沟通过
      traits: {
        'interests': ['音乐', '艺术', '电影'],
        'personality_traits': ['冷静', '理性', '神秘'],
        'communication_style': '含蓄',
        'age': 28,
        'height': 170,
        'price': 1200,
        'region': '广州',
      },
      tags: ['冷酷', '御姐', '神秘', '艺术'],
    ),
    // 真实女友
    GirlfriendModel(
      id: 'gf-4',
      name: '小樱',
      avatarUrl: 'https://i.pravatar.cc/300?img=5',
      personality: '知性优雅',
      description: '知性优雅的女孩，喜欢文学和哲学，能与你进行深度的思想交流。',
      intimacy: 30,
      isPremium: true,
      isVirtual: false,
      cupSize: 'D',
      traits: {
        'interests': ['文学', '哲学', '历史'],
        'personality_traits': ['知性', '优雅', '深思熟虑'],
        'communication_style': '睿智',
        'age': 25,
        'height': 162,
        'price': 1500,
        'region': '深圳',
        'services': ['三通'],
        'fee': 2000,
      },
      tags: ['知性', '优雅', '文学', '深度'],
    ),
    // 虚拟女友 - 已沟通过，显示亲密度
     GirlfriendModel(
      id: 'gf-5',
      name: '小菲',
      avatarUrl: 'https://i.pravatar.cc/300?img=7',
      personality: '俏皮可爱',
      description: '俏皮可爱的女孩，喜欢动漫和游戏，总是能给你带来欢笑。',
      intimacy: 20,
      isPremium: true,
      isVirtual: true,
      cupSize: 'C',
      lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      lastMessage: '今天想玩什么游戏呢？',
      traits: {
        'interests': ['动漫', '游戏', 'cosplay'],
        'personality_traits': ['俏皮', '可爱', '天真'],
        'communication_style': '活泼',
        'age': 22,
        'height': 158,
        'price': 500,
        'region': '杭州',
      },
      tags: ['俏皮', '可爱', '二次元', '游戏'],
    ),
    // 真实女友
     GirlfriendModel(
       id: 'gf-6',
       name: '小琳',
      avatarUrl: 'https://i.pravatar.cc/300?img=8',
      personality: '成熟稳重',
      description: '成熟稳重的女性，事业有成，能给你人生指导和情感支持。',
      intimacy: 40,
      isPremium: true,
      isVirtual: false,
      cupSize: 'E',
      traits: {
        'interests': ['商业', '投资', '健身'],
        'personality_traits': ['成熟', '稳重', '独立'],
        'communication_style': '理性',
        'age': 30,
        'height': 172,
        'price': 2000,
        'region': '成都',
        'services': ['可飞', '三通'],
        'fee': 3000,
      },
      tags: ['成熟', '稳重', '事业', '独立'],
    ),
  ];

  // Load girlfriends from API or local storage
  Future<void> loadGirlfriends() async {
    try {
      // In a real app, we would fetch from API
      // For demo, we'll load from local storage and add demo girlfriends if empty
      await Future.delayed(const Duration(seconds: 1));
      
      // 从本地存储加载女友列表
      final prefs = await SharedPreferences.getInstance();
      final List<String>? girlfriendsJson = prefs.getStringList('girlfriends');
      
      if (girlfriendsJson != null && girlfriendsJson.isNotEmpty) {
        // 解析JSON并创建女友模型
        final List<GirlfriendModel> loadedGirlfriends = girlfriendsJson
            .map((json) => jsonDecode(json))
            .map((data) => GirlfriendModel.fromJson(data))
            .toList();
        
        // 合并用户创建的女友和演示女友
        _girlfriends = [...loadedGirlfriends];
        
        // 确保演示女友也存在（避免重复添加）
        for (var demoGf in _demoGirlfriends) {
          if (!_girlfriends.any((gf) => gf.id == demoGf.id)) {
            _girlfriends.add(demoGf);
          }
        }
      } else {
        // 如果本地存储为空，使用演示女友
        _girlfriends = [..._demoGirlfriends];
      }
      
      // Load current girlfriend if exists
      await _loadCurrentGirlfriend();
      
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Set current girlfriend
  void setCurrentGirlfriend(GirlfriendModel girlfriend) async {
    _currentGirlfriend = girlfriend;
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_girlfriend_id', girlfriend.id);
    
    notifyListeners();
  }

  // Load current girlfriend from preferences
  Future<void> _loadCurrentGirlfriend() async {
    final prefs = await SharedPreferences.getInstance();
    final currentGirlfriendId = prefs.getString('current_girlfriend_id');
    
    if (currentGirlfriendId != null && _girlfriends.isNotEmpty) {
      _currentGirlfriend = _girlfriends.firstWhere(
        (gf) => gf.id == currentGirlfriendId,
        orElse: () => _girlfriends.first,
      );
    } else if (_girlfriends.isNotEmpty) {
      _currentGirlfriend = _girlfriends.first;
    }
  }

  // Update girlfriend intimacy
  Future<void> updateIntimacy(String girlfriendId, int amount) async {
    final index = _girlfriends.indexWhere((gf) => gf.id == girlfriendId);
    
    if (index != -1) {
      final girlfriend = _girlfriends[index];
      final newIntimacy = girlfriend.intimacy + amount;
      
      _girlfriends[index] = girlfriend.copyWith(intimacy: newIntimacy);
      
      if (_currentGirlfriend?.id == girlfriendId) {
        _currentGirlfriend = _girlfriends[index];
      }
      
      // 保存更新后的女友列表到本地存储
      await _saveGirlfriends();
      
      notifyListeners();
    }
  }

  // Get girlfriend by ID
  GirlfriendModel? getGirlfriendById(String id) {
    try {
      return _girlfriends.firstWhere((gf) => gf.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Update last message for a girlfriend
  Future<void> updateLastMessage(String girlfriendId, String message) async {
    final index = _girlfriends.indexWhere((gf) => gf.id == girlfriendId);
    
    if (index != -1) {
      final girlfriend = _girlfriends[index];
      _girlfriends[index] = girlfriend.copyWith(
        lastMessage: message,
        lastMessageTime: DateTime.now(),
      );
      
      if (_currentGirlfriend?.id == girlfriendId) {
        _currentGirlfriend = _girlfriends[index];
      }
      
      // 保存更新后的女友列表到本地存储
      await _saveGirlfriends();
      
      notifyListeners();
    }
  }
  
  // Update online status for a girlfriend
  Future<void> updateOnlineStatus(String girlfriendId, bool isOnline) async {
    final index = _girlfriends.indexWhere((gf) => gf.id == girlfriendId);
    
    if (index != -1) {
      final girlfriend = _girlfriends[index];
      _girlfriends[index] = girlfriend.copyWith(isOnline: isOnline);
      
      if (_currentGirlfriend?.id == girlfriendId) {
        _currentGirlfriend = _girlfriends[index];
      }
      
      notifyListeners();
    }
  }
  
  // Update girlfriend information
  Future<void> updateGirlfriend(GirlfriendModel updatedGirlfriend) async {
    final index = _girlfriends.indexWhere((gf) => gf.id == updatedGirlfriend.id);
    
    if (index != -1) {
      _girlfriends[index] = updatedGirlfriend;
      
      if (_currentGirlfriend?.id == updatedGirlfriend.id) {
        _currentGirlfriend = updatedGirlfriend;
      }
      
      // 保存更新后的女友列表到本地存储
      await _saveGirlfriends();
      
      notifyListeners();
    }
  }
  
  // 保存女友列表到本地存储
  Future<void> _saveGirlfriends() async {
    try {
      debugPrint('=== _saveGirlfriends 开始 ===');
      debugPrint('准备保存的女友数量: ${_girlfriends.length}');
      
      final prefs = await SharedPreferences.getInstance();
      debugPrint('SharedPreferences 实例获取成功');
      
      final List<String> girlfriendsJson = _girlfriends
          .map((gf) => gf.toJson())
          .map((json) => jsonEncode(json))
          .toList();
      debugPrint('JSON序列化完成，序列化后数量: ${girlfriendsJson.length}');
      
      await prefs.setStringList('girlfriends', girlfriendsJson);
      debugPrint('保存女友列表成功');
      debugPrint('=== _saveGirlfriends 完成 ===');
    } catch (error) {
      debugPrint('保存女友列表失败: $error');
      debugPrint('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }
}