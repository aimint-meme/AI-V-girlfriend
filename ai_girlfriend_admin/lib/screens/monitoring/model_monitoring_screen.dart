import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/monitoring_provider.dart';

class ModelMonitoringScreen extends StatefulWidget {
  const ModelMonitoringScreen({super.key});

  @override
  State<ModelMonitoringScreen> createState() => _ModelMonitoringScreenState();
}

class _ModelMonitoringScreenState extends State<ModelMonitoringScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '24h';
  String _selectedModel = '全部模型';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonitoringProvider>().loadModelData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/monitoring/model',
      child: Consumer<MonitoringProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面标题和控制栏
              _buildHeader(),
              const SizedBox(height: 24),
              
              // 核心指标卡片
              _buildStatsCards(provider),
              const SizedBox(height: 24),
              
              // 标签页内容
              Expanded(
                child: Column(
                  children: [
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCallVolumeTab(provider),
                          _buildResponseTimeTab(provider),
                          _buildModelPerformanceTab(provider),
                          _buildErrorAnalysisTab(provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '模型调用量/响应时延',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI模型使用情况和性能监控',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        const Spacer(),
        // 时间范围选择
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              items: ['1h', '6h', '24h', '7d', '30d'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeRange = newValue;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 模型选择
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedModel,
              items: ['全部模型', 'GPT-4', 'GPT-3.5', 'Claude-3', '文心一言'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedModel = newValue;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            context.read<MonitoringProvider>().loadModelData();
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('刷新'),
        ),
      ],
    );
  }

  Widget _buildStatsCards(MonitoringProvider provider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: '总调用量',
            value: '${provider.totalCalls}',
            subtitle: '今日: ${provider.todayCalls}',
            icon: Icons.api,
            trend: provider.callsTrend,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '平均响应时间',
            value: '${provider.avgResponseTime}ms',
            subtitle: '较昨日: ${provider.responseTimeTrend > 0 ? '+' : ''}${provider.responseTimeTrend}ms',
            icon: Icons.speed,
            trend: provider.responseTimeTrend,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '成功率',
            value: '${provider.successRate}%',
            subtitle: '错误率: ${(100 - provider.successRate).toStringAsFixed(1)}%',
            icon: Icons.check_circle,
            trend: provider.successRateTrend,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Token消耗',
            value: '${(provider.totalTokens / 1000).toStringAsFixed(1)}K',
            subtitle: '今日: ${(provider.todayTokens / 1000).toStringAsFixed(1)}K',
            icon: Icons.token,
            trend: provider.tokensTrend,
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppTheme.textSecondaryColor,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
            icon: Icon(Icons.trending_up, size: 20),
            text: '调用量趋势',
          ),
          Tab(
            icon: Icon(Icons.timer, size: 20),
            text: '响应时间',
          ),
          Tab(
            icon: Icon(Icons.analytics, size: 20),
            text: '模型性能',
          ),
          Tab(
            icon: Icon(Icons.error_outline, size: 20),
            text: '错误分析',
          ),
        ],
      ),
    );
  }

  Widget _buildCallVolumeTab(MonitoringProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 调用量趋势图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '调用量趋势 ($_selectedTimeRange)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppTheme.borderColor,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: AppTheme.borderColor,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                const style = TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                );
                                Widget text;
                                switch (value.toInt()) {
                                  case 0:
                                    text = const Text('00:00', style: style);
                                    break;
                                  case 6:
                                    text = const Text('06:00', style: style);
                                    break;
                                  case 12:
                                    text = const Text('12:00', style: style);
                                    break;
                                  case 18:
                                    text = const Text('18:00', style: style);
                                    break;
                                  case 24:
                                    text = const Text('24:00', style: style);
                                    break;
                                  default:
                                    text = const Text('', style: style);
                                    break;
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: text,
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 42,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: AppTheme.borderColor, width: 1),
                        ),
                        minX: 0,
                        maxX: 24,
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: provider.callVolumeData,
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: false,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 模型使用分布
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '模型使用分布',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: provider.modelUsageData,
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '热门时段分析',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...provider.peakHours.map((hour) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                child: Text(
                                  '${hour['hour']}:00',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: hour['usage'] / 100,
                                  backgroundColor: AppTheme.borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${hour['usage']}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeTab(MonitoringProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 响应时间趋势
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '响应时间趋势',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: provider.responseTimeData,
                            isCurved: true,
                            color: Colors.orange,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.orange.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 响应时间分布
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '响应时间分布',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(enabled: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      const style = TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      );
                                      String text;
                                      switch (value.toInt()) {
                                        case 0:
                                          text = '<100ms';
                                          break;
                                        case 1:
                                          text = '100-500ms';
                                          break;
                                        case 2:
                                          text = '500ms-1s';
                                          break;
                                        case 3:
                                          text = '1-3s';
                                          break;
                                        case 4:
                                          text = '>3s';
                                          break;
                                        default:
                                          text = '';
                                          break;
                                      }
                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        child: Text(text, style: style),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: provider.responseTimeDistribution,
                            ),
                          ),
                        ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '性能指标',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMetricItem('P50 响应时间', '${provider.p50ResponseTime}ms', Colors.blue),
                        _buildMetricItem('P90 响应时间', '${provider.p90ResponseTime}ms', Colors.orange),
                        _buildMetricItem('P99 响应时间', '${provider.p99ResponseTime}ms', Colors.red),
                        _buildMetricItem('最大响应时间', '${provider.maxResponseTime}ms', Colors.purple),
                        _buildMetricItem('最小响应时间', '${provider.minResponseTime}ms', Colors.green),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModelPerformanceTab(MonitoringProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 模型性能对比
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '模型性能对比',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('模型')),
                        DataColumn(label: Text('调用量')),
                        DataColumn(label: Text('平均响应时间')),
                        DataColumn(label: Text('成功率')),
                        DataColumn(label: Text('Token消耗')),
                        DataColumn(label: Text('成本')),
                      ],
                      rows: provider.modelPerformanceData.map((model) {
                        return DataRow(
                          cells: [
                            DataCell(Text(model['name'])),
                            DataCell(Text(model['calls'].toString())),
                            DataCell(Text('${model['avgResponseTime']}ms')),
                            DataCell(Text('${model['successRate']}%')),
                            DataCell(Text('${model['tokens']}')),
                            DataCell(Text('¥${model['cost']}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Token使用统计
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Token使用趋势',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: provider.tokenUsageData,
                                  isCurved: true,
                                  color: Colors.purple,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.purple.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '成本分析',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCostItem('今日成本', '¥${provider.todayCost}', Colors.green),
                        _buildCostItem('本月成本', '¥${provider.monthCost}', Colors.blue),
                        _buildCostItem('预计月成本', '¥${provider.estimatedMonthlyCost}', Colors.orange),
                        const Divider(),
                        _buildCostItem('平均每次调用', '¥${provider.avgCostPerCall}', Colors.purple),
                        _buildCostItem('平均每Token', '¥${provider.avgCostPerToken}', Colors.red),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorAnalysisTab(MonitoringProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '错误类型分布',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: provider.errorTypeData,
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                            ),
                          ),
                        ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '错误趋势',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: AppTheme.borderColor),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: provider.errorTrendData,
                                  isCurved: true,
                                  color: Colors.red,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.red.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 错误详情列表
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近错误记录',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('时间')),
                        DataColumn(label: Text('模型')),
                        DataColumn(label: Text('错误类型')),
                        DataColumn(label: Text('错误信息')),
                        DataColumn(label: Text('状态码')),
                        DataColumn(label: Text('操作')),
                      ],
                      rows: provider.recentErrors.map((error) {
                        return DataRow(
                          cells: [
                            DataCell(Text(error['time'])),
                            DataCell(Text(error['model'])),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getErrorTypeColor(error['type']).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  error['type'],
                                  style: TextStyle(
                                    color: _getErrorTypeColor(error['type']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  error['message'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(error['statusCode'].toString())),
                            DataCell(
                              TextButton(
                                onPressed: () {
                                  _showErrorDetails(error);
                                },
                                child: const Text('详情'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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

  Widget _buildMetricItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getErrorTypeColor(String type) {
    switch (type) {
      case '超时':
        return Colors.orange;
      case '限流':
        return Colors.red;
      case '认证失败':
        return Colors.purple;
      case '服务不可用':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  void _showErrorDetails(Map<String, dynamic> error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('错误详情 - ${error['type']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('时间', error['time']),
              _buildDetailRow('模型', error['model']),
              _buildDetailRow('错误类型', error['type']),
              _buildDetailRow('状态码', error['statusCode'].toString()),
              _buildDetailRow('错误信息', error['message']),
              if (error['stackTrace'] != null)
                _buildDetailRow('堆栈跟踪', error['stackTrace']),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}