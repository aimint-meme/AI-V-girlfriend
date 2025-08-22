import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/service_management_provider.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 筛选条件
  String _selectedStatus = '全部';
  String _selectedService = '全部';
  String _selectedPayment = '全部';
  DateTimeRange? _selectedDateRange;
  final TextEditingController _searchController = TextEditingController();
  
  // 分页
  int _currentPage = 1;
  int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceManagementProvider>().loadOrderData();
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
      currentRoute: '/services/orders',
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
                          '订单管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理预约订单、支付状态和订单处理流程',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _exportOrders(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出订单'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _batchProcess(),
                          icon: const Icon(Icons.batch_prediction),
                          label: const Text('批量处理'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _refreshOrders(),
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
                        title: '总订单数',
                        value: NumberFormat('#,##0').format(provider.totalOrders),
                        subtitle: '今日: ${provider.todayOrders}',
                        trend: provider.orderTrend,
                        icon: Icons.shopping_cart,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '待处理',
                        value: '${provider.pendingOrders}',
                        subtitle: '需要处理的订单',
                        trend: provider.pendingTrend,
                        icon: Icons.pending,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '订单金额',
                        value: '¥${NumberFormat('#,##0').format(provider.totalAmount)}',
                        subtitle: '今日: ¥${NumberFormat('#,##0').format(provider.todayAmount)}',
                        trend: provider.amountTrend,
                        icon: Icons.attach_money,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '完成率',
                        value: '${provider.completionRate.toStringAsFixed(1)}%',
                        subtitle: '订单完成率',
                        trend: provider.completionTrend,
                        icon: Icons.check_circle,
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
                                icon: Icon(Icons.list),
                                text: '订单列表',
                              ),
                              Tab(
                                icon: Icon(Icons.pending_actions),
                                text: '待处理',
                              ),
                              Tab(
                                icon: Icon(Icons.payment),
                                text: '支付管理',
                              ),
                              Tab(
                                icon: Icon(Icons.analytics),
                                text: '订单分析',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOrderListTab(provider),
                              _buildPendingOrdersTab(provider),
                              _buildPaymentManagementTab(provider),
                              _buildOrderAnalyticsTab(provider),
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

  Widget _buildOrderListTab(ServiceManagementProvider provider) {
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
                    hintText: '搜索订单号、用户名...',
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
                    labelText: '订单状态',
                  ),
                  items: ['全部', '待支付', '已支付', '服务中', '已完成', '已取消', '退款中']
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
          
          // 订单列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOrderTable(),
          ),
          
          // 分页
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildOrderTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('订单信息')),
          DataColumn(label: Text('用户')),
          DataColumn(label: Text('服务')),
          DataColumn(label: Text('金额')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        rows: _generateMockOrders().map((order) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order['orderNo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '预约时间: ${DateFormat('MM-dd HH:mm').format(order['appointmentTime'])}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        order['userName'][0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order['userName'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      order['serviceName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${order['duration']}分钟',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '¥${order['amount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(_buildOrderStatusChip(order['status'])),
              DataCell(
                Text(
                  DateFormat('MM-dd HH:mm').format(order['createdAt']),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _viewOrderDetail(order),
                      icon: const Icon(Icons.visibility, size: 16),
                      tooltip: '查看详情',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleOrderAction(value, order),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('编辑'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('取消订单'),
                        ),
                        const PopupMenuItem(
                          value: 'refund',
                          child: Text('退款'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPendingOrdersTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 待处理订单统计
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${provider.pendingPaymentOrders}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                        const Text('待支付订单'),
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
                          '${provider.pendingServiceOrders}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        const Text('待服务订单'),
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
                          '${provider.pendingRefundOrders}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                        const Text('待退款订单'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 待处理订单列表
          Expanded(
            child: ListView.builder(
              itemCount: _generatePendingOrders().length,
              itemBuilder: (context, index) {
                final order = _generatePendingOrders()[index];
                return _buildPendingOrderCard(order);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentManagementTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 支付统计
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
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
                        '支付方式分布',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildPaymentMethodItem('微信支付', 45.2, AppColors.success),
                            _buildPaymentMethodItem('支付宝', 32.8, AppColors.primary),
                            _buildPaymentMethodItem('银行卡', 15.6, AppColors.info),
                            _buildPaymentMethodItem('余额支付', 6.4, AppColors.warning),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 200,
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
                        '退款统计',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildRefundStatItem('本月退款', '¥12,450', '23笔'),
                      _buildRefundStatItem('退款率', '2.3%', '较上月-0.5%'),
                      _buildRefundStatItem('平均处理时间', '2.5小时', '较上月-0.3h'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 支付问题订单
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
                    '支付问题订单',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _generatePaymentIssueOrders().length,
                      itemBuilder: (context, index) {
                        final order = _generatePaymentIssueOrders()[index];
                        return _buildPaymentIssueCard(order);
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

  Widget _buildOrderAnalyticsTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 订单趋势分析
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
                        '订单趋势',
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
                              '订单趋势图表\n（此处可集成图表库）',
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
                        '服务类型分布',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildServiceDistributionItem('陪聊服务', 156, AppColors.primary),
                            _buildServiceDistributionItem('语音通话', 89, AppColors.success),
                            _buildServiceDistributionItem('视频通话', 67, AppColors.info),
                            _buildServiceDistributionItem('定制服务', 34, AppColors.warning),
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
          
          // 详细分析
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
                        '用户行为分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAnalysisItem('平均订单价值', '¥85', '+12.5%'),
                      _buildAnalysisItem('复购率', '68%', '+5.2%'),
                      _buildAnalysisItem('取消率', '3.2%', '-1.1%'),
                      _buildAnalysisItem('满意度', '4.8分', '+0.2'),
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
                      _buildTimeAnalysisItem('高峰时段', '19:00-22:00', '35%'),
                      _buildTimeAnalysisItem('次高峰', '14:00-17:00', '28%'),
                      _buildTimeAnalysisItem('平峰时段', '09:00-12:00', '22%'),
                      _buildTimeAnalysisItem('低峰时段', '其他时间', '15%'),
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

  Widget _buildOrderStatusChip(String status) {
    Color color;
    switch (status) {
      case '待支付':
        color = AppColors.warning;
        break;
      case '已支付':
        color = AppColors.info;
        break;
      case '服务中':
        color = AppColors.primary;
        break;
      case '已完成':
        color = AppColors.success;
        break;
      case '已取消':
        color = AppColors.error;
        break;
      case '退款中':
        color = Colors.orange;
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

  Widget _buildPendingOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _getStatusColor(order['status']),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order['orderNo'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildOrderStatusChip(order['status']),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${order['userName']} - ${order['serviceName']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '金额: ¥${order['amount']} | 预约时间: ${DateFormat('MM-dd HH:mm').format(order['appointmentTime'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => _processOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(order['status']),
                    minimumSize: const Size(80, 32),
                  ),
                  child: Text(
                    _getActionText(order['status']),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => _viewOrderDetail(order),
                  child: const Text(
                    '查看详情',
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

  Widget _buildPaymentMethodItem(String method, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                method,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
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

  Widget _buildRefundStatItem(String label, String value, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIssueCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: AppColors.error,
        ),
        title: Text(
          order['orderNo'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${order['issue']} - ${order['userName']}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¥${order['amount']}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => _handlePaymentIssue(order),
              icon: const Icon(Icons.build, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDistributionItem(String service, int count, Color color) {
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
              service,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$count',
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

  Widget _buildAnalysisItem(String label, String value, String trend) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                trend,
                style: TextStyle(
                  fontSize: 10,
                  color: trend.startsWith('+') ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeAnalysisItem(String period, String time, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case '待支付':
        return AppColors.warning;
      case '待服务':
        return AppColors.info;
      case '退款中':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _getActionText(String status) {
    switch (status) {
      case '待支付':
        return '催付款';
      case '待服务':
        return '安排服务';
      case '退款中':
        return '处理退款';
      default:
        return '处理';
    }
  }

  List<Map<String, dynamic>> _generateMockOrders() {
    return [
      {
        'orderNo': 'ORD202401150001',
        'userName': '张小美',
        'serviceName': '温柔陪聊',
        'amount': 50,
        'duration': 60,
        'status': '已完成',
        'appointmentTime': DateTime.now().add(const Duration(hours: 2)),
        'createdAt': DateTime.now().subtract(const Duration(hours: 1)),
      },
      {
        'orderNo': 'ORD202401150002',
        'userName': '李小萌',
        'serviceName': '语音通话',
        'amount': 80,
        'duration': 30,
        'status': '服务中',
        'appointmentTime': DateTime.now().add(const Duration(hours: 1)),
        'createdAt': DateTime.now().subtract(const Duration(minutes: 30)),
      },
      {
        'orderNo': 'ORD202401150003',
        'userName': '王小可',
        'serviceName': '视频通话',
        'amount': 120,
        'duration': 30,
        'status': '待支付',
        'appointmentTime': DateTime.now().add(const Duration(hours: 3)),
        'createdAt': DateTime.now().subtract(const Duration(minutes: 15)),
      },
    ];
  }

  List<Map<String, dynamic>> _generatePendingOrders() {
    return [
      {
        'orderNo': 'ORD202401150004',
        'userName': '赵小雅',
        'serviceName': '定制服务',
        'amount': 200,
        'status': '待支付',
        'appointmentTime': DateTime.now().add(const Duration(hours: 4)),
      },
      {
        'orderNo': 'ORD202401150005',
        'userName': '钱小慧',
        'serviceName': '陪聊服务',
        'amount': 60,
        'status': '待服务',
        'appointmentTime': DateTime.now().add(const Duration(hours: 1)),
      },
    ];
  }

  List<Map<String, dynamic>> _generatePaymentIssueOrders() {
    return [
      {
        'orderNo': 'ORD202401150006',
        'userName': '孙小娜',
        'amount': 85,
        'issue': '支付超时',
      },
      {
        'orderNo': 'ORD202401150007',
        'userName': '周小琳',
        'amount': 150,
        'issue': '退款申请',
      },
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

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('订单导出功能开发中...')),
    );
  }

  void _batchProcess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量处理功能开发中...')),
    );
  }

  void _refreshOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新订单数据...')),
    );
  }

  void _viewOrderDetail(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看订单详情: ${order['orderNo']}')),
    );
  }

  void _handleOrderAction(String action, Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对订单 ${order['orderNo']} 执行操作: $action')),
    );
  }

  void _processOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('处理订单: ${order['orderNo']}')),
    );
  }

  void _handlePaymentIssue(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('处理支付问题: ${order['orderNo']}')),
    );
  }
}