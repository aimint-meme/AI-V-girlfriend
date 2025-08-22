class SystemMetrics {
  final double cpuUsage;
  final double memoryUsage;
  final double memoryUsed;
  final double memoryTotal;
  final double networkIn;
  final double networkOut;
  final int avgResponseTime;
  final double cpuTrend;
  final double memoryTrend;
  final double networkTrend;
  final double responseTrend;
  final DateTime timestamp;

  SystemMetrics({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.memoryUsed,
    required this.memoryTotal,
    required this.networkIn,
    required this.networkOut,
    required this.avgResponseTime,
    required this.cpuTrend,
    required this.memoryTrend,
    required this.networkTrend,
    required this.responseTrend,
    required this.timestamp,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    return SystemMetrics(
      cpuUsage: (json['cpuUsage'] ?? 0.0).toDouble(),
      memoryUsage: (json['memoryUsage'] ?? 0.0).toDouble(),
      memoryUsed: (json['memoryUsed'] ?? 0.0).toDouble(),
      memoryTotal: (json['memoryTotal'] ?? 0.0).toDouble(),
      networkIn: (json['networkIn'] ?? 0.0).toDouble(),
      networkOut: (json['networkOut'] ?? 0.0).toDouble(),
      avgResponseTime: json['avgResponseTime'] ?? 0,
      cpuTrend: (json['cpuTrend'] ?? 0.0).toDouble(),
      memoryTrend: (json['memoryTrend'] ?? 0.0).toDouble(),
      networkTrend: (json['networkTrend'] ?? 0.0).toDouble(),
      responseTrend: (json['responseTrend'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'memoryUsed': memoryUsed,
      'memoryTotal': memoryTotal,
      'networkIn': networkIn,
      'networkOut': networkOut,
      'avgResponseTime': avgResponseTime,
      'cpuTrend': cpuTrend,
      'memoryTrend': memoryTrend,
      'networkTrend': networkTrend,
      'responseTrend': responseTrend,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // 获取CPU状态
  String get cpuStatus {
    if (cpuUsage > 90) return '严重';
    if (cpuUsage > 70) return '警告';
    if (cpuUsage > 50) return '注意';
    return '正常';
  }

  // 获取内存状态
  String get memoryStatus {
    if (memoryUsage > 95) return '严重';
    if (memoryUsage > 80) return '警告';
    if (memoryUsage > 60) return '注意';
    return '正常';
  }

  // 获取网络状态
  String get networkStatus {
    if (networkIn > 80 || networkOut > 80) return '繁忙';
    if (networkIn > 50 || networkOut > 50) return '活跃';
    return '正常';
  }

  // 获取响应时间状态
  String get responseStatus {
    if (avgResponseTime > 2000) return '严重';
    if (avgResponseTime > 1000) return '警告';
    if (avgResponseTime > 500) return '注意';
    return '正常';
  }
}

class SystemInfo {
  final String os;
  final String cpuModel;
  final int cpuCores;
  final double totalMemory;
  final double diskSpace;
  final int uptime;
  final String version;
  final Map<String, dynamic> environment;

  SystemInfo({
    required this.os,
    required this.cpuModel,
    required this.cpuCores,
    required this.totalMemory,
    required this.diskSpace,
    required this.uptime,
    required this.version,
    this.environment = const {},
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      os: json['os'] ?? '',
      cpuModel: json['cpuModel'] ?? '',
      cpuCores: json['cpuCores'] ?? 0,
      totalMemory: (json['totalMemory'] ?? 0.0).toDouble(),
      diskSpace: (json['diskSpace'] ?? 0.0).toDouble(),
      uptime: json['uptime'] ?? 0,
      version: json['version'] ?? '',
      environment: json['environment'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'os': os,
      'cpuModel': cpuModel,
      'cpuCores': cpuCores,
      'totalMemory': totalMemory,
      'diskSpace': diskSpace,
      'uptime': uptime,
      'version': version,
      'environment': environment,
    };
  }
}

class ProcessInfo {
  final String id;
  final String name;
  final double cpuUsage;
  final double memoryUsage;
  final int pid;
  final String status;
  final DateTime startTime;

  ProcessInfo({
    required this.id,
    required this.name,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.pid,
    required this.status,
    required this.startTime,
  });

  factory ProcessInfo.fromJson(Map<String, dynamic> json) {
    return ProcessInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      cpuUsage: (json['cpuUsage'] ?? 0.0).toDouble(),
      memoryUsage: (json['memoryUsage'] ?? 0.0).toDouble(),
      pid: json['pid'] ?? 0,
      status: json['status'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'pid': pid,
      'status': status,
      'startTime': startTime.toIso8601String(),
    };
  }

  // 获取进程运行时间
  Duration get runningTime => DateTime.now().difference(startTime);

  // 是否为高资源消耗进程
  bool get isHighResourceUsage => cpuUsage > 50 || memoryUsage > 500;
}

class ApiEndpoint {
  final String path;
  final String method;
  final int requestCount;
  final int errorCount;
  final double avgResponseTime;
  final double successRate;
  final String status;
  final List<double> responseTimeHistory;
  final DateTime lastRequest;

  ApiEndpoint({
    required this.path,
    required this.method,
    required this.requestCount,
    required this.errorCount,
    required this.avgResponseTime,
    required this.successRate,
    required this.status,
    required this.responseTimeHistory,
    required this.lastRequest,
  });

  factory ApiEndpoint.fromJson(Map<String, dynamic> json) {
    return ApiEndpoint(
      path: json['path'] ?? '',
      method: json['method'] ?? '',
      requestCount: json['requestCount'] ?? 0,
      errorCount: json['errorCount'] ?? 0,
      avgResponseTime: (json['avgResponseTime'] ?? 0.0).toDouble(),
      successRate: (json['successRate'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
      responseTimeHistory: List<double>.from(json['responseTimeHistory'] ?? []),
      lastRequest: DateTime.parse(json['lastRequest'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'method': method,
      'requestCount': requestCount,
      'errorCount': errorCount,
      'avgResponseTime': avgResponseTime,
      'successRate': successRate,
      'status': status,
      'responseTimeHistory': responseTimeHistory,
      'lastRequest': lastRequest.toIso8601String(),
    };
  }

  // 获取健康状态
  String get healthStatus {
    if (successRate < 90) return 'unhealthy';
    if (avgResponseTime > 1000) return 'slow';
    return 'healthy';
  }

  // 是否为热门端点
  bool get isPopular => requestCount > 1000;

  // 获取错误率
  double get errorRate => requestCount > 0 ? (errorCount / requestCount) * 100 : 0;
}

class AlertModel {
  final String id;
  final String title;
  final String message;
  final String level; // critical, warning, info
  final String source;
  final DateTime timestamp;
  final bool isResolved;
  final String details;
  final Map<String, dynamic> metadata;

  AlertModel({
    required this.id,
    required this.title,
    required this.message,
    required this.level,
    required this.source,
    required this.timestamp,
    this.isResolved = false,
    this.details = '',
    this.metadata = const {},
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      level: json['level'] ?? 'info',
      source: json['source'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isResolved: json['isResolved'] ?? false,
      details: json['details'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'level': level,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'isResolved': isResolved,
      'details': details,
      'metadata': metadata,
    };
  }

  AlertModel copyWith({
    String? id,
    String? title,
    String? message,
    String? level,
    String? source,
    DateTime? timestamp,
    bool? isResolved,
    String? details,
    Map<String, dynamic>? metadata,
  }) {
    return AlertModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      level: level ?? this.level,
      source: source ?? this.source,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      details: details ?? this.details,
      metadata: metadata ?? this.metadata,
    );
  }

  // 获取优先级
  int get priority {
    switch (level) {
      case 'critical':
        return 3;
      case 'warning':
        return 2;
      case 'info':
        return 1;
      default:
        return 0;
    }
  }

  // 获取持续时间
  Duration get duration => DateTime.now().difference(timestamp);

  // 是否为紧急告警
  bool get isUrgent => level == 'critical' && !isResolved;
}

class UserActivityMetrics {
  final int currentOnlineUsers;
  final int todayNewUsers;
  final int activeUsers;
  final int totalSessions;
  final double avgSessionDuration;
  final Map<String, int> userActions;
  final Map<String, int> topPages;
  final List<int> activeUsersHistory;
  final DateTime timestamp;

  UserActivityMetrics({
    required this.currentOnlineUsers,
    required this.todayNewUsers,
    required this.activeUsers,
    required this.totalSessions,
    required this.avgSessionDuration,
    required this.userActions,
    required this.topPages,
    required this.activeUsersHistory,
    required this.timestamp,
  });

  factory UserActivityMetrics.fromJson(Map<String, dynamic> json) {
    return UserActivityMetrics(
      currentOnlineUsers: json['currentOnlineUsers'] ?? 0,
      todayNewUsers: json['todayNewUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      avgSessionDuration: (json['avgSessionDuration'] ?? 0.0).toDouble(),
      userActions: Map<String, int>.from(json['userActions'] ?? {}),
      topPages: Map<String, int>.from(json['topPages'] ?? {}),
      activeUsersHistory: List<int>.from(json['activeUsersHistory'] ?? []),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentOnlineUsers': currentOnlineUsers,
      'todayNewUsers': todayNewUsers,
      'activeUsers': activeUsers,
      'totalSessions': totalSessions,
      'avgSessionDuration': avgSessionDuration,
      'userActions': userActions,
      'topPages': topPages,
      'activeUsersHistory': activeUsersHistory,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // 获取用户活跃度
  String get activityLevel {
    if (currentOnlineUsers > 1000) return '非常活跃';
    if (currentOnlineUsers > 500) return '活跃';
    if (currentOnlineUsers > 100) return '一般';
    return '较低';
  }

  // 获取会话质量
  String get sessionQuality {
    if (avgSessionDuration > 30) return '优秀';
    if (avgSessionDuration > 15) return '良好';
    if (avgSessionDuration > 5) return '一般';
    return '较差';
  }
}

class MonitoringStats {
  final SystemMetrics systemMetrics;
  final UserActivityMetrics userMetrics;
  final List<ApiEndpoint> apiEndpoints;
  final List<AlertModel> alerts;
  final List<ProcessInfo> processes;
  final SystemInfo systemInfo;
  final DateTime lastUpdate;

  MonitoringStats({
    required this.systemMetrics,
    required this.userMetrics,
    required this.apiEndpoints,
    required this.alerts,
    required this.processes,
    required this.systemInfo,
    required this.lastUpdate,
  });

  factory MonitoringStats.fromJson(Map<String, dynamic> json) {
    return MonitoringStats(
      systemMetrics: SystemMetrics.fromJson(json['systemMetrics'] ?? {}),
      userMetrics: UserActivityMetrics.fromJson(json['userMetrics'] ?? {}),
      apiEndpoints: (json['apiEndpoints'] as List<dynamic>? ?? [])
          .map((e) => ApiEndpoint.fromJson(e))
          .toList(),
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .map((e) => AlertModel.fromJson(e))
          .toList(),
      processes: (json['processes'] as List<dynamic>? ?? [])
          .map((e) => ProcessInfo.fromJson(e))
          .toList(),
      systemInfo: SystemInfo.fromJson(json['systemInfo'] ?? {}),
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'systemMetrics': systemMetrics.toJson(),
      'userMetrics': userMetrics.toJson(),
      'apiEndpoints': apiEndpoints.map((e) => e.toJson()).toList(),
      'alerts': alerts.map((e) => e.toJson()).toList(),
      'processes': processes.map((e) => e.toJson()).toList(),
      'systemInfo': systemInfo.toJson(),
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }

  // 获取系统整体健康状态
  String get overallHealth {
    final criticalAlerts = alerts.where((a) => a.level == 'critical' && !a.isResolved).length;
    if (criticalAlerts > 0) return '严重';
    
    final warningAlerts = alerts.where((a) => a.level == 'warning' && !a.isResolved).length;
    if (warningAlerts > 5) return '警告';
    
    if (systemMetrics.cpuUsage > 80 || systemMetrics.memoryUsage > 85) return '注意';
    
    return '正常';
  }

  // 获取API健康状态
  String get apiHealth {
    final unhealthyApis = apiEndpoints.where((api) => api.healthStatus != 'healthy').length;
    if (unhealthyApis > apiEndpoints.length * 0.3) return '不健康';
    if (unhealthyApis > 0) return '部分异常';
    return '健康';
  }

  // 获取用户活跃度状态
  String get userActivityStatus => userMetrics.activityLevel;
}