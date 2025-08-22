import 'package:flutter/material.dart';
import '../widgets/admin_layout.dart';
import '../constants/app_theme.dart';

class RiskControlScreen extends StatefulWidget {
  const RiskControlScreen({super.key});

  @override
  State<RiskControlScreen> createState() => _RiskControlScreenState();
}

class _RiskControlScreenState extends State<RiskControlScreen> {
  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/risk-control',
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '风控管理',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '敏感词管理/违规检测、实时预警/人工干预、违规处理异常/名单机制',
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
                      Icons.security,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '风控管理功能开发中...',
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