import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/conversation_model.dart';
import '../../providers/content_analysis_provider.dart';
import 'package:provider/provider.dart';

class ContentAnalysisScreen extends StatefulWidget {
  const ContentAnalysisScreen({super.key});

  @override
  State<ContentAnalysisScreen> createState() => _ContentAnalysisScreenState();
}

class _ContentAnalysisScreenState extends State<ContentAnalysisScreen> {
  String _selectedTimeRange = '最近7天';
  String _selectedCharacter = '全部角色';
  String _selectedSentiment = '全部情感';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentAnalysisProvider>().loadAnalysisData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/content/analysis',
      child: Consumer<ContentAnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题和筛选
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '对话内容分析',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '分析用户对话内容、情感倾向和话题分布',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // 时间范围
                        _buildFilterDropdown(
                          '时间范围',
                          _selectedTimeRange,
                          ['最近7天', '最近30天', '最近90天'],
                          (value) => setState(() => _selectedTimeRange = value!),
                        ),
                        const SizedBox(width: 12),
                        // 角色筛选
                        _buildFilterDropdown(
                          '角色',
                          _selectedCharacter,
                          ['全部角色', '小雪', '小美', '小智', '小萌'],
                          (value) => setState(() => _selectedCharacter = value!),
                        ),
                        const SizedBox(width: 12),
                        // 情感筛选
                        _buildFilterDropdown(
                          '情感',
                          _selectedSentiment,
                          ['全部情感', '积极', '中性', '消极'],
                          (value) => setState(() => _selectedSentiment = value!),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 核心指标
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '总对话数',
                        value: NumberFormat('#,###').format(provider.totalConversations),
                        subtitle: '今日: ${provider.todayConversations}',
                        trend: 15.6,
                        icon: Icons.chat,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均轮数',
                        value: '${provider.averageRounds.toStringAsFixed(1)}轮',
                        subtitle: '单次对话',
                        trend: 8.3,
                        icon: Icons.forum,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '积极情感占比',
                        value: '${provider.positiveSentimentRate.toStringAsFixed(1)}%',
                        subtitle: '情感分析',
                        trend: 5.2,
                        icon: Icons.sentiment_satisfied,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均响应时间',
                        value: '${provider.averageResponseTime.toStringAsFixed(1)}s',
                        subtitle: 'AI响应',
                        trend: -12.4,
                        icon: Icons.speed,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
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
                          _buildConversationTrendChart(provider),
                          const SizedBox(height: 24),
                          _buildSentimentAnalysisChart(provider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // 右侧图表
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildTopicDistributionChart(provider),
                          const SizedBox(height: 24),
                          _buildCharacterPopularityChart(provider),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 详细分析
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildKeywordAnalysis(provider),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildQualityMetrics(provider),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 实时监控
                _buildRealTimeMonitoring(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              items: items.map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              )).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTrendChart(ContentAnalysisProvider provider) {
    return ChartCard(
      title: '对话趋势分析',
      subtitle: '过去7天的对话量变化',
      child: SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 100,
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
                    final date = DateTime.now().subtract(Duration(days: (6 - value.toInt())));
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
                  interval: 100,
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
            maxX: 6,
            minY: 0,
            maxY: 500,
            lineBarsData: [
              LineChartBarData(
                spots: provider.conversationTrendData.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.toDouble());
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

  Widget _buildSentimentAnalysisChart(ContentAnalysisProvider provider) {
    return ChartCard(
      title: '情感倾向分析',
      subtitle: '用户情感分布趋势',
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
                    final hours = ['00', '04', '08', '12', '16', '20', '24'];
                    if (value.toInt() < hours.length) {
                      return Text(
                        '${hours[value.toInt()]}:00',
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
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
            maxX: 6,
            minY: 0,
            maxY: 100,
            lineBarsData: [
              // 积极情感
              LineChartBarData(
                spots: provider.positiveSentimentTrend.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.success,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              // 中性情感
              LineChartBarData(
                spots: provider.neutralSentimentTrend.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.info,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
              // 消极情感
              LineChartBarData(
                spots: provider.negativeSentimentTrend.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value);
                }).toList(),
                isCurved: true,
                color: AppColors.error,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicDistributionChart(ContentAnalysisProvider provider) {
    return ChartCard(
      title: '话题分布',
      subtitle: '热门话题占比',
      child: SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: provider.topicDistribution.entries.map((entry) {
              final colors = [AppColors.primary, AppColors.secondary, AppColors.info, AppColors.warning, AppColors.success];
              final index = provider.topicDistribution.keys.toList().indexOf(entry.key);
              return PieChartSectionData(
                color: colors[index % colors.length],
                value: entry.value,
                title: '${entry.value.toStringAsFixed(1)}%',
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

  Widget _buildCharacterPopularityChart(ContentAnalysisProvider provider) {
    return ChartCard(
      title: '角色受欢迎度',
      subtitle: '各角色对话占比',
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barGroups: provider.characterPopularity.entries.map((entry) {
              final index = provider.characterPopularity.keys.toList().indexOf(entry.key);
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: entry.value,
                    gradient: AppColors.primaryGradient,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final characters = provider.characterPopularity.keys.toList();
                    if (value.toInt() < characters.length) {
                      return Text(
                        characters[value.toInt()],
                        style: const TextStyle(fontSize: 10),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
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
          ),
        ),
      ),
    );
  }

  Widget _buildKeywordAnalysis(ContentAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '关键词分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: provider.topKeywords.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics(ContentAnalysisProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '对话质量指标',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildQualityMetric('用户满意度', provider.userSatisfaction, '%', AppColors.success),
            const SizedBox(height: 12),
            _buildQualityMetric('对话完成率', provider.conversationCompletionRate, '%', AppColors.info),
            const SizedBox(height: 12),
            _buildQualityMetric('AI理解准确率', provider.aiUnderstandingRate, '%', AppColors.primary),
            const SizedBox(height: 12),
            _buildQualityMetric('重复对话率', provider.repetitiveConversationRate, '%', AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetric(String title, double value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRealTimeMonitoring(ContentAnalysisProvider provider) {
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
                  '实时监控',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '实时更新',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildRealtimeMetric(
                    '当前在线对话',
                    provider.currentActiveConversations.toString(),
                    Icons.chat_bubble,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRealtimeMetric(
                    '每分钟消息数',
                    provider.messagesPerMinute.toString(),
                    Icons.speed,
                    AppColors.info,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRealtimeMetric(
                    '异常对话数',
                    provider.abnormalConversations.toString(),
                    Icons.warning,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRealtimeMetric(
                    '系统响应延迟',
                    '${provider.systemLatency}ms',
                    Icons.timer,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}