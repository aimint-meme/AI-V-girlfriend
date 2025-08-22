import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/system_settings_provider.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // 用户搜索
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = '全部';
  String _selectedStatus = '全部';
  
  // 角色创建
  final TextEditingController _roleNameController = TextEditingController();
  final TextEditingController _roleDescController = TextEditingController();
  Set<String> _selectedPermissions = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemSettingsProvider>().loadPermissionSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _roleNameController.dispose();
    _roleDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/settings/permissions',
      child: Consumer<SystemSettingsProvider>(
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
                          '权限管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理用户角色权限和系统访问控制',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showCreateRoleDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('创建角色'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _exportPermissions(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出权限'),
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
                        title: '用户总数',
                        value: '${provider.totalUsers}',
                        subtitle: '活跃用户: ${provider.activeUsers}',
                        trend: provider.userGrowthTrend,
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '角色数量',
                        value: '${provider.totalRoles}',
                        subtitle: '自定义角色: ${provider.customRoles}',
                        trend: provider.roleGrowthTrend,
                        icon: Icons.admin_panel_settings,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '权限项目',
                        value: '${provider.totalPermissions}',
                        subtitle: '已分配: ${provider.assignedPermissions}',
                        trend: provider.permissionTrend,
                        icon: Icons.security,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '安全评分',
                        value: '${provider.securityScore}分',
                        subtitle: '权限安全评估',
                        trend: provider.securityTrend,
                        icon: Icons.shield,
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
                                icon: Icon(Icons.people),
                                text: '用户管理',
                              ),
                              Tab(
                                icon: Icon(Icons.admin_panel_settings),
                                text: '角色管理',
                              ),
                              Tab(
                                icon: Icon(Icons.security),
                                text: '权限配置',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildUserManagementTab(provider),
                              _buildRoleManagementTab(provider),
                              _buildPermissionConfigTab(provider),
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

  Widget _buildUserManagementTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
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
                    hintText: '搜索用户名、邮箱...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyUserFilters(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: '角色筛选',
                  ),
                  items: ['全部', '超级管理员', '管理员', '运营人员', '客服人员', '普通用户']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                    _applyUserFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态筛选',
                  ),
                  items: ['全部', '正常', '禁用', '锁定']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyUserFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 用户列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildUserTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('用户信息')),
          DataColumn(label: Text('角色')),
          DataColumn(label: Text('状态')),
          DataColumn(label: Text('最后登录')),
          DataColumn(label: Text('创建时间')),
          DataColumn(label: Text('操作')),
        ],
        rows: _generateMockUsers().map((user) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        user['name'][0],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user['email'],
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
              DataCell(_buildRoleChip(user['role'])),
              DataCell(_buildStatusChip(user['status'])),
              DataCell(
                Text(
                  DateFormat('MM-dd HH:mm').format(user['lastLogin']),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  DateFormat('yyyy-MM-dd').format(user['createdAt']),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editUser(user),
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      onPressed: () => _toggleUserStatus(user),
                      icon: Icon(
                        user['status'] == '正常' ? Icons.block : Icons.check_circle,
                        size: 18,
                      ),
                      tooltip: user['status'] == '正常' ? '禁用' : '启用',
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleUserAction(value, user),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'reset_password',
                          child: Text('重置密码'),
                        ),
                        const PopupMenuItem(
                          value: 'view_logs',
                          child: Text('查看日志'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('删除用户'),
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

  Widget _buildRoleManagementTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 角色列表
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _generateMockRoles().length,
              itemBuilder: (context, index) {
                final role = _generateMockRoles()[index];
                return _buildRoleCard(role);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionConfigTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 权限树
          Expanded(
            flex: 2,
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
                    '权限配置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: _buildPermissionTree(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 权限详情
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
                    '权限详情',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildPermissionDetailItem(
                          '用户管理',
                          '管理系统用户账户',
                          ['查看用户', '创建用户', '编辑用户', '删除用户'],
                        ),
                        _buildPermissionDetailItem(
                          '角色管理',
                          '管理用户角色和权限',
                          ['查看角色', '创建角色', '编辑角色', '删除角色'],
                        ),
                        _buildPermissionDetailItem(
                          '内容管理',
                          '管理系统内容和数据',
                          ['查看内容', '创建内容', '编辑内容', '删除内容'],
                        ),
                        _buildPermissionDetailItem(
                          '系统设置',
                          '管理系统配置和设置',
                          ['查看设置', '修改设置', '系统维护', '数据备份'],
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

  Widget _buildRoleCard(Map<String, dynamic> role) {
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
                  role['icon'],
                  color: role['color'],
                  size: 32,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleRoleAction(value, role),
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
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              role['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role['description'],
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
                  '${role['userCount']} 用户',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${role['permissionCount']} 权限',
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

  Widget _buildRoleChip(String role) {
    final colors = {
      '超级管理员': AppColors.error,
      '管理员': AppColors.primary,
      '运营人员': AppColors.success,
      '客服人员': AppColors.info,
      '普通用户': Colors.grey,
    };
    
    final color = colors[role] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      case '锁定':
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildPermissionTree() {
    final permissions = [
      {
        'name': '用户管理',
        'icon': Icons.people,
        'children': ['查看用户', '创建用户', '编辑用户', '删除用户'],
      },
      {
        'name': '角色管理',
        'icon': Icons.admin_panel_settings,
        'children': ['查看角色', '创建角色', '编辑角色', '删除角色'],
      },
      {
        'name': '内容管理',
        'icon': Icons.content_paste,
        'children': ['查看内容', '创建内容', '编辑内容', '删除内容'],
      },
      {
        'name': '系统设置',
        'icon': Icons.settings,
        'children': ['查看设置', '修改设置', '系统维护', '数据备份'],
      },
    ];

    return permissions.map((permission) {
      return ExpansionTile(
        leading: Icon(permission['icon'] as IconData),
        title: Text(permission['name'] as String),
        children: (permission['children'] as List<String>).map((child) {
          return CheckboxListTile(
            title: Text(child),
            value: _selectedPermissions.contains('${permission['name']}_$child'),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedPermissions.add('${permission['name']}_$child');
                } else {
                  _selectedPermissions.remove('${permission['name']}_$child');
                }
              });
            },
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildPermissionDetailItem(String title, String description, List<String> permissions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: permissions.map((permission) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    permission,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockUsers() {
    return [
      {
        'id': 'user_001',
        'name': '张三',
        'email': 'zhangsan@example.com',
        'role': '管理员',
        'status': '正常',
        'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
        'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      },
      {
        'id': 'user_002',
        'name': '李四',
        'email': 'lisi@example.com',
        'role': '运营人员',
        'status': '正常',
        'lastLogin': DateTime.now().subtract(const Duration(hours: 5)),
        'createdAt': DateTime.now().subtract(const Duration(days: 25)),
      },
      {
        'id': 'user_003',
        'name': '王五',
        'email': 'wangwu@example.com',
        'role': '客服人员',
        'status': '禁用',
        'lastLogin': DateTime.now().subtract(const Duration(days: 3)),
        'createdAt': DateTime.now().subtract(const Duration(days: 20)),
      },
      {
        'id': 'user_004',
        'name': '赵六',
        'email': 'zhaoliu@example.com',
        'role': '普通用户',
        'status': '正常',
        'lastLogin': DateTime.now().subtract(const Duration(minutes: 30)),
        'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockRoles() {
    return [
      {
        'id': 'role_001',
        'name': '超级管理员',
        'description': '拥有系统所有权限，可以管理所有功能和用户',
        'icon': Icons.admin_panel_settings,
        'color': AppColors.error,
        'userCount': 2,
        'permissionCount': 24,
      },
      {
        'id': 'role_002',
        'name': '管理员',
        'description': '拥有大部分管理权限，可以管理用户和内容',
        'icon': Icons.manage_accounts,
        'color': AppColors.primary,
        'userCount': 5,
        'permissionCount': 18,
      },
      {
        'id': 'role_003',
        'name': '运营人员',
        'description': '负责内容运营和用户管理相关工作',
        'icon': Icons.work,
        'color': AppColors.success,
        'userCount': 8,
        'permissionCount': 12,
      },
      {
        'id': 'role_004',
        'name': '客服人员',
        'description': '处理用户问题和客户服务相关工作',
        'icon': Icons.support_agent,
        'color': AppColors.info,
        'userCount': 12,
        'permissionCount': 8,
      },
      {
        'id': 'role_005',
        'name': '普通用户',
        'description': '基础用户权限，只能查看基本信息',
        'icon': Icons.person,
        'color': Colors.grey,
        'userCount': 156,
        'permissionCount': 4,
      },
      {
        'id': 'role_006',
        'name': '审核员',
        'description': '负责内容审核和风控管理',
        'icon': Icons.verified,
        'color': AppColors.warning,
        'userCount': 6,
        'permissionCount': 10,
      },
    ];
  }

  void _applyUserFilters() {
    // 实现用户筛选逻辑
  }

  void _showCreateRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建角色'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _roleNameController,
                decoration: const InputDecoration(
                  labelText: '角色名称',
                  hintText: '请输入角色名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入角色名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleDescController,
                decoration: const InputDecoration(
                  labelText: '角色描述',
                  hintText: '请输入角色描述',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => _createRole(),
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _createRole() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('角色"${_roleNameController.text}"创建成功！'),
          backgroundColor: AppColors.success,
        ),
      );
      _roleNameController.clear();
      _roleDescController.clear();
    }
  }

  void _exportPermissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('权限配置导出功能开发中...')),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑用户: ${user['name']}')),
    );
  }

  void _toggleUserStatus(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user['status'] == '正常' ? '禁用' : '启用'}用户: ${user['name']}')),
    );
  }

  void _handleUserAction(String action, Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对用户 ${user['name']} 执行操作: $action')),
    );
  }

  void _handleRoleAction(String action, Map<String, dynamic> role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对角色 ${role['name']} 执行操作: $action')),
    );
  }
}