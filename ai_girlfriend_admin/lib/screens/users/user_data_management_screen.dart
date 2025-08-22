import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/admin_layout.dart';
import '../../constants/app_theme.dart';
import '../../providers/user_management_provider.dart';
import '../../models/user_model.dart';
import 'user_profile_detail_screen.dart';

class UserDataManagementScreen extends StatefulWidget {
  const UserDataManagementScreen({super.key});

  @override
  State<UserDataManagementScreen> createState() => _UserDataManagementScreenState();
}

class _UserDataManagementScreenState extends State<UserDataManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '全部';
  String _selectedMembership = '全部';
  DateTime? _startDate;
  DateTime? _endDate;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserManagementProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/users/data',
      child: Consumer<UserManagementProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                          '用户数据管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理用户账号、充值记录、亲密度等基础数据',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddUserDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('添加用户'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportUsers(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出数据'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 搜索和筛选区域
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // 搜索框
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: '搜索用户ID、用户名、邮箱...',
                                  prefixIcon: Icon(Icons.search),
                                ),
                                onChanged: (value) => _applyFilters(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 状态筛选
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  labelText: '用户状态',
                                ),
                                items: ['全部', '正常', '禁用', '待验证']
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
                            // 会员类型筛选
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedMembership,
                                decoration: const InputDecoration(
                                  labelText: '会员类型',
                                ),
                                items: ['全部', '普通用户', '会员', '高级会员', '终身会员']
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedMembership = value!;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // 日期范围选择
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '注册时间:',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () => _selectDateRange(),
                                    child: Text(
                                      _startDate != null && _endDate != null
                                          ? '${DateFormat('yyyy-MM-dd').format(_startDate!)} - ${DateFormat('yyyy-MM-dd').format(_endDate!)}'
                                          : '选择日期范围',
                                    ),
                                  ),
                                  if (_startDate != null)
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _startDate = null;
                                          _endDate = null;
                                        });
                                        _applyFilters();
                                      },
                                      icon: const Icon(Icons.clear),
                                      tooltip: '清除日期筛选',
                                    ),
                                ],
                              ),
                            ),
                            // 重置按钮
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重置筛选'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 统计信息
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatCard('总用户数', provider.totalUsers.toString(), Icons.people, AppColors.primary),
                      const SizedBox(width: 16),
                      _buildStatCard('活跃用户', provider.activeUsers.toString(), Icons.person_outline, AppColors.success),
                      const SizedBox(width: 16),
                      _buildStatCard('会员用户', provider.memberUsers.toString(), Icons.star, AppColors.warning),
                      const SizedBox(width: 16),
                      _buildStatCard('今日新增', provider.todayNewUsers.toString(), Icons.person_add, AppColors.info),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 用户列表
                Container(
                  height: 600, // 设置固定高度
                  child: Card(
                    child: Column(
                      children: [
                        // 表格标题
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '用户列表 (${provider.filteredUsers.length})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => provider.loadUsers(),
                                    icon: const Icon(Icons.refresh),
                                    tooltip: '刷新数据',
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'export':
                                          _exportUsers();
                                          break;
                                        case 'import':
                                          _importUsers();
                                          break;
                                        case 'batch_delete':
                                          _batchDeleteUsers();
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'export',
                                        child: Row(
                                          children: [
                                            Icon(Icons.download),
                                            SizedBox(width: 8),
                                            Text('导出选中'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'import',
                                        child: Row(
                                          children: [
                                            Icon(Icons.upload),
                                            SizedBox(width: 8),
                                            Text('批量导入'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'batch_delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 8),
                                            Text('批量删除'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 数据表格
                        Expanded(
                          child: provider.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildUserTable(provider),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200, // 设置固定宽度
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTable(UserManagementProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      columns: [
        DataColumn2(
          label: const Text('用户ID'),
          size: ColumnSize.S,
          onSort: (columnIndex, ascending) => _sort(columnIndex, ascending, provider),
        ),
        DataColumn2(
          label: const Text('用户名'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => _sort(columnIndex, ascending, provider),
        ),
        DataColumn2(
          label: const Text('邮箱'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: const Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: const Text('会员类型'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: const Text('余额'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: const Text('注册时间'),
          size: ColumnSize.M,
          onSort: (columnIndex, ascending) => _sort(columnIndex, ascending, provider),
        ),
        DataColumn2(
          label: const Text('操作'),
          size: ColumnSize.M,
        ),
      ],
      rows: provider.filteredUsers.map((user) {
        return DataRow2(
          cells: [
            DataCell(
              SelectableText(
                user.id,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.username,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(Text(user.email)),
            DataCell(_buildStatusChip(user.status)),
            DataCell(_buildMembershipChip(user.membershipType)),
            DataCell(
              Text(
                '¥${user.balance.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Text(DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt)),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showUserDetail(user),
                    icon: const Icon(Icons.visibility),
                    tooltip: '查看详情',
                  ),
                  IconButton(
                    onPressed: () => _showUserProfile(user),
                    icon: const Icon(Icons.account_circle),
                    tooltip: '查看用户画像',
                  ),
                  IconButton(
                    onPressed: () => _editUser(user),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleUserAction(value, user),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reset_password',
                        child: Text('重置密码'),
                      ),
                      const PopupMenuItem(
                        value: 'toggle_status',
                        child: Text('切换状态'),
                      ),
                      const PopupMenuItem(
                        value: 'view_logs',
                        child: Text('查看日志'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除用户'),
                      ),
                    ],
                    child: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '正常':
        color = AppColors.success;
        break;
      case '禁用':
        color = AppColors.error;
        break;
      case '待验证':
        color = AppColors.warning;
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

  Widget _buildMembershipChip(String membershipType) {
    Color color;
    IconData icon;
    switch (membershipType) {
      case '会员':
        color = AppColors.warning;
        icon = Icons.star;
        break;
      case '高级会员':
        color = AppColors.secondary;
        icon = Icons.star;
        break;
      case '终身会员':
        color = AppColors.primary;
        icon = Icons.diamond;
        break;
      default:
        color = AppColors.info;
        icon = Icons.person;
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
            membershipType,
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

  void _applyFilters() {
    final provider = context.read<UserManagementProvider>();
    provider.applyFilters(
      searchQuery: _searchController.text,
      status: _selectedStatus == '全部' ? null : _selectedStatus,
      membershipType: _selectedMembership == '全部' ? null : _selectedMembership,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = '全部';
      _selectedMembership = '全部';
      _startDate = null;
      _endDate = null;
    });
    _applyFilters();
  }

  void _sort(int columnIndex, bool ascending, UserManagementProvider provider) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
    provider.sortUsers(columnIndex, ascending);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _showAddUserDialog() {
    // TODO: 实现添加用户对话框
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加用户功能开发中...')),
    );
  }

  void _showUserDetail(UserModel user) {
    // TODO: 实现用户详情对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看用户详情 ${user.username}')),
    );
  }

  void _showUserProfile(UserModel user) {
    context.go('/users/profile/${user.id}');
  }

  void _editUser(UserModel user) {
    // TODO: 实现编辑用户对话框
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑用户 ${user.username}')),
    );
  }

  void _handleUserAction(String action, UserModel user) {
    // TODO: 实现用户操作
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对用户 ${user.username} 执行操作: $action')),
    );
  }

  void _exportUsers() {
    // TODO: 实现导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出用户数据功能开发中...')),
    );
  }

  void _importUsers() {
    // TODO: 实现导入功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入用户数据功能开发中...')),
    );
  }

  void _batchDeleteUsers() {
    // TODO: 实现批量删除功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量删除功能开发中...')),
    );
  }
}