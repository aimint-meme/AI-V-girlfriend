import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic> _dashboardData = {};
  List<Map<String, dynamic>> _recentActivities = [];
  Map<String, dynamic> _systemStats = {};
  List<Map<String, dynamic>> _chartData = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic> get dashboardData => _dashboardData;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  Map<String, dynamic> get systemStats => _systemStats;
  List<Map<String, dynamic>> get chartData => _chartData;

  DashboardProvider() {
    loadDashboardData();
  }

  // 加载仪表板数据
  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _dashboardData = {
        'totalUsers': 15420,
        'activeUsers': 8965,
        'totalRevenue': 125680.50,
        'monthlyRevenue': 28450.30,
        'totalCharacters': 156,
        'activeCharacters': 89,
        'totalConversations': 45230,
        'todayConversations': 1250,
        'userGrowthRate': 12.5,
        'revenueGrowthRate': 8.3,
        'characterUsageRate': 76.2,
        'systemUptime': 99.8,
      };

      _systemStats = {
        'cpuUsage': 45.2,
        'memoryUsage': 68.7,
        'diskUsage': 34.1,
        'networkTraffic': 125.6,
        'activeConnections': 2340,
        'errorRate': 0.02,
        'responseTime': 120,
        'throughput': 1500,
      };

      _recentActivities = [
        {
          'id': '1',
          'type': 'user_register',
          'title': '新用户注册',
          'description': '用户 user123 完成注册',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
          'icon': 'person_add',
          'color': 'success',
        },
        {
          'id': '2',
          'type': 'payment',
          'title': '支付成功',
          'description': '用户 user456 购买会员服务，金额 ¥99',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
          'icon': 'payment',
          'color': 'info',
        },
        {
          'id': '3',
          'type': 'character_create',
          'title': '角色创建',
          'description': '管理员创建新角色「小雪」',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
          'icon': 'person',
          'color': 'primary',
        },
        {
          'id': '4',
          'type': 'system_alert',
          'title': '系统告警',
          'description': '服务器CPU使用率超过80%',
          'timestamp': DateTime.now().subtract(const Duration(minutes: 35)),
          'icon': 'warning',
          'color': 'warning',
        },
        {
          'id': '5',
          'type': 'content_update',
          'title': '内容更新',
          'description': '更新了10个对话模板',
          'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
          'icon': 'edit',
          'color': 'secondary',
        },
      ];

      _chartData = _generateChartData();
      
    } catch (e) {
      debugPrint('加载仪表板数据失败: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 生成图表数据
  List<Map<String, dynamic>> _generateChartData() {
    final now = DateTime.now();
    final chartData = <Map<String, dynamic>>[];
    
    // 生成过去30天的数据
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      chartData.add({
        'date': date,
        'users': 300 + (i * 10) + (i % 7 * 50), // 模拟用户增长
        'revenue': 1000 + (i * 50) + (i % 5 * 200), // 模拟收入增长
        'conversations': 500 + (i * 20) + (i % 3 * 100), // 模拟对话量
        'activeCharacters': 20 + (i % 10), // 模拟活跃角色数
      });
    }
    
    return chartData;
  }

  // 刷新数据
  Future<void> refreshData() async {
    await loadDashboardData();
  }

  // 获取用户统计
  Map<String, dynamic> getUserStats() {
    return {
      'total': _dashboardData['totalUsers'] ?? 0,
      'active': _dashboardData['activeUsers'] ?? 0,
      'growthRate': _dashboardData['userGrowthRate'] ?? 0,
      'newToday': 125, // 今日新增用户
      'retention': 78.5, // 用户留存率
    };
  }

  // 获取收入统计
  Map<String, dynamic> getRevenueStats() {
    return {
      'total': _dashboardData['totalRevenue'] ?? 0,
      'monthly': _dashboardData['monthlyRevenue'] ?? 0,
      'growthRate': _dashboardData['revenueGrowthRate'] ?? 0,
      'todayRevenue': 2450.80, // 今日收入
      'averagePerUser': 8.15, // 用户平均收入
    };
  }

  // 获取角色统计
  Map<String, dynamic> getCharacterStats() {
    return {
      'total': _dashboardData['totalCharacters'] ?? 0,
      'active': _dashboardData['activeCharacters'] ?? 0,
      'usageRate': _dashboardData['characterUsageRate'] ?? 0,
      'popular': 'AI助手小雪', // 最受欢迎角色
      'newThisWeek': 5, // 本周新增角色
    };
  }

  // 获取对话统计
  Map<String, dynamic> getConversationStats() {
    return {
      'total': _dashboardData['totalConversations'] ?? 0,
      'today': _dashboardData['todayConversations'] ?? 0,
      'averageLength': 15.6, // 平均对话轮数
      'satisfaction': 4.2, // 用户满意度
      'peakHour': '20:00-21:00', // 高峰时段
    };
  }

  // 获取系统健康状态
  String getSystemHealthStatus() {
    final uptime = _dashboardData['systemUptime'] ?? 0;
    if (uptime >= 99.5) return 'excellent';
    if (uptime >= 99.0) return 'good';
    if (uptime >= 95.0) return 'fair';
    return 'poor';
  }

  // 获取告警数量
  int getAlertCount() {
    return _recentActivities
        .where((activity) => activity['type'] == 'system_alert')
        .length;
  }

  // 添加新活动
  void addActivity(Map<String, dynamic> activity) {
    _recentActivities.insert(0, activity);
    // 只保留最近50条活动
    if (_recentActivities.length > 50) {
      _recentActivities = _recentActivities.take(50).toList();
    }
    notifyListeners();
  }

  // 更新系统统计
  void updateSystemStats(Map<String, dynamic> newStats) {
    _systemStats = {..._systemStats, ...newStats};
    notifyListeners();
  }

  // 获取趋势数据
  List<Map<String, dynamic>> getTrendData(String metric, int days) {
    return _chartData.take(days).map((data) => {
      'date': data['date'],
      'value': data[metric] ?? 0,
    }).toList();
  }

  // 获取热门功能使用统计
  List<Map<String, dynamic>> getFeatureUsageStats() {
    return [
      {'name': '智能对话', 'usage': 85.6, 'trend': 'up'},
      {'name': '角色定制', 'usage': 72.3, 'trend': 'up'},
      {'name': '情感分析', 'usage': 68.9, 'trend': 'stable'},
      {'name': '语音交互', 'usage': 45.2, 'trend': 'up'},
      {'name': '图片生成', 'usage': 38.7, 'trend': 'down'},
      {'name': '知识问答', 'usage': 56.4, 'trend': 'up'},
    ];
  }

  // 获取地区分布数据
  List<Map<String, dynamic>> getRegionDistribution() {
    return [
      {'region': '华东', 'users': 4520, 'percentage': 29.3},
      {'region': '华南', 'users': 3680, 'percentage': 23.9},
      {'region': '华北', 'users': 3210, 'percentage': 20.8},
      {'region': '西南', 'users': 2150, 'percentage': 13.9},
      {'region': '华中', 'users': 1860, 'percentage': 12.1},
    ];
  }
}