import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/content_analysis_provider.dart';

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedDomain = '全部';
  String _selectedStatus = '全部';
  String _selectedSource = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentAnalysisProvider>().loadKnowledgeBase();
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
      currentRoute: '/content/knowledge',
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
                          '知识库管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理AI知识库内容、数据源和知识更新',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddKnowledgeDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('添加知识'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _importKnowledge(),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('批量导入'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _syncKnowledge(),
                          icon: const Icon(Icons.sync),
                          label: const Text('同步更新'),
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
                        title: '知识条目',
                        value: NumberFormat('#,##0').format(provider.totalKnowledgeItems),
                        subtitle: '已验证: ${provider.verifiedItems}',
                        trend: provider.knowledgeGrowth,
                        icon: Icons.library_books,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '数据源',
                        value: '${provider.dataSources}',
                        subtitle: '活跃源: ${provider.activeDataSources}',
                        trend: provider.dataSourceTrend,
                        icon: Icons.source,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '更新频率',
                        value: '${provider.updateFrequency}/天',
                        subtitle: '最近更新: ${provider.lastUpdateHours}小时前',
                        trend: provider.updateTrend,
                        icon: Icons.update,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '准确率',
                        value: '${provider.knowledgeAccuracy.toStringAsFixed(1)}%',
                        subtitle: '质量评分',
                        trend: provider.accuracyTrend,
                        icon: Icons.verified,
                        color: AppColors.warning,
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
                              text: '知识列表',
                            ),
                            Tab(
                              icon: Icon(Icons.source),
                              text: '数据源',
                            ),
                            Tab(
                              icon: Icon(Icons.sync),
                              text: '同步管理',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics),
                              text: '质量分析',
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
                            _buildKnowledgeList(provider),
                            _buildDataSources(provider),
                            _buildSyncManagement(provider),
                            _buildQualityAnalysis(provider),
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

  Widget _buildKnowledgeList(ContentAnalysisProvider provider) {
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
                    hintText: '搜索知识内容、标签、关键词...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(provider),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDomain,
                  decoration: const InputDecoration(
                    labelText: '知识领域',
                  ),
                  items: ['全部', '情感交流', '生活常识', '娱乐休闲', '学习工作', '健康养生', '时事新闻']
                      .map((domain) => DropdownMenuItem(
                            value: domain,
                            child: Text(domain),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDomain = value!;
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
                  items: ['全部', '已验证', '待审核', '需更新', '已过期']
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
                  value: _selectedSource,
                  decoration: const InputDecoration(
                    labelText: '数据源',
                  ),
                  items: ['全部', '官方资料', '用户贡献', '网络爬取', '专家审核', 'API接口']
                      .map((source) => DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSource = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 知识列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildKnowledgeTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeTable(ContentAnalysisProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(
          label: Text('知识内容'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('领域'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('数据源'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('可信度'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('使用次数'),
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
      rows: _generateMockKnowledge().map((knowledge) {
        return DataRow2(
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    knowledge['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    knowledge['summary'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            DataCell(_buildDomainChip(knowledge['domain'])),
            DataCell(_buildSourceChip(knowledge['source'])),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified,
                    size: 16,
                    color: _getCredibilityColor(knowledge['credibility']),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${knowledge['credibility']}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _getCredibilityColor(knowledge['credibility']),
                    ),
                  ),
                ],
              ),
            ),
            DataCell(
              Text(
                NumberFormat('#,##0').format(knowledge['usageCount']),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(_buildKnowledgeStatusChip(knowledge['status'])),
            DataCell(
              Text(DateFormat('yyyy-MM-dd\nHH:mm').format(knowledge['updatedAt'])),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editKnowledge(knowledge),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    onPressed: () => _viewKnowledge(knowledge),
                    icon: const Icon(Icons.visibility),
                    tooltip: '查看',
                  ),
                  IconButton(
                    onPressed: () => _verifyKnowledge(knowledge),
                    icon: const Icon(Icons.verified_user),
                    tooltip: '验证',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleKnowledgeAction(value, knowledge),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'refresh',
                        child: Text('刷新数据'),
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

  Widget _buildDataSources(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 数据源管理工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '数据源管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddDataSourceDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('添加数据源'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _testAllDataSources(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('测试连接'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 数据源列表
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _generateMockDataSources().length,
              itemBuilder: (context, index) {
                final dataSource = _generateMockDataSources()[index];
                return _buildDataSourceCard(dataSource);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncManagement(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 同步管理工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '同步管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _startFullSync(),
                    icon: const Icon(Icons.sync),
                    label: const Text('全量同步'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _startIncrementalSync(),
                    icon: const Icon(Icons.update),
                    label: const Text('增量同步'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 同步状态和历史
          Expanded(
            child: Row(
              children: [
                // 同步状态
                Expanded(
                  flex: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '同步状态',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ..._generateSyncStatus().map((status) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSyncStatusItem(status),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 同步历史
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '同步历史',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _generateSyncHistory().length,
                              itemBuilder: (context, index) {
                                final history = _generateSyncHistory()[index];
                                return _buildSyncHistoryItem(history);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityAnalysis(ContentAnalysisProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 质量分析概览
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
                          '质量趋势',
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
                              '知识质量趋势图表\n（此处可集成图表库）',
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
                              '质量分布',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateQualityDistribution().map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: item['color'],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['label'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
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
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '问题统计',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateIssueStats().map((issue) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    issue['type'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    '${issue['count']}',
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

  Widget _buildDomainChip(String domain) {
    final colors = {
      '情感交流': AppColors.primary,
      '生活常识': AppColors.success,
      '娱乐休闲': AppColors.warning,
      '学习工作': AppColors.info,
      '健康养生': Colors.green,
      '时事新闻': Colors.orange,
    };
    
    final color = colors[domain] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        domain,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSourceChip(String source) {
    final colors = {
      '官方资料': AppColors.success,
      '用户贡献': AppColors.primary,
      '网络爬取': AppColors.warning,
      '专家审核': AppColors.info,
      'API接口': Colors.purple,
    };
    
    final color = colors[source] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        source,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKnowledgeStatusChip(String status) {
    Color color;
    switch (status) {
      case '已验证':
        color = AppColors.success;
        break;
      case '待审核':
        color = AppColors.warning;
        break;
      case '需更新':
        color = AppColors.info;
        break;
      case '已过期':
        color = AppColors.error;
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

  Color _getCredibilityColor(int credibility) {
    if (credibility >= 90) return AppColors.success;
    if (credibility >= 70) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildDataSourceCard(Map<String, dynamic> dataSource) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      dataSource['icon'],
                      color: dataSource['color'],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dataSource['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildConnectionStatus(dataSource['status']),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dataSource['description'],
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
                  '${dataSource['itemCount']} 条目',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '更新: ${dataSource['lastSync']}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _testDataSource(dataSource),
                    child: const Text('测试', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _syncDataSource(dataSource),
                    child: const Text('同步', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(String status) {
    Color color;
    switch (status) {
      case '正常':
        color = AppColors.success;
        break;
      case '异常':
        color = AppColors.error;
        break;
      case '同步中':
        color = AppColors.warning;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSyncStatusItem(Map<String, dynamic> status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status['source'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              status['lastSync'],
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
        _buildConnectionStatus(status['status']),
      ],
    );
  }

  Widget _buildSyncHistoryItem(Map<String, dynamic> history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              history['success'] ? Icons.check_circle : Icons.error,
              color: history['success'] ? AppColors.success : AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${history['time']} • ${history['duration']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${history['itemCount']} 条目',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _generateMockKnowledge() {
    return [
      {
        'id': 'kb_001',
        'title': '如何表达关心和安慰',
        'summary': '在对方情绪低落时的安慰话术和表达方式',
        'domain': '情感交流',
        'source': '专家审核',
        'credibility': 95,
        'usageCount': 8420,
        'status': '已验证',
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'kb_002',
        'title': '日常生活小贴士',
        'summary': '实用的生活小窍门和健康建议',
        'domain': '生活常识',
        'source': '官方资料',
        'credibility': 88,
        'usageCount': 6750,
        'status': '已验证',
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 'kb_003',
        'title': '热门电影和音乐推荐',
        'summary': '最新的娱乐资讯和推荐内容',
        'domain': '娱乐休闲',
        'source': '网络爬取',
        'credibility': 72,
        'usageCount': 4320,
        'status': '需更新',
        'updatedAt': DateTime.now().subtract(const Duration(days: 7)),
      },
      {
        'id': 'kb_004',
        'title': '工作效率提升方法',
        'summary': '提高工作和学习效率的技巧',
        'domain': '学习工作',
        'source': '用户贡献',
        'credibility': 81,
        'usageCount': 5680,
        'status': '待审核',
        'updatedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': 'kb_005',
        'title': '健康饮食搭配建议',
        'summary': '营养均衡的饮食搭配和健康建议',
        'domain': '健康养生',
        'source': 'API接口',
        'credibility': 92,
        'usageCount': 7890,
        'status': '已验证',
        'updatedAt': DateTime.now().subtract(const Duration(hours: 12)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateMockDataSources() {
    return [
      {
        'id': 'ds_001',
        'name': '官方知识库',
        'description': '官方维护的权威知识内容',
        'icon': Icons.verified,
        'color': AppColors.success,
        'status': '正常',
        'itemCount': 15420,
        'lastSync': '2小时前',
      },
      {
        'id': 'ds_002',
        'name': '百科API',
        'description': '第三方百科知识接口',
        'icon': Icons.api,
        'color': AppColors.primary,
        'status': '正常',
        'itemCount': 28750,
        'lastSync': '30分钟前',
      },
      {
        'id': 'ds_003',
        'name': '用户贡献',
        'description': '用户提交的知识内容',
        'icon': Icons.people,
        'color': AppColors.warning,
        'status': '同步中',
        'itemCount': 8920,
        'lastSync': '正在同步',
      },
      {
        'id': 'ds_004',
        'name': '新闻爬虫',
        'description': '自动爬取的新闻资讯',
        'icon': Icons.web,
        'color': AppColors.info,
        'status': '异常',
        'itemCount': 12340,
        'lastSync': '6小时前',
      },
    ];
  }

  List<Map<String, dynamic>> _generateSyncStatus() {
    return [
      {
        'source': '官方知识库',
        'status': '正常',
        'lastSync': '2小时前',
      },
      {
        'source': '百科API',
        'status': '正常',
        'lastSync': '30分钟前',
      },
      {
        'source': '用户贡献',
        'status': '同步中',
        'lastSync': '正在同步',
      },
      {
        'source': '新闻爬虫',
        'status': '异常',
        'lastSync': '6小时前',
      },
    ];
  }

  List<Map<String, dynamic>> _generateSyncHistory() {
    return [
      {
        'description': '全量同步完成',
        'time': '2小时前',
        'duration': '15分钟',
        'itemCount': 1250,
        'success': true,
      },
      {
        'description': '增量同步完成',
        'time': '6小时前',
        'duration': '3分钟',
        'itemCount': 85,
        'success': true,
      },
      {
        'description': '同步失败 - 网络超时',
        'time': '12小时前',
        'duration': '2分钟',
        'itemCount': 0,
        'success': false,
      },
      {
        'description': '增量同步完成',
        'time': '1天前',
        'duration': '5分钟',
        'itemCount': 156,
        'success': true,
      },
    ];
  }

  List<Map<String, dynamic>> _generateQualityDistribution() {
    return [
      {'label': '高质量', 'percentage': 65, 'color': AppColors.success},
      {'label': '中等质量', 'percentage': 28, 'color': AppColors.warning},
      {'label': '低质量', 'percentage': 7, 'color': AppColors.error},
    ];
  }

  List<Map<String, dynamic>> _generateIssueStats() {
    return [
      {'type': '内容过期', 'count': 23},
      {'type': '信息不准确', 'count': 15},
      {'type': '重复内容', 'count': 8},
      {'type': '格式错误', 'count': 5},
    ];
  }

  void _applyFilters(ContentAnalysisProvider provider) {
    // 这里实现筛选逻辑
  }

  void _showAddKnowledgeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加知识功能开发中...')),
    );
  }

  void _importKnowledge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导入功能开发中...')),
    );
  }

  void _syncKnowledge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步更新功能开发中...')),
    );
  }

  void _editKnowledge(Map<String, dynamic> knowledge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑知识: ${knowledge['title']}')),
    );
  }

  void _viewKnowledge(Map<String, dynamic> knowledge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看知识: ${knowledge['title']}')),
    );
  }

  void _verifyKnowledge(Map<String, dynamic> knowledge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('验证知识: ${knowledge['title']}')),
    );
  }

  void _handleKnowledgeAction(String action, Map<String, dynamic> knowledge) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对知识 ${knowledge['title']} 执行操作: $action')),
    );
  }

  void _showAddDataSourceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加数据源功能开发中...')),
    );
  }

  void _testAllDataSources() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试所有数据源连接...')),
    );
  }

  void _testDataSource(Map<String, dynamic> dataSource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('测试数据源: ${dataSource['name']}')),
    );
  }

  void _syncDataSource(Map<String, dynamic> dataSource) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('同步数据源: ${dataSource['name']}')),
    );
  }

  void _startFullSync() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始全量同步...')),
    );
  }

  void _startIncrementalSync() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始增量同步...')),
    );
  }
}