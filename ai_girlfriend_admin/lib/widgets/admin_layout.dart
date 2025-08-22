import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../providers/auth_provider.dart';
import '../constants/app_theme.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isCollapsed = false;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      label: '仪表板',
      route: '/dashboard',
      keepExpanded: true,
      children: [
        NavigationItem(
          icon: Icons.dashboard_outlined,
          label: '数据看板',
          route: '/dashboard',
        ),
        NavigationItem(
          icon: Icons.chat,
          label: '对话内容分析',
          route: '/content/analysis',
        ),
        NavigationItem(
          icon: Icons.timeline,
          label: '模型调用量',
          route: '/monitoring/model',
        ),
        NavigationItem(
          icon: Icons.analytics,
          label: '模型API实时数据',
          route: '/monitoring/realtime',
        ),
        NavigationItem(
          icon: Icons.speed,
          label: '模型API性能监控',
          route: '/monitoring/performance',
        ),
        NavigationItem(
          icon: Icons.people,
          label: '用户活跃度统计',
          route: '/monitoring/user-activity',
        ),
        NavigationItem(
          icon: Icons.monetization_on,
          label: '商业变现数据',
          route: '/monitoring/business',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.people,
      label: '用户管理',
      route: '/users',
      children: [
        NavigationItem(
          icon: Icons.person_add,
          label: '用户数据管理',
          route: '/users/data',
        ),
        NavigationItem(
          icon: Icons.account_circle,
          label: '用户画像',
          route: '/users/profile',
        ),
        NavigationItem(
          icon: Icons.analytics,
          label: '行为分析',
          route: '/users/behavior',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.article,
      label: '内容管理',
      route: '/content',
      children: [
        NavigationItem(
          icon: Icons.audiotrack,
          label: '语音库',
          route: '/content/voice',
        ),
        NavigationItem(
          icon: Icons.movie,
          label: '场景库',
          route: '/content/scene',
        ),
        NavigationItem(
          icon: Icons.description,
          label: 'Prompt模板管理',
          route: '/content/templates',
        ),
        NavigationItem(
          icon: Icons.library_books,
          label: '知识库管理',
          route: '/content/knowledge',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.person,
      label: '角色库',
      route: '/characters',
      children: [
        NavigationItem(
          icon: Icons.storage,
          label: '角色数据管理',
          route: '/characters/data',
        ),
        NavigationItem(
          icon: Icons.create,
          label: '创建角色',
          route: '/characters/create',
        ),
        NavigationItem(
          icon: Icons.tune,
          label: '角色能力配置',
          route: '/characters/config',
        ),
        NavigationItem(
          icon: Icons.settings,
          label: '预设角色配置',
          route: '/content/character',
        ),
      ],
    ),

    NavigationItem(
      icon: Icons.event,
      label: '活动配置',
      route: '/activities',
      children: [
        NavigationItem(
          icon: Icons.calendar_today,
          label: '节日主题/皮肤上线',
          route: '/activities/themes',
        ),
        NavigationItem(
          icon: Icons.card_giftcard,
          label: '任务奖励配置/成就机制',
          route: '/activities/rewards',
        ),
        NavigationItem(
          icon: Icons.campaign,
          label: '商城商品管理/服务预约配置',
          route: '/activities/commerce',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.security,
      label: '风控管理',
      route: '/risk-control',
      children: [
        NavigationItem(
          icon: Icons.gavel,
          label: '敏感词管理/违规检测',
          route: '/risk-control/content',
        ),
        NavigationItem(
          icon: Icons.person_search,
          label: '实时预警/人工干预',
          route: '/risk-control/monitoring',
        ),
        NavigationItem(
          icon: Icons.build,
          label: '违规处理异常/名单机制',
          route: '/risk-control/handling',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.payment,
      label: '支付管理',
      route: '/payments',
      children: [
        NavigationItem(
          icon: Icons.receipt,
          label: '支付记录查询/对账功能',
          route: '/payments/records',
        ),
        NavigationItem(
          icon: Icons.account_balance,
          label: '退款处理/异常订单处理',
          route: '/payments/refunds',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.business,
      label: '预约/商城管理',
      route: '/services',
      children: [
        NavigationItem(
          icon: Icons.settings_applications,
          label: '服务类型配置',
          route: '/services/config',
        ),
        NavigationItem(
          icon: Icons.shopping_cart,
          label: '订单管理',
          route: '/services/orders',
        ),
        NavigationItem(
          icon: Icons.support_agent,
          label: '服务管理',
          route: '/services/providers',
        ),
        NavigationItem(
          icon: Icons.schedule,
          label: '排程管理',
          route: '/services/schedule',
        ),
        NavigationItem(
          icon: Icons.history,
          label: '预约记录',
          route: '/services/bookings',
        ),
      ],
    ),
    NavigationItem(
      icon: Icons.settings,
      label: '系统设置',
      route: '/settings',
      children: [
        NavigationItem(
          icon: Icons.admin_panel_settings,
          label: '权限管理',
          route: '/settings/permissions',
        ),
        NavigationItem(
          icon: Icons.history,
          label: '日志记录',
          route: '/settings/logs',
        ),
        NavigationItem(
          icon: Icons.backup,
          label: '数据备份与恢复/系统升级',
          route: '/settings/backup',
        ),
        NavigationItem(
          icon: Icons.api,
          label: 'API接口管理/第三方服务集成',
          route: '/settings/api',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // 侧边栏
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isCollapsed ? 70 : 280,
            child: _buildSidebar(),
          ),
          // 主内容区域
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo区域
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'AI虚拟女友',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '后台管理系统',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          
          // 导航菜单
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _navigationItems.map((item) => _buildNavigationItem(item)).toList(),
            ),
          ),
          
          // 折叠按钮
          Container(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isCollapsed = !_isCollapsed;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(NavigationItem item) {
    // 特殊处理菜单的激活状态
    bool isActive;
    if (item.route == '/dashboard' && item.children != null) {
      // 仪表板菜单：当前路由是/dashboard或任何子菜单路由时都激活
      isActive = widget.currentRoute == '/dashboard' || 
                 item.children!.any((child) => widget.currentRoute == child.route);
    } else if (item.children != null && item.children!.isNotEmpty) {
      // 有子菜单的情况：只有当前路由匹配子菜单时才激活，避免路径前缀冲突
      isActive = item.children!.any((child) => widget.currentRoute == child.route);
    } else {
      isActive = widget.currentRoute.startsWith(item.route);
    }
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    
    // 当侧边栏收起时，只显示图标，不显示下拉箭头
    if (_isCollapsed) {
      return ListTile(
        leading: Icon(
          item.icon,
          color: isActive ? AppColors.primary : AppTheme.textSecondaryColor,
          size: 20,
        ),
        title: const SizedBox.shrink(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => context.go(item.route),
      );
    }
    
    return ExpansionTile(
      key: PageStorageKey(item.route),
      leading: Icon(
        item.icon,
        color: isActive ? AppColors.primary : AppTheme.textSecondaryColor,
        size: 20,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppTheme.textPrimaryColor,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.only(left: 32),
      initiallyExpanded: (isActive && hasChildren) || item.keepExpanded,
      onExpansionChanged: hasChildren ? null : (_) {
        context.go(item.route);
      },
      children: hasChildren
          ? item.children!.map((child) => _buildChildNavigationItem(child)).toList()
          : [],
    );
  }

  Widget _buildChildNavigationItem(NavigationItem item) {
    final isActive = widget.currentRoute == item.route;
    
    return ListTile(
      leading: Icon(
        item.icon,
        color: isActive ? AppColors.primary : AppTheme.textSecondaryColor,
        size: 16,
      ),
      title: Text(
        item.label,
        style: TextStyle(
          color: isActive ? AppColors.primary : AppTheme.textPrimaryColor,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      dense: true,
      onTap: () => context.go(item.route),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // 面包屑导航
            Expanded(
              child: _buildBreadcrumb(),
            ),
            
            // 右侧操作区域
            Row(
              children: [
                // 通知图标
                IconButton(
                  onPressed: () {
                    // 显示通知
                  },
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // 用户菜单
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'profile':
                            // 个人资料
                            break;
                          case 'settings':
                            context.go('/settings');
                            break;
                          case 'logout':
                            _showLogoutDialog(authProvider);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 18),
                              SizedBox(width: 12),
                              Text('个人资料'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_outlined, size: 18),
                              SizedBox(width: 12),
                              Text('系统设置'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 18),
                              SizedBox(width: 12),
                              Text('退出登录'),
                            ],
                          ),
                        ),
                      ],
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              authProvider.username.isNotEmpty
                                  ? authProvider.username[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                authProvider.username,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '超级管理员',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    final routeParts = widget.currentRoute.split('/').where((part) => part.isNotEmpty).toList();
    
    return Row(
      children: [
        Icon(
          Icons.home_outlined,
          size: 16,
          color: AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 8),
        ...routeParts.asMap().entries.map((entry) {
          final index = entry.key;
          final part = entry.value;
          final isLast = index == routeParts.length - 1;
          
          String label;
          switch (part) {
            case 'dashboard':
              label = '仪表板';
              break;
            case 'users':
              label = '用户管理';
              break;
            case 'content':
              label = '内容管理';
              break;
            case 'characters':
              label = '角色库';
              break;
            case 'monitoring':
              label = '数据监控';
              break;
            case 'activities':
              label = '活动配置';
              break;
            case 'risk-control':
              label = '风控管理';
              break;
            case 'payments':
              label = '支付管理';
              break;
            case 'services':
              label = '服务管理';
              break;
            case 'settings':
              label = '系统设置';
              break;
            default:
              label = part;
          }
          
          return Row(
            children: [
              if (index > 0) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isLast ? AppTheme.textPrimaryColor : AppTheme.textSecondaryColor,
                  fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final String route;
  final List<NavigationItem>? children;
  final bool keepExpanded;

  NavigationItem({
    required this.icon,
    required this.label,
    required this.route,
    this.children,
    this.keepExpanded = false,
  });
}