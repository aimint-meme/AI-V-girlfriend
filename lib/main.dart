import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/girlfriend_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_girlfriend_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/invitation_screen.dart';
import 'screens/coin_screen.dart';
import 'screens/membership_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authProvider = AuthProvider();
            // 异步初始化邀请服务
            authProvider.initialize().catchError((error) {
              print('初始化邀请服务失败: $error');
            });
            return authProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => GirlfriendProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final chatProvider = ChatProvider();
            // 异步初始化RAG服务
            chatProvider.initializeServices().catchError((error) {
              print('初始化RAG服务失败: $error');
            });
            return chatProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MaterialApp(
        title: 'AI Virtual Girlfriend',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B9D),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Color(0xFF2D3748),
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B9D),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.3),
            color: const Color(0xFF2D2D2D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/create_girlfriend': (context) => const CreateGirlfriendScreen(),
          '/chat': (context) => const ChatScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/invitation': (context) => const InvitationScreen(),
          '/coin': (context) => const CoinScreen(),
          '/membership': (context) => const MembershipScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}