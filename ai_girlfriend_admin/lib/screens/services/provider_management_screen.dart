import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/service_management_provider.dart';

class ProviderManagementScreen extends StatefulWidget {
  const ProviderManagementScreen({super.key});

  @override
  State<ProviderManagementScreen> createState() => _ProviderManagementScreenState();
}

class _ProviderManagementScreenState extends State<ProviderManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // 筛选条件
  String _selectedStatus = '全部';
  String _selectedLevel = '全部';
  String _selectedService = '全部';
  final TextEditingController _searchController = TextEditingController();
  
  // 服务者创建表单
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String _selectedGender = '女';
  int _selectedAge = 22;
  List<String> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceManagementProvider>().loadProviderData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/services/providers',
      child: Consumer<ServiceManagementProvider>(
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
                          '服务管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理服务提供者、服务质量和服务评价',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showAddProviderDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('添加服务者'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportProviders(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出数据'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _refreshData(),
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
                        title: '服务者总数',
                        value: '${provider.totalProviders}',
                        subtitle: '在线: ${provider.onlineProviders}',
                        trend: provider.providerTrend,
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均评分',
                        value: '${provider.averageRating.toStringAsFixed(1)}',
                        subtitle: '满分5.0分',
                        trend: provider.ratingTrend,
                        icon: Icons.star,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '服务完成率',
                        value: '${provider.serviceCompletionRate.toStringAsFixed(1)}%',
                        subtitle: '本月完成率',
                        trend: provider.completionTrend,
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '月收入',
                        value: '¥${NumberFormat('#,##0').format(provider.monthlyIncome)}',
                        subtitle: '服务者平均收入',
                        trend: provider.incomeTrend,
                        icon: Icons.attach_money,
                        color: AppColors.info,
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
                                icon: Icon(Icons.people),
                                text: '服务者列表',
                              ),
                              Tab(
                                icon: Icon(Icons.star),
                                text: '评价管理',
                              ),
                              Tab(
                                icon: Icon(Icons.trending_up),
                                text: '绩效统计',
                              ),
                              Tab(
                                icon: Icon(Icons.settings),
                                text: '服务配置',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildProviderListTab(provider),
                              _buildReviewManagementTab(provider),
                              _buildPerformanceTab(provider),
                              _buildServiceConfigTab(provider),
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

  Widget _buildProviderListTab(ServiceManagementProvider provider) {
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
                    hintText: '搜索服务者姓名、ID...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ['全部', '在线', '离线', '忙碌', '休息', '禁用']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: '等级',
                  ),
                  items: ['全部', '新手', '熟练', '专家', '大师']
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedService,
                  decoration: const InputDecoration(
                    labelText: '服务类型',
                  ),
                  items: ['全部', '陪聊服务', '语音通话', '视频通话', '定制服务']
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text(service),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedService = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 服务者网格
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProviderGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _generateMockProviders().length,
      itemBuilder: (context, index) {
        final serviceProvider = _generateMockProviders()[index];
        return _buildProviderCard(serviceProvider);
      },
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> serviceProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 头像和状态
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    serviceProvider['name'][0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getStatusColor(serviceProvider['status']),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 基本信息
            Text(
              serviceProvider['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${serviceProvider['age']}岁 | ${serviceProvider['gender']}',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            
            // 评分和等级
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  serviceProvider['rating'].toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLevelChip(serviceProvider['level']),
              ],
            ),
            const SizedBox(height: 8),
            
            // 服务统计
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${serviceProvider['totalOrders']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '订单',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '¥${serviceProvider['monthlyIncome']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      '月收入',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewProviderDetail(serviceProvider),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      '详情',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _manageProvider(serviceProvider),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                    ),
                    child: const Text(
                      '管理',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewManagementTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 评价统计
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        const Text('平均评分'),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < 4 ? AppColors.warning : Colors.grey.shade300,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '评分分布',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildRatingDistribution('5星', 68, AppColors.success),
                        _buildRatingDistribution('4星', 22, AppColors.info),
                        _buildRatingDistribution('3星', 7, AppColors.warning),
                        _buildRatingDistribution('2星', 2, AppColors.error),
                        _buildRatingDistribution('1星', 1, Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 评价列表
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最新评价',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _generateMockReviews().length,
                        itemBuilder: (context, index) {
                          final review = _generateMockReviews()[index];
                          return _buildReviewCard(review);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 绩效排行榜
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 400,
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
                        '本月绩效排行',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _generateTopPerformers().length,
                          itemBuilder: (context, index) {
                            final performer = _generateTopPerformers()[index];
                            return _buildPerformanceRankItem(performer, index + 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 400,
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
                        '绩效趋势',
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
                              '绩效趋势图表\n（此处可集成图表库）',
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
            ],
          ),
          const SizedBox(height: 20),
          
          // 绩效指标
          Row(
            children: [
              Expanded(
                child: _buildPerformanceMetricCard(
                  '服务完成率',
                  '96.8%',
                  '+2.3%',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceMetricCard(
                  '客户满意度',
                  '4.8分',
                  '+0.2',
                  Icons.star,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceMetricCard(
                  '响应速度',
                  '2.3分钟',
                  '-0.5分钟',
                  Icons.speed,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceMetricCard(
                  '复购率',
                  '72%',
                  '+5%',
                  Icons.repeat,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceConfigTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 服务配置
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
                        '服务质量标准',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildQualityStandardItem('响应时间', '< 3分钟', true),
                      _buildQualityStandardItem('服务态度', '评分 ≥ 4.5', true),
                      _buildQualityStandardItem('完成率', '≥ 95%', true),
                      _buildQualityStandardItem('投诉率', '< 2%', false),
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
                        '奖惩机制',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRewardPenaltyItem('优秀服务奖', '+10%收入', AppColors.success),
                      _buildRewardPenaltyItem('满意度奖励', '+5%收入', AppColors.info),
                      _buildRewardPenaltyItem('迟到扣分', '-2分', AppColors.warning),
                      _buildRewardPenaltyItem('投诉处罚', '-5分', AppColors.error),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 培训管理
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
                    '培训管理',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildTrainingCard(
                          '服务礼仪',
                          '基础服务礼仪培训',
                          '2小时',
                          Icons.school,
                          AppColors.primary,
                        ),
                        _buildTrainingCard(
                          '沟通技巧',
                          '客户沟通技巧提升',
                          '3小时',
                          Icons.chat,
                          AppColors.success,
                        ),
                        _buildTrainingCard(
                          '心理疏导',
                          '情感支持和心理疏导',
                          '4小时',
                          Icons.psychology,
                          AppColors.info,
                        ),
                        _buildTrainingCard(
                          '安全规范',
                          '服务安全规范培训',
                          '1小时',
                          Icons.security,
                          AppColors.warning,
                        ),
                        _buildTrainingCard(
                          '投诉处理',
                          '客户投诉处理流程',
                          '2小时',
                          Icons.support_agent,
                          AppColors.error,
                        ),
                        _buildTrainingCard(
                          '技能提升',
                          '专业技能提升课程',
                          '6小时',
                          Icons.trending_up,
                          Colors.purple,
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

  Widget _buildLevelChip(String level) {
    Color color;
    switch (level) {
      case '新手':
        color = Colors.grey;
        break;
      case '熟练':
        color = AppColors.info;
        break;
      case '专家':
        color = AppColors.success;
        break;
      case '大师':
        color = AppColors.warning;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRatingDistribution(String rating, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              rating,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    review['userName'][0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            review['userName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < review['rating'] 
                                    ? AppColors.warning 
                                    : Colors.grey.shade300,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      Text(
                        '服务者: ${review['providerName']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review['comment'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(review['createdAt']),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                if (review['reply'] != null)
                  TextButton(
                    onPressed: () => _viewReply(review),
                    child: const Text(
                      '查看回复',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRankItem(Map<String, dynamic> performer, int rank) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.warning : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performer['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${performer['orders']}单 | ¥${performer['income']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${performer['score']}分',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricCard(String title, String value, String trend, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              color: trend.startsWith('+') ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityStandardItem(String standard, String requirement, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.cancel,
            color: met ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standard,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  requirement,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPenaltyItem(String item, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(String title, String description, String duration, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '在线':
        return AppColors.success;
      case '忙碌':
        return AppColors.warning;
      case '休息':
        return AppColors.info;
      case '离线':
        return Colors.grey;
      case '禁用':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _generateMockProviders() {
    return [
      {
        'id': 'provider_001',
        'name': '小雨',
        'age': 22,
        'gender': '女',
        'rating': 4.9,
        'level': '专家',
        'status': '在线',
        'totalOrders': 156,
        'monthlyIncome': 8500,
        'services': ['陪聊服务', '语音通话'],
      },
      {
        'id': 'provider_002',
        'name': '晓晓',
        'age': 24,
        'gender': '女',
        'rating': 4.8,
        'level': '熟练',
        'status': '忙碌',
        'totalOrders': 134,
        'monthlyIncome': 7200,
        'services': ['视频通话', '定制服务'],
      },
      {
        'id': 'provider_003',
        'name': '甜甜',
        'age': 21,
        'gender': '女',
        'rating': 4.7,
        'level': '熟练',
        'status': '在线',
        'totalOrders': 98,
        'monthlyIncome': 6800,
        'services': ['陪聊服务', '语音通话'],
      },
      {
        'id': 'provider_004',
        'name': '柔柔',
        'age': 23,
        'gender': '女',
        'rating': 4.6,
        'level': '新手',
        'status': '休息',
        'totalOrders': 67,
        'monthlyIncome': 4500,
        'services': ['陪聊服务'],
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockReviews() {
    return [
      {
        'userName': '张先生',
        'providerName': '小雨',
        'rating': 5,
        'comment': '服务态度很好，聊天很愉快，会继续选择的。',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
        'reply': null,
      },
      {
        'userName': '李女士',
        'providerName': '晓晓',
        'rating': 4,
        'comment': '视频通话质量不错，人很温柔，就是时间有点短。',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
        'reply': '谢谢您的评价，下次会延长服务时间。',
      },
    ];
  }

  List<Map<String, dynamic>> _generateTopPerformers() {
    return [
      {
        'name': '小雨',
        'orders': 156,
        'income': 8500,
        'score': 98,
      },
      {
        'name': '晓晓',
        'orders': 134,
        'income': 7200,
        'score': 95,
      },
      {
        'name': '甜甜',
        'orders': 98,
        'income': 6800,
        'score': 92,
      },
    ];
  }

  void _applyFilters() {
    // 实现筛选逻辑
  }

  void _showAddProviderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加服务者'),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    hintText: '请输入姓名',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: '性别',
                        ),
                        items: ['女', '男']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _selectedAge.toString(),
                        decoration: const InputDecoration(
                          labelText: '年龄',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _selectedAge = int.tryParse(value) ?? 22;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    hintText: '请输入手机号',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    hintText: '请输入邮箱',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: const InputDecoration(
                    labelText: '个人简介',
                    hintText: '请输入个人简介',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _addProvider(),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _addProvider() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('服务者"${_nameController.text}"添加成功！'),
          backgroundColor: AppColors.success,
        ),
      );
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _bioController.clear();
    }
  }

  void _exportProviders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务者数据导出功能开发中...')),
    );
  }

  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新数据...')),
    );
  }

  void _viewProviderDetail(Map<String, dynamic> serviceProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看服务者详情: ${serviceProvider['name']}')),
    );
  }

  void _manageProvider(Map<String, dynamic> serviceProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('管理服务者: ${serviceProvider['name']}')),
    );
  }

  void _viewReply(Map<String, dynamic> review) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看回复: ${review['reply']}')),
    );
  }
}