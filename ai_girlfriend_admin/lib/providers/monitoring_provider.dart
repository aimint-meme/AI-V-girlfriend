import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/monitoring_model.dart';

class MonitoringProvider extends ChangeNotifier {
  SystemMetrics? _systemMetrics;
  SystemInfo? _systemInfo;
  UserActivityMetrics? _userMetrics;
  List<ProcessInfo> _topProcesses = [];
  Map<String, ApiEndpoint> _apiEndpoints = {};
  List<AlertModel> _alerts = [];
  
  // 历史数据
  List<double> _cpuHistory = [];
  List<double> _memoryHistory = [];
  List<double> _networkInHistory = [];
  List<double> _networkOutHistory = [];
  List<int> _activeUsersHistory = [];
  
  // 实时监控状态
  bool _isRealTimeActive = false;
  Timer? _realTimeTimer;
  Timer? _autoRefreshTimer;
  bool _isLoading = false;
  String? _error;
  String _currentTimeRange = '最近1小时';

  // 模型监控数据
  int _totalCalls = 0;
  int _todayCalls = 0;
  double _callsTrend = 0.0;
  
  int _avgResponseTime = 0;
  double _responseTimeTrend = 0.0;
  
  double _successRate = 0.0;
  double _successRateTrend = 0.0;
  
  int _totalTokens = 0;
  int _todayTokens = 0;
  double _tokensTrend = 0.0;
  
  // 图表数据
  List<FlSpot> _callVolumeData = [];
  List<PieChartSectionData> _modelUsageData = [];
  List<Map<String, dynamic>> _peakHours = [];
  
  List<FlSpot> _responseTimeData = [];
  List<BarChartGroupData> _responseTimeDistribution = [];
  
  // 性能指标
  int _p50ResponseTime = 0;
  int _p90ResponseTime = 0;
  int _p99ResponseTime = 0;
  int _maxResponseTime = 0;
  int _minResponseTime = 0;
  
  // 模型性能数据
  List<Map<String, dynamic>> _modelPerformanceData = [];
  List<FlSpot> _tokenUsageData = [];
  
  // 成本数据
  double _todayCost = 0.0;
  double _monthCost = 0.0;
  double _estimatedMonthlyCost = 0.0;
  double _avgCostPerCall = 0.0;
  double _avgCostPerToken = 0.0;
  
  // 错误分析数据
  List<PieChartSectionData> _errorTypeData = [];
  List<FlSpot> _errorTrendData = [];
  List<Map<String, dynamic>> _recentErrors = [];
  
  // 商业数据
  double _totalRevenue = 0.0;
  double _monthlyRevenue = 0.0;
  double _revenueTrend = 0.0;
  
  double _arpu = 0.0;
  double _arpuTrend = 0.0;
  
  int _payingUsers = 0;
  double _paymentRate = 0.0;
  double _payingUsersTrend = 0.0;
  
  double _ltv = 0.0;
  double _ltvCacRatio = 0.0;
  double _ltvTrend = 0.0;
  
  // 收入分析数据
  List<FlSpot> _revenueData = [];
  List<PieChartSectionData> _revenueSourceData = [];
  List<Map<String, dynamic>> _revenueGrowthMetrics = [];
  
  // 用户变现数据
  List<Map<String, dynamic>> _conversionFunnelData = [];
  List<BarChartGroupData> _userValueDistribution = [];
  double _paymentConversionRate = 0.0;
  double _userRetentionRate = 0.0;
  double _avgSessionDuration = 0.0;
  int _monthlyActiveUsers = 0;
  double _churnRate = 0.0;
  
  // 产品销售数据
  List<Map<String, dynamic>> _productSalesData = [];
  List<PieChartSectionData> _salesChannelData = [];
  List<FlSpot> _salesTrendData = [];
  
  // 盈利分析数据
  double _grossMargin = 0.0;
  double _grossMarginTrend = 0.0;
  double _netMargin = 0.0;
  double _netMarginTrend = 0.0;
  double _roi = 0.0;
  double _roiTrend = 0.0;
  double _roas = 0.0;
  double _roasTrend = 0.0;
  
  List<PieChartSectionData> _costStructureData = [];
  List<FlSpot> _profitForecastData = [];
  
  // 财务健康度
  double _cashFlowHealth = 0.0;
  double _profitabilityHealth = 0.0;
  double _growthHealth = 0.0;
  double _costControlHealth = 0.0;

  // Getters
  SystemMetrics? get systemMetrics => _systemMetrics;
  SystemInfo? get systemInfo => _systemInfo;
  UserActivityMetrics? get userMetrics => _userMetrics;
  List<ProcessInfo> get topProcesses => _topProcesses;
  Map<String, ApiEndpoint> get apiEndpoints => _apiEndpoints;
  List<AlertModel> get alerts => _alerts;
  
  List<double> get cpuHistory => _cpuHistory;
  List<double> get memoryHistory => _memoryHistory;
  List<double> get networkInHistory => _networkInHistory;
  List<double> get networkOutHistory => _networkOutHistory;
  List<int> get activeUsersHistory => _activeUsersHistory;
  
  bool get isRealTimeActive => _isRealTimeActive;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentTimeRange => _currentTimeRange;

  // 用户活跃度数据快捷访问
  int get currentOnlineUsers => _userMetrics?.currentOnlineUsers ?? 0;
  int get todayNewUsers => _userMetrics?.todayNewUsers ?? 0;
  
  // 模型监控数据 getters
  int get totalCalls => _totalCalls;
  int get todayCalls => _todayCalls;
  double get callsTrend => _callsTrend;
  
  int get avgResponseTime => _avgResponseTime;
  double get responseTimeTrend => _responseTimeTrend;
  
  double get successRate => _successRate;
  double get successRateTrend => _successRateTrend;
  
  int get totalTokens => _totalTokens;
  int get todayTokens => _todayTokens;
  double get tokensTrend => _tokensTrend;
  
  List<FlSpot> get callVolumeData => _callVolumeData;
  List<PieChartSectionData> get modelUsageData => _modelUsageData;
  List<Map<String, dynamic>> get peakHours => _peakHours;
  
  List<FlSpot> get responseTimeData => _responseTimeData;
  List<BarChartGroupData> get responseTimeDistribution => _responseTimeDistribution;
  
  int get p50ResponseTime => _p50ResponseTime;
  int get p90ResponseTime => _p90ResponseTime;
  int get p99ResponseTime => _p99ResponseTime;
  int get maxResponseTime => _maxResponseTime;
  int get minResponseTime => _minResponseTime;
  
  List<Map<String, dynamic>> get modelPerformanceData => _modelPerformanceData;
  List<FlSpot> get tokenUsageData => _tokenUsageData;
  
  double get todayCost => _todayCost;
  double get monthCost => _monthCost;
  double get estimatedMonthlyCost => _estimatedMonthlyCost;
  double get avgCostPerCall => _avgCostPerCall;
  double get avgCostPerToken => _avgCostPerToken;
  
  List<PieChartSectionData> get errorTypeData => _errorTypeData;
  List<FlSpot> get errorTrendData => _errorTrendData;
  List<Map<String, dynamic>> get recentErrors => _recentErrors;
  
  // 商业数据 getters
  double get totalRevenue => _totalRevenue;
  double get monthlyRevenue => _monthlyRevenue;
  double get revenueTrend => _revenueTrend;
  
  double get arpu => _arpu;
  double get arpuTrend => _arpuTrend;
  
  int get payingUsers => _payingUsers;
  double get paymentRate => _paymentRate;
  double get payingUsersTrend => _payingUsersTrend;
  
  double get ltv => _ltv;
  double get ltvCacRatio => _ltvCacRatio;
  double get ltvTrend => _ltvTrend;
  
  List<FlSpot> get revenueData => _revenueData;
  List<PieChartSectionData> get revenueSourceData => _revenueSourceData;
  List<Map<String, dynamic>> get revenueGrowthMetrics => _revenueGrowthMetrics;
  
  List<Map<String, dynamic>> get conversionFunnelData => _conversionFunnelData;
  List<BarChartGroupData> get userValueDistribution => _userValueDistribution;
  double get paymentConversionRate => _paymentConversionRate;
  double get userRetentionRate => _userRetentionRate;
  double get avgSessionDuration => _avgSessionDuration;
  int get monthlyActiveUsers => _monthlyActiveUsers;
  double get churnRate => _churnRate;
  
  List<Map<String, dynamic>> get productSalesData => _productSalesData;
  List<PieChartSectionData> get salesChannelData => _salesChannelData;
  List<FlSpot> get salesTrendData => _salesTrendData;
  
  double get grossMargin => _grossMargin;
  double get grossMarginTrend => _grossMarginTrend;
  double get netMargin => _netMargin;
  double get netMarginTrend => _netMarginTrend;
  double get roi => _roi;
  double get roiTrend => _roiTrend;
  double get roas => _roas;
  double get roasTrend => _roasTrend;
  
  List<PieChartSectionData> get costStructureData => _costStructureData;
  List<FlSpot> get profitForecastData => _profitForecastData;
  
  double get cashFlowHealth => _cashFlowHealth;
  double get profitabilityHealth => _profitabilityHealth;
  double get growthHealth => _growthHealth;
  double get costControlHealth => _costControlHealth;
  int get activeUsers => _userMetrics?.activeUsers ?? 0;
  int get totalSessions => _userMetrics?.totalSessions ?? 0;
  Map<String, int> get userActions => _userMetrics?.userActions ?? {};
  Map<String, int> get topPages => _userMetrics?.topPages ?? {};

  // API监控数据快捷访问
  int get totalApiRequests => _apiEndpoints.values.fold(0, (sum, api) => sum + api.requestCount);
  double get apiSuccessRate => _apiEndpoints.isEmpty ? 0 : 
      _apiEndpoints.values.map((api) => api.successRate).reduce((a, b) => a + b) / _apiEndpoints.length;
  int get avgApiResponseTime => _apiEndpoints.isEmpty ? 0 : 
      (_apiEndpoints.values.map((api) => api.avgResponseTime).reduce((a, b) => a + b) / _apiEndpoints.length).round();
  int get apiErrors => _apiEndpoints.values.fold(0, (sum, api) => sum + api.errorCount);

  // 告警数据快捷访问
  int get criticalAlerts => _alerts.where((a) => a.level == 'critical' && !a.isResolved).length;
  int get warningAlerts => _alerts.where((a) => a.level == 'warning' && !a.isResolved).length;
  int get infoAlerts => _alerts.where((a) => a.level == 'info' && !a.isResolved).length;
  int get resolvedAlerts => _alerts.where((a) => a.isResolved).length;

  // 启动实时监控
  void startRealTimeMonitoring() {
    if (_isRealTimeActive) return;
    
    _isRealTimeActive = true;
    notifyListeners();
    
    // 立即加载一次数据
    _loadMonitoringData();
    
    // 启动定时器，每5秒更新一次
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateRealTimeData();
    });
  }

  // 停止实时监控
  void stopRealTimeMonitoring() {
    _isRealTimeActive = false;
    _realTimeTimer?.cancel();
    _realTimeTimer = null;
    notifyListeners();
  }

  // 启动自动刷新
  void startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      refreshData();
    });
  }

  // 停止自动刷新
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  // 手动刷新数据
  Future<void> refreshData() async {
    await _loadMonitoringData();
  }

  // 更改时间范围
  void changeTimeRange(String timeRange) {
    _currentTimeRange = timeRange;
    _loadHistoryData();
    notifyListeners();
  }

  // 加载监控数据
  Future<void> _loadMonitoringData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用延迟
      await Future.delayed(const Duration(milliseconds: 500));
      
      _systemMetrics = _generateSystemMetrics();
      _systemInfo = _generateSystemInfo();
      _userMetrics = _generateUserMetrics();
      _topProcesses = _generateTopProcesses();
      _apiEndpoints = _generateApiEndpoints();
      _alerts = _generateAlerts();
      
      _loadHistoryData();
      
    } catch (e) {
      _error = '加载监控数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新实时数据
  void _updateRealTimeData() {
    if (!_isRealTimeActive) return;
    
    // 更新系统指标
    _systemMetrics = _generateSystemMetrics();
    
    // 更新历史数据
    _updateHistoryData();
    
    // 检查并生成新告警
    _checkAndGenerateAlerts();
    
    notifyListeners();
  }

  // 加载历史数据
  void _loadHistoryData() {
    final dataPoints = _getDataPointsForTimeRange();
    
    _cpuHistory = _generateHistoryData(dataPoints, 20, 80);
    _memoryHistory = _generateHistoryData(dataPoints, 30, 70);
    _networkInHistory = _generateHistoryData(dataPoints, 10, 50);
    _networkOutHistory = _generateHistoryData(dataPoints, 5, 30);
    _activeUsersHistory = _generateIntHistoryData(dataPoints, 100, 500);
  }

  // 更新历史数据
  void _updateHistoryData() {
    final random = Random();
    
    // 移除最旧的数据点，添加新的数据点
    if (_cpuHistory.length >= 60) {
      _cpuHistory.removeAt(0);
      _memoryHistory.removeAt(0);
      _networkInHistory.removeAt(0);
      _networkOutHistory.removeAt(0);
    }
    
    _cpuHistory.add(_systemMetrics?.cpuUsage ?? random.nextDouble() * 100);
    _memoryHistory.add(_systemMetrics?.memoryUsage ?? random.nextDouble() * 100);
    _networkInHistory.add(_systemMetrics?.networkIn ?? random.nextDouble() * 100);
    _networkOutHistory.add(_systemMetrics?.networkOut ?? random.nextDouble() * 100);
    
    if (_activeUsersHistory.length >= 24) {
      _activeUsersHistory.removeAt(0);
    }
    _activeUsersHistory.add(currentOnlineUsers);
  }

  // 检查并生成告警
  void _checkAndGenerateAlerts() {
    final random = Random();
    
    // CPU使用率告警
    if (_systemMetrics != null && _systemMetrics!.cpuUsage > 90) {
      _addAlert(AlertModel(
        id: 'cpu_${DateTime.now().millisecondsSinceEpoch}',
        title: 'CPU使用率过高',
        message: 'CPU使用率达到${_systemMetrics!.cpuUsage.toStringAsFixed(1)}%，请检查系统负载',
        level: 'critical',
        source: 'system',
        timestamp: DateTime.now(),
        details: '当前CPU使用率: ${_systemMetrics!.cpuUsage.toStringAsFixed(1)}%\n建议: 检查高CPU占用进程',
      ));
    }
    
    // 内存使用率告警
    if (_systemMetrics != null && _systemMetrics!.memoryUsage > 95) {
      _addAlert(AlertModel(
        id: 'memory_${DateTime.now().millisecondsSinceEpoch}',
        title: '内存使用率过高',
        message: '内存使用率达到${_systemMetrics!.memoryUsage.toStringAsFixed(1)}%，系统可能出现性能问题',
        level: 'critical',
        source: 'system',
        timestamp: DateTime.now(),
        details: '当前内存使用: ${_systemMetrics!.memoryUsed.toStringAsFixed(1)}GB / ${_systemMetrics!.memoryTotal.toStringAsFixed(1)}GB',
      ));
    }
    
    // API响应时间告警
    if (_systemMetrics != null && _systemMetrics!.avgResponseTime > 2000) {
      _addAlert(AlertModel(
        id: 'api_${DateTime.now().millisecondsSinceEpoch}',
        title: 'API响应时间过长',
        message: 'API平均响应时间达到${_systemMetrics!.avgResponseTime}ms，用户体验可能受影响',
        level: 'warning',
        source: 'api',
        timestamp: DateTime.now(),
        details: '当前平均响应时间: ${_systemMetrics!.avgResponseTime}ms\n建议响应时间: <500ms',
      ));
    }
    
    // 随机生成一些信息级别的告警
    if (random.nextDouble() < 0.1) { // 10%概率
      final infoMessages = [
        '系统备份已完成',
        '新用户注册数量激增',
        '数据库连接池已优化',
        '缓存命中率提升',
        '系统更新已部署',
      ];
      
      _addAlert(AlertModel(
        id: 'info_${DateTime.now().millisecondsSinceEpoch}',
        title: '系统信息',
        message: infoMessages[random.nextInt(infoMessages.length)],
        level: 'info',
        source: 'system',
        timestamp: DateTime.now(),
      ));
    }
  }

  // 添加告警
  void _addAlert(AlertModel alert) {
    // 检查是否已存在相同类型的未解决告警
    final existingAlert = _alerts.firstWhere(
      (a) => a.source == alert.source && a.level == alert.level && !a.isResolved,
      orElse: () => AlertModel(id: '', title: '', message: '', level: '', source: '', timestamp: DateTime.now()),
    );
    
    if (existingAlert.id.isEmpty) {
      _alerts.insert(0, alert);
      
      // 限制告警数量，保留最新的50条
      if (_alerts.length > 50) {
        _alerts = _alerts.take(50).toList();
      }
    }
  }

  // 解决告警
  void resolveAlert(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isResolved: true);
      notifyListeners();
    }
  }

  // 忽略告警
  void ignoreAlert(String alertId) {
    _alerts.removeWhere((alert) => alert.id == alertId);
    notifyListeners();
  }

  // 清除所有告警
  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
  }

  // 刷新告警
  void refreshAlerts() {
    // 移除已解决的告警
    _alerts.removeWhere((alert) => alert.isResolved);
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 获取时间范围对应的数据点数量
  int _getDataPointsForTimeRange() {
    switch (_currentTimeRange) {
      case '最近15分钟':
        return 15;
      case '最近1小时':
        return 60;
      case '最近6小时':
        return 72; // 每5分钟一个点
      case '最近24小时':
        return 24; // 每小时一个点
      default:
        return 60;
    }
  }

  // 生成历史数据
  List<double> _generateHistoryData(int points, double min, double max) {
    final random = Random();
    final data = <double>[];
    
    for (int i = 0; i < points; i++) {
      data.add(min + random.nextDouble() * (max - min));
    }
    
    return data;
  }

  // 生成整数历史数据
  List<int> _generateIntHistoryData(int points, int min, int max) {
    final random = Random();
    final data = <int>[];
    
    for (int i = 0; i < points; i++) {
      data.add(min + random.nextInt(max - min));
    }
    
    return data;
  }

  // 生成系统指标
  SystemMetrics _generateSystemMetrics() {
    final random = Random();
    final now = DateTime.now();
    
    return SystemMetrics(
      cpuUsage: 20 + random.nextDouble() * 60, // 20-80%
      memoryUsage: 30 + random.nextDouble() * 50, // 30-80%
      memoryUsed: 4 + random.nextDouble() * 8, // 4-12GB
      memoryTotal: 16.0,
      networkIn: random.nextDouble() * 100, // 0-100MB/s
      networkOut: random.nextDouble() * 50, // 0-50MB/s
      avgResponseTime: 200 + random.nextInt(800), // 200-1000ms
      cpuTrend: (random.nextDouble() - 0.5) * 20, // -10 to +10
      memoryTrend: (random.nextDouble() - 0.5) * 15, // -7.5 to +7.5
      networkTrend: (random.nextDouble() - 0.5) * 30, // -15 to +15
      responseTrend: (random.nextDouble() - 0.5) * 100, // -50 to +50
      timestamp: now,
    );
  }

  // 生成系统信息
  SystemInfo _generateSystemInfo() {
    return SystemInfo(
      os: 'Ubuntu 22.04 LTS',
      cpuModel: 'Intel Xeon E5-2686 v4',
      cpuCores: 8,
      totalMemory: 16.0,
      diskSpace: 500.0,
      uptime: 1234567, // 秒
      version: '1.0.0',
      environment: {
        'NODE_ENV': 'production',
        'PORT': '3000',
        'DATABASE_URL': 'postgresql://...',
      },
    );
  }

  // 生成用户活跃度指标
  UserActivityMetrics _generateUserMetrics() {
    final random = Random();
    
    return UserActivityMetrics(
      currentOnlineUsers: 150 + random.nextInt(300), // 150-450
      todayNewUsers: 20 + random.nextInt(50), // 20-70
      activeUsers: 800 + random.nextInt(400), // 800-1200
      totalSessions: 2000 + random.nextInt(1000), // 2000-3000
      avgSessionDuration: 15 + random.nextDouble() * 20, // 15-35分钟
      userActions: {
        '聊天': 1200 + random.nextInt(500),
        '浏览': 800 + random.nextInt(300),
        '搜索': 400 + random.nextInt(200),
        '分享': 150 + random.nextInt(100),
        '设置': 80 + random.nextInt(50),
      },
      topPages: {
        '/chat': 2500 + random.nextInt(500),
        '/home': 1800 + random.nextInt(300),
        '/profile': 1200 + random.nextInt(200),
        '/settings': 800 + random.nextInt(150),
        '/help': 400 + random.nextInt(100),
      },
      activeUsersHistory: _activeUsersHistory,
      timestamp: DateTime.now(),
    );
  }

  // 生成进程信息
  List<ProcessInfo> _generateTopProcesses() {
    final random = Random();
    final processes = [
      'node server.js',
      'postgres',
      'redis-server',
      'nginx',
      'pm2',
      'docker',
      'systemd',
      'chrome',
    ];
    
    return processes.map((name) => ProcessInfo(
      id: 'proc_${name.hashCode}',
      name: name,
      cpuUsage: random.nextDouble() * 50, // 0-50%
      memoryUsage: 100 + random.nextDouble() * 500, // 100-600MB
      pid: 1000 + random.nextInt(9000),
      status: 'running',
      startTime: DateTime.now().subtract(Duration(hours: random.nextInt(24))),
    )).toList();
  }

  // 生成API端点
  Map<String, ApiEndpoint> _generateApiEndpoints() {
    final random = Random();
    final endpoints = {
      '/api/chat': 'POST',
      '/api/users': 'GET',
      '/api/auth/login': 'POST',
      '/api/characters': 'GET',
      '/api/upload': 'POST',
    };
    
    return endpoints.map((path, method) => MapEntry(
      path,
      ApiEndpoint(
        path: path,
        method: method,
        requestCount: 1000 + random.nextInt(5000),
        errorCount: random.nextInt(50),
        avgResponseTime: 200 + random.nextDouble() * 800,
        successRate: 90 + random.nextDouble() * 10,
        status: random.nextDouble() > 0.1 ? 'healthy' : 'unhealthy',
        responseTimeHistory: List.generate(30, (index) => 
            200 + random.nextDouble() * 800),
        lastRequest: DateTime.now().subtract(
            Duration(seconds: random.nextInt(300))),
      ),
    ));
  }

  // 生成告警
  List<AlertModel> _generateAlerts() {
    final random = Random();
    final alerts = <AlertModel>[];
    
    // 生成一些历史告警
    final alertTemplates = [
      {'title': 'CPU使用率过高', 'level': 'warning', 'source': 'system'},
      {'title': '磁盘空间不足', 'level': 'critical', 'source': 'system'},
      {'title': 'API响应时间过长', 'level': 'warning', 'source': 'api'},
      {'title': '数据库连接异常', 'level': 'critical', 'source': 'database'},
      {'title': '用户登录失败率过高', 'level': 'warning', 'source': 'auth'},
      {'title': '系统备份完成', 'level': 'info', 'source': 'system'},
    ];
    
    for (int i = 0; i < 10; i++) {
      final template = alertTemplates[random.nextInt(alertTemplates.length)];
      alerts.add(AlertModel(
        id: 'alert_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: template['title'] as String,
        message: '${template['title']} - 详细信息请查看系统日志',
        level: template['level'] as String,
        source: template['source'] as String,
        timestamp: DateTime.now().subtract(Duration(minutes: i * 15)),
        isResolved: random.nextDouble() > 0.3, // 70%概率已解决
        details: '这是一个模拟的告警详情信息。实际使用时，这里会包含具体的错误信息、堆栈跟踪或系统状态。',
      ));
    }
    
    // 按时间倒序排列
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return alerts;
  }

  // 加载模型监控数据
  Future<void> loadModelData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 模拟API调用延迟
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 模拟基础统计数据
      _totalCalls = 125847;
      _todayCalls = 3456;
      _callsTrend = 15.3;
      
      _avgResponseTime = 245;
      _responseTimeTrend = -12.5;
      
      _successRate = 98.7;
      _successRateTrend = 0.8;
      
      _totalTokens = 2847593;
      _todayTokens = 89456;
      _tokensTrend = 18.2;
      
      // 模拟调用量趋势数据
      _callVolumeData = [
        const FlSpot(0, 2.5),
        const FlSpot(2, 1.8),
        const FlSpot(4, 1.2),
        const FlSpot(6, 2.8),
        const FlSpot(8, 4.5),
        const FlSpot(10, 6.2),
        const FlSpot(12, 7.8),
        const FlSpot(14, 8.5),
        const FlSpot(16, 9.2),
        const FlSpot(18, 8.8),
        const FlSpot(20, 7.5),
        const FlSpot(22, 5.2),
        const FlSpot(24, 3.8),
      ];
      
      // 模拟模型使用分布
      _modelUsageData = [
        PieChartSectionData(
           color: const Color(0xFF2196F3),
           value: 45.2,
           title: 'GPT-4\n45.2%',
           radius: 60,
           titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
        PieChartSectionData(
          color: const Color(0xFF4CAF50),
          value: 28.6,
          title: 'GPT-3.5\n28.6%',
          radius: 60,
          titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
        ),
        PieChartSectionData(
          color: const Color(0xFFFF9800),
          value: 18.3,
          title: 'Claude-3\n18.3%',
          radius: 60,
          titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF9C27B0),
            value: 7.9,
            title: '文心一言\n7.9%',
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        ),
      ];
      
      // 模拟热门时段数据
      _peakHours = [
        {'hour': '09', 'usage': 65},
        {'hour': '10', 'usage': 78},
        {'hour': '11', 'usage': 85},
        {'hour': '14', 'usage': 92},
        {'hour': '15', 'usage': 88},
        {'hour': '16', 'usage': 95},
        {'hour': '19', 'usage': 82},
        {'hour': '20', 'usage': 75},
        {'hour': '21', 'usage': 68},
      ];
      
      // 模拟响应时间数据
      _responseTimeData = [
        const FlSpot(0, 180),
        const FlSpot(2, 165),
        const FlSpot(4, 155),
        const FlSpot(6, 195),
        const FlSpot(8, 220),
        const FlSpot(10, 245),
        const FlSpot(12, 285),
        const FlSpot(14, 310),
        const FlSpot(16, 295),
        const FlSpot(18, 275),
        const FlSpot(20, 250),
        const FlSpot(22, 210),
        const FlSpot(24, 185),
      ];
      
      // 模拟响应时间分布
      _responseTimeDistribution = [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 35,
              color: const Color(0xFF4CAF50),
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 45,
              color: const Color(0xFF2196F3),
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 15,
              color: const Color(0xFFFF9800),
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: 4,
              color: const Color(0xFFF44336),
              width: 20,
            ),
          ],
        ),
        BarChartGroupData(
          x: 4,
          barRods: [
            BarChartRodData(
              toY: 1,
              color: const Color(0xFF9C27B0),
              width: 20,
            ),
          ],
        ),
      ];
      
      // 模拟性能指标
      _p50ResponseTime = 185;
      _p90ResponseTime = 420;
      _p99ResponseTime = 850;
      _maxResponseTime = 1250;
      _minResponseTime = 85;
      
      // 模拟模型性能数据
      _modelPerformanceData = [
        {
          'name': 'GPT-4',
          'calls': 56892,
          'avgResponseTime': 285,
          'successRate': 99.2,
          'tokens': 1285647,
          'cost': 2847.50,
        },
        {
          'name': 'GPT-3.5',
          'calls': 35984,
          'avgResponseTime': 165,
          'successRate': 98.8,
          'tokens': 856234,
          'cost': 856.23,
        },
        {
          'name': 'Claude-3',
          'calls': 23056,
          'avgResponseTime': 195,
          'successRate': 98.5,
          'tokens': 524789,
          'cost': 1574.37,
        },
        {
          'name': '文心一言',
          'calls': 9915,
          'avgResponseTime': 225,
          'successRate': 97.9,
          'tokens': 180923,
          'cost': 362.85,
        },
      ];
      
      // 模拟Token使用趋势
      _tokenUsageData = [
        const FlSpot(0, 15000),
        const FlSpot(2, 12000),
        const FlSpot(4, 8500),
        const FlSpot(6, 18500),
        const FlSpot(8, 25000),
        const FlSpot(10, 32000),
        const FlSpot(12, 38500),
        const FlSpot(14, 42000),
        const FlSpot(16, 39500),
        const FlSpot(18, 35000),
        const FlSpot(20, 28500),
        const FlSpot(22, 22000),
        const FlSpot(24, 18500),
      ];
      
      // 模拟成本数据
      _todayCost = 285.67;
      _monthCost = 8547.23;
      _estimatedMonthlyCost = 25641.69;
      _avgCostPerCall = 0.0678;
      _avgCostPerToken = 0.000024;
      
      // 模拟错误类型分布
      _errorTypeData = [
        PieChartSectionData(
          color: const Color(0xFFF44336),
          value: 45.2,
          title: '超时\n45.2%',
          radius: 50,
          titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFFFF9800),
            value: 28.6,
            title: '限流\n28.6%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF9C27B0),
            value: 18.3,
            title: '认证失败\n18.3%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: const Color(0xFF9E9E9E),
            value: 7.9,
            title: '服务不可用\n7.9%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
        ),
      ];
      
      // 模拟错误趋势数据
      _errorTrendData = [
        const FlSpot(0, 2),
        const FlSpot(2, 1),
        const FlSpot(4, 0),
        const FlSpot(6, 3),
        const FlSpot(8, 5),
        const FlSpot(10, 4),
        const FlSpot(12, 7),
        const FlSpot(14, 6),
        const FlSpot(16, 4),
        const FlSpot(18, 3),
        const FlSpot(20, 2),
        const FlSpot(22, 1),
        const FlSpot(24, 1),
      ];
      
      // 模拟最近错误记录
      _recentErrors = [
        {
          'time': '2024-01-15 14:32:15',
          'model': 'GPT-4',
          'type': '超时',
          'message': '请求超时，服务器响应时间超过30秒',
          'statusCode': 408,
          'stackTrace': 'TimeoutException: Request timeout after 30000ms\n  at HttpClient.request()\n  at ModelService.callGPT4()',
        },
        {
          'time': '2024-01-15 14:28:42',
          'model': 'Claude-3',
          'type': '限流',
          'message': 'API调用频率超过限制，请稍后重试',
          'statusCode': 429,
          'stackTrace': 'RateLimitException: Too many requests\n  at ApiClient.makeRequest()\n  at ModelService.callClaude3()',
        },
        {
          'time': '2024-01-15 14:25:18',
          'model': 'GPT-3.5',
          'type': '认证失败',
          'message': 'API密钥无效或已过期',
          'statusCode': 401,
          'stackTrace': 'AuthenticationException: Invalid API key\n  at AuthService.validateKey()\n  at ModelService.callGPT35()',
        },
        {
          'time': '2024-01-15 14:20:55',
          'model': '文心一言',
          'type': '服务不可用',
          'message': '模型服务暂时不可用，请稍后重试',
          'statusCode': 503,
          'stackTrace': 'ServiceUnavailableException: Service temporarily unavailable\n  at ModelService.callWenxin()',
        },
        {
          'time': '2024-01-15 14:18:33',
          'model': 'GPT-4',
          'type': '超时',
          'message': '网络连接超时',
          'statusCode': 408,
          'stackTrace': 'NetworkTimeoutException: Connection timeout\n  at NetworkClient.connect()',
        },
      ];
      
    } catch (e) {
       _error = '加载模型监控数据失败: $e';
       print(_error);
     } finally {
       _isLoading = false;
       notifyListeners();
     }
   }
   
   // 加载商业数据
   Future<void> loadBusinessData() async {
     _isLoading = true;
     _error = null;
     notifyListeners();
     
     try {
       // 模拟API调用延迟
       await Future.delayed(const Duration(milliseconds: 1000));
       
       // 模拟核心商业指标
       _totalRevenue = 2847593.50;
       _monthlyRevenue = 456789.20;
       _revenueTrend = 23.5;
       
       _arpu = 156.78;
       _arpuTrend = 8.3;
       
       _payingUsers = 18456;
       _paymentRate = 12.8;
       _payingUsersTrend = 15.2;
       
       _ltv = 892.45;
       _ltvCacRatio = 3.2;
       _ltvTrend = 12.7;
       
       // 模拟收入趋势数据
       _revenueData = [
         const FlSpot(0, 25000),
         const FlSpot(5, 28000),
         const FlSpot(10, 32000),
         const FlSpot(15, 35000),
         const FlSpot(20, 42000),
         const FlSpot(25, 38000),
         const FlSpot(30, 45000),
       ];
       
       // 模拟收入来源分布
       _revenueSourceData = [
         PieChartSectionData(
           color: const Color(0xFF4CAF50),
           value: 45.2,
           title: '会员订阅\n45.2%',
           radius: 60,
           titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF2196F3),
           value: 28.6,
           title: '虚拟礼品\n28.6%',
           radius: 60,
           titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFFFF9800),
           value: 18.3,
           title: '高级功能\n18.3%',
           radius: 60,
           titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF9C27B0),
           value: 7.9,
           title: '广告收入\n7.9%',
           radius: 60,
           titleStyle: TextStyle(
             fontSize: 12,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
       ];
       
       // 模拟收入增长指标
       _revenueGrowthMetrics = [
         {'label': '月度增长率', 'value': '+23.5%', 'color': Colors.green},
         {'label': '季度增长率', 'value': '+67.8%', 'color': Colors.blue},
         {'label': '年度增长率', 'value': '+156.2%', 'color': Colors.orange},
         {'label': '复合增长率', 'value': '+89.4%', 'color': Colors.purple},
       ];
       
       // 模拟用户付费转化漏斗
       _conversionFunnelData = [
         {'label': '访问用户', 'count': 100000, 'rate': 100.0, 'color': Colors.blue},
         {'label': '注册用户', 'count': 45000, 'rate': 45.0, 'color': Colors.green},
         {'label': '活跃用户', 'count': 28000, 'rate': 28.0, 'color': Colors.orange},
         {'label': '付费用户', 'count': 18456, 'rate': 18.5, 'color': Colors.red},
         {'label': 'VIP用户', 'count': 5200, 'rate': 5.2, 'color': Colors.purple},
       ];
       
       // 模拟用户价值分布
       _userValueDistribution = [
         BarChartGroupData(
           x: 0,
           barRods: [
             BarChartRodData(
               toY: 65,
               color: Colors.grey,
               width: 20,
             ),
           ],
         ),
         BarChartGroupData(
           x: 1,
           barRods: [
             BarChartRodData(
               toY: 20,
               color: Colors.blue,
               width: 20,
             ),
           ],
         ),
         BarChartGroupData(
           x: 2,
           barRods: [
             BarChartRodData(
               toY: 10,
               color: Colors.green,
               width: 20,
             ),
           ],
         ),
         BarChartGroupData(
           x: 3,
           barRods: [
             BarChartRodData(
               toY: 4,
               color: Colors.orange,
               width: 20,
             ),
           ],
         ),
         BarChartGroupData(
           x: 4,
           barRods: [
             BarChartRodData(
               toY: 1,
               color: Colors.purple,
               width: 20,
             ),
           ],
         ),
       ];
       
       // 模拟用户指标
       _paymentConversionRate = 12.8;
       _userRetentionRate = 78.5;
       _avgSessionDuration = 24.6;
       _monthlyActiveUsers = 144567;
       _churnRate = 8.3;
       
       // 模拟产品销售数据
       _productSalesData = [
         {
           'name': '月度会员',
           'sales': 12456,
           'revenue': 186840.0,
           'conversionRate': 15.2,
           'avgOrderValue': 15.0,
           'trend': 1,
         },
         {
           'name': '年度会员',
           'sales': 3890,
           'revenue': 233400.0,
           'conversionRate': 8.7,
           'avgOrderValue': 60.0,
           'trend': 1,
         },
         {
           'name': '虚拟礼品',
           'sales': 28945,
           'revenue': 144725.0,
           'conversionRate': 22.3,
           'avgOrderValue': 5.0,
           'trend': 1,
         },
         {
           'name': 'AI对话包',
           'sales': 8567,
           'revenue': 85670.0,
           'conversionRate': 12.1,
           'avgOrderValue': 10.0,
           'trend': -1,
         },
         {
           'name': '个性化定制',
           'sales': 1234,
           'revenue': 61700.0,
           'conversionRate': 3.4,
           'avgOrderValue': 50.0,
           'trend': 1,
         },
       ];
       
       // 模拟销售渠道分布
       _salesChannelData = [
         PieChartSectionData(
           color: const Color(0xFF4CAF50),
           value: 42.5,
           title: '应用内购买\n42.5%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF2196F3),
           value: 28.3,
           title: '网页支付\n28.3%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFFFF9800),
           value: 18.7,
           title: '第三方平台\n18.7%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF9C27B0),
           value: 10.5,
           title: '其他渠道\n10.5%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
       ];
       
       // 模拟销售趋势数据
       _salesTrendData = [
         const FlSpot(0, 15000),
         const FlSpot(5, 18000),
         const FlSpot(10, 22000),
         const FlSpot(15, 25000),
         const FlSpot(20, 28000),
         const FlSpot(25, 24000),
         const FlSpot(30, 32000),
       ];
       
       // 模拟盈利指标
       _grossMargin = 68.5;
       _grossMarginTrend = 3.2;
       _netMargin = 24.7;
       _netMarginTrend = 1.8;
       _roi = 156.8;
       _roiTrend = 12.4;
       _roas = 4.2;
       _roasTrend = 8.7;
       
       // 模拟成本结构数据
       _costStructureData = [
         PieChartSectionData(
           color: const Color(0xFFF44336),
           value: 35.2,
           title: '人力成本\n35.2%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF2196F3),
           value: 28.6,
           title: '技术成本\n28.6%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFFFF9800),
           value: 18.3,
           title: '营销成本\n18.3%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
         PieChartSectionData(
           color: const Color(0xFF4CAF50),
           value: 17.9,
           title: '运营成本\n17.9%',
           radius: 50,
           titleStyle: TextStyle(
             fontSize: 10,
             fontWeight: FontWeight.bold,
             color: Colors.white,
           ),
         ),
       ];
       
       // 模拟盈利预测数据
       _profitForecastData = [
         const FlSpot(0, 8000),
         const FlSpot(3, 12000),
         const FlSpot(6, 18000),
         const FlSpot(9, 25000),
         const FlSpot(12, 32000),
       ];
       
       // 模拟财务健康度
       _cashFlowHealth = 85.2;
       _profitabilityHealth = 78.6;
       _growthHealth = 92.3;
       _costControlHealth = 74.8;
       
     } catch (e) {
       _error = '加载商业数据失败: $e';
       print(_error);
     } finally {
       _isLoading = false;
       notifyListeners();
     }
   }
 
   @override
  void dispose() {
    stopRealTimeMonitoring();
    stopAutoRefresh();
    super.dispose();
  }
}