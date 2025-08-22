import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/user_management_provider.dart';
import 'providers/content_analysis_provider.dart';
import 'providers/character_config_provider.dart';
import 'providers/monitoring_provider.dart';
import 'providers/theme_management_provider.dart';
import 'providers/content_moderation_provider.dart';
import 'providers/payment_provider.dart';
import 'providers/system_settings_provider.dart';
import 'providers/service_management_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user_management_screen.dart';
import 'screens/content_management_screen.dart';
import 'screens/character_management_screen.dart';
import 'screens/data_monitoring_screen.dart';
import 'screens/activity_config_screen.dart';
import 'screens/risk_control_screen.dart';
import 'screens/payment_management_screen.dart';
import 'screens/service_management_screen.dart';
import 'screens/system_settings_screen.dart';
import 'screens/users/user_data_management_screen.dart';
import 'screens/users/user_profile_analysis_screen.dart';
import 'screens/users/user_behavior_analysis_screen.dart';
import 'screens/content/content_analysis_screen.dart';
import 'screens/content/character_config_screen.dart';
import 'screens/characters/character_data_screen.dart';
import 'screens/characters/character_creation_screen.dart';
import 'screens/characters/character_ability_screen.dart';
import 'screens/settings/api_management_screen.dart';
import 'screens/settings/permissions_screen.dart';
import 'screens/settings/logs_screen.dart';
import 'screens/services/service_config_screen.dart';
import 'screens/services/order_management_screen.dart';
import 'screens/services/provider_management_screen.dart';
import 'screens/services/schedule_management_screen.dart';
import 'screens/services/booking_records_screen.dart';
import 'screens/monitoring/model_monitoring_screen.dart';
import 'screens/monitoring/business_data_screen.dart';
import 'screens/users/user_profile_detail_screen.dart';
import 'screens/content/prompt_template_screen.dart';
import 'screens/content/knowledge_base_screen.dart';
import 'screens/content/voice_library_screen.dart';
import 'screens/content/scene_library_screen.dart';
import 'screens/monitoring/realtime_monitoring_screen.dart';
import 'screens/activities/theme_management_screen.dart';
import 'screens/risk/content_moderation_screen.dart';
import 'screens/payments/payment_records_screen.dart';
import 'screens/placeholder_screen.dart';
import 'constants/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 关闭调试模式的溢出错误显示
  if (kDebugMode) {
    debugPaintSizeEnabled = false;
  }
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
        ChangeNotifierProvider(create: (_) => ContentAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => CharacterConfigProvider()),
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        ChangeNotifierProvider(create: (_) => ThemeManagementProvider()),
        ChangeNotifierProvider(create: (_) => ContentModerationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SystemSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ServiceManagementProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'AI虚拟女友后台管理系统',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            routerConfig: _createRouter(authProvider),
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/dashboard' : '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoginRoute = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoginRoute) {
          return '/login';
        }
        if (isAuthenticated && isLoginRoute) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/users/data',
          builder: (context, state) => const UserDataManagementScreen(),
        ),
        GoRoute(
          path: '/users/profile',
          builder: (context, state) => const UserProfileAnalysisScreen(),
        ),
        GoRoute(
          path: '/users/behavior',
          builder: (context, state) => const UserBehaviorAnalysisScreen(),
        ),
        GoRoute(
          path: '/users/profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return UserProfileDetailScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/content',
          builder: (context, state) => const ContentManagementScreen(),
        ),
        GoRoute(
          path: '/content/analysis',
          builder: (context, state) => const ContentAnalysisScreen(),
        ),
        GoRoute(
          path: '/content/character',
          builder: (context, state) => const CharacterConfigScreen(),
        ),
        GoRoute(
          path: '/content/templates',
          builder: (context, state) => const PromptTemplateScreen(),
        ),
        GoRoute(
          path: '/content/voice',
          builder: (context, state) => const VoiceLibraryScreen(),
        ),
        GoRoute(
          path: '/content/scene',
          builder: (context, state) => const SceneLibraryScreen(),
        ),
        GoRoute(
          path: '/content/knowledge',
          builder: (context, state) => const KnowledgeBaseScreen(),
        ),
        GoRoute(
          path: '/characters',
          builder: (context, state) => const CharacterManagementScreen(),
        ),
        GoRoute(
          path: '/characters/data',
          builder: (context, state) => const CharacterDataScreen(),
        ),
        GoRoute(
          path: '/characters/create',
          builder: (context, state) => const CharacterCreationScreen(),
        ),
        GoRoute(
          path: '/characters/config',
          builder: (context, state) => const CharacterAbilityScreen(),
        ),
        GoRoute(
          path: '/monitoring',
          builder: (context, state) => const DataMonitoringScreen(),
        ),
        GoRoute(
          path: '/monitoring/realtime',
          builder: (context, state) => const RealtimeMonitoringScreen(),
        ),
        GoRoute(
          path: '/monitoring/performance',
          builder: (context, state) => const PlaceholderScreen(
            title: '模型API性能监控',
            description: '监控模型API的性能指标和响应时间',
            currentRoute: '/monitoring/performance',
          ),
        ),
        GoRoute(
          path: '/monitoring/user-activity',
          builder: (context, state) => const PlaceholderScreen(
            title: '用户活跃度统计',
            description: '统计和分析用户活跃度数据',
            currentRoute: '/monitoring/user-activity',
          ),
        ),
        GoRoute(
          path: '/activities',
          builder: (context, state) => const ActivityConfigScreen(),
        ),
        GoRoute(
          path: '/activities/themes',
          builder: (context, state) => const ThemeManagementScreen(),
        ),
        GoRoute(
          path: '/risk-control',
          builder: (context, state) => const RiskControlScreen(),
        ),
        GoRoute(
          path: '/risk-control/content',
          builder: (context, state) => const ContentModerationScreen(),
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentManagementScreen(),
        ),
        GoRoute(
          path: '/payments/records',
          builder: (context, state) => const PaymentRecordsScreen(),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const ServiceManagementScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SystemSettingsScreen(),
        ),

        // 占位路由 - 内容管理
        GoRoute(
          path: '/content/library',
          builder: (context, state) => const PlaceholderScreen(
            title: '语音库管理/场景库管理',
            description: '管理语音资源和场景库内容',
            currentRoute: '/content/library',
          ),
        ),


        // 占位路由 - 数据监控
        GoRoute(
          path: '/monitoring/model',
          builder: (context, state) => const ModelMonitoringScreen(),
        ),
        GoRoute(
          path: '/monitoring/business',
          builder: (context, state) => const BusinessDataScreen(),
        ),
        // 占位路由 - 活动配置
        GoRoute(
          path: '/activities/rewards',
          builder: (context, state) => const PlaceholderScreen(
            title: '任务奖励配置/成就机制',
            description: '配置用户任务奖励和成就系统',
            currentRoute: '/activities/rewards',
          ),
        ),
        GoRoute(
          path: '/activities/commerce',
          builder: (context, state) => const PlaceholderScreen(
            title: '商城商品管理/服务预约配置',
            description: '管理商城商品和服务预约功能',
            currentRoute: '/activities/commerce',
          ),
        ),
        // 占位路由 - 风控管理
        GoRoute(
          path: '/risk-control/monitoring',
          builder: (context, state) => const PlaceholderScreen(
            title: '实时预警/人工干预',
            description: '实时风险监控和人工干预管理',
            currentRoute: '/risk-control/monitoring',
          ),
        ),
        GoRoute(
          path: '/risk-control/handling',
          builder: (context, state) => const PlaceholderScreen(
            title: '违规处理异常/名单机制',
            description: '违规处理流程和黑白名单管理',
            currentRoute: '/risk-control/handling',
          ),
        ),
        // 占位路由 - 支付管理
        GoRoute(
          path: '/payments/refunds',
          builder: (context, state) => const PlaceholderScreen(
            title: '退款处理/异常订单处理',
            description: '处理退款申请和异常订单',
            currentRoute: '/payments/refunds',
          ),
        ),
        // 占位路由 - 服务管理
        GoRoute(
          path: '/services/config',
          builder: (context, state) => const ServiceConfigScreen(),
        ),
        GoRoute(
          path: '/services/orders',
          builder: (context, state) => const OrderManagementScreen(),
        ),
        GoRoute(
          path: '/services/schedule',
          builder: (context, state) => const ScheduleManagementScreen(),
        ),
        GoRoute(
          path: '/services/bookings',
          builder: (context, state) => const BookingRecordsScreen(),
        ),
        GoRoute(
          path: '/services/providers',
          builder: (context, state) => const ProviderManagementScreen(),
        ),
        // 占位路由 - 系统设置
        GoRoute(
          path: '/settings/permissions',
          builder: (context, state) => const PermissionsScreen(),
        ),
        GoRoute(
          path: '/settings/backup',
          builder: (context, state) => const PlaceholderScreen(
            title: '数据备份与恢复/系统升级',
            description: '系统数据备份恢复和版本升级',
            currentRoute: '/settings/backup',
          ),
        ),
        GoRoute(
          path: '/settings/api',
          builder: (context, state) => const ApiManagementScreen(),
        ),
        GoRoute(
          path: '/settings/logs',
          builder: (context, state) => const LogsScreen(),
        ),
      ],
    );
  }
}
