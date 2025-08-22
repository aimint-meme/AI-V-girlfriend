import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: null,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFF6B9D).withValues(alpha: 0.2),
                        const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Profile section
                  _buildProfileSection(context),
                  const SizedBox(height: 24),
                  
                  // Settings sections
                  _buildSettingsSection(
                    context,
                    '外观设置',
                    Icons.palette_outlined,
                    [
                      _buildModernSwitchTile(
                        context,
                        '深色模式',
                        '切换应用的深色/浅色主题',
                        Icons.dark_mode_outlined,
                        themeProvider.themeMode == ThemeMode.dark,
                        (value) {
                          themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                        },
                      ),
                      _buildModernSwitchTile(
                        context,
                        '跟随系统',
                        '使用系统的深色/浅色主题设置',
                        Icons.settings_system_daydream_outlined,
                        themeProvider.themeMode == ThemeMode.system,
                        (value) {
                          if (value) {
                            themeProvider.setThemeMode(ThemeMode.system);
                          } else {
                            themeProvider.setThemeMode(ThemeMode.light);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    context,
                    '聊天设置',
                    Icons.chat_bubble_outline,
                    [
                      _buildModernSwitchTile(
                        context,
                        '文字转语音',
                        '将AI回复转换为语音',
                        Icons.record_voice_over_outlined,
                        chatProvider.isTtsEnabled,
                        (value) {
                          chatProvider.setTtsEnabled(value);
                        },
                      ),
                      _buildModernSwitchTile(
                        context,
                        '语音输入',
                        '使用语音输入代替文字输入',
                        Icons.mic_outlined,
                        chatProvider.isVoiceInputEnabled,
                        (value) {
                          chatProvider.setVoiceInputEnabled(value);
                        },
                      ),
                      _buildModernSwitchTile(
                        context,
                        '自动回复',
                        '当你一段时间不活跃时，AI会主动发起对话',
                        Icons.auto_awesome_outlined,
                        chatProvider.isAutoReplyEnabled,
                        (value) {
                          chatProvider.setAutoReplyEnabled(value);
                        },
                      ),
                      _buildModernSliderTile(
                        context,
                        '回复速度',
                        '调整AI回复的速度',
                        Icons.speed_outlined,
                        chatProvider.replySpeed,
                        (value) {
                          chatProvider.setReplySpeed(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    context,
                    '通知设置',
                    Icons.notifications_outlined,
                    [
                      _buildModernSwitchTile(
                        context,
                        '推送通知',
                        '接收来自AI的消息通知',
                        Icons.notifications_active_outlined,
                        chatProvider.isPushNotificationEnabled,
                        (value) {
                          chatProvider.setPushNotificationEnabled(value);
                        },
                      ),
                      _buildModernSwitchTile(
                        context,
                        '声音',
                        '收到消息时播放声音',
                        Icons.volume_up_outlined,
                        chatProvider.isNotificationSoundEnabled,
                        (value) {
                          chatProvider.setNotificationSoundEnabled(value);
                        },
                      ),
                      _buildModernSwitchTile(
                        context,
                        '振动',
                        '收到消息时振动',
                        Icons.vibration_outlined,
                        chatProvider.isNotificationVibrationEnabled,
                        (value) {
                          chatProvider.setNotificationVibrationEnabled(value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    context,
                    '账户功能',
                    Icons.account_circle_outlined,
                    [
                      _buildModernActionTile(
                        context,
                        '邀请好友',
                        '邀请好友注册，获得丰厚奖励',
                        Icons.share_outlined,
                        () {
                          Navigator.of(context).pushNamed('/invitation');
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
                            '赚金币',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _buildModernActionTile(
                        context,
                        '金币中心',
                        '购买金币，享受更多服务',
                        Icons.monetization_on_outlined,
                        () {
                          Navigator.of(context).pushNamed('/coin');
                        },
                      ),
                      _buildModernActionTile(
                        context,
                        '会员中心',
                        '开通会员，解锁专属特权',
                        Icons.star_outline,
                        () {
                          Navigator.of(context).pushNamed('/membership');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    context,
                    '隐私设置',
                    Icons.privacy_tip_outlined,
                    [
                      _buildModernSwitchTile(
                        context,
                        '数据收集',
                        '允许收集匿名使用数据以改进服务',
                        Icons.analytics_outlined,
                        authProvider.isDataCollectionEnabled,
                        (value) {
                          authProvider.setDataCollectionEnabled(value);
                        },
                      ),
                      _buildModernActionTile(
                        context,
                        '清除聊天记录',
                        '删除所有聊天历史',
                        Icons.delete_outline,
                        () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('清除聊天记录'),
                              content: const Text('确定要删除所有聊天记录吗？此操作无法撤销。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    chatProvider.clearAllMessages();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('聊天记录已清除')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('确定'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildModernActionTile(
                        context,
                        '隐私政策',
                        '查看我们如何处理您的数据',
                        Icons.policy_outlined,
                        () {
                          _showPrivacyPolicy(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildSettingsSection(
                    context,
                    '关于应用',
                    Icons.info_outline,
                    [
                      _buildModernInfoTile(
                        context,
                        '版本',
                        '1.0.0',
                        Icons.system_update_outlined,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '最新版本',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      _buildModernActionTile(
                        context,
                        '反馈问题',
                        '帮助我们改进应用',
                        Icons.feedback_outlined,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('反馈功能即将上线，敬请期待！')),
                          );
                        },
                      ),
                      _buildModernActionTile(
                        context,
                        '评分',
                        '如果您喜欢我们的应用，请给我们评分',
                        Icons.star_outline,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('评分功能即将上线，敬请期待！')),
                          );
                        },
                      ),
                      _buildModernActionTile(
                        context,
                        '分享应用',
                        '与朋友分享这个应用',
                        Icons.share_outlined,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('分享功能即将上线，敬请期待！')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B9D).withValues(alpha: 0.1),
            const Color(0xFF6C5CE7).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFC44569)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '用户',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '管理您的个人设置和偏好',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: Color(0xFFFF6B9D),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF6B9D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          ...children.map((child) => Column(
            children: [
              child,
              if (child != children.last)
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: 20,
                  endIndent: 20,
                ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value
                  ? const Color(0xFFFF6B9D).withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? const Color(0xFFFF6B9D) : Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFFF6B9D),
              activeTrackColor: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade600,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing else Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoTile(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildModernSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B9D),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFFF6B9D),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: const Color(0xFFFF6B9D),
              overlayColor: const Color(0xFFFF6B9D).withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: value < 0.3 ? '慢' : (value > 0.7 ? '快' : '中'),
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '慢',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '快',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('隐私政策'),
        content: SingleChildScrollView(
          child: Text(
            '隐私政策\n\n'
            '最后更新日期：2023年12月1日\n\n'
            '本隐私政策描述了我们在您使用AI虚拟女友应用时收集、使用和披露您的个人信息的政策和程序。\n\n'
            '我们收集的信息\n'
            '- 账户信息：当您创建账户时，我们会收集您的电子邮件地址和密码。\n'
            '- 聊天内容：我们会存储您与AI虚拟女友的对话内容，以提供更好的服务。\n'
            '- 使用数据：我们收集有关您如何使用应用的数据，例如功能使用频率和会话时长。\n\n'
            '信息使用\n'
            '我们使用收集的信息来：\n'
            '- 提供、维护和改进我们的服务\n'
            '- 个性化您的体验\n'
            '- 开发新功能\n\n'
            '信息共享\n'
            '我们不会出售您的个人信息。我们可能在以下情况下共享您的信息：\n'
            '- 经您同意\n'
            '- 遵守法律要求\n'
            '- 保护我们的权利和财产\n\n'
            '数据安全\n'
            '我们采取合理措施保护您的个人信息不被未经授权的访问或披露。\n\n'
            '您的选择\n'
            '您可以：\n'
            '- 随时更新或删除您的账户信息\n'
            '- 选择不参与数据收集\n'
            '- 清除聊天历史\n\n'
            '联系我们\n'
            '如果您对本隐私政策有任何疑问，请联系我们：support@aivirtualgirlfriend.com',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}