import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/knowledge_base_service.dart';
import 'knowledge_base_screen.dart';
import 'hot_topics_screen.dart';

class SimpleTestScreen extends StatefulWidget {
  const SimpleTestScreen({Key? key}) : super(key: key);

  @override
  State<SimpleTestScreen> createState() => _SimpleTestScreenState();
}

class _SimpleTestScreenState extends State<SimpleTestScreen> {
  List<KnowledgeEntry> _publicKnowledge = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPublicKnowledge();
  }
  
  Future<void> _loadPublicKnowledge() async {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (!chatProvider.isInitialized) {
        await chatProvider.initializeServices();
      }
      
      setState(() {
        _publicKnowledge = chatProvider.knowledgeBaseService
            .getAllKnowledge(includePublic: true)
            .where((entry) => entry.id.startsWith('public_'))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载公开知识库失败: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('秘地'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const KnowledgeBaseScreen(),
                ),
              );
            },
            tooltip: '知识库管理',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPublicKnowledge,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 页面标题和描述
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade100,
                            Colors.purple.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.explore,
                                size: 32,
                                color: Colors.pink.shade600,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '探索神秘秘地',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '发现精彩功能，探索无限可能，开启专属体验之旅',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 功能入口区域
                     Text(
                       '秘地功能',
                       style: TextStyle(
                         fontSize: 20,
                         fontWeight: FontWeight.bold,
                         color: Colors.grey.shade800,
                       ),
                     ),
                     const SizedBox(height: 16),
                     
                     // 功能入口网格
                     GridView.count(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       crossAxisCount: 2,
                       crossAxisSpacing: 12,
                       mainAxisSpacing: 12,
                       childAspectRatio: 1.1,
                       children: [
                         _buildFeatureCard(
                           icon: Icons.shopping_bag_outlined,
                           title: '商城',
                           subtitle: '精品商品等你来选购\n(正在开发中)',
                           color: Colors.red,
                           onTap: () => _showComingSoon('商城'),
                           isComingSoon: true,
                         ),
                         _buildFeatureCard(
                           icon: Icons.calendar_today_outlined,
                           title: '服务预约',
                           subtitle: '预约专属服务体验\n(正在开发中)',
                           color: Colors.teal,
                           onTap: () => _showComingSoon('服务预约'),
                           isComingSoon: true,
                         ),
                         _buildFeatureCard(
                           icon: Icons.library_books,
                           title: '知识库',
                           subtitle: '免费公开、付费、高阶\n多层次知识体系',
                           color: Colors.blue,
                           onTap: () => _navigateToKnowledgeCenter(),
                         ),
                         _buildFeatureCard(
                           icon: Icons.trending_up,
                           title: '热门话题',
                           subtitle: '发现热门讨论话题\n一键创建虚拟女友',
                           color: Colors.orange,
                           onTap: () => _navigateToHotTopics(),
                         ),
                       ],
                     ),
                    
                    const SizedBox(height: 32),
                    
                    // 快捷操作区域
                    Text(
                      '快捷操作',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.add_circle_outline,
                            title: '分享知识',
                            subtitle: '添加公开知识条目',
                            color: Colors.green,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const KnowledgeBaseScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.search,
                            title: '搜索知识',
                            subtitle: '查找感兴趣的内容',
                            color: Colors.blue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const KnowledgeBaseScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildKnowledgeCard(KnowledgeEntry knowledge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showKnowledgeDetail(knowledge);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      knowledge.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.public,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '公开',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                knowledge.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                knowledge.content.length > 100
                    ? '${knowledge.content.substring(0, 100)}...'
                    : knowledge.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: knowledge.tags.take(3).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard({
     required IconData icon,
     required String title,
     required String subtitle,
     required Color color,
     required VoidCallback onTap,
     bool isComingSoon = false,
   }) {
     return Card(
       elevation: 3,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
       ),
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(16),
         child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             gradient: LinearGradient(
               colors: [
                 color.withOpacity(0.1),
                 color.withOpacity(0.05),
               ],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
           ),
           child: Stack(
             children: [
               Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Container(
                     padding: const EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: color.withOpacity(0.2),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                       icon,
                       size: 28,
                       color: isComingSoon ? Colors.grey.shade500 : color,
                     ),
                   ),
                   const SizedBox(height: 12),
                   Text(
                     title,
                     style: TextStyle(
                       fontSize: 14,
                       fontWeight: FontWeight.bold,
                       color: isComingSoon ? Colors.grey.shade600 : null,
                     ),
                     textAlign: TextAlign.center,
                   ),
                   const SizedBox(height: 4),
                   Text(
                     subtitle,
                     style: TextStyle(
                       fontSize: 11,
                       color: Colors.grey.shade600,
                     ),
                     textAlign: TextAlign.center,
                     maxLines: 3,
                     overflow: TextOverflow.ellipsis,
                   ),
                 ],
               ),
               if (isComingSoon)
                 Positioned(
                   top: 8,
                   right: 8,
                   child: Container(
                     padding: const EdgeInsets.symmetric(
                       horizontal: 6,
                       vertical: 2,
                     ),
                     decoration: BoxDecoration(
                       color: Colors.orange.shade100,
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(
                         color: Colors.orange.shade300,
                         width: 1,
                       ),
                     ),
                     child: Text(
                       '开发中',
                       style: TextStyle(
                         fontSize: 8,
                         color: Colors.orange.shade700,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                   ),
                 ),
             ],
           ),
         ),
       ),
     );
   }
   
   Widget _buildActionCard({
     required IconData icon,
     required String title,
     required String subtitle,
     required Color color,
     required VoidCallback onTap,
   }) {
     return Card(
       elevation: 2,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(12),
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
             children: [
               Icon(
                 icon,
                 size: 32,
                 color: color,
               ),
               const SizedBox(height: 8),
               Text(
                 title,
                 style: const TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 4),
               Text(
                 subtitle,
                 style: TextStyle(
                   fontSize: 12,
                   color: Colors.grey.shade600,
                 ),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       ),
     );
   }
  
  void _navigateToKnowledgeCenter() {
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (context) => _KnowledgeCenterScreen(),
       ),
     );
   }
   
   void _navigateToPublicKnowledge() {
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (context) => _PublicKnowledgeScreen(publicKnowledge: _publicKnowledge),
       ),
     );
   }
   
   void _navigateToHotTopics() {
     Navigator.of(context).push(
       MaterialPageRoute(
         builder: (context) => const HotTopicsScreen(),
       ),
     );
   }
   
   void _showComingSoon(String feature) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Row(
           children: [
             Icon(Icons.info_outline, color: Colors.blue),
             const SizedBox(width: 8),
             Text('$feature'),
           ],
         ),
         content: Text('$feature功能即将推出，敬请期待！'),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('确定'),
           ),
         ],
       ),
     );
   }
   
   void _showKnowledgeDetail(KnowledgeEntry knowledge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(knowledge.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  knowledge.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                knowledge.content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '标签:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: knowledge.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
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
 }
 
 class _KnowledgeCenterScreen extends StatelessWidget {
   const _KnowledgeCenterScreen();
   
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('知识库中心'),
         backgroundColor: Colors.transparent,
         elevation: 0,
       ),
       body: Padding(
         padding: const EdgeInsets.all(16),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // 页面标题和描述
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(
                 gradient: LinearGradient(
                   colors: [
                     Colors.blue.shade100,
                     Colors.indigo.shade100,
                   ],
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                 ),
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.library_books,
                         size: 32,
                         color: Colors.blue.shade600,
                       ),
                       const SizedBox(width: 12),
                       Text(
                         '知识库中心',
                         style: TextStyle(
                           fontSize: 24,
                           fontWeight: FontWeight.bold,
                           color: Colors.blue.shade700,
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   Text(
                     '探索多层次知识体系，从免费公开到高阶专业内容',
                     style: TextStyle(
                       fontSize: 16,
                       color: Colors.grey.shade700,
                     ),
                   ),
                 ],
               ),
             ),
             const SizedBox(height: 32),
             
             // 知识库类型列表
             Expanded(
               child: ListView(
                 children: [
                   _buildKnowledgeTypeCard(
                     context,
                     icon: Icons.public,
                     title: '免费公开知识库',
                     subtitle: '社区分享的免费知识内容',
                     description: '包含用户分享的各类知识、经验和话题，完全免费开放',
                     color: Colors.green,
                     onTap: () {
                       Navigator.of(context).pop();
                       // 这里可以导航到原来的公开知识库页面
                     },
                   ),
                   const SizedBox(height: 16),
                   _buildKnowledgeTypeCard(
                     context,
                     icon: Icons.payment,
                     title: '付费知识库',
                     subtitle: '精选优质付费内容',
                     description: '专业作者创作的高质量知识内容，需要付费解锁',
                     color: Colors.orange,
                     onTap: () {
                       _showComingSoon(context, '付费知识库');
                     },
                     isComingSoon: true,
                   ),
                   const SizedBox(height: 16),
                   _buildKnowledgeTypeCard(
                     context,
                     icon: Icons.school,
                     title: '高阶知识库',
                     subtitle: '专业级深度学习内容',
                     description: '面向专业人士的高级知识体系，包含深度分析和专业指导',
                     color: Colors.purple,
                     onTap: () {
                       _showComingSoon(context, '高阶知识库');
                     },
                     isComingSoon: true,
                   ),
                 ],
               ),
             ),
           ],
         ),
       ),
     );
   }
   
   Widget _buildKnowledgeTypeCard(
     BuildContext context, {
     required IconData icon,
     required String title,
     required String subtitle,
     required String description,
     required Color color,
     required VoidCallback onTap,
     bool isComingSoon = false,
   }) {
     return Card(
       elevation: 4,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
       ),
       child: InkWell(
         onTap: onTap,
         borderRadius: BorderRadius.circular(16),
         child: Container(
           padding: const EdgeInsets.all(20),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             gradient: LinearGradient(
               colors: [
                 color.withOpacity(0.1),
                 color.withOpacity(0.05),
               ],
               begin: Alignment.topLeft,
               end: Alignment.bottomRight,
             ),
           ),
           child: Stack(
             children: [
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: color.withOpacity(0.2),
                       shape: BoxShape.circle,
                     ),
                     child: Icon(
                       icon,
                       size: 32,
                       color: isComingSoon ? Colors.grey.shade500 : color,
                     ),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           title,
                           style: TextStyle(
                             fontSize: 18,
                             fontWeight: FontWeight.bold,
                             color: isComingSoon ? Colors.grey.shade600 : null,
                           ),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           subtitle,
                           style: TextStyle(
                             fontSize: 14,
                             color: Colors.grey.shade600,
                             fontWeight: FontWeight.w500,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           description,
                           style: TextStyle(
                             fontSize: 13,
                             color: Colors.grey.shade600,
                             height: 1.4,
                           ),
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
               if (isComingSoon)
                 Positioned(
                   top: 0,
                   right: 0,
                   child: Container(
                     padding: const EdgeInsets.symmetric(
                       horizontal: 8,
                       vertical: 4,
                     ),
                     decoration: BoxDecoration(
                       color: Colors.orange.shade100,
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(
                         color: Colors.orange.shade300,
                         width: 1,
                       ),
                     ),
                     child: Text(
                       '即将推出',
                       style: TextStyle(
                         fontSize: 10,
                         color: Colors.orange.shade700,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                   ),
                 ),
             ],
           ),
         ),
       ),
     );
   }
   
   void _showComingSoon(BuildContext context, String feature) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Row(
           children: [
             Icon(Icons.info_outline, color: Colors.blue),
             const SizedBox(width: 8),
             Text(feature),
           ],
         ),
         content: Text('${feature}功能即将推出，敬请期待！'),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(),
             child: const Text('确定'),
           ),
         ],
       ),
     );
   }
 }
 
 class _PublicKnowledgeScreen extends StatefulWidget {
   final List<KnowledgeEntry> publicKnowledge;
   
   const _PublicKnowledgeScreen({required this.publicKnowledge});
   
   @override
   State<_PublicKnowledgeScreen> createState() => _PublicKnowledgeScreenState();
 }
 
 class _PublicKnowledgeScreenState extends State<_PublicKnowledgeScreen> {
   List<KnowledgeEntry> _filteredKnowledge = [];
   final TextEditingController _searchController = TextEditingController();
   String _selectedCategory = '全部';
   
   @override
   void initState() {
     super.initState();
     _filteredKnowledge = widget.publicKnowledge;
   }
   
   @override
   void dispose() {
     _searchController.dispose();
     super.dispose();
   }
   
   void _filterKnowledge() {
     setState(() {
       _filteredKnowledge = widget.publicKnowledge.where((knowledge) {
         final matchesSearch = _searchController.text.isEmpty ||
             knowledge.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
             knowledge.content.toLowerCase().contains(_searchController.text.toLowerCase());
         
         final matchesCategory = _selectedCategory == '全部' || knowledge.category == _selectedCategory;
         
         return matchesSearch && matchesCategory;
       }).toList();
     });
   }
   
   @override
   Widget build(BuildContext context) {
     final categories = ['全部', ...widget.publicKnowledge.map((k) => k.category).toSet().toList()];
     
     return Scaffold(
       appBar: AppBar(
         title: const Text('公开知识库'),
         backgroundColor: Colors.transparent,
         elevation: 0,
         actions: [
           IconButton(
             icon: const Icon(Icons.add),
             onPressed: () {
               Navigator.of(context).push(
                 MaterialPageRoute(
                   builder: (context) => const KnowledgeBaseScreen(),
                 ),
               );
             },
             tooltip: '添加知识',
           ),
         ],
       ),
       body: Column(
         children: [
           // 搜索和筛选区域
           Container(
             padding: const EdgeInsets.all(16),
             child: Column(
               children: [
                 // 搜索框
                 TextField(
                   controller: _searchController,
                   decoration: InputDecoration(
                     hintText: '搜索公开知识...',
                     prefixIcon: const Icon(Icons.search),
                     suffixIcon: _searchController.text.isNotEmpty
                         ? IconButton(
                             icon: const Icon(Icons.clear),
                             onPressed: () {
                               _searchController.clear();
                               _filterKnowledge();
                             },
                           )
                         : null,
                     border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(12),
                     ),
                   ),
                   onChanged: (_) => _filterKnowledge(),
                 ),
                 const SizedBox(height: 12),
                 // 类别筛选
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Row(
                     children: categories.map((category) {
                       final isSelected = category == _selectedCategory;
                       return Padding(
                         padding: const EdgeInsets.only(right: 8),
                         child: FilterChip(
                           label: Text(category),
                           selected: isSelected,
                           onSelected: (selected) {
                             setState(() {
                               _selectedCategory = category;
                             });
                             _filterKnowledge();
                           },
                           backgroundColor: Colors.grey.shade100,
                           selectedColor: Colors.blue.shade100,
                           checkmarkColor: Colors.blue.shade700,
                         ),
                       );
                     }).toList(),
                   ),
                 ),
               ],
             ),
           ),
           // 知识列表
           Expanded(
             child: _filteredKnowledge.isEmpty
                 ? Center(
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Icon(
                           Icons.search_off,
                           size: 64,
                           color: Colors.grey.shade400,
                         ),
                         const SizedBox(height: 16),
                         Text(
                           widget.publicKnowledge.isEmpty ? '暂无公开知识' : '没有找到相关内容',
                           style: TextStyle(
                             fontSize: 18,
                             color: Colors.grey.shade600,
                           ),
                         ),
                         const SizedBox(height: 8),
                         Text(
                           widget.publicKnowledge.isEmpty 
                               ? '成为第一个分享知识的人吧！' 
                               : '尝试调整搜索条件',
                           style: TextStyle(
                             fontSize: 14,
                             color: Colors.grey.shade500,
                           ),
                         ),
                         if (widget.publicKnowledge.isEmpty) ...[
                           const SizedBox(height: 24),
                           ElevatedButton.icon(
                             onPressed: () {
                               Navigator.of(context).push(
                                 MaterialPageRoute(
                                   builder: (context) => const KnowledgeBaseScreen(),
                                 ),
                               );
                             },
                             icon: const Icon(Icons.add),
                             label: const Text('分享知识'),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.blue,
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
                       ],
                     ),
                   )
                 : ListView.builder(
                     padding: const EdgeInsets.symmetric(horizontal: 16),
                     itemCount: _filteredKnowledge.length,
                     itemBuilder: (context, index) {
                       final knowledge = _filteredKnowledge[index];
                       return _buildKnowledgeCard(knowledge);
                     },
                   ),
           ),
         ],
       ),
     );
   }
   
   Widget _buildKnowledgeCard(KnowledgeEntry knowledge) {
     return Card(
       margin: const EdgeInsets.only(bottom: 12),
       elevation: 2,
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(12),
       ),
       child: InkWell(
         onTap: () => _showKnowledgeDetail(knowledge),
         borderRadius: BorderRadius.circular(12),
         child: Padding(
           padding: const EdgeInsets.all(16),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(
                       horizontal: 8,
                       vertical: 4,
                     ),
                     decoration: BoxDecoration(
                       color: Colors.blue.shade100,
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Text(
                       knowledge.category,
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.blue.shade700,
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                   const Spacer(),
                   Icon(
                     Icons.public,
                     size: 16,
                     color: Colors.green.shade600,
                   ),
                   const SizedBox(width: 4),
                   Text(
                     '公开',
                     style: TextStyle(
                       fontSize: 12,
                       color: Colors.green.shade600,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 12),
               Text(
                 knowledge.title,
                 style: const TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               Text(
                 knowledge.content.length > 100
                     ? '${knowledge.content.substring(0, 100)}...'
                     : knowledge.content,
                 style: TextStyle(
                   fontSize: 14,
                   color: Colors.grey.shade600,
                   height: 1.4,
                 ),
               ),
               const SizedBox(height: 12),
               Wrap(
                 spacing: 8,
                 children: knowledge.tags.take(3).map((tag) {
                   return Container(
                     padding: const EdgeInsets.symmetric(
                       horizontal: 8,
                       vertical: 2,
                     ),
                     decoration: BoxDecoration(
                       color: Colors.orange.shade100,
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       tag,
                       style: TextStyle(
                         fontSize: 11,
                         color: Colors.orange.shade700,
                       ),
                     ),
                   );
                 }).toList(),
               ),
             ],
           ),
         ),
       ),
     );
   }
   
   void _showKnowledgeDetail(KnowledgeEntry knowledge) {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: Text(knowledge.title),
         content: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               Container(
                 padding: const EdgeInsets.symmetric(
                   horizontal: 8,
                   vertical: 4,
                 ),
                 decoration: BoxDecoration(
                   color: Colors.blue.shade100,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: Text(
                   knowledge.category,
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.blue.shade700,
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ),
               const SizedBox(height: 16),
               Text(
                 knowledge.content,
                 style: const TextStyle(
                   fontSize: 14,
                   height: 1.5,
                 ),
               ),
               const SizedBox(height: 16),
               const Text(
                 '标签:',
                 style: TextStyle(
                   fontSize: 14,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               Wrap(
                 spacing: 8,
                 children: knowledge.tags.map((tag) {
                   return Container(
                     padding: const EdgeInsets.symmetric(
                       horizontal: 8,
                       vertical: 4,
                     ),
                     decoration: BoxDecoration(
                       color: Colors.orange.shade100,
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       tag,
                       style: TextStyle(
                         fontSize: 12,
                         color: Colors.orange.shade700,
                       ),
                     ),
                   );
                 }).toList(),
               ),
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
 }