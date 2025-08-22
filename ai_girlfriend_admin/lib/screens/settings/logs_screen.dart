import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/system_settings_provider.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 搜索和筛选
  final TextEditingController _searchController = TextEditingController();
  String _selectedLogType = '全部';
  String _selectedLevel = '全部';
  String _selectedUser = '全部';
  DateTimeRange? _selectedDateRange;
  
  // 分页
  int _currentPage = 1;
  int _pageSize = 50;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemSettingsProvider>().loadLogSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/settings/logs',
      child: Consumer<SystemSettingsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '日志记录',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '系统操作日志记录和审计追踪',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _exportLogs(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出日志'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _clearOldLogs(),
                          icon: const Icon(Icons.delete_sweep),
                          label: const Text('清理日志'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _refreshLogs(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('刷新'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 统计卡片
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '今日日志',
                        value: NumberFormat('#,##0').format(provider.todayLogs),
                        subtitle: '较昨日: ${provider.logGrowthTrend > 0 ? '+' : ''}${provider.logGrowthTrend.toStringAsFixed(1)}%',
                        trend: provider.logGrowthTrend,
                        icon: Icons.today,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '错误日志',
                        value: '${provider.errorLogs}',
                        subtitle: '需要关注的错误',
                        trend: provider.errorTrend,
                        icon: Icons.error,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '存储空间',
                        value: '${provider.logStorageUsed.toStringAsFixed(1)}GB',
                        subtitle: '总容量: ${provider.logStorageTotal}GB',
                        trend: provider.storageTrend,
                        icon: Icons.storage,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '活跃用户',
                        value: '${provider.activeLogUsers}',
                        subtitle: '今日操作用户数',
                        trend: provider.activeUserTrend,
                        icon: Icons.people,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 标签页
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 标签栏
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.list),
                                text: '操作日志',
                              ),
                              Tab(
                                icon: Icon(Icons.login),
                                text: '登录日志',
                              ),
                              Tab(
                                icon: Icon(Icons.error),
                                text: '错误日志',
                              ),
                              Tab(
                                icon: Icon(Icons.analytics),
                                text: '统计分析',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOperationLogsTab(provider),
                              _buildLoginLogsTab(provider),
                              _buildErrorLogsTab(provider),
                              _buildAnalyticsTab(provider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOperationLogsTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 搜索和筛选
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索操作内容、用户名...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLogType,
                  decoration: const InputDecoration(
                    labelText: '操作类型',
                  ),
                  items: ['全部', '用户管理', '角色管理', '内容管理', '系统设置', '数据操作']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLogType = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedUser,
                  decoration: const InputDecoration(
                    labelText: '操作用户',
                  ),
                  items: ['全部', '张三', '李四', '王五', '赵六']
                      .map((user) => DropdownMenuItem(
                            value: user,
                            child: Text(user),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUser = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _selectDateRange(),
                icon: const Icon(Icons.date_range),
                label: Text(_selectedDateRange == null 
                    ? '选择日期' 
                    : '${DateFormat('MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('MM-dd').format(_selectedDateRange!.end)}'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 日志列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOperationLogsList(),
          ),
          
          // 分页
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildLoginLogsTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 筛选条件
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索用户名、IP地址...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: '登录状态',
                  ),
                  items: ['全部', '成功', '失败', '异常']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 登录日志列表
          Expanded(
            child: _buildLoginLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorLogsTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 错误统计
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${provider.criticalErrors}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const Text('严重错误'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${provider.warningErrors}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        const Text('警告错误'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${provider.infoErrors}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        const Text('信息错误'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 错误日志列表
          Expanded(
            child: _buildErrorLogsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 统计图表
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '日志趋势分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '日志趋势图表\n（此处可集成图表库）',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '操作类型分布',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildAnalyticsItem('用户管理', 1245, AppColors.primary),
                            _buildAnalyticsItem('内容管理', 892, AppColors.success),
                            _buildAnalyticsItem('系统设置', 567, AppColors.warning),
                            _buildAnalyticsItem('数据操作', 234, AppColors.info),
                            _buildAnalyticsItem('角色管理', 123, AppColors.error),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 详细统计
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '活跃用户排行',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._generateTopUsers().map((user) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(user['name']),
                            Text(
                              '${user['operations']} 次操作',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '时段分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._generateTimeAnalysis().map((time) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(time['period']),
                            Text(
                              '${time['percentage']}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationLogsList() {
    return ListView.builder(
      itemCount: _generateMockOperationLogs().length,
      itemBuilder: (context, index) {
        final log = _generateMockOperationLogs()[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLogTypeColor(log['type']).withOpacity(0.1),
              child: Icon(
                _getLogTypeIcon(log['type']),
                color: _getLogTypeColor(log['type']),
                size: 20,
              ),
            ),
            title: Text(
              log['operation'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '用户: ${log['user']} | IP: ${log['ip']}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(log['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            trailing: _buildLogStatusChip(log['status']),
            onTap: () => _showLogDetail(log),
          ),
        );
      },
    );
  }

  Widget _buildLoginLogsList() {
    return ListView.builder(
      itemCount: _generateMockLoginLogs().length,
      itemBuilder: (context, index) {
        final log = _generateMockLoginLogs()[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getLoginStatusColor(log['status']).withOpacity(0.1),
              child: Icon(
                _getLoginStatusIcon(log['status']),
                color: _getLoginStatusColor(log['status']),
                size: 20,
              ),
            ),
            title: Text(
              '${log['user']} ${log['status']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IP: ${log['ip']} | 设备: ${log['device']}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(log['timestamp']),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            trailing: log['location'] != null 
                ? Text(
                    log['location'],
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildErrorLogsList() {
    return ListView.builder(
      itemCount: _generateMockErrorLogs().length,
      itemBuilder: (context, index) {
        final log = _generateMockErrorLogs()[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getErrorLevelColor(log['level']).withOpacity(0.1),
              child: Icon(
                _getErrorLevelIcon(log['level']),
                color: _getErrorLevelColor(log['level']),
                size: 20,
              ),
            ),
            title: Text(
              log['message'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${log['module']} | ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log['timestamp'])}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '错误详情:',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        log['details'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            NumberFormat('#,##0').format(count),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogStatusChip(String status) {
    Color color;
    switch (status) {
      case '成功':
        color = AppColors.success;
        break;
      case '失败':
        color = AppColors.error;
        break;
      case '警告':
        color = AppColors.warning;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('第 $_currentPage 页'),
        IconButton(
          onPressed: () => _changePage(_currentPage + 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Color _getLogTypeColor(String type) {
    switch (type) {
      case '用户管理':
        return AppColors.primary;
      case '角色管理':
        return AppColors.success;
      case '内容管理':
        return AppColors.info;
      case '系统设置':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  IconData _getLogTypeIcon(String type) {
    switch (type) {
      case '用户管理':
        return Icons.people;
      case '角色管理':
        return Icons.admin_panel_settings;
      case '内容管理':
        return Icons.content_paste;
      case '系统设置':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Color _getLoginStatusColor(String status) {
    switch (status) {
      case '登录成功':
        return AppColors.success;
      case '登录失败':
        return AppColors.error;
      case '登出':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  IconData _getLoginStatusIcon(String status) {
    switch (status) {
      case '登录成功':
        return Icons.login;
      case '登录失败':
        return Icons.error;
      case '登出':
        return Icons.logout;
      default:
        return Icons.info;
    }
  }

  Color _getErrorLevelColor(String level) {
    switch (level) {
      case 'ERROR':
        return AppColors.error;
      case 'WARN':
        return AppColors.warning;
      case 'INFO':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  IconData _getErrorLevelIcon(String level) {
    switch (level) {
      case 'ERROR':
        return Icons.error;
      case 'WARN':
        return Icons.warning;
      case 'INFO':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  List<Map<String, dynamic>> _generateMockOperationLogs() {
    return [
      {
        'id': 'log_001',
        'operation': '创建用户账户',
        'type': '用户管理',
        'user': '张三',
        'ip': '192.168.1.100',
        'status': '成功',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
        'details': '创建用户账户: lisi@example.com',
      },
      {
        'id': 'log_002',
        'operation': '修改角色权限',
        'type': '角色管理',
        'user': '李四',
        'ip': '192.168.1.101',
        'status': '成功',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 15)),
        'details': '为角色"管理员"添加"用户删除"权限',
      },
      {
        'id': 'log_003',
        'operation': '删除内容',
        'type': '内容管理',
        'user': '王五',
        'ip': '192.168.1.102',
        'status': '失败',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'details': '尝试删除内容ID: 12345，权限不足',
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockLoginLogs() {
    return [
      {
        'id': 'login_001',
        'user': '张三',
        'status': '登录成功',
        'ip': '192.168.1.100',
        'device': 'Chrome/Windows',
        'location': '北京',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      },
      {
        'id': 'login_002',
        'user': '李四',
        'status': '登录失败',
        'ip': '192.168.1.101',
        'device': 'Firefox/Mac',
        'location': '上海',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
      },
      {
        'id': 'login_003',
        'user': '王五',
        'status': '登出',
        'ip': '192.168.1.102',
        'device': 'Safari/iOS',
        'location': '广州',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockErrorLogs() {
    return [
      {
        'id': 'error_001',
        'level': 'ERROR',
        'message': '数据库连接失败',
        'module': 'Database',
        'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
        'details': 'Connection timeout after 30 seconds\nHost: db.example.com:3306\nError: Connection refused',
      },
      {
        'id': 'error_002',
        'level': 'WARN',
        'message': 'API调用频率过高',
        'module': 'API Gateway',
        'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
        'details': 'Rate limit exceeded for IP: 192.168.1.100\nLimit: 1000 requests/hour\nCurrent: 1250 requests',
      },
      {
        'id': 'error_003',
        'level': 'INFO',
        'message': '系统维护完成',
        'module': 'System',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)),
        'details': 'Scheduled maintenance completed successfully\nDuration: 2 hours\nAffected services: User Management, Content API',
      },
    ];
  }

  List<Map<String, dynamic>> _generateTopUsers() {
    return [
      {'name': '张三', 'operations': 156},
      {'name': '李四', 'operations': 134},
      {'name': '王五', 'operations': 98},
      {'name': '赵六', 'operations': 76},
      {'name': '钱七', 'operations': 45},
    ];
  }

  List<Map<String, dynamic>> _generateTimeAnalysis() {
    return [
      {'period': '09:00-12:00', 'percentage': 35},
      {'period': '14:00-18:00', 'percentage': 42},
      {'period': '19:00-22:00', 'percentage': 18},
      {'period': '其他时间', 'percentage': 5},
    ];
  }

  void _applyFilters() {
    // 实现筛选逻辑
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('日志导出功能开发中...')),
    );
  }

  void _clearOldLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清理'),
        content: const Text('确定要清理30天前的日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('日志清理完成'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('确认清理'),
          ),
        ],
      ),
    );
  }

  void _refreshLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新日志...')),
    );
  }

  void _showLogDetail(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('日志详情 - ${log['operation']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('操作类型: ${log['type']}'),
            Text('操作用户: ${log['user']}'),
            Text('IP地址: ${log['ip']}'),
            Text('状态: ${log['status']}'),
            Text('时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log['timestamp'])}'),
            const SizedBox(height: 16),
            const Text('详细信息:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                log['details'],
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}