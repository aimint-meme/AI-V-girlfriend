import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/content_analysis_provider.dart';

class PromptTemplateScreen extends StatefulWidget {
  const PromptTemplateScreen({super.key});

  @override
  State<PromptTemplateScreen> createState() => _PromptTemplateScreenState();
}

class _PromptTemplateScreenState extends State<PromptTemplateScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';
  String _selectedLanguage = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentAnalysisProvider>().loadPromptTemplates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/content/templates',
      child: Consumer<ContentAnalysisProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prompt模板管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理AI对话模板、场景模板和系统提示词',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateTemplateDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('新建模板'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _importTemplates(),
                          icon: const Icon(Icons.upload),
                          label: const Text('批量导入'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportTemplates(provider),
                          icon: const Icon(Icons.download),
                          label: const Text('导出模板'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 统计卡片
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '模板总数',
                        value: '${provider.totalTemplates}',
                        subtitle: '活跃模板: ${provider.activeTemplates}',
                        trend: provider.templateGrowth,
                        icon: Icons.description,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '使用频次',
                        value: NumberFormat('#,##0').format(provider.templateUsageCount),
                        subtitle: '本月调用次数',
                        trend: provider.usageTrend,
                        icon: Icons.trending_up,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均评分',
                        value: '${provider.avgTemplateRating.toStringAsFixed(1)}分',
                        subtitle: '用户满意度评价',
                        trend: provider.ratingTrend,
                        icon: Icons.star,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '优化建议',
                        value: '${provider.optimizationSuggestions}',
                        subtitle: '待优化模板数量',
                        trend: -provider.optimizationTrend,
                        icon: Icons.lightbulb,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 标签页
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 标签栏
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.grey.shade600,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.list),
                              text: '模板列表',
                            ),
                            Tab(
                              icon: Icon(Icons.category),
                              text: '分类管理',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics),
                              text: '使用统计',
                            ),
                          ],
                        ),
                      ),
                      // 标签页内容
                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTemplateList(provider),
                            _buildCategoryManagement(provider),
                            _buildUsageStatistics(provider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateList(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 搜索和筛选
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: '搜索模板名称、标签、内容...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(provider),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '模板分类',
                  ),
                  items: ['全部', '对话模板', '系统提示', '角色设定', '场景描述', '情感表达']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ['全部', '启用', '禁用', '草稿', '审核中']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  decoration: const InputDecoration(
                    labelText: '语言',
                  ),
                  items: ['全部', '中文', '英文', '日文', '韩文']
                      .map((language) => DropdownMenuItem(
                            value: language,
                            child: Text(language),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLanguage = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 模板列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTemplateTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateTable(ContentAnalysisProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(
          label: Text('模板信息'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('分类'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('语言'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('使用次数'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('评分'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('更新时间'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('操作'),
          size: ColumnSize.M,
        ),
      ],
      rows: _generateMockTemplates().map((template) {
        return DataRow2(
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    template['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    template['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            DataCell(_buildCategoryChip(template['category'])),
            DataCell(_buildLanguageChip(template['language'])),
            DataCell(
              Text(
                NumberFormat('#,##0').format(template['usageCount']),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    template['rating'].toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            DataCell(_buildStatusChip(template['status'])),
            DataCell(
              Text(DateFormat('yyyy-MM-dd\nHH:mm').format(template['updatedAt'])),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editTemplate(template),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    onPressed: () => _previewTemplate(template),
                    icon: const Icon(Icons.visibility),
                    tooltip: '预览',
                  ),
                  IconButton(
                    onPressed: () => _duplicateTemplate(template),
                    icon: const Icon(Icons.copy),
                    tooltip: '复制',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleTemplateAction(value, template),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'test',
                        child: Text('测试模板'),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('导出'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryManagement(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 分类管理工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '模板分类管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateCategoryDialog(),
                icon: const Icon(Icons.add),
                label: const Text('新建分类'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 分类列表
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _generateMockCategories().length,
              itemBuilder: (context, index) {
                final category = _generateMockCategories()[index];
                return _buildCategoryCard(category);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatistics(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 使用统计概览
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '使用趋势',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '模板使用趋势图表\n（此处可集成图表库）',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '热门模板 TOP 5',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateTopTemplates().map((template) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      template['name'],
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat('#,##0').format(template['usage']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '分类使用分布',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateCategoryUsage().map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['category'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${item['percentage']}%',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final colors = {
      '对话模板': AppColors.primary,
      '系统提示': AppColors.success,
      '角色设定': AppColors.warning,
      '场景描述': AppColors.info,
      '情感表达': Colors.purple,
    };
    
    final color = colors[category] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String language) {
    final colors = {
      '中文': Colors.red,
      '英文': Colors.blue,
      '日文': Colors.pink,
      '韩文': Colors.orange,
    };
    
    final color = colors[language] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        language,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '启用':
        color = AppColors.success;
        break;
      case '禁用':
        color = AppColors.error;
        break;
      case '草稿':
        color = AppColors.warning;
        break;
      case '审核中':
        color = AppColors.info;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  category['icon'],
                  color: category['color'],
                  size: 32,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleCategoryAction(value, category),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('编辑'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category['description'],
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${category['templateCount']} 个模板',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${category['usageCount']} 次使用',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockTemplates() {
    return [
      {
        'id': 'tpl_001',
        'name': '日常问候模板',
        'description': '用于日常问候和寒暄的对话模板',
        'category': '对话模板',
        'language': '中文',
        'usageCount': 15420,
        'rating': 4.8,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'tpl_002',
        'name': '情感安慰系统提示',
        'description': '当用户情绪低落时的安慰话术',
        'category': '系统提示',
        'language': '中文',
        'usageCount': 8930,
        'rating': 4.6,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 5)),
      },
      {
        'id': 'tpl_003',
        'name': '温柔女友角色设定',
        'description': '温柔体贴的女友角色人设模板',
        'category': '角色设定',
        'language': '中文',
        'usageCount': 12350,
        'rating': 4.9,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 'tpl_004',
        'name': '咖啡厅约会场景',
        'description': '咖啡厅约会的场景描述模板',
        'category': '场景描述',
        'language': '中文',
        'usageCount': 6780,
        'rating': 4.5,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': 'tpl_005',
        'name': '撒娇表达模板',
        'description': '可爱撒娇的情感表达方式',
        'category': '情感表达',
        'language': '中文',
        'usageCount': 9240,
        'rating': 4.7,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 4)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockCategories() {
    return [
      {
        'id': 'cat_001',
        'name': '对话模板',
        'description': '日常对话和交流的模板',
        'icon': Icons.chat,
        'color': AppColors.primary,
        'templateCount': 45,
        'usageCount': 25680,
      },
      {
        'id': 'cat_002',
        'name': '系统提示',
        'description': '系统级别的提示和引导',
        'icon': Icons.settings,
        'color': AppColors.success,
        'templateCount': 23,
        'usageCount': 18920,
      },
      {
        'id': 'cat_003',
        'name': '角色设定',
        'description': '不同角色的人设和性格',
        'icon': Icons.person,
        'color': AppColors.warning,
        'templateCount': 32,
        'usageCount': 31450,
      },
      {
        'id': 'cat_004',
        'name': '场景描述',
        'description': '各种场景的环境描述',
        'icon': Icons.landscape,
        'color': AppColors.info,
        'templateCount': 28,
        'usageCount': 15670,
      },
      {
        'id': 'cat_005',
        'name': '情感表达',
        'description': '情感和情绪的表达方式',
        'icon': Icons.favorite,
        'color': Colors.purple,
        'templateCount': 19,
        'usageCount': 22340,
      },
      {
        'id': 'cat_006',
        'name': '特殊功能',
        'description': '特殊场合和功能的模板',
        'icon': Icons.star,
        'color': Colors.orange,
        'templateCount': 12,
        'usageCount': 8950,
      },
    ];
  }

  List<Map<String, dynamic>> _generateTopTemplates() {
    return [
      {'name': '日常问候模板', 'usage': 15420},
      {'name': '温柔女友角色设定', 'usage': 12350},
      {'name': '撒娇表达模板', 'usage': 9240},
      {'name': '情感安慰系统提示', 'usage': 8930},
      {'name': '咖啡厅约会场景', 'usage': 6780},
    ];
  }

  List<Map<String, dynamic>> _generateCategoryUsage() {
    return [
      {'category': '角色设定', 'percentage': 28.5},
      {'category': '对话模板', 'percentage': 23.2},
      {'category': '情感表达', 'percentage': 20.1},
      {'category': '系统提示', 'percentage': 17.8},
      {'category': '场景描述', 'percentage': 10.4},
    ];
  }

  void _applyFilters(ContentAnalysisProvider provider) {
    // 这里实现筛选逻辑
  }

  void _showCreateTemplateDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('新建模板功能开发中...')),
    );
  }

  void _importTemplates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导入功能开发中...')),
    );
  }

  void _exportTemplates(ContentAnalysisProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出模板功能开发中...')),
    );
  }

  void _editTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑模板: ${template['name']}')),
    );
  }

  void _previewTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预览模板: ${template['name']}')),
    );
  }

  void _duplicateTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('复制模板: ${template['name']}')),
    );
  }

  void _handleTemplateAction(String action, Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对模板 ${template['name']} 执行操作: $action')),
    );
  }

  void _showCreateCategoryDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('新建分类功能开发中...')),
    );
  }

  void _handleCategoryAction(String action, Map<String, dynamic> category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对分类 ${category['name']} 执行操作: $action')),
    );
  }
}