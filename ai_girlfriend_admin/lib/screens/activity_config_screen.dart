import 'package:flutter/material.dart';
import '../widgets/admin_layout.dart';
import '../constants/app_theme.dart';

class ActivityConfigScreen extends StatefulWidget {
  const ActivityConfigScreen({super.key});

  @override
  State<ActivityConfigScreen> createState() => _ActivityConfigScreenState();
}

class _ActivityConfigScreenState extends State<ActivityConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/activities',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '活动配置',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '节日主题/皮肤上线、任务奖励配置/成就机制、商城商品管理/服务预约配置',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '活动配置功能开发中...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}