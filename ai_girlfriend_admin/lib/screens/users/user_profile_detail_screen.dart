import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/user_management_provider.dart';

class UserProfileDetailScreen extends StatefulWidget {
  final String userId;
  
  const UserProfileDetailScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  UserModel? _user;
  bool _isLoading = true;
  
  // 模拟用户画像数据
  Map<String, dynamic> _userProfile = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 获取用户基本信息
      final provider = context.read<UserManagementProvider>();
      _user = provider.getUserById(widget.userId);
      
      // 模拟加载用户画像数据
      await Future.delayed(const Duration(milliseconds: 800));
      
      _userProfile = {
        // 基础信息
        'totalInteractions': 1247,
        'totalSpent': 2856.50,
        'avgSessionDuration': 28.5,
        'favoriteCharacter': '小雪',
        'membershipDays': 156,
        'lastActiveDate': DateTime.now().subtract(const Duration(hours: 2)),
        
        // 互动数据
        'dailyInteractions': [
          FlSpot(0, 12),
          FlSpot(1, 18),
          FlSpot(2, 15),
          FlSpot(3, 22),
          FlSpot(4, 28),
          FlSpot(5, 25),
          FlSpot(6, 30),
          FlSpot(7, 35),
          FlSpot(8, 32),
          FlSpot(9, 28),
          FlSpot(10, 24),
          FlSpot(11, 20),
          FlSpot(12, 26),
          FlSpot(13, 31),
        ],
        
        // 消费数据
        'monthlySpending': [
          FlSpot(1, 150),
          FlSpot(2, 280),
          FlSpot(3, 320),
          FlSpot(4, 180),
          FlSpot(5, 450),
          FlSpot(6, 380),
        ],
        
        // 角色偏好
        'characterPreferences': [
          {'name': '小雪', 'percentage': 45.2, 'color': Colors.blue},
          {'name': '小美', 'percentage': 28.6, 'color': Colors.pink},
          {'name': '小萌', 'percentage': 18.3, 'color': Colors.purple},
          {'name': '其他', 'percentage': 7.9, 'color': Colors.grey},
        ],
        
        // 互动类型分布
        'interactionTypes': [
          {'type': '文字聊天', 'count': 856, 'percentage': 68.7},
          {'type': '语音通话', 'count': 234, 'percentage': 18.8},
          {'type': '视频互动', 'count': 98, 'percentage': 7.9},
          {'type': '游戏互动', 'count': 59, 'percentage': 4.7},
        ],
        
        // 消费记录
        'recentTransactions': [
          {
            'date': DateTime.now().subtract(const Duration(days: 1)),
            'type': '会员续费',
            'amount': 99.0,
            'status': '成功',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 3)),
            'type': '虚拟礼品',
            'amount': 25.0,
            'status': '成功',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 5)),
            'type': 'AI对话包',
            'amount': 15.0,
            'status': '成功',
          },
          {
            'date': DateTime.now().subtract(const Duration(days: 7)),
            'type': '个性化定制',
            'amount': 50.0,
            'status': '成功',
          },
        ],
        
        // 行为标签
        'behaviorTags': [
          {'label': '高活跃用户', 'color': Colors.green},
          {'label': '付费用户', 'color': Colors.orange},
          {'label': '忠实用户', 'color': Colors.blue},
          {'label': '社交型', 'color': Colors.purple},
        ],
        
        // 使用时段偏好
        'timePreferences': {
          '早晨(6-12)': 15.2,
          '下午(12-18)': 28.6,
          '晚上(18-24)': 45.8,
          '深夜(0-6)': 10.4,
        },
      };
      
    } catch (e) {
      print('加载用户画像失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AdminLayout(
        currentRoute: '/users/profile-detail',
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_user == null) {
      return AdminLayout(
        currentRoute: '/users/profile-detail',
        child: const Center(
          child: Text('用户不存在'),
        ),
      );
    }

    return AdminLayout(
      currentRoute: '/users/profile-detail',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 页面标题和返回按钮
            Row(
              children: [
                IconButton(
                  onPressed: () => context.go('/users/data'),
                  icon: const Icon(Icons.arrow_back),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户画像详情',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_user!.username} 的详细互动和消费分析',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 用户基本信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 24),
            
            // 核心指标卡片
            _buildMetricsCards(),
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
                        _buildInteractionTab(),
                        _buildConsumptionTab(),
                        _buildPreferencesTab(),
                        _buildBehaviorTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 用户头像
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                _user!.username.isNotEmpty ? _user!.username[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            
            // 用户基本信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _user!.username,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildMembershipChip(_user!.membershipType),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${_user!.id}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '邮箱: ${_user!.email}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '注册时间: ${DateFormat('yyyy-MM-dd HH:mm').format(_user!.createdAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '最后活跃: ${DateFormat('yyyy-MM-dd HH:mm').format(_userProfile['lastActiveDate'])}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // 行为标签
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: (_userProfile['behaviorTags'] as List).map((tag) {
                    return Chip(
                      label: Text(
                        tag['label'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: tag['color'],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: '总互动次数',
            value: '${_userProfile['totalInteractions']}',
            subtitle: '平均每日: ${(_userProfile['totalInteractions'] / 30).toInt()}次',
            icon: Icons.chat,
            trend: 15.2,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '总消费金额',
            value: '¥${_userProfile['totalSpent']}',
            subtitle: '月均: ¥${(_userProfile['totalSpent'] / 6).toStringAsFixed(0)}',
            icon: Icons.monetization_on,
            trend: 8.7,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '平均会话时长',
            value: '${_userProfile['avgSessionDuration']}分钟',
            subtitle: '高于平均水平',
            icon: Icons.access_time,
            trend: 12.3,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: '会员天数',
            value: '${_userProfile['membershipDays']}天',
            subtitle: '忠实用户',
            icon: Icons.star,
            trend: 0.0,
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
            icon: Icon(Icons.chat_bubble, size: 20),
            text: '互动分析',
          ),
          Tab(
            icon: Icon(Icons.shopping_cart, size: 20),
            text: '消费分析',
          ),
          Tab(
            icon: Icon(Icons.favorite, size: 20),
            text: '偏好分析',
          ),
          Tab(
            icon: Icon(Icons.psychology, size: 20),
            text: '行为分析',
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 互动趋势图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '近14天互动趋势',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}日',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _userProfile['dailyInteractions'],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
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
          
          // 互动类型分布
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '互动类型分布',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(_userProfile['interactionTypes'] as List).map((type) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              type['type'],
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: LinearProgressIndicator(
                              value: type['percentage'] / 100,
                              backgroundColor: Colors.grey.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${type['count']}次 (${type['percentage']}%)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 消费趋势图
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '近6个月消费趋势',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}月',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '¥${value.toInt()}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _userProfile['monthlySpending'],
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
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
          
          // 最近消费记录
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最近消费记录',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('日期')),
                        DataColumn(label: Text('类型')),
                        DataColumn(label: Text('金额')),
                        DataColumn(label: Text('状态')),
                      ],
                      rows: (_userProfile['recentTransactions'] as List).map((transaction) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(DateFormat('MM-dd HH:mm').format(transaction['date'])),
                            ),
                            DataCell(Text(transaction['type'])),
                            DataCell(
                              Text(
                                '¥${transaction['amount']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  transaction['status'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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

  Widget _buildPreferencesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // 角色偏好
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '角色偏好分布',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: (_userProfile['characterPreferences'] as List).map((pref) {
                                return PieChartSectionData(
                                  color: pref['color'],
                                  value: pref['percentage'],
                                  title: '${pref['name']}\n${pref['percentage']}%',
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
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
              
              // 使用时段偏好
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '使用时段偏好',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...(_userProfile['timePreferences'] as Map<String, double>).entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: LinearProgressIndicator(
                                    value: entry.value / 100,
                                    backgroundColor: Colors.grey.withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${entry.value}%',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 最喜欢的角色详情
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最喜欢的角色: ${_userProfile['favoriteCharacter']}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.pink,
                        child: Text(
                          _userProfile['favoriteCharacter'][0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '互动次数: 563次',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '总时长: 28.5小时',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '亲密度: ❤️❤️❤️❤️❤️ (满级)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 用户行为特征
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '用户行为特征',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: (_userProfile['behaviorTags'] as List).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: tag['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tag['color']),
                        ),
                        child: Text(
                          tag['label'],
                          style: TextStyle(
                            color: tag['color'],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 行为分析报告
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI行为分析报告',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户画像总结',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '该用户是一位高活跃度的付费用户，表现出强烈的社交需求和稳定的消费习惯。主要活跃时间集中在晚上，偏好与"小雪"角色进行深度互动，平均会话时长远超平均水平。消费行为理性，主要集中在会员续费和虚拟礼品购买，显示出较高的用户忠诚度和付费意愿。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '运营建议',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. 可以针对该用户推送"小雪"角色的专属内容和活动\n2. 在晚间时段推送个性化消息，提高互动率\n3. 推荐高级会员服务，该用户具有较强的付费意愿\n4. 可以邀请参与新功能的内测，作为种子用户',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
  }

  Widget _buildMembershipChip(String membershipType) {
    Color color;
    switch (membershipType) {
      case '终身会员':
        color = Colors.purple;
        break;
      case '高级会员':
        color = Colors.orange;
        break;
      case '会员':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        membershipType,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}