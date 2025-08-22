import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/girlfriend_provider.dart';
import '../providers/chat_provider.dart';
import '../models/girlfriend_model.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: '聊天记录',
            ),
            Tab(
              icon: Icon(Icons.person_add),
              text: '我创建的',
            ),
          ],
          indicatorColor: const Color(0xFFFF6B9D),
          labelColor: const Color(0xFFFF6B9D),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatHistoryTab(),
          _buildCreatedGirlfriendsTab(),
        ],
      ),
    );
  }
  
  Widget _buildChatHistoryTab() {
    return Consumer<GirlfriendProvider>(
      builder: (context, girlfriendProvider, child) {
        // 获取所有有聊天记录的女友
        final chatHistoryGirlfriends = girlfriendProvider.girlfriends
            .where((gf) => gf.lastMessageTime != null)
            .toList();
        
        // 按最后消息时间排序
        chatHistoryGirlfriends.sort((a, b) => 
            (b.lastMessageTime ?? DateTime(1970)).compareTo(
                a.lastMessageTime ?? DateTime(1970)));
        
        if (chatHistoryGirlfriends.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '还没有聊天记录',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '去首页选择一个AI女友开始聊天吧！',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chatHistoryGirlfriends.length,
          itemBuilder: (context, index) {
            final girlfriend = chatHistoryGirlfriends[index];
            return _buildMessageCard(girlfriend, true);
          },
        );
      },
    );
  }
  
  Widget _buildCreatedGirlfriendsTab() {
    return Consumer<GirlfriendProvider>(
      builder: (context, girlfriendProvider, child) {
        // 获取用户创建的女友（假设有isCreatedByUser字段）
        final createdGirlfriends = girlfriendProvider.girlfriends
            .where((gf) => gf.isCreatedByUser ?? false)
            .toList();
        
        // 按创建时间排序
        createdGirlfriends.sort((a, b) => 
            (b.createdAt ?? DateTime(1970)).compareTo(
                a.createdAt ?? DateTime(1970)));
        
        if (createdGirlfriends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  '还没有创建角色',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '点击下方按钮创建你的专属AI女友',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create_girlfriend');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('创建角色'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B9D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // 创建新角色按钮
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/create_girlfriend');
                },
                icon: const Icon(Icons.add),
                label: const Text('创建新角色'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B9D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // 已创建的角色列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: createdGirlfriends.length,
                itemBuilder: (context, index) {
                  final girlfriend = createdGirlfriends[index];
                  return _buildMessageCard(girlfriend, false);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildMessageCard(GirlfriendModel girlfriend, bool showLastMessage) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // 设置当前女友并跳转到聊天界面
          final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
          girlfriendProvider.setCurrentGirlfriend(girlfriend);
          
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 头像
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      girlfriend.avatarUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // 在线状态指示器
                  if (girlfriend.isOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 信息区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 名字和时间
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          girlfriend.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (showLastMessage && girlfriend.lastMessageTime != null)
                          Text(
                            _formatTime(girlfriend.lastMessageTime!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 人格标签
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        girlfriend.personality,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 最后一条消息或描述
                    if (showLastMessage && girlfriend.lastMessage != null)
                      Text(
                        girlfriend.lastMessage!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else if (!showLastMessage)
                      Text(
                        girlfriend.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    // 亲密度显示
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: Colors.pink[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '亲密度: ${girlfriend.intimacy}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.pink[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 亲密度进度条
                        Expanded(
                          child: LinearProgressIndicator(
                            value: girlfriend.intimacy / 100.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.pink[400]!,
                            ),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${girlfriend.intimacy}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 右侧箭头
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}