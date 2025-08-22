import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../services/knowledge_base_service.dart';
import '../services/knowledge_unlock_service.dart';
import '../models/knowledge_payment_model.dart';
import '../widgets/knowledge_payment_dialog.dart';
import '../widgets/advanced_tags_selection_dialog.dart';
import 'package:uuid/uuid.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<KnowledgeEntry> _filteredEntries = [];
  List<KnowledgeEntry> _allEntries = [];
  String _selectedCategory = '全部';
  bool _showPublicOnly = false;
  
  // 付费体系相关
  final KnowledgeUnlockService _unlockService = KnowledgeUnlockService();
  int _userCoins = 10000; // 模拟用户金币
  bool _isUnlockServiceInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    await _unlockService.initialize();
    setState(() {
      _isUnlockServiceInitialized = true;
    });
    await _loadKnowledgeBase();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadKnowledgeBase() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (!chatProvider.isInitialized) {
      await chatProvider.initializeServices();
    }
    
    final entries = chatProvider.knowledgeBaseService.getAllKnowledge();
    setState(() {
      _allEntries = entries;
      _filteredEntries = entries;
    });
  }
  
  void _filterEntries() {
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        final matchesSearch = entry.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            entry.content.toLowerCase().contains(_searchController.text.toLowerCase());
        final matchesCategory = _selectedCategory == '全部' || entry.category == _selectedCategory;
        final matchesPublic = !_showPublicOnly || entry.type == KnowledgeType.free;
        
        return matchesSearch && matchesCategory && matchesPublic;
      }).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('知识库'),
        backgroundColor: Colors.blue.shade600,
        actions: [
          // 金币显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_userCoins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
          ),
          // 高阶标签管理
          if (_isUnlockServiceInitialized && _unlockService.isMembershipValid)
            IconButton(
              onPressed: _showAdvancedTagsDialog,
              icon: const Icon(Icons.label_outline),
              tooltip: '高阶内容标签',
            ),
          // 会员状态
          if (_isUnlockServiceInitialized)
            PopupMenuButton<String>(
              icon: Icon(
                _unlockService.isMembershipValid 
                    ? Icons.workspace_premium 
                    : Icons.person_outline,
                color: _unlockService.isMembershipValid 
                    ? Colors.amber.shade300 
                    : Colors.white70,
              ),
              tooltip: '会员中心',
              onSelected: (value) {
                if (value == 'membership') {
                  _showMembershipDialog();
                } else if (value == 'statistics') {
                  _showUnlockStatistics();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'membership',
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium),
                      const SizedBox(width: 8),
                      Text(_unlockService.isMembershipValid ? '会员管理' : '购买会员'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'statistics',
                  child: Row(
                    children: [
                      Icon(Icons.analytics),
                      SizedBox(width: 8),
                      Text('解锁统计'),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '浏览', icon: Icon(Icons.library_books)),
            Tab(text: '添加', icon: Icon(Icons.add)),
            Tab(text: '统计', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(),
          _buildAddTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }
  
  Widget _buildBrowseTab() {
    return Column(
      children: [
        // 搜索和筛选
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索知识条目...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => _filterEntries(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: '分类',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['全部', '学习方法', '心理健康', '人际关系', '职业发展']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        _filterEntries();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilterChip(
                    label: const Text('仅公开'),
                    selected: _showPublicOnly,
                    onSelected: (selected) {
                      setState(() {
                        _showPublicOnly = selected;
                      });
                      _filterEntries();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        // 知识条目列表
        Expanded(
          child: _filteredEntries.isEmpty
              ? const Center(
                  child: Text(
                    '暂无知识条目',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredEntries.length,
                  itemBuilder: (context, index) {
                    final entry = _filteredEntries[index];
                    return _buildKnowledgeCard(entry);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildKnowledgeCard(KnowledgeEntry entry) {
    final isUnlocked = _isUnlockServiceInitialized ? _unlockService.isKnowledgeUnlocked(entry.id) : entry.isUnlocked;
    final canAccess = _isUnlockServiceInitialized ? entry.canUserAccess(
      isMember: _unlockService.isMembershipValid,
      membershipType: _unlockService.currentMembershipType,
      unlockedTags: _unlockService.advancedContentUnlock.unlockedTags,
      purchasedKnowledgeIds: {},
    ) : entry.isUnlocked;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: canAccess ? () => _showKnowledgeDetail(entry) : () => _showUnlockDialog(entry),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: canAccess ? Colors.black : Colors.grey.shade600,
                      ),
                    ),
                  ),
                  _buildPaymentTierChip(entry.paymentTier),
                  if (!canAccess) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: Colors.orange.shade600,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                canAccess 
                    ? (entry.content.length > 100 ? '${entry.content.substring(0, 100)}...' : entry.content)
                    : entry.previewContent,
                style: TextStyle(
                  color: canAccess ? Colors.grey.shade700 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ...entry.tags.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue.shade50,
                  )).toList(),
                  if (entry.requiredTags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.label_outline,
                            size: 12,
                            color: Colors.purple.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '需要${entry.requiredTags.length}个高阶标签',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    entry.category,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  if (!canAccess)
                    TextButton.icon(
                      onPressed: () => _showUnlockDialog(entry),
                      icon: const Icon(Icons.lock_open, size: 16),
                      label: Text(
                        entry.unlockStatusText,
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    )
                  else
                    Text(
                      '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPaymentTierChip(KnowledgePaymentTier tier) {
    Color color;
    String label;
    
    switch (tier) {
      case KnowledgePaymentTier.free:
        color = Colors.green;
        label = '免费';
        break;
      case KnowledgePaymentTier.premium:
        color = Colors.blue;
        label = '付费';
        break;
      case KnowledgePaymentTier.advanced:
        color = Colors.purple;
        label = '高阶';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
  
  void _showUnlockDialog(KnowledgeEntry entry) {
    showDialog(
      context: context,
      builder: (context) => KnowledgePaymentDialog(
        knowledgeEntry: entry,
        userCoins: _userCoins,
        onUnlockSuccess: () {
          setState(() {
            // 刷新界面
          });
        },
      ),
    );
  }
  
  void _showKnowledgeDetail(KnowledgeEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '标签:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: entry.tags.map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Colors.blue.shade50,
                  )).toList(),
                ),
              ],
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
   
   void _showAdvancedTagsDialog() {
     showDialog(
       context: context,
       builder: (context) => AdvancedTagsSelectionDialog(
         onSelectionChanged: () {
           setState(() {
             // 刷新界面以反映标签变化
           });
         },
       ),
     );
   }
   
   void _showMembershipDialog() {
     showDialog(
       context: context,
       builder: (context) => MembershipPurchaseDialog(
         userCoins: _userCoins,
         onPurchaseSuccess: () {
           setState(() {
             // 刷新界面
           });
         },
       ),
     );
   }
   
   void _showUnlockStatistics() {
     final statistics = _unlockService.getUnlockStatistics();
     
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('解锁统计'),
         content: SingleChildScrollView(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               _buildStatRow('已解锁知识库', '${statistics['totalUnlocked']}个'),
               _buildStatRow('付费解锁', '${statistics['paidUnlocked']}个'),
               _buildStatRow('会员解锁', '${statistics['membershipUnlocked']}个'),
               _buildStatRow('总花费', '${statistics['totalSpent']}金币'),
               const Divider(),
               _buildStatRow('会员类型', statistics['membershipType']),
               _buildStatRow('会员状态', statistics['membershipValid'] ? '有效' : '无效'),
               if (statistics['membershipExpiry'] != null)
                 _buildStatRow('会员到期', statistics['membershipExpiry']),
               const Divider(),
               _buildStatRow('高阶标签', '${statistics['unlockedAdvancedTags']}个'),
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
   
   Widget _buildStatRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 4),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(
             label,
             style: const TextStyle(fontWeight: FontWeight.w500),
           ),
           Text(
             value,
             style: TextStyle(color: Colors.grey.shade700),
           ),
         ],
       ),
     );
   }
   
   Widget _buildTypeChip(KnowledgeType type) {
    Color color;
    String label;
    
    switch (type) {
      case KnowledgeType.free:
        color = Colors.green;
        label = '免费';
        break;
      case KnowledgeType.premium:
        color = Colors.orange;
        label = '付费';
        break;
      case KnowledgeType.advanced:
        color = Colors.purple;
        label = '高级';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildAddTab() {
    return const _AddKnowledgeForm();
  }
  
  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '知识库统计',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('总条目', '${_allEntries.length}', Icons.library_books)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('免费条目', '${_allEntries.where((e) => e.type == KnowledgeType.free).length}', Icons.free_breakfast)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('付费条目', '${_allEntries.where((e) => e.type == KnowledgeType.premium).length}', Icons.payment)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('高级条目', '${_allEntries.where((e) => e.type == KnowledgeType.advanced).length}', Icons.star)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue.shade600),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddKnowledgeForm extends StatefulWidget {
  const _AddKnowledgeForm();
  
  @override
  State<_AddKnowledgeForm> createState() => _AddKnowledgeFormState();
}

class _AddKnowledgeFormState extends State<_AddKnowledgeForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isPublic = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
  
  void _addKnowledgeEntry() async {
    if (!_formKey.currentState!.validate()) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (!chatProvider.isInitialized) {
      await chatProvider.initializeServices();
    }
    
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    
    final entry = KnowledgeEntry(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _categoryController.text.trim(),
      tags: tags,
      createdAt: DateTime.now(),
    );
    
    try {
      await chatProvider.knowledgeBaseService.addKnowledgeEntry(entry, isPublic: _isPublic);
      
      // 清空表单
      _titleController.clear();
      _contentController.clear();
      _categoryController.clear();
      _tagsController.clear();
      setState(() {
        _isPublic = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('知识条目添加成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '添加新知识条目',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '标题 *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '内容 *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入内容';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: '标签 (用逗号分隔)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('公开知识'),
              subtitle: const Text('其他用户也可以使用这个知识条目'),
              value: _isPublic,
              onChanged: (value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addKnowledgeEntry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('添加知识条目'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}