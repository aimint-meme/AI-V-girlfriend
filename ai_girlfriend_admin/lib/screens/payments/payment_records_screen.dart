import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/payment_model.dart';
import '../../providers/payment_provider.dart';
import 'package:provider/provider.dart';

class PaymentRecordsScreen extends StatefulWidget {
  const PaymentRecordsScreen({super.key});

  @override
  State<PaymentRecordsScreen> createState() => _PaymentRecordsScreenState();
}

class _PaymentRecordsScreenState extends State<PaymentRecordsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '全部';
  String _selectedPaymentMethod = '全部';
  String _selectedTimeRange = '最近7天';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentData();
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
      currentRoute: '/payments/records',
      child: Consumer<PaymentProvider>(
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
                          '支付记录查询/对账',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理支付记录、财务对账和交易统计分析',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showReconciliationDialog(),
                          icon: const Icon(Icons.account_balance),
                          label: const Text('开始对账'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportRecords(provider),
                          icon: const Icon(Icons.download),
                          label: const Text('导出记录'),
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
                        title: '今日交易额',
                        value: '¥${NumberFormat('#,##0.00').format(provider.todayAmount)}',
                        subtitle: '交易笔数: ${provider.todayCount}',
                        trend: provider.todayTrend,
                        icon: Icons.payments,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '本月收入',
                        value: '¥${NumberFormat('#,##0.00').format(provider.monthlyRevenue)}',
                        subtitle: '较上月: ${provider.monthlyGrowth > 0 ? '+' : ''}${provider.monthlyGrowth.toStringAsFixed(1)}%',
                        trend: provider.monthlyGrowth,
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '成功率',
                        value: '${provider.successRate.toStringAsFixed(1)}%',
                        subtitle: '失败: ${provider.failedCount}笔',
                        trend: provider.successRateTrend,
                        icon: Icons.check_circle,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '待对账金额',
                        value: '¥${NumberFormat('#,##0.00').format(provider.pendingAmount)}',
                        subtitle: '笔数: ${provider.pendingCount}',
                        trend: -provider.pendingTrend,
                        icon: Icons.pending,
                        color: AppColors.warning,
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
                              icon: Icon(Icons.receipt),
                              text: '支付记录',
                            ),
                            Tab(
                              icon: Icon(Icons.account_balance),
                              text: '对账管理',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics),
                              text: '财务统计',
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
                            _buildPaymentRecords(provider),
                            _buildReconciliation(provider),
                            _buildFinancialStats(provider),
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

  Widget _buildPaymentRecords(PaymentProvider provider) {
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
                    hintText: '搜索订单号、用户ID...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(provider),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '支付状态',
                  ),
                  items: ['全部', '成功', '失败', '处理中', '已退款']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: '支付方式',
                  ),
                  items: ['全部', '微信支付', '支付宝', '银行卡', '苹果支付', '其他']
                      .map((method) => DropdownMenuItem(
                            value: method,
                            child: Text(method),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedTimeRange,
                  decoration: const InputDecoration(
                    labelText: '时间范围',
                  ),
                  items: ['最近7天', '最近30天', '最近3个月', '自定义']
                      .map((range) => DropdownMenuItem(
                            value: range,
                            child: Text(range),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTimeRange = value!;
                    });
                    if (value == '自定义') {
                      _showDateRangePicker();
                    } else {
                      _applyFilters(provider);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 支付记录表格
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPaymentTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTable(PaymentProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(
          label: Text('订单信息'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('用户'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('金额'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('支付方式'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('创建时间'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('操作'),
          size: ColumnSize.M,
        ),
      ],
      rows: provider.filteredPayments.map((payment) {
        return DataRow2(
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    payment.orderNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    payment.productName,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                    payment.userId,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (payment.userName.isNotEmpty)
                    Text(
                      payment.userName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),
            DataCell(
              Text(
                '¥${NumberFormat('#,##0.00').format(payment.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: payment.status == '成功' ? AppColors.success : Colors.black,
                ),
              ),
            ),
            DataCell(_buildPaymentMethodChip(payment.paymentMethod)),
            DataCell(_buildStatusChip(payment.status)),
            DataCell(
              Text(DateFormat('yyyy-MM-dd\nHH:mm:ss').format(payment.createdAt)),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showPaymentDetail(payment),
                    icon: const Icon(Icons.visibility),
                    tooltip: '查看详情',
                  ),
                  if (payment.status == '成功')
                    IconButton(
                      onPressed: () => _showRefundDialog(payment),
                      icon: const Icon(Icons.undo),
                      tooltip: '退款',
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handlePaymentAction(value, payment),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('导出记录'),
                      ),
                      const PopupMenuItem(
                        value: 'resend_notification',
                        child: Text('重发通知'),
                      ),
                      if (payment.status == '处理中')
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('取消订单'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildReconciliation(PaymentProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 对账工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '对账管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _startAutoReconciliation(provider),
                    icon: const Icon(Icons.auto_fix_high),
                    label: const Text('自动对账'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showManualReconciliationDialog(),
                    icon: const Icon(Icons.edit),
                    label: const Text('手动对账'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 对账状态概览
          Row(
            children: [
              Expanded(
                child: _buildReconciliationCard(
                  '已对账',
                  '${provider.reconciledCount}',
                  '¥${NumberFormat('#,##0.00').format(provider.reconciledAmount)}',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReconciliationCard(
                  '待对账',
                  '${provider.pendingCount}',
                  '¥${NumberFormat('#,##0.00').format(provider.pendingAmount)}',
                  Icons.pending,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReconciliationCard(
                  '异常记录',
                  '${provider.exceptionCount}',
                  '¥${NumberFormat('#,##0.00').format(provider.exceptionAmount)}',
                  Icons.error,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildReconciliationCard(
                  '对账率',
                  '${provider.reconciliationRate.toStringAsFixed(1)}%',
                  '本月统计',
                  Icons.analytics,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 对账记录列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.reconciliationRecords.length,
              itemBuilder: (context, index) {
                final record = provider.reconciliationRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getReconciliationIcon(record.status),
                                  color: _getReconciliationColor(record.status),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '对账批次: ${record.batchNo}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _buildReconciliationStatusChip(record.status),
                              ],
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(record.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildReconciliationInfo('对账金额', '¥${NumberFormat('#,##0.00').format(record.totalAmount)}'),
                            const SizedBox(width: 32),
                            _buildReconciliationInfo('成功笔数', '${record.successCount}'),
                            const SizedBox(width: 32),
                            _buildReconciliationInfo('异常笔数', '${record.exceptionCount}'),
                            const SizedBox(width: 32),
                            _buildReconciliationInfo('对账方式', record.type),
                          ],
                        ),
                        if (record.exceptionCount > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '发现 ${record.exceptionCount} 笔异常记录，需要人工处理',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => _showExceptionDetails(record),
                                  child: const Text('查看详情'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialStats(PaymentProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 财务统计工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '财务统计分析',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  DropdownButton<String>(
                    value: provider.selectedStatsPeriod,
                    items: ['今日', '本周', '本月', '本季度', '本年']
                        .map((period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ))
                        .toList(),
                    onChanged: (value) => provider.changeStatsPeriod(value!),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _exportFinancialReport(provider),
                    icon: const Icon(Icons.file_download),
                    label: const Text('导出报表'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 财务统计内容
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧统计卡片
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildRevenueChart(provider),
                      const SizedBox(height: 20),
                      _buildPaymentMethodChart(provider),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // 右侧详细统计
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildTopProducts(provider),
                      const SizedBox(height: 20),
                      _buildRecentTransactions(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChip(String method) {
    Color color;
    IconData icon;
    switch (method) {
      case '微信支付':
        color = Colors.green;
        icon = Icons.chat;
        break;
      case '支付宝':
        color = Colors.blue;
        icon = Icons.account_balance_wallet;
        break;
      case '银行卡':
        color = Colors.orange;
        icon = Icons.credit_card;
        break;
      case '苹果支付':
        color = Colors.black;
        icon = Icons.apple;
        break;
      default:
        color = Colors.grey;
        icon = Icons.payment;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            method,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '成功':
        color = AppColors.success;
        break;
      case '失败':
        color = AppColors.error;
        break;
      case '处理中':
        color = AppColors.warning;
        break;
      case '已退款':
        color = AppColors.info;
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

  Widget _buildReconciliationCard(String title, String value, String subtitle, IconData icon, Color color) {
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconciliationStatusChip(String status) {
    Color color;
    switch (status) {
      case '已完成':
        color = AppColors.success;
        break;
      case '处理中':
        color = AppColors.warning;
        break;
      case '异常':
        color = AppColors.error;
        break;
      default:
        color = AppColors.info;
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

  Widget _buildReconciliationInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(PaymentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '收入趋势',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text(
                  '收入趋势图表\n（此处可集成图表库）',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChart(PaymentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            ...provider.paymentMethodStats.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildPaymentMethodChip(entry.key),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '¥${NumberFormat('#,##0').format(entry.value.amount)}',
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

  Widget _buildTopProducts(PaymentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门商品 TOP 5',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.topProducts.take(5).map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '¥${NumberFormat('#,##0').format(product.revenue)}',
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

  Widget _buildRecentTransactions(PaymentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近交易',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.recentTransactions.take(5).map((transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        transaction.productName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '¥${NumberFormat('#,##0.00').format(transaction.amount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MM-dd HH:mm').format(transaction.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondaryColor,
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

  IconData _getReconciliationIcon(String status) {
    switch (status) {
      case '已完成':
        return Icons.check_circle;
      case '处理中':
        return Icons.pending;
      case '异常':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getReconciliationColor(String status) {
    switch (status) {
      case '已完成':
        return AppColors.success;
      case '处理中':
        return AppColors.warning;
      case '异常':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _applyFilters(PaymentProvider provider) {
    provider.applyFilters(
      searchQuery: _searchController.text,
      status: _selectedStatus == '全部' ? null : _selectedStatus,
      paymentMethod: _selectedPaymentMethod == '全部' ? null : _selectedPaymentMethod,
      timeRange: _selectedTimeRange,
      customDateRange: _customDateRange,
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _customDateRange = picked;
      });
      _applyFilters(context.read<PaymentProvider>());
    }
  }

  void _showPaymentDetail(PaymentRecord payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('支付详情 - ${payment.orderNo}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('订单号', payment.orderNo),
              _buildDetailItem('商品名称', payment.productName),
              _buildDetailItem('用户ID', payment.userId),
              _buildDetailItem('支付金额', '¥${NumberFormat('#,##0.00').format(payment.amount)}'),
              _buildDetailItem('支付方式', payment.paymentMethod),
              _buildDetailItem('支付状态', payment.status),
              _buildDetailItem('创建时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(payment.createdAt)),
              if (payment.completedAt != null)
                _buildDetailItem('完成时间', DateFormat('yyyy-MM-dd HH:mm:ss').format(payment.completedAt!)),
              if (payment.transactionId.isNotEmpty)
                _buildDetailItem('交易流水号', payment.transactionId),
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

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(PaymentRecord payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('退款功能开发中: ${payment.orderNo}')),
    );
  }

  void _handlePaymentAction(String action, PaymentRecord payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对订单 ${payment.orderNo} 执行操作: $action')),
    );
  }

  void _showReconciliationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('对账功能开发中...')),
    );
  }

  void _startAutoReconciliation(PaymentProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('自动对账功能开发中...')),
    );
  }

  void _showManualReconciliationDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('手动对账功能开发中...')),
    );
  }

  void _showExceptionDetails(ReconciliationRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看异常详情: ${record.batchNo}')),
    );
  }

  void _exportRecords(PaymentProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出支付记录功能开发中...')),
    );
  }

  void _exportFinancialReport(PaymentProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出财务报表功能开发中...')),
    );
  }
}