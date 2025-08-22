import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/user_management_provider.dart';
import 'package:provider/provider.dart';

class UserProfileAnalysisScreen extends StatefulWidget {
  const UserProfileAnalysisScreen({super.key});

  @override
  State<UserProfileAnalysisScreen> createState() => _UserProfileAnalysisScreenState();
}

class _UserProfileAnalysisScreenState extends State<UserProfileAnalysisScreen> {
  String _selectedTimeRange = '最近30天';
  String _selectedSegment = '全部用户';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/users/profile',
      child: Consumer<UserManagementProvider>(
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
                          '用户画像分析',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '深入分析用户行为特征、偏好和价值分布',
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
                              items: ['最近7天', '最近30天', '最近90天', '最近一年']
                                  .map((range) => DropdownMenuItem(
                                        value: range,
                                        child: Text(range),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedTimeRange = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 用户分群选择
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSegment,
                              items: ['全部用户', '新用户', '活跃用户', '付费用户', '流失用户']
                                  .map((segment) => DropdownMenuItem(
                                        value: segment,
                                        child: Text(segment),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedSegment = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 核心指标卡片
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '用户留存率',
                        value: '78.5%',
                        subtitle: '7日留存',
                        trend: 5.2,
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均会话时长',
                        value: '25.6分钟',
                        subtitle: '单次会话',
                        trend: 12.3,
                        icon: Icons.access_time,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'ARPU',
                        value: '¥156.8',
                        subtitle: '每用户平均收入',
                        trend: -2.1,
                        icon: Icons.attach_money,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '用户满意度',
                        value: '4.2/5.0',
                        subtitle: '平均评分',
                        trend: 8.7,
                        icon: Icons.star,
                        color: AppColors.secondary,
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
                          _buildUserSegmentChart(provider),
                          const SizedBox(height: 24),
                          _buildAgeDistributionChart(provider),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // 右侧图表
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          _buildGenderDistributionChart(provider),
                          const SizedBox(height: 24),
                          _buildMembershipDistributionChart(provider),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 用户行为分析
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildUserBehaviorAnalysis(provider),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildUserValueAnalysis(provider),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 用户偏好分析
                _buildUserPreferenceAnalysis(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserSegmentChart(UserManagementProvider provider) {
    return ChartCard(
      title: '用户分群分析',
      subtitle: '基于活跃度和价值的用户分群',
      child: SizedBox(
        height: 300,
        child: ScatterChart(
          ScatterChartData(
            scatterSpots: _generateUserSegmentData(provider.users),
            minX: 0,
            maxX: 100,
            minY: 0,
            maxY: 2000,
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
                axisNameWidget: const Text('活跃度'),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '¥${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
                axisNameWidget: const Text('消费金额'),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              drawVerticalLine: true,
            ),
            borderData: FlBorderData(show: true),
          ),
        ),
      ),
    );
  }

  Widget _buildAgeDistributionChart(UserManagementProvider provider) {
    return ChartCard(
      title: '年龄分布',
      subtitle: '用户年龄段分析',
      child: SizedBox(
        height: 300,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barGroups: _generateAgeDistributionData(provider.users),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final ageGroups = ['18-25', '26-35', '36-45', '46-55', '55+'];
                    if (value.toInt() < ageGroups.length) {
                      return Text(
                        ageGroups[value.toInt()],
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
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt()}%',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => Colors.blueGrey,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final ageGroups = ['18-25岁', '26-35岁', '36-45岁', '46-55岁', '55岁以上'];
                  return BarTooltipItem(
                    '${ageGroups[groupIndex]}\n${rod.toY.round()}%',
                    const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDistributionChart(UserManagementProvider provider) {
    return ChartCard(
      title: '性别分布',
      subtitle: '用户性别比例',
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: AppColors.primary,
                value: 45,
                title: '男性\n45%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: AppColors.secondary,
                value: 55,
                title: '女性\n55%',
                radius: 60,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipDistributionChart(UserManagementProvider provider) {
    final stats = provider.statistics;
    if (stats == null) return const SizedBox();

    return ChartCard(
      title: '会员分布',
      subtitle: '会员类型占比',
      child: SizedBox(
        height: 200,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: [
              PieChartSectionData(
                color: Colors.grey,
                value: stats.membershipDistribution['普通用户']?.toDouble() ?? 0,
                title: '普通',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: AppColors.warning,
                value: stats.membershipDistribution['会员']?.toDouble() ?? 0,
                title: '会员',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: AppColors.secondary,
                value: stats.membershipDistribution['高级会员']?.toDouble() ?? 0,
                title: '高级',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                color: AppColors.primary,
                value: stats.membershipDistribution['终身会员']?.toDouble() ?? 0,
                title: '终身',
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserBehaviorAnalysis(UserManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户行为分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildBehaviorMetric('平均日活跃时长', '2.5小时', Icons.access_time, AppColors.info),
            const SizedBox(height: 12),
            _buildBehaviorMetric('平均对话轮数', '15.6轮', Icons.chat, AppColors.primary),
            const SizedBox(height: 12),
            _buildBehaviorMetric('功能使用率', '68.3%', Icons.functions, AppColors.success),
            const SizedBox(height: 12),
            _buildBehaviorMetric('分享频率', '3.2次/周', Icons.share, AppColors.secondary),
            const SizedBox(height: 12),
            _buildBehaviorMetric('反馈提交率', '12.8%', Icons.feedback, AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildUserValueAnalysis(UserManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户价值分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildValueSegment('高价值用户', '15%', '月消费>500元', AppColors.success),
            const SizedBox(height: 12),
            _buildValueSegment('中价值用户', '35%', '月消费100-500元', AppColors.warning),
            const SizedBox(height: 12),
            _buildValueSegment('低价值用户', '30%', '月消费<100元', AppColors.info),
            const SizedBox(height: 12),
            _buildValueSegment('免费用户', '20%', '未付费用户', Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPreferenceAnalysis(UserManagementProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用户偏好分析',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '热门角色类型',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildPreferenceItem('温柔型', '32%', AppColors.primary),
                      _buildPreferenceItem('活泼型', '28%', AppColors.secondary),
                      _buildPreferenceItem('知性型', '25%', AppColors.info),
                      _buildPreferenceItem('冷酷型', '15%', AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '活跃时段',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildPreferenceItem('晚上(19-23点)', '45%', AppColors.primary),
                      _buildPreferenceItem('下午(14-18点)', '25%', AppColors.secondary),
                      _buildPreferenceItem('上午(9-12点)', '20%', AppColors.info),
                      _buildPreferenceItem('深夜(23-2点)', '10%', AppColors.warning),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '功能偏好',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildPreferenceItem('智能对话', '78%', AppColors.primary),
                      _buildPreferenceItem('语音交互', '56%', AppColors.secondary),
                      _buildPreferenceItem('图片生成', '34%', AppColors.info),
                      _buildPreferenceItem('知识问答', '42%', AppColors.warning),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorMetric(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildValueSegment(String title, String percentage, String description, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              percentage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: double.parse(percentage.replaceAll('%', '')) / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(String title, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            percentage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<ScatterSpot> _generateUserSegmentData(List<UserModel> users) {
    return users.asMap().entries.map<ScatterSpot>((entry) {
      final user = entry.value;
      final activityScore = _calculateActivityScore(user);
      final spendingValue = user.totalSpent;
      
      return ScatterSpot(
        activityScore,
        spendingValue,
      );
    }).toList();
  }

  double _calculateActivityScore(UserModel user) {
    final daysSinceLastLogin = DateTime.now().difference(user.lastLoginAt).inDays;
    if (daysSinceLastLogin == 0) return 90 + (user.conversationCount % 10);
    if (daysSinceLastLogin <= 3) return 70 + (user.conversationCount % 20);
    if (daysSinceLastLogin <= 7) return 50 + (user.conversationCount % 20);
    return 10 + (user.conversationCount % 40);
  }

  Color _getSegmentColor(double activity, double spending) {
    if (activity > 70 && spending > 500) return AppColors.success; // 高价值高活跃
    if (activity > 70) return AppColors.info; // 高活跃
    if (spending > 500) return AppColors.warning; // 高价值
    return Colors.grey; // 普通用户
  }

  List<BarChartGroupData> _generateAgeDistributionData(List<UserModel> users) {
    final ageGroups = [0, 0, 0, 0, 0]; // 18-25, 26-35, 36-45, 46-55, 55+
    
    for (final user in users) {
      final age = user.profile['age'] as int? ?? 25;
      if (age <= 25) {
        ageGroups[0]++;
      } else if (age <= 35) {
        ageGroups[1]++;
      } else if (age <= 45) {
        ageGroups[2]++;
      } else if (age <= 55) {
        ageGroups[3]++;
      } else {
        ageGroups[4]++;
      }
    }
    
    final total = users.length;
    return ageGroups.asMap().entries.map((entry) {
      final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: percentage,
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}