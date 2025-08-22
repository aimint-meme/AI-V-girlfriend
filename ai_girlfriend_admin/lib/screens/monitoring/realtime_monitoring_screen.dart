import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/monitoring_model.dart';
import '../../providers/monitoring_provider.dart';
import 'package:provider/provider.dart';

class RealtimeMonitoringScreen extends StatefulWidget {
  const RealtimeMonitoringScreen({super.key});

  @override
  State<RealtimeMonitoringScreen> createState() => _RealtimeMonitoringScreenState();
}

class _RealtimeMonitoringScreenState extends State<RealtimeMonitoringScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '最近1小时';
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MonitoringProvider>();
      provider.startRealTimeMonitoring();
      if (_autoRefresh) {
        provider.startAutoRefresh();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<MonitoringProvider>().stopRealTimeMonitoring();
    context.read<MonitoringProvider>().stopAutoRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/monitoring/realtime',
      child: Consumer<MonitoringProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题和控制
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '实时数据分析/性能监控',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: provider.isRealTimeActive ? AppColors.success : AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.isRealTimeActive ? '实时监控中' : '监控已停止',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '实时监控系统性能、用户活跃度和业务指标',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // 时间范围选择
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTimeRange,
                              items: ['最近15分钟', '最近1小时', '最近6小时', '最近24小时']
                                  .map((range) => DropdownMenuItem(
                                        value: range,
                                        child: Text(range),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTimeRange = value!;
                                });
                                provider.changeTimeRange(value!);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 自动刷新开关
                        Row(
                          children: [
                            Switch(
                              value: _autoRefresh,
                              onChanged: (value) {
                                setState(() {
                                  _autoRefresh = value;
                                });
                                if (value) {
                                  provider.startAutoRefresh();
                                } else {
                                  provider.stopAutoRefresh();
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '自动刷新',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // 手动刷新按钮
                        IconButton(
                          onPressed: () => provider.refreshData(),
                          icon: const Icon(Icons.refresh),
                          tooltip: '手动刷新',
                        ),
                        // 导出报告按钮
                        IconButton(
                          onPressed: () => _exportReport(provider),
                          icon: const Icon(Icons.download),
                          tooltip: '导出报告',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 关键指标卡片
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'CPU使用率',
                        value: '${provider.systemMetrics?.cpuUsage.toStringAsFixed(1)}%',
                        subtitle: '当前负载',
                        trend: provider.systemMetrics?.cpuTrend ?? 0,
                        icon: Icons.memory,
                        color: _getMetricColor(provider.systemMetrics?.cpuUsage ?? 0, 80),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '内存使用率',
                        value: '${provider.systemMetrics?.memoryUsage.toStringAsFixed(1)}%',
                        subtitle: '${(provider.systemMetrics?.memoryUsed ?? 0).toStringAsFixed(1)}GB / ${(provider.systemMetrics?.memoryTotal ?? 0).toStringAsFixed(1)}GB',
                        trend: provider.systemMetrics?.memoryTrend ?? 0,
                        icon: Icons.storage,
                        color: _getMetricColor(provider.systemMetrics?.memoryUsage ?? 0, 85),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '网络流量',
                        value: '${(provider.systemMetrics?.networkIn ?? 0).toStringAsFixed(1)}MB/s',
                        subtitle: '入站流量',
                        trend: provider.systemMetrics?.networkTrend ?? 0,
                        icon: Icons.network_check,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '响应时间',
                        value: '${provider.systemMetrics?.avgResponseTime ?? 0}ms',
                        subtitle: 'API平均响应',
                        trend: provider.systemMetrics?.responseTrend ?? 0,
                        icon: Icons.speed,
                        color: _getResponseTimeColor(provider.systemMetrics?.avgResponseTime ?? 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 标签页
                Container(
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
                              icon: Icon(Icons.computer),
                              text: '系统性能',
                            ),
                            Tab(
                              icon: Icon(Icons.people),
                              text: '用户活跃度',
                            ),
                            Tab(
                              icon: Icon(Icons.api),
                              text: 'API监控',
                            ),
                            Tab(
                              icon: Icon(Icons.warning),
                              text: '告警中心',
                            ),
                          ],
                        ),
                      ),
                      // 标签页内容
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSystemPerformance(provider),
                            _buildUserActivity(provider),
                            _buildApiMonitoring(provider),
                            _buildAlertCenter(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSystemPerformance(MonitoringProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧图表
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildCpuMemoryChart(provider),
                const SizedBox(height: 20),
                _buildNetworkChart(provider),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // 右侧信息
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSystemInfo(provider),
                const SizedBox(height: 20),
                _buildProcessList(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCpuMemoryChart(MonitoringProvider provider) {
    return ChartCard(
      title: 'CPU & 内存使用率',
      subtitle: '实时系统资源监控',
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 20,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final time = DateTime.now().subtract(Duration(minutes: (60 - value.toInt())));
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat('HH:mm').format(time),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 20,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 60,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              // CPU使用率
              LineChartBarData(
                spots: provider.cpuHistory.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withOpacity(0.1),
                ),
              ),
              // 内存使用率
              LineChartBarData(
                spots: provider.memoryHistory.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.secondary,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.secondary.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkChart(MonitoringProvider provider) {
    return ChartCard(
      title: '网络流量',
      subtitle: '入站/出站流量监控',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final time = DateTime.now().subtract(Duration(minutes: (30 - value.toInt())));
                    return Text(
                      DateFormat('HH:mm').format(time),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}MB/s',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 30,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              // 入站流量
              LineChartBarData(
                spots: provider.networkInHistory.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.success,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              // 出站流量
              LineChartBarData(
                spots: provider.networkOutHistory.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.warning,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfo(MonitoringProvider provider) {
    final systemInfo = provider.systemInfo;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '系统信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem('操作系统', systemInfo?.os ?? 'Unknown'),
            _buildInfoItem('CPU型号', systemInfo?.cpuModel ?? 'Unknown'),
            _buildInfoItem('CPU核心数', '${systemInfo?.cpuCores ?? 0}'),
            _buildInfoItem('总内存', '${systemInfo?.totalMemory ?? 0}GB'),
            _buildInfoItem('磁盘空间', '${systemInfo?.diskSpace ?? 0}GB'),
            _buildInfoItem('运行时间', _formatUptime(systemInfo?.uptime ?? 0)),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessList(MonitoringProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '进程监控',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.topProcesses.map((process) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      process.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${process.cpuUsage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getMetricColor(process.cpuUsage, 50),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivity(MonitoringProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildActiveUsersChart(provider),
                const SizedBox(height: 20),
                _buildUserActionChart(provider),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildUserStats(provider),
                const SizedBox(height: 20),
                _buildTopPages(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUsersChart(MonitoringProvider provider) {
    return ChartCard(
      title: '活跃用户数',
      subtitle: '实时在线用户监控',
      child: SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final time = DateTime.now().subtract(Duration(hours: (24 - value.toInt())));
                    return Text(
                      DateFormat('HH:mm').format(time),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 24,
            minY: 0,
            maxY: provider.activeUsersHistory.isNotEmpty 
                ? provider.activeUsersHistory.reduce((a, b) => a > b ? a : b) * 1.2
                : 100,
            lineBarsData: [
              LineChartBarData(
                spots: provider.activeUsersHistory.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.toDouble());
                }).toList(),
                isCurved: true,
                gradient: AppColors.primaryGradient,
                barWidth: 3,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserActionChart(MonitoringProvider provider) {
    return ChartCard(
      title: '用户行为分布',
      subtitle: '各类操作的实时统计',
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: provider.userActions.entries.map((entry) {
              final colors = [AppColors.primary, AppColors.secondary, AppColors.info, AppColors.warning, AppColors.success];
              final index = provider.userActions.keys.toList().indexOf(entry.key);
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: entry.value.toDouble(),
                title: '${entry.value}',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserStats(MonitoringProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户统计',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatItem('当前在线', '${provider.currentOnlineUsers}', AppColors.success),
            _buildStatItem('今日新增', '${provider.todayNewUsers}', AppColors.info),
            _buildStatItem('活跃用户', '${provider.activeUsers}', AppColors.primary),
            _buildStatItem('会话总数', '${provider.totalSessions}', AppColors.secondary),
            _buildStatItem('平均会话时长', '${provider.avgSessionDuration}分钟', AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPages(MonitoringProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门页面',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.topPages.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildApiMonitoring(MonitoringProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // API统计卡片
          Row(
            children: [
              Expanded(
                child: _buildApiStatCard('总请求数', '${provider.totalApiRequests}', Icons.api, AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildApiStatCard('成功率', '${provider.apiSuccessRate.toStringAsFixed(1)}%', Icons.check_circle, AppColors.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildApiStatCard('平均响应时间', '${provider.avgApiResponseTime}ms', Icons.speed, AppColors.info),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildApiStatCard('错误数', '${provider.apiErrors}', Icons.error, AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // API详细监控
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildApiResponseTimeChart(provider),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _buildApiEndpointsList(provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiResponseTimeChart(MonitoringProvider provider) {
    return ChartCard(
      title: 'API响应时间趋势',
      subtitle: '各API端点响应时间监控',
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final time = DateTime.now().subtract(Duration(minutes: (30 - value.toInt())));
                    return Text(
                      DateFormat('HH:mm').format(time),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 42,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}ms',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 30,
            minY: 0,
            maxY: 2000,
            lineBarsData: provider.apiEndpoints.entries.map((entry) {
              final colors = [AppColors.primary, AppColors.secondary, AppColors.info, AppColors.warning];
              final index = provider.apiEndpoints.keys.toList().indexOf(entry.key);
              return LineChartBarData(
                spots: entry.value.responseTimeHistory.asMap().entries.map((historyEntry) {
                  return FlSpot(historyEntry.key.toDouble(), historyEntry.value.toDouble());
                }).toList(),
                isCurved: true,
                color: colors[index % colors.length],
                barWidth: 2,
                dotData: const FlDotData(show: false),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildApiEndpointsList(MonitoringProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API端点监控',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: provider.apiEndpoints.length,
                itemBuilder: (context, index) {
                  final entry = provider.apiEndpoints.entries.elementAt(index);
                  final endpoint = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: endpoint.status == 'healthy' ? AppColors.success : AppColors.error,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  endpoint.status == 'healthy' ? '正常' : '异常',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${endpoint.avgResponseTime}ms',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                              Text(
                                '${endpoint.requestCount} 请求',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCenter(MonitoringProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 告警统计
          Row(
            children: [
              Expanded(
                child: _buildAlertStatCard('严重告警', '${provider.criticalAlerts}', Icons.error, AppColors.error),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlertStatCard('警告', '${provider.warningAlerts}', Icons.warning, AppColors.warning),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlertStatCard('信息', '${provider.infoAlerts}', Icons.info, AppColors.info),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAlertStatCard('已解决', '${provider.resolvedAlerts}', Icons.check_circle, AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 告警列表
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '实时告警 (${provider.alerts.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () => provider.clearAllAlerts(),
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('清除全部'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => provider.refreshAlerts(),
                              icon: const Icon(Icons.refresh),
                              tooltip: '刷新告警',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.alerts.length,
                      itemBuilder: (context, index) {
                        final alert = provider.alerts[index];
                        return ListTile(
                          leading: Icon(
                            _getAlertIcon(alert.level),
                            color: _getAlertColor(alert.level),
                          ),
                          title: Text(
                            alert.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert.message),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss').format(alert.timestamp),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleAlertAction(value, alert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'resolve',
                                child: Text('标记为已解决'),
                              ),
                              const PopupMenuItem(
                                value: 'ignore',
                                child: Text('忽略'),
                              ),
                              const PopupMenuItem(
                                value: 'details',
                                child: Text('查看详情'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMetricColor(double value, double threshold) {
    if (value > threshold) return AppColors.error;
    if (value > threshold * 0.8) return AppColors.warning;
    return AppColors.success;
  }

  Color _getResponseTimeColor(int responseTime) {
    if (responseTime > 1000) return AppColors.error;
    if (responseTime > 500) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getAlertIcon(String level) {
    switch (level) {
      case 'critical':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getAlertColor(String level) {
    switch (level) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'info':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  String _formatUptime(int seconds) {
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${days}天 ${hours}小时 ${minutes}分钟';
  }

  void _handleAlertAction(String action, AlertModel alert) {
    final provider = context.read<MonitoringProvider>();
    switch (action) {
      case 'resolve':
        provider.resolveAlert(alert.id);
        break;
      case 'ignore':
        provider.ignoreAlert(alert.id);
        break;
      case 'details':
        _showAlertDetails(alert);
        break;
    }
  }

  void _showAlertDetails(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('级别: ${alert.level}'),
            const SizedBox(height: 8),
            Text('时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(alert.timestamp)}'),
            const SizedBox(height: 8),
            Text('消息: ${alert.message}'),
            if (alert.details.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('详情: ${alert.details}'),
            ],
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

  void _exportReport(MonitoringProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出监控报告功能开发中...')),
    );
  }
}