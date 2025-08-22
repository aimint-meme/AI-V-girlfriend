import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/service_management_provider.dart';

class ServiceConfigScreen extends StatefulWidget {
  const ServiceConfigScreen({super.key});

  @override
  State<ServiceConfigScreen> createState() => _ServiceConfigScreenState();
}

class _ServiceConfigScreenState extends State<ServiceConfigScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // 服务创建表单控制器
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescController = TextEditingController();
  final TextEditingController _basePriceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  // 筛选条件
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';
  String _selectedPriceRange = '全部';
  
  // 服务配置
  String _selectedServiceType = '陪聊服务';
  bool _isVipService = false;
  bool _allowCustomization = true;
  double _commissionRate = 15.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceManagementProvider>().loadServiceConfig();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _serviceNameController.dispose();
    _serviceDescController.dispose();
    _basePriceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/services/config',
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
                          '服务类型配置',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '配置预约和商城服务类型、价格策略和服务规则',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showCreateServiceDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('新增服务'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportServiceConfig(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出配置'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _saveAllConfigs(),
                          icon: const Icon(Icons.save),
                          label: const Text('保存配置'),
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
                        title: '服务类型',
                        value: '${provider.totalServiceTypes}',
                        subtitle: '启用: ${provider.activeServiceTypes}',
                        trend: provider.serviceTypeTrend,
                        icon: Icons.category,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均价格',
                        value: '¥${provider.averagePrice.toStringAsFixed(0)}',
                        subtitle: '价格区间: ¥${provider.minPrice}-${provider.maxPrice}',
                        trend: provider.priceTrend,
                        icon: Icons.attach_money,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '预约量',
                        value: NumberFormat('#,##0').format(provider.totalBookings),
                        subtitle: '本月: ${NumberFormat('#,##0').format(provider.monthlyBookings)}',
                        trend: provider.bookingTrend,
                        icon: Icons.event,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '收入',
                        value: '¥${NumberFormat('#,##0').format(provider.totalRevenue)}',
                        subtitle: '本月收入',
                        trend: provider.revenueTrend,
                        icon: Icons.trending_up,
                        color: AppColors.warning,
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
                                text: '服务列表',
                              ),
                              Tab(
                                icon: Icon(Icons.category),
                                text: '服务分类',
                              ),
                              Tab(
                                icon: Icon(Icons.attach_money),
                                text: '价格策略',
                              ),
                              Tab(
                                icon: Icon(Icons.settings),
                                text: '服务规则',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildServiceListTab(provider),
                              _buildServiceCategoryTab(provider),
                              _buildPricingStrategyTab(provider),
                              _buildServiceRulesTab(provider),
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

  Widget _buildServiceListTab(ServiceManagementProvider provider) {
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
                  decoration: const InputDecoration(
                    hintText: '搜索服务名称、描述...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '服务分类',
                  ),
                  items: ['全部', '陪聊服务', '语音通话', '视频通话', '定制服务', '特殊服务']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ['全部', '启用', '禁用', '维护中']
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
                  value: _selectedPriceRange,
                  decoration: const InputDecoration(
                    labelText: '价格区间',
                  ),
                  items: ['全部', '0-50元', '50-100元', '100-200元', '200元以上']
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPriceRange = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 服务列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildServiceGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _generateMockServices().length,
      itemBuilder: (context, index) {
        final service = _generateMockServices()[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  service['icon'],
                  color: service['color'],
                  size: 32,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleServiceAction(value, service),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('编辑'),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Text('复制'),
                    ),
                    const PopupMenuItem(
                      value: 'disable',
                      child: Text('禁用'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              service['description'],
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¥${service['price']}/次',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                _buildServiceStatusChip(service['status']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${service['bookings']} 预约',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${service['duration']}分钟',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategoryTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 分类管理
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '服务分类管理',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._generateServiceCategories().map((category) {
                        return _buildCategoryItem(category);
                      }).toList(),
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
                        '分类统计',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            '分类统计图表\n（此处可集成图表库）',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
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

  Widget _buildPricingStrategyTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 价格策略配置
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
                        '基础定价策略',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPricingStrategyItem(
                        '固定价格',
                        '每次服务固定收费',
                        Icons.attach_money,
                        AppColors.primary,
                        true,
                      ),
                      _buildPricingStrategyItem(
                        '时长计费',
                        '按服务时长收费',
                        Icons.schedule,
                        AppColors.success,
                        false,
                      ),
                      _buildPricingStrategyItem(
                        '阶梯定价',
                        '根据服务次数阶梯定价',
                        Icons.trending_up,
                        AppColors.warning,
                        false,
                      ),
                      _buildPricingStrategyItem(
                        '会员价格',
                        'VIP会员专享价格',
                        Icons.star,
                        AppColors.info,
                        true,
                      ),
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
                        '价格配置',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPriceConfigItem('基础价格', '¥50', '最低服务价格'),
                      _buildPriceConfigItem('VIP折扣', '8.5折', 'VIP会员享受折扣'),
                      _buildPriceConfigItem('平台抽成', '15%', '平台服务费比例'),
                      _buildPriceConfigItem('最低提成', '¥5', '服务者最低收入'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 价格分析
          Container(
            width: double.infinity,
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
                  '价格分析',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceAnalysisCard(
                        '平均客单价',
                        '¥85',
                        '+12.5%',
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceAnalysisCard(
                        '最受欢迎价位',
                        '¥50-80',
                        '68%占比',
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceAnalysisCard(
                        '价格敏感度',
                        '中等',
                        '弹性系数0.6',
                        AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildPriceAnalysisCard(
                        '竞争力指数',
                        '良好',
                        '市场排名前30%',
                        AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRulesTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 服务规则配置
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
                        '预约规则',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRuleSwitch('提前预约', true, '需要提前24小时预约'),
                      _buildRuleSwitch('取消政策', true, '允许提前2小时取消'),
                      _buildRuleSwitch('改期政策', false, '允许改期一次'),
                      _buildRuleSwitch('自动确认', true, '自动确认预约请求'),
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
                        '服务规则',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRuleSwitch('实名认证', true, '服务者需要实名认证'),
                      _buildRuleSwitch('评价系统', true, '启用用户评价功能'),
                      _buildRuleSwitch('投诉处理', true, '启用投诉处理机制'),
                      _buildRuleSwitch('质量监控', false, '启用服务质量监控'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 时间规则
          Container(
            width: double.infinity,
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
                  '时间规则配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeRuleCard(
                        '服务时间',
                        '09:00 - 23:00',
                        '每日可预约时间段',
                        Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeRuleCard(
                        '最短时长',
                        '30分钟',
                        '单次服务最短时长',
                        Icons.timer,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeRuleCard(
                        '最长时长',
                        '180分钟',
                        '单次服务最长时长',
                        Icons.timer_off,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeRuleCard(
                        '间隔时间',
                        '15分钟',
                        '预约间隔最短时间',
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceStatusChip(String status) {
    Color color;
    switch (status) {
      case '启用':
        color = AppColors.success;
        break;
      case '禁用':
        color = AppColors.error;
        break;
      case '维护中':
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
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              category['icon'],
              color: category['color'],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${category['count']} 个服务',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: category['enabled'],
              onChanged: (value) {
                // 处理分类启用/禁用
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingStrategyItem(String title, String description, IconData icon, Color color, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? color.withOpacity(0.3) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? AppTheme.textSecondaryColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) {
                // 处理定价策略启用/禁用
              },
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceConfigItem(String label, String value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAnalysisCard(String title, String value, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
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
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSwitch(String title, bool value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              // 处理规则开关
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuleCard(String title, String value, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockServices() {
    return [
      {
        'id': 'service_001',
        'name': '温柔陪聊',
        'description': '温柔体贴的聊天陪伴服务',
        'category': '陪聊服务',
        'price': 50,
        'duration': 60,
        'bookings': 156,
        'status': '启用',
        'icon': Icons.chat,
        'color': AppColors.primary,
      },
      {
        'id': 'service_002',
        'name': '语音通话',
        'description': '甜美声音的语音通话服务',
        'category': '语音通话',
        'price': 80,
        'duration': 30,
        'bookings': 89,
        'status': '启用',
        'icon': Icons.phone,
        'color': AppColors.success,
      },
      {
        'id': 'service_003',
        'name': '视频通话',
        'description': '面对面的视频通话体验',
        'category': '视频通话',
        'price': 120,
        'duration': 30,
        'bookings': 67,
        'status': '启用',
        'icon': Icons.videocam,
        'color': AppColors.info,
      },
      {
        'id': 'service_004',
        'name': '定制服务',
        'description': '个性化定制专属服务',
        'category': '定制服务',
        'price': 200,
        'duration': 90,
        'bookings': 34,
        'status': '启用',
        'icon': Icons.star,
        'color': AppColors.warning,
      },
      {
        'id': 'service_005',
        'name': '情感咨询',
        'description': '专业的情感心理咨询',
        'category': '特殊服务',
        'price': 150,
        'duration': 60,
        'bookings': 45,
        'status': '维护中',
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
      {
        'id': 'service_006',
        'name': '游戏陪玩',
        'description': '一起玩游戏的陪伴服务',
        'category': '陪聊服务',
        'price': 60,
        'duration': 120,
        'bookings': 78,
        'status': '启用',
        'icon': Icons.games,
        'color': Colors.orange,
      },
    ];
  }

  List<Map<String, dynamic>> _generateServiceCategories() {
    return [
      {
        'id': 'cat_001',
        'name': '陪聊服务',
        'count': 12,
        'enabled': true,
        'icon': Icons.chat,
        'color': AppColors.primary,
      },
      {
        'id': 'cat_002',
        'name': '语音通话',
        'count': 8,
        'enabled': true,
        'icon': Icons.phone,
        'color': AppColors.success,
      },
      {
        'id': 'cat_003',
        'name': '视频通话',
        'count': 6,
        'enabled': true,
        'icon': Icons.videocam,
        'color': AppColors.info,
      },
      {
        'id': 'cat_004',
        'name': '定制服务',
        'count': 4,
        'enabled': true,
        'icon': Icons.star,
        'color': AppColors.warning,
      },
      {
        'id': 'cat_005',
        'name': '特殊服务',
        'count': 3,
        'enabled': false,
        'icon': Icons.psychology,
        'color': Colors.purple,
      },
    ];
  }

  void _applyFilters() {
    // 实现筛选逻辑
  }

  void _showCreateServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增服务'),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _serviceNameController,
                  decoration: const InputDecoration(
                    labelText: '服务名称',
                    hintText: '请输入服务名称',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入服务名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _serviceDescController,
                  decoration: const InputDecoration(
                    labelText: '服务描述',
                    hintText: '请输入服务描述',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _basePriceController,
                        decoration: const InputDecoration(
                          labelText: '基础价格',
                          hintText: '0',
                          suffixText: '元',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(
                          labelText: '服务时长',
                          hintText: '60',
                          suffixText: '分钟',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedServiceType,
                  decoration: const InputDecoration(
                    labelText: '服务类型',
                  ),
                  items: ['陪聊服务', '语音通话', '视频通话', '定制服务', '特殊服务']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('VIP专享'),
                        value: _isVipService,
                        onChanged: (value) {
                          setState(() {
                            _isVipService = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('允许定制'),
                        value: _allowCustomization,
                        onChanged: (value) {
                          setState(() {
                            _allowCustomization = value!;
                          });
                        },
                      ),
                    ),
                  ],
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
            onPressed: () => _createService(),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _createService() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('服务"${_serviceNameController.text}"创建成功！'),
          backgroundColor: AppColors.success,
        ),
      );
      _serviceNameController.clear();
      _serviceDescController.clear();
      _basePriceController.clear();
      _durationController.clear();
    }
  }

  void _exportServiceConfig() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('服务配置导出功能开发中...')),
    );
  }

  void _saveAllConfigs() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('所有配置保存成功！'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _handleServiceAction(String action, Map<String, dynamic> service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对服务 ${service['name']} 执行操作: $action')),
    );
  }
}