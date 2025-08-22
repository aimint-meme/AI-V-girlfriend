import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/girlfriend_provider.dart';
import '../widgets/custom_button.dart';
import 'knowledge_base_screen.dart';
import 'checkin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context);
    final currentGirlfriend = girlfriendProvider.currentGirlfriend;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: Colors.pink.shade400,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '用户信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.user?.displayName ?? '用户',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.user?.email ?? 'user@example.com',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '会员等级: ${authProvider.isMembershipActive ? '高级会员' : '普通会员'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: authProvider.isMembershipActive
                                          ? Colors.pink.shade400
                                          : Colors.grey.shade600,
                                      fontWeight: authProvider.isMembershipActive
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.monetization_on,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${authProvider.coinBalance}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.amber.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: '会员中心',
                            icon: Icons.workspace_premium,
                            color: Colors.purple.shade400,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/membership');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: '金币中心',
                            icon: Icons.monetization_on,
                            color: Colors.amber.shade700,
                            onPressed: () {
                              Navigator.of(context).pushNamed('/coins');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!authProvider.isMembershipActive)
                      CustomButton(
                        text: '升级到高级会员',
                        onPressed: () {
                          // Show premium upgrade dialog
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('升级到高级会员'),
                              content: const Text(
                                '高级会员可以享受以下特权:\n\n'  
                                '- 无限制聊天\n'
                                '- 更多AI虚拟女友选择\n'
                                '- 自定义AI虚拟女友\n'
                                '- 高级对话能力\n'
                                '- 语音和图片识别\n\n'
                                '月费: ¥28/月\n'
                                '年费: ¥298/年（优惠2个月）',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    // Implement payment logic here
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('支付功能即将上线，敬请期待！')),
                                    );
                                  },
                                  child: const Text('立即升级'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Current girlfriend section
            if (currentGirlfriend != null) ...[  
              const Text(
                '当前伴侣',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          currentGirlfriend.avatarUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 40),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentGirlfriend.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentGirlfriend.personality,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 16,
                                  color: Colors.pink.shade400,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '亲密度: ${currentGirlfriend.intimacy}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.pink.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat),
                        color: Colors.pink.shade400,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/chat');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Stats section
            const Text(
              '统计数据',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatItem(Icons.chat_bubble, '总聊天消息数', '${authProvider.stats.totalMessages}'),
                    const Divider(),
                    _buildStatItem(Icons.calendar_today, '使用天数', '${authProvider.stats.daysActive}'),
                    const Divider(),
                    _buildStatItem(Icons.favorite, '收到的喜欢', '${authProvider.stats.likesReceived}'),
                    const Divider(),
                    _buildStatItem(Icons.emoji_emotions, '情绪分析', '${authProvider.stats.moodScore}%积极'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Account actions
            const Text(
              '账户操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildActionItem(
                      Icons.event_available,
                      '每日签到',
                      '签到获得金币，连续签到更有奖励',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CheckinScreen(),
                          ),
                        );
                      },
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9D), Color(0xFFFF8A80)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '+2金币',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    _buildActionItem(
                      Icons.settings,
                      '设置',
                      '应用设置和偏好配置',
                      () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      Icons.library_books,
                      '知识库管理',
                      '管理AI对话知识库，提升回复质量',
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const KnowledgeBaseScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      Icons.edit,
                      '编辑个人资料',
                      '修改您的个人信息和偏好设置',
                      () {
                        // Navigate to edit profile
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('编辑个人资料功能即将上线，敬请期待！')),
                        );
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      Icons.lock,
                      '修改密码',
                      '更新您的账户密码',
                      () {
                        // Navigate to change password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('修改密码功能即将上线，敬请期待！')),
                        );
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      Icons.logout,
                      '退出登录',
                      '退出当前账户',
                      () async {
                        // Confirm logout
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('退出登录'),
                            content: const Text('确定要退出当前账户吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          setState(() {
                            _isLoading = true;
                          });
                          
                          try {
                            await authProvider.logout();
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          } catch (error) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('退出失败: ${error.toString()}')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 1), // 移除，使用主导航
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink.shade400, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String title, String subtitle, VoidCallback onTap, {Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}