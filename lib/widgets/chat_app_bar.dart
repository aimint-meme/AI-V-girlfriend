import 'package:flutter/material.dart';
import '../models/girlfriend_model.dart';
import '../screens/messages_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/character_settings_screen.dart';

class ChatAppBar extends StatelessWidget {
  final GirlfriendModel girlfriend;
  final bool isSpeaking;
  final VoidCallback onTtsToggle;
  final bool isTtsEnabled;

  const ChatAppBar({
    Key? key,
    required this.girlfriend,
    required this.isSpeaking,
    required this.onTtsToggle,
    required this.isTtsEnabled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.pink.shade400,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          // 导航到消息列表页面（索引1）
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(initialIndex: 1),
            ),
            (route) => false,
          );
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(girlfriend.avatarUrl),
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  girlfriend.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '在线',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isTtsEnabled ? Icons.volume_up : Icons.volume_off,
            color: Colors.white,
          ),
          onPressed: onTtsToggle,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'settings':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CharacterSettingsScreen(girlfriend: girlfriend),
                  ),
                );
                break;
              case 'info':
                _showCharacterInfo(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 20),
                  SizedBox(width: 8),
                  Text('角色设置'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('角色信息'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showCharacterInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(girlfriend.avatarUrl),
            ),
            const SizedBox(width: 12),
            Text(girlfriend.name),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('描述', girlfriend.description),
              if (girlfriend.background?.isNotEmpty == true)
                _buildInfoRow('背景', girlfriend.background!),
              if (girlfriend.introduction?.isNotEmpty == true)
                _buildInfoRow('简介', girlfriend.introduction!),
              _buildInfoRow('性格', girlfriend.personality),
              if (girlfriend.race?.isNotEmpty == true)
                _buildInfoRow('种族', girlfriend.race!),
              if (girlfriend.voiceType?.isNotEmpty == true)
                _buildInfoRow('声音类型', girlfriend.voiceType!),
              if (girlfriend.chatMode?.isNotEmpty == true)
                _buildInfoRow('聊天模式', girlfriend.chatMode!),
              _buildInfoRow('亲密度', '${girlfriend.intimacy}'),
              _buildInfoRow('创建时间', girlfriend.createdAt?.toString().substring(0, 19) ?? '未知'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}