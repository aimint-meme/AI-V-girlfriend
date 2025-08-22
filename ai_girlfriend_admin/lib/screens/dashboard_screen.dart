import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/admin_layout.dart';
import '../widgets/stat_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/activity_list.dart';
import '../constants/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/dashboard',
      child: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: dashboardProvider.refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 页面标题和刷新按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '仪表板',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '欢迎回来，${context.read<AuthProvider>().username}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '最后更新: ${DateFormat('MM-dd HH:mm').format(DateTime.now())}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: dashboardProvider.refreshData,
                            icon: const Icon(Icons.refresh),
                            tooltip: '刷新数据',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 统计卡片
                  _buildStatsCards(dashboardProvider),
                  const SizedBox(height: 32),

                  // 图表区域
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 左侧图表
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildUserGrowthChart(dashboardProvider),
                            const SizedBox(height: 24),
                            _buildRevenueChart(dashboardProvider),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // 右侧活动列表
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildRecentActivities(dashboardProvider),
                            const SizedBox(height: 24),
                            _buildSystemStatus(dashboardProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 功能使用统计和地区分布
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFeatureUsageChart(dashboardProvider),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildRegionDistribution(dashboardProvider),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(DashboardProvider provider) {
    final userStats = provider.getUserStats();
    final revenueStats = provider.getRevenueStats();
    final characterStats = provider.getCharacterStats();
    final conversationStats = provider.getConversationStats();

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: '总用户数',
            value: NumberFormat('#,###').format(userStats['total']),
            subtitle: '活跃用户: ${NumberFormat('#,###').format(userStats['active'])}',
            trend: userStats['growthRate'],
            icon: Icons.people,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '总收入',
            value: '¥${NumberFormat('#,###.##').format(revenueStats['total'])}',
            subtitle: '本月: ¥${NumberFormat('#,###.##').format(revenueStats['monthly'])}',
            trend: revenueStats['growthRate'],
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '角色数量',
            value: characterStats['total'].toString(),
            subtitle: '活跃: ${characterStats['active']}',
            trend: characterStats['usageRate'],
            icon: Icons.person,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '对话总数',
            value: NumberFormat('#,###').format(conversationStats['total']),
            subtitle: '今日: ${NumberFormat('#,###').format(conversationStats['today'])}',
            trend: 15.6,
            icon: Icons.chat,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserGrowthChart(DashboardProvider provider) {
    return ChartCard(
      title: '用户增长趋势',
      subtitle: '过去30天',
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1000,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 5,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final date = DateTime.now().subtract(Duration(days: (29 - value.toInt())));
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1000,
                  reservedSize: 42,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 29,
            minY: 0,
            maxY: 20000,
            lineBarsData: [
              LineChartBarData(
                spots: provider.chartData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value['users'].toDouble());
                }).toList(),
                isCurved: true,
                gradient: AppColors.primaryGradient,
                barWidth: 3,
                isStrokeCapRound: true,
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

  Widget _buildRevenueChart(DashboardProvider provider) {
    return ChartCard(
      title: '收入趋势',
      subtitle: '过去30天',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 5000,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey,
                tooltipHorizontalAlignment: FLHorizontalAlignment.right,
                tooltipMargin: -10,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '¥${rod.toY.round()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final date = DateTime.now().subtract(Duration(days: (29 - value.toInt())));
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat('dd').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                  reservedSize: 38,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1000,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: provider.chartData.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value['revenue'].toDouble(),
                    gradient: AppColors.accentGradient,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivities(DashboardProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '最近活动',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 查看全部活动
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ActivityList(
              activities: provider.recentActivities.take(5).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus(DashboardProvider provider) {
    final systemStats = provider.systemStats;
    final healthStatus = provider.getSystemHealthStatus();
    
    Color statusColor;
    String statusText;
    switch (healthStatus) {
      case 'excellent':
        statusColor = AppColors.success;
        statusText = '优秀';
        break;
      case 'good':
        statusColor = AppColors.info;
        statusText = '良好';
        break;
      case 'fair':
        statusColor = AppColors.warning;
        statusText = '一般';
        break;
      default:
        statusColor = AppColors.error;
        statusText = '较差';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '系统状态',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSystemMetric('CPU使用率', systemStats['cpuUsage'], '%'),
            const SizedBox(height: 12),
            _buildSystemMetric('内存使用率', systemStats['memoryUsage'], '%'),
            const SizedBox(height: 12),
            _buildSystemMetric('磁盘使用率', systemStats['diskUsage'], '%'),
            const SizedBox(height: 12),
            _buildSystemMetric('响应时间', systemStats['responseTime'], 'ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemMetric(String label, dynamic value, String unit) {
    final percentage = value is double ? value : value.toDouble();
    Color color;
    if (percentage < 50) {
      color = AppColors.success;
    } else if (percentage < 80) {
      color = AppColors.warning;
    } else {
      color = AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${percentage.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildFeatureUsageChart(DashboardProvider provider) {
    final featureStats = provider.getFeatureUsageStats();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '功能使用统计',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...featureStats.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      feature['name'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: feature['usage'] / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${feature['usage'].toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    feature['trend'] == 'up'
                        ? Icons.trending_up
                        : feature['trend'] == 'down'
                            ? Icons.trending_down
                            : Icons.trending_flat,
                    size: 16,
                    color: feature['trend'] == 'up'
                        ? AppColors.success
                        : feature['trend'] == 'down'
                            ? AppColors.error
                            : AppColors.info,
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionDistribution(DashboardProvider provider) {
    final regionData = provider.getRegionDistribution();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户地区分布',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: regionData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    final colors = [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.accent,
                      AppColors.info,
                      AppColors.success,
                    ];
                    
                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: data['percentage'],
                      title: '${data['percentage']}%',
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
            const SizedBox(height: 16),
            ...regionData.map((region) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: [AppColors.primary, AppColors.secondary, AppColors.accent, AppColors.info, AppColors.success]
                          [regionData.indexOf(region) % 5],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      region['region'],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    NumberFormat('#,###').format(region['users']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
}