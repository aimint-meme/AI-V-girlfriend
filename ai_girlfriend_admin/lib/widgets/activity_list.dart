import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_theme.dart';

class ActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final bool showAll;
  final VoidCallback? onViewAll;

  const ActivityList({
    super.key,
    required this.activities,
    this.showAll = false,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const EmptyActivityList();
    }

    final displayActivities = showAll ? activities : activities.take(5).toList();

    return Column(
      children: [
        ...displayActivities.map((activity) => ActivityItem(
          activity: activity,
        )).toList(),
        if (!showAll && activities.length > 5 && onViewAll != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onViewAll,
            child: Text('查看全部 (${activities.length})'),
          ),
        ],
      ],
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onTap;

  const ActivityItem({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = activity['timestamp'] as DateTime;
    final type = activity['type'] as String;
    final title = activity['title'] as String;
    final description = activity['description'] as String;
    final iconName = activity['icon'] as String;
    final colorName = activity['color'] as String;

    final icon = _getIconData(iconName);
    final color = _getColor(colorName);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // 内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTimestamp(timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'payment':
        return Icons.payment;
      case 'person':
        return Icons.person;
      case 'warning':
        return Icons.warning;
      case 'edit':
        return Icons.edit;
      case 'security':
        return Icons.security;
      case 'settings':
        return Icons.settings;
      case 'notification':
        return Icons.notifications;
      case 'error':
        return Icons.error;
      case 'check':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return AppColors.success;
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(timestamp);
    }
  }
}

class EmptyActivityList extends StatelessWidget {
  const EmptyActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无活动记录',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// 活动类型筛选器
class ActivityTypeFilter extends StatefulWidget {
  final List<String> types;
  final List<String> selectedTypes;
  final ValueChanged<List<String>>? onChanged;

  const ActivityTypeFilter({
    super.key,
    required this.types,
    required this.selectedTypes,
    this.onChanged,
  });

  @override
  State<ActivityTypeFilter> createState() => _ActivityTypeFilterState();
}

class _ActivityTypeFilterState extends State<ActivityTypeFilter> {
  late List<String> _selectedTypes;

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.types.map((type) {
        final isSelected = _selectedTypes.contains(type);
        return FilterChip(
          label: Text(_getTypeDisplayName(type)),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTypes.add(type);
              } else {
                _selectedTypes.remove(type);
              }
            });
            widget.onChanged?.call(_selectedTypes);
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'user_register':
        return '用户注册';
      case 'payment':
        return '支付';
      case 'character_create':
        return '角色创建';
      case 'system_alert':
        return '系统告警';
      case 'content_update':
        return '内容更新';
      case 'user_login':
        return '用户登录';
      case 'user_logout':
        return '用户登出';
      case 'admin_action':
        return '管理操作';
      default:
        return type;
    }
  }
}

// 活动详情对话框
class ActivityDetailDialog extends StatelessWidget {
  final Map<String, dynamic> activity;

  const ActivityDetailDialog({
    super.key,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = activity['timestamp'] as DateTime;
    final type = activity['type'] as String;
    final title = activity['title'] as String;
    final description = activity['description'] as String;
    final iconName = activity['icon'] as String;
    final colorName = activity['color'] as String;

    final icon = _getIconData(iconName);
    final color = _getColor(colorName);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '时间: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '类型: ${_getTypeDisplayName(type)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          // 可以添加更多详细信息
          if (activity.containsKey('details')) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '详细信息:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              activity['details'].toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'payment':
        return Icons.payment;
      case 'person':
        return Icons.person;
      case 'warning':
        return Icons.warning;
      case 'edit':
        return Icons.edit;
      case 'security':
        return Icons.security;
      case 'settings':
        return Icons.settings;
      case 'notification':
        return Icons.notifications;
      case 'error':
        return Icons.error;
      case 'check':
        return Icons.check_circle;
      case 'info':
        return Icons.info;
      default:
        return Icons.circle;
    }
  }

  Color _getColor(String colorName) {
    switch (colorName) {
      case 'success':
        return AppColors.success;
      case 'info':
        return AppColors.info;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      case 'primary':
        return AppColors.primary;
      case 'secondary':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'user_register':
        return '用户注册';
      case 'payment':
        return '支付';
      case 'character_create':
        return '角色创建';
      case 'system_alert':
        return '系统告警';
      case 'content_update':
        return '内容更新';
      case 'user_login':
        return '用户登录';
      case 'user_logout':
        return '用户登出';
      case 'admin_action':
        return '管理操作';
      default:
        return type;
    }
  }
}