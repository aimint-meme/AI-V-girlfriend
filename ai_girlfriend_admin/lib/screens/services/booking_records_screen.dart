import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/service_management_provider.dart';

class BookingRecordsScreen extends StatefulWidget {
  const BookingRecordsScreen({super.key});

  @override
  State<BookingRecordsScreen> createState() => _BookingRecordsScreenState();
}

class _BookingRecordsScreenState extends State<BookingRecordsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 筛选条件
  String _selectedStatus = '全部';
  String _selectedService = '全部';
  String _selectedProvider = '全部';
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
      context.read<ServiceManagementProvider>().loadBookingData();
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
      currentRoute: '/services/bookings',
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
                          '预约记录',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '查看和管理所有预约记录、服务历史和客户反馈',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _exportRecords(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出记录'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _generateReport(),
                          icon: const Icon(Icons.assessment),
                          label: const Text('生成报告'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _refreshRecords(),
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
                        title: '总预约数',
                        value: NumberFormat('#,##0').format(provider.totalBookingRecords),
                        subtitle: '本月: ${NumberFormat('#,##0').format(provider.monthlyBookingRecords)}',
                        trend: provider.bookingRecordTrend,
                        icon: Icons.event,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '完成率',
                        value: '${provider.bookingCompletionRate.toStringAsFixed(1)}%',
                        subtitle: '服务完成率',
                        trend: provider.completionRateTrend,
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均评分',
                        value: '${provider.averageBookingRating.toStringAsFixed(1)}',
                        subtitle: '客户满意度',
                        trend: provider.ratingTrend,
                        icon: Icons.star,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '取消率',
                        value: '${provider.cancellationRate.toStringAsFixed(1)}%',
                        subtitle: '预约取消率',
                        trend: provider.cancellationTrend,
                        icon: Icons.cancel,
                        color: AppColors.error,
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
                                text: '预约列表',
                              ),
                              Tab(
                                icon: Icon(Icons.history),
                                text: '服务历史',
                              ),
                              Tab(
                                icon: Icon(Icons.feedback),
                                text: '客户反馈',
                              ),
                              Tab(
                                icon: Icon(Icons.analytics),
                                text: '数据分析',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildBookingListTab(provider),
                              _buildServiceHistoryTab(provider),
                              _buildCustomerFeedbackTab(provider),
                              _buildDataAnalyticsTab(provider),
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

  Widget _buildBookingListTab(ServiceManagementProvider provider) {
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
                    hintText: '搜索预约号、用户名...',
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
                    labelText: '预约状态',
                  ),
                  items: ['全部', '待确认', '已确认', '进行中', '已完成', '已取消', '已过期']
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: const InputDecoration(
                    labelText: '服务者',
                  ),
                  items: ['全部', '小雨', '晓晓', '甜甜', '柔柔']
                      .map((provider) => DropdownMenuItem(
                            value: provider,
                            child: Text(provider),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvider = value!;
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
          
          // 预约列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBookingTable(),
          ),
          
          // 分页
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildBookingTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('预约信息')),
          DataColumn(label: Text('客户')),
          DataColumn(label: Text('服务者')),
          DataColumn(label: Text('服务')),
          DataColumn(label: Text('时间')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('评分')),
          DataColumn(label: Text('操作')),
        ],
        rows: _generateMockBookings().map((booking) {
          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      booking['bookingNo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '¥${booking['amount']}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
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
                        booking['customerName'][0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking['customerName'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.success.withOpacity(0.1),
                      child: Text(
                        booking['providerName'][0],
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      booking['providerName'],
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
                      booking['serviceName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${booking['duration']}分钟',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
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
                      DateFormat('MM-dd').format(booking['appointmentTime']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm').format(booking['appointmentTime']),
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(_buildBookingStatusChip(booking['status'])),
              DataCell(
                booking['rating'] != null
                    ? Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: AppColors.warning,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            booking['rating'].toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '未评分',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _viewBookingDetail(booking),
                      icon: const Icon(Icons.visibility, size: 16),
                      tooltip: '查看详情',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleBookingAction(value, booking),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('编辑'),
                        ),
                        const PopupMenuItem(
                          value: 'contact',
                          child: Text('联系客户'),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('取消预约'),
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

  Widget _buildServiceHistoryTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 历史统计
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${provider.totalServiceHistory}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text('总服务次数'),
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
                          '${provider.totalServiceHours}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        const Text('总服务时长(小时)'),
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
                          '${provider.repeatCustomers}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                        const Text('回头客数量'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 服务历史时间线
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
                    '服务历史时间线',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _generateServiceHistory().length,
                      itemBuilder: (context, index) {
                        final history = _generateServiceHistory()[index];
                        return _buildServiceHistoryItem(history);
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

  Widget _buildCustomerFeedbackTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 反馈统计
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
                        '评分分布',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildRatingDistribution('5星', 68, AppColors.success),
                            _buildRatingDistribution('4星', 22, AppColors.info),
                            _buildRatingDistribution('3星', 7, AppColors.warning),
                            _buildRatingDistribution('2星', 2, AppColors.error),
                            _buildRatingDistribution('1星', 1, Colors.grey),
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
                        '反馈关键词',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildKeywordChip('温柔', 45),
                          _buildKeywordChip('耐心', 38),
                          _buildKeywordChip('专业', 32),
                          _buildKeywordChip('贴心', 28),
                          _buildKeywordChip('有趣', 25),
                          _buildKeywordChip('准时', 22),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 客户反馈列表
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
                    '最新客户反馈',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _generateCustomerFeedback().length,
                      itemBuilder: (context, index) {
                        final feedback = _generateCustomerFeedback()[index];
                        return _buildFeedbackCard(feedback);
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

  Widget _buildDataAnalyticsTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 数据分析图表
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
                        '预约趋势分析',
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
                              '预约趋势图表\n（此处可集成图表库）',
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
                        '服务类型偏好',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildServicePreferenceItem('陪聊服务', 45.2, AppColors.primary),
                            _buildServicePreferenceItem('语音通话', 28.6, AppColors.success),
                            _buildServicePreferenceItem('视频通话', 18.3, AppColors.info),
                            _buildServicePreferenceItem('定制服务', 7.9, AppColors.warning),
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
          
          // 详细分析数据
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
                        '时段分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTimeSlotAnalysis('09:00-12:00', 15.2),
                      _buildTimeSlotAnalysis('12:00-14:00', 8.6),
                      _buildTimeSlotAnalysis('14:00-18:00', 32.4),
                      _buildTimeSlotAnalysis('18:00-22:00', 43.8),
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
                        '客户行为分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCustomerBehaviorItem('平均预约间隔', '3.2天'),
                      _buildCustomerBehaviorItem('平均服务时长', '45分钟'),
                      _buildCustomerBehaviorItem('重复预约率', '68%'),
                      _buildCustomerBehaviorItem('提前预约时间', '2.5小时'),
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

  Widget _buildBookingStatusChip(String status) {
    Color color;
    switch (status) {
      case '待确认':
        color = AppColors.warning;
        break;
      case '已确认':
        color = AppColors.info;
        break;
      case '进行中':
        color = AppColors.primary;
        break;
      case '已完成':
        color = AppColors.success;
        break;
      case '已取消':
        color = AppColors.error;
        break;
      case '已过期':
        color = Colors.grey;
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

  Widget _buildServiceHistoryItem(Map<String, dynamic> history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getServiceColor(history['serviceName']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getServiceIcon(history['serviceName']),
              color: _getServiceColor(history['serviceName']),
              size: 20,
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
                      history['serviceName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MM-dd HH:mm').format(history['completedAt']),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '客户: ${history['customerName']} | 服务者: ${history['providerName']}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '时长: ${history['duration']}分钟',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (history['rating'] != null) ...[
                      Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        history['rating'].toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildKeywordChip(String keyword, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$keyword ($count)',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
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
                    feedback['customerName'][0],
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
                            feedback['customerName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < feedback['rating'] 
                                    ? AppColors.warning 
                                    : Colors.grey.shade300,
                                size: 16,
                              );
                            }),
                          ),
                        ],
                      ),
                      Text(
                        '${feedback['serviceName']} - ${feedback['providerName']}',
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
              feedback['comment'],
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('yyyy-MM-dd HH:mm').format(feedback['createdAt']),
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

  Widget _buildServicePreferenceItem(String service, double percentage, Color color) {
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

  Widget _buildTimeSlotAnalysis(String timeSlot, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeSlot,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
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

  Widget _buildCustomerBehaviorItem(String label, String value) {
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
          Text(
            value,
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

  Color _getServiceColor(String serviceName) {
    switch (serviceName) {
      case '陪聊服务':
        return AppColors.primary;
      case '语音通话':
        return AppColors.success;
      case '视频通话':
        return AppColors.info;
      case '定制服务':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case '陪聊服务':
        return Icons.chat;
      case '语音通话':
        return Icons.phone;
      case '视频通话':
        return Icons.videocam;
      case '定制服务':
        return Icons.star;
      default:
        return Icons.help;
    }
  }

  List<Map<String, dynamic>> _generateMockBookings() {
    return [
      {
        'bookingNo': 'BK202401150001',
        'customerName': '张小美',
        'providerName': '小雨',
        'serviceName': '陪聊服务',
        'amount': 50,
        'duration': 60,
        'appointmentTime': DateTime.now().add(const Duration(hours: 2)),
        'status': '已确认',
        'rating': 4.8,
      },
      {
        'bookingNo': 'BK202401150002',
        'customerName': '李小萌',
        'providerName': '晓晓',
        'serviceName': '语音通话',
        'amount': 80,
        'duration': 30,
        'appointmentTime': DateTime.now().add(const Duration(hours: 1)),
        'status': '进行中',
        'rating': null,
      },
      {
        'bookingNo': 'BK202401150003',
        'customerName': '王小可',
        'providerName': '甜甜',
        'serviceName': '视频通话',
        'amount': 120,
        'duration': 30,
        'appointmentTime': DateTime.now().add(const Duration(hours: 3)),
        'status': '待确认',
        'rating': null,
      },
    ];
  }

  List<Map<String, dynamic>> _generateServiceHistory() {
    return [
      {
        'serviceName': '陪聊服务',
        'customerName': '张小美',
        'providerName': '小雨',
        'duration': 60,
        'rating': 4.8,
        'completedAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'serviceName': '语音通话',
        'customerName': '李小萌',
        'providerName': '晓晓',
        'duration': 45,
        'rating': 4.6,
        'completedAt': DateTime.now().subtract(const Duration(hours: 5)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateCustomerFeedback() {
    return [
      {
        'customerName': '张先生',
        'providerName': '小雨',
        'serviceName': '陪聊服务',
        'rating': 5,
        'comment': '服务态度很好，聊天很愉快，会继续选择的。',
        'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      },
      {
        'customerName': '李女士',
        'providerName': '晓晓',
        'serviceName': '语音通话',
        'rating': 4,
        'comment': '声音很甜美，服务很专业，就是时间有点短。',
        'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
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

  void _exportRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('预约记录导出功能开发中...')),
    );
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('报告生成功能开发中...')),
    );
  }

  void _refreshRecords() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新预约记录...')),
    );
  }

  void _viewBookingDetail(Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看预约详情: ${booking['bookingNo']}')),
    );
  }

  void _handleBookingAction(String action, Map<String, dynamic> booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对预约 ${booking['bookingNo']} 执行操作: $action')),
    );
  }
}