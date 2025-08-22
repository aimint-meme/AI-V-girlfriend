import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/service_management_provider.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 日历相关
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  
  // 筛选条件
  String _selectedProvider = '全部';
  String _selectedStatus = '全部';
  String _selectedTimeSlot = '全部';
  
  // 排班设置
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  int _slotDuration = 30; // 分钟
  List<String> _workDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceManagementProvider>().loadScheduleData();
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
      currentRoute: '/services/schedule',
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
                          '排程管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理服务者排班、时间安排和工作计划',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _autoSchedule(),
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('智能排班'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportSchedule(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出排班'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _refreshSchedule(),
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
                        title: '今日排班',
                        value: '${provider.todaySchedules}',
                        subtitle: '在线: ${provider.onlineSchedules}',
                        trend: provider.scheduleTrend,
                        icon: Icons.today,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '空闲时段',
                        value: '${provider.availableSlots}',
                        subtitle: '可预约时段',
                        trend: provider.availabilityTrend,
                        icon: Icons.schedule,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '利用率',
                        value: '${provider.utilizationRate.toStringAsFixed(1)}%',
                        subtitle: '时间利用率',
                        trend: provider.utilizationTrend,
                        icon: Icons.pie_chart,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '冲突数',
                        value: '${provider.conflictCount}',
                        subtitle: '需要处理的冲突',
                        trend: provider.conflictTrend,
                        icon: Icons.warning,
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
                                icon: Icon(Icons.calendar_today),
                                text: '日程视图',
                              ),
                              Tab(
                                icon: Icon(Icons.view_week),
                                text: '周视图',
                              ),
                              Tab(
                                icon: Icon(Icons.settings),
                                text: '排班设置',
                              ),
                              Tab(
                                icon: Icon(Icons.analytics),
                                text: '排班分析',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildDayViewTab(provider),
                              _buildWeekViewTab(provider),
                              _buildScheduleSettingsTab(provider),
                              _buildScheduleAnalyticsTab(provider),
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

  Widget _buildDayViewTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 左侧日历
          Container(
            width: 300,
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
                  '选择日期',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                // 简化的日历选择器
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // 月份导航
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => _previousMonth(),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              DateFormat('yyyy年MM月').format(_focusedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _nextMonth(),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      // 日期网格
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                          ),
                          itemCount: 35,
                          itemBuilder: (context, index) {
                            final date = _getDateForIndex(index);
                            final isSelected = _isSameDay(date, _selectedDate);
                            final isToday = _isSameDay(date, DateTime.now());
                            
                            return GestureDetector(
                              onTap: () => _selectDate(date),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primary 
                                      : isToday 
                                          ? AppColors.primary.withOpacity(0.2)
                                          : null,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: isSelected 
                                          ? Colors.white 
                                          : Colors.black,
                                      fontWeight: isSelected || isToday 
                                          ? FontWeight.bold 
                                          : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // 快速筛选
                Text(
                  '筛选条件',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedProvider,
                  decoration: const InputDecoration(
                    labelText: '服务者',
                    isDense: true,
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
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    isDense: true,
                  ),
                  items: ['全部', '空闲', '忙碌', '休息', '请假']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          
          // 右侧时间表
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日期标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy年MM月dd日 E').format(_selectedDate),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _addSchedule(),
                          icon: const Icon(Icons.add),
                          label: const Text('添加排班'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _refreshDayView(),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // 时间轴
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _buildTimelineView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    return ListView.builder(
      itemCount: 24, // 24小时
      itemBuilder: (context, index) {
        final hour = index;
        final schedules = _getSchedulesForHour(hour);
        
        return Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              // 时间标签
              Container(
                width: 60,
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              // 排班内容
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: schedules.map((schedule) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getScheduleColor(schedule['status']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _getScheduleColor(schedule['status']),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                schedule['providerName'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                schedule['status'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getScheduleColor(schedule['status']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekViewTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 周导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormat('yyyy年MM月dd日').format(_getWeekStart())} - ${DateFormat('MM月dd日').format(_getWeekEnd())}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _previousWeek(),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  OutlinedButton(
                    onPressed: () => _goToToday(),
                    child: const Text('今天'),
                  ),
                  IconButton(
                    onPressed: () => _nextWeek(),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 周视图表格
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // 表头
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          child: const Text(
                            '时间',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ...List.generate(7, (index) {
                          final date = _getWeekStart().add(Duration(days: index));
                          final isToday = _isSameDay(date, DateTime.now());
                          
                          return Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isToday ? AppColors.primary.withOpacity(0.1) : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('E').format(date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isToday ? AppColors.primary : null,
                                    ),
                                  ),
                                  Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isToday ? AppColors.primary : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  // 时间行
                  Expanded(
                    child: ListView.builder(
                      itemCount: 14, // 9:00-22:00
                      itemBuilder: (context, index) {
                        final hour = 9 + index;
                        
                        return Container(
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}:00',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                              ),
                              ...List.generate(7, (dayIndex) {
                                final date = _getWeekStart().add(Duration(days: dayIndex));
                                final schedules = _getSchedulesForDateTime(date, hour);
                                
                                return Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    child: Column(
                                      children: schedules.map((schedule) {
                                        return Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.all(1),
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: _getScheduleColor(schedule['status']).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                            child: Text(
                                              schedule['providerName'],
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
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

  Widget _buildScheduleSettingsTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 左侧设置
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
                    '排班规则设置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 工作时间设置
                  Text(
                    '工作时间',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('开始时间'),
                          subtitle: Text(_startTime.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectStartTime(),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('结束时间'),
                          subtitle: Text(_endTime.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectEndTime(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 时段设置
                  Text(
                    '时段设置',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('时段时长:'),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: _slotDuration,
                        items: [15, 30, 45, 60]
                            .map((duration) => DropdownMenuItem(
                                  value: duration,
                                  child: Text('${duration}分钟'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _slotDuration = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 工作日设置
                  Text(
                    '工作日设置',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'].map((day) {
                      final isSelected = _workDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _workDays.add(day);
                            } else {
                              _workDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  
                  // 保存按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveScheduleSettings(),
                      child: const Text('保存设置'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // 右侧模板
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
                    '排班模板',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: ListView(
                      children: [
                        _buildScheduleTemplate(
                          '标准班次',
                          '09:00-18:00',
                          '周一至周五',
                          Icons.work,
                          AppColors.primary,
                        ),
                        _buildScheduleTemplate(
                          '早班',
                          '06:00-14:00',
                          '周一至周日',
                          Icons.wb_sunny,
                          AppColors.warning,
                        ),
                        _buildScheduleTemplate(
                          '晚班',
                          '14:00-22:00',
                          '周一至周日',
                          Icons.nights_stay,
                          AppColors.info,
                        ),
                        _buildScheduleTemplate(
                          '夜班',
                          '22:00-06:00',
                          '周五至周日',
                          Icons.bedtime,
                          Colors.purple,
                        ),
                        _buildScheduleTemplate(
                          '弹性班次',
                          '自定义时间',
                          '灵活安排',
                          Icons.schedule,
                          AppColors.success,
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

  Widget _buildScheduleAnalyticsTab(ServiceManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 分析图表
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
                        '工作负荷分析',
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
                              '工作负荷图表\n（此处可集成图表库）',
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
                        '时段利用率',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildUtilizationItem('09:00-12:00', 85.2, AppColors.success),
                            _buildUtilizationItem('12:00-14:00', 65.8, AppColors.warning),
                            _buildUtilizationItem('14:00-18:00', 92.3, AppColors.primary),
                            _buildUtilizationItem('18:00-22:00', 78.9, AppColors.info),
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
          
          // 详细统计
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
                        '服务者工作统计',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildProviderWorkStats('小雨', 45, 8.5, 96.2),
                      _buildProviderWorkStats('晓晓', 38, 7.2, 94.1),
                      _buildProviderWorkStats('甜甜', 42, 8.0, 95.8),
                      _buildProviderWorkStats('柔柔', 35, 6.8, 92.3),
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
                        '排班效率分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEfficiencyMetric('平均响应时间', '2.3分钟', '-0.5分钟'),
                      _buildEfficiencyMetric('空闲时间', '12.5%', '+2.1%'),
                      _buildEfficiencyMetric('加班时间', '8.2小时/周', '-1.3小时'),
                      _buildEfficiencyMetric('客户满意度', '4.8分', '+0.2分'),
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

  Widget _buildScheduleTemplate(String name, String time, String days, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('$time\n$days'),
        trailing: OutlinedButton(
          onPressed: () => _applyTemplate(name),
          child: const Text('应用'),
        ),
      ),
    );
  }

  Widget _buildUtilizationItem(String timeSlot, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  color: color,
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
      ),
    );
  }

  Widget _buildProviderWorkStats(String name, int hours, double avgHours, double efficiency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${hours}h',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${avgHours}h/天',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${efficiency.toStringAsFixed(1)}%',
            style: TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyMetric(String metric, String value, String change) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 10,
                  color: change.startsWith('+') ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScheduleColor(String status) {
    switch (status) {
      case '空闲':
        return AppColors.success;
      case '忙碌':
        return AppColors.primary;
      case '休息':
        return AppColors.info;
      case '请假':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  DateTime _getDateForIndex(int index) {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayWeekday - 1));
    return startDate.add(Duration(days: index));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _getWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime _getWeekEnd() {
    return _getWeekStart().add(const Duration(days: 6));
  }

  List<Map<String, dynamic>> _getSchedulesForHour(int hour) {
    // 模拟数据
    if (hour >= 9 && hour <= 22) {
      return [
        {
          'providerName': '小雨',
          'status': hour < 12 ? '空闲' : hour < 18 ? '忙碌' : '休息',
        },
        {
          'providerName': '晓晓',
          'status': hour < 14 ? '忙碌' : hour < 20 ? '空闲' : '休息',
        },
      ];
    }
    return [];
  }

  List<Map<String, dynamic>> _getSchedulesForDateTime(DateTime date, int hour) {
    // 模拟数据
    if (hour >= 9 && hour <= 22) {
      return [
        {
          'providerName': '小雨',
          'status': '空闲',
        },
      ];
    }
    return [];
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
  }

  void _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _autoSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('智能排班功能开发中...')),
    );
  }

  void _exportSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('排班导出功能开发中...')),
    );
  }

  void _refreshSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新排班数据...')),
    );
  }

  void _addSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加排班功能开发中...')),
    );
  }

  void _refreshDayView() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新日程视图...')),
    );
  }

  void _saveScheduleSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('排班设置保存成功！'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyTemplate(String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('应用排班模板: $templateName')),
    );
  }
}