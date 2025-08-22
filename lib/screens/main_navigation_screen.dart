import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import 'home_screen.dart';
import 'simple_test_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20), // Reduced padding for better spacing
          child: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateToChat: () {
                setState(() {
                  _currentIndex = 1; // Switch to messages tab
                });
              }),
              const MessagesScreen(),
              const SimpleTestScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(ResponsiveUtils.isMobile(context) ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveUtils.isMobile(context) ? 20 : 25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(ResponsiveUtils.isMobile(context) ? 20 : 25),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: const Color(0xFFFF6B9D),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 24),
                activeIcon: Icon(Icons.home_rounded, size: 26),
                label: '海选',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_rounded, size: 24),
                activeIcon: Icon(Icons.message_rounded, size: 26),
                label: '骚话',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded, size: 24),
                activeIcon: Icon(Icons.explore_rounded, size: 26),
                label: '秘地',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 24),
                activeIcon: Icon(Icons.person_rounded, size: 26),
                label: '个人中心',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0 ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed('/create_girlfriend');
          },
          backgroundColor: const Color(0xFFFF6B9D),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            '创建',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ) : null,
    );
  }
}