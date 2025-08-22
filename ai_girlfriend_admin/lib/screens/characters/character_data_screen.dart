import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/character_config_provider.dart';

class CharacterDataScreen extends StatefulWidget {
  const CharacterDataScreen({super.key});

  @override
  State<CharacterDataScreen> createState() => _CharacterDataScreenState();
}

class _CharacterDataScreenState extends State<CharacterDataScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';
  String _selectedPopularity = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterConfigProvider>().loadCharacterData();
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
      currentRoute: '/characters/data',
      child: Consumer<CharacterConfigProvider>(
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
                          '角色数据管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理AI角色的基础数据、属性信息和使用统计',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showImportDialog(),
                          icon: const Icon(Icons.upload),
                          label: const Text('批量导入'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportCharacterData(provider),
                          icon: const Icon(Icons.download),
                          label: const Text('导出数据'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showBackupDialog(),
                          icon: const Icon(Icons.backup),
                          label: const Text('数据备份'),
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
                        title: '角色总数',
                        value: '${provider.totalCharacters}',
                        subtitle: '活跃角色: ${provider.activeCharacters}',
                        trend: provider.characterGrowth,
                        icon: Icons.person,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '使用频次',
                        value: NumberFormat('#,##0').format(provider.totalInteractions),
                        subtitle: '本月互动次数',
                        trend: provider.interactionTrend,
                        icon: Icons.chat,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均评分',
                        value: '${provider.averageRating.toStringAsFixed(1)}分',
                        subtitle: '用户满意度评价',
                        trend: provider.ratingTrend,
                        icon: Icons.star,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '数据完整度',
                        value: '${provider.dataCompleteness.toStringAsFixed(1)}%',
                        subtitle: '角色信息完整性',
                        trend: provider.completenessTrend,
                        icon: Icons.data_usage,
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
                              text: '角色列表',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics),
                              text: '数据统计',
                            ),
                            Tab(
                              icon: Icon(Icons.settings),
                              text: '数据管理',
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
                            _buildCharacterList(provider),
                            _buildDataStatistics(provider),
                            _buildDataManagement(provider),
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

  Widget _buildCharacterList(CharacterConfigProvider provider) {
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
                    hintText: '搜索角色名称、标签、描述...',
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
                    labelText: '角色类型',
                  ),
                  items: ['全部', '温柔型', '活泼型', '知性型', '冷酷型', '神秘型', '可爱型']
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
                  items: ['全部', '启用', '禁用', '测试中', '维护中']
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
                  value: _selectedPopularity,
                  decoration: const InputDecoration(
                    labelText: '热度',
                  ),
                  items: ['全部', '热门', '普通', '冷门']
                      .map((popularity) => DropdownMenuItem(
                            value: popularity,
                            child: Text(popularity),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPopularity = value!;
                    });
                    _applyFilters(provider);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 角色列表
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCharacterTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterTable(CharacterConfigProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1200,
      columns: const [
        DataColumn2(
          label: Text('角色信息'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('类型'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('互动次数'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('评分'),
          size: ColumnSize.S,
          numeric: true,
        ),
        DataColumn2(
          label: Text('完整度'),
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
      rows: _generateMockCharacters().map((character) {
        return DataRow2(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      character['name'][0],
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          character['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          character['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DataCell(_buildTypeChip(character['type'])),
            DataCell(
              Text(
                NumberFormat('#,##0').format(character['interactions']),
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
                    character['rating'].toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: character['completeness'] / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getCompletenessColor(character['completeness']),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${character['completeness']}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(_buildStatusChip(character['status'])),
            DataCell(
              Text(DateFormat('yyyy-MM-dd\nHH:mm').format(character['updatedAt'])),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _viewCharacterDetail(character),
                    icon: const Icon(Icons.visibility),
                    tooltip: '查看详情',
                  ),
                  IconButton(
                    onPressed: () => _editCharacterData(character),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑数据',
                  ),
                  IconButton(
                    onPressed: () => _analyzeCharacter(character),
                    icon: const Icon(Icons.analytics),
                    tooltip: '数据分析',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCharacterAction(value, character),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'backup',
                        child: Text('备份数据'),
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

  Widget _buildDataStatistics(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 数据统计概览
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
                          '角色使用趋势',
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
                              '角色使用趋势图表\n（此处可集成图表库）',
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
                              '热门角色 TOP 5',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateTopCharacters().map((character) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      character['name'][0],
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      character['name'],
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat('#,##0').format(character['interactions']),
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
                              '类型分布',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._generateTypeDistribution().map((item) => Padding(
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
                                        item['type'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${item['count']}',
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

  Widget _buildDataManagement(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 数据管理工具
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.backup,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '数据备份',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '定期备份角色数据，确保数据安全',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _createBackup(),
                                child: const Text('创建备份'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _showBackupList(),
                                child: const Text('备份列表'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '数据同步',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '同步角色数据到其他环境',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _syncToTest(),
                                child: const Text('同步到测试'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _syncToProduction(),
                                child: const Text('同步到生产'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cleaning_services,
                              color: AppColors.warning,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '数据清理',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '清理无效和重复的角色数据',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _scanDuplicates(),
                                child: const Text('扫描重复'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _cleanInvalidData(),
                                child: const Text('清理数据'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 数据质量报告
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '数据质量报告',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQualityMetric(
                          '完整性',
                          '${provider.dataCompleteness.toStringAsFixed(1)}%',
                          provider.dataCompleteness,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQualityMetric(
                          '准确性',
                          '${provider.dataAccuracy.toStringAsFixed(1)}%',
                          provider.dataAccuracy,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQualityMetric(
                          '一致性',
                          '${provider.dataConsistency.toStringAsFixed(1)}%',
                          provider.dataConsistency,
                          AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQualityMetric(
                          '时效性',
                          '${provider.dataTimeliness.toStringAsFixed(1)}%',
                          provider.dataTimeliness,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final colors = {
      '温柔型': AppColors.success,
      '活泼型': AppColors.warning,
      '知性型': AppColors.primary,
      '冷酷型': Colors.grey,
      '神秘型': Colors.purple,
      '可爱型': Colors.pink,
    };
    
    final color = colors[type] ?? Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type,
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
      case '测试中':
        color = AppColors.warning;
        break;
      case '维护中':
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

  Color _getCompletenessColor(int completeness) {
    if (completeness >= 90) return AppColors.success;
    if (completeness >= 70) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildQualityMetric(String title, String value, double percentage, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateMockCharacters() {
    return [
      {
        'id': 'char_001',
        'name': '小雪',
        'description': '温柔体贴的邻家女孩',
        'type': '温柔型',
        'interactions': 15420,
        'rating': 4.8,
        'completeness': 95,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': 'char_002',
        'name': '小樱',
        'description': '活泼开朗的阳光少女',
        'type': '活泼型',
        'interactions': 12350,
        'rating': 4.6,
        'completeness': 88,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': 'char_003',
        'name': '小慧',
        'description': '聪明睿智的知性美女',
        'type': '知性型',
        'interactions': 9870,
        'rating': 4.7,
        'completeness': 92,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(hours: 12)),
      },
      {
        'id': 'char_004',
        'name': '小冰',
        'description': '高冷神秘的冰山美人',
        'type': '冷酷型',
        'interactions': 7650,
        'rating': 4.4,
        'completeness': 85,
        'status': '测试中',
        'updatedAt': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': 'char_005',
        'name': '小萌',
        'description': '软萌可爱的小天使',
        'type': '可爱型',
        'interactions': 11200,
        'rating': 4.9,
        'completeness': 90,
        'status': '启用',
        'updatedAt': DateTime.now().subtract(const Duration(hours: 6)),
      },
    ];
  }

  List<Map<String, dynamic>> _generateTopCharacters() {
    return [
      {'name': '小雪', 'interactions': 15420},
      {'name': '小樱', 'interactions': 12350},
      {'name': '小萌', 'interactions': 11200},
      {'name': '小慧', 'interactions': 9870},
      {'name': '小冰', 'interactions': 7650},
    ];
  }

  List<Map<String, dynamic>> _generateTypeDistribution() {
    return [
      {'type': '温柔型', 'count': 25, 'color': AppColors.success},
      {'type': '活泼型', 'count': 18, 'color': AppColors.warning},
      {'type': '知性型', 'count': 15, 'color': AppColors.primary},
      {'type': '可爱型', 'count': 12, 'color': Colors.pink},
      {'type': '冷酷型', 'count': 8, 'color': Colors.grey},
      {'type': '神秘型', 'count': 5, 'color': Colors.purple},
    ];
  }

  void _applyFilters(CharacterConfigProvider provider) {
    // 这里实现筛选逻辑
  }

  void _showImportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导入功能开发中...')),
    );
  }

  void _exportCharacterData(CharacterConfigProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出角色数据功能开发中...')),
    );
  }

  void _showBackupDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('数据备份功能开发中...')),
    );
  }

  void _viewCharacterDetail(Map<String, dynamic> character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看角色详情: ${character['name']}')),
    );
  }

  void _editCharacterData(Map<String, dynamic> character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑角色数据: ${character['name']}')),
    );
  }

  void _analyzeCharacter(Map<String, dynamic> character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('分析角色数据: ${character['name']}')),
    );
  }

  void _handleCharacterAction(String action, Map<String, dynamic> character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对角色 ${character['name']} 执行操作: $action')),
    );
  }

  void _createBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建数据备份...')),
    );
  }

  void _showBackupList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('显示备份列表功能开发中...')),
    );
  }

  void _syncToTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步到测试环境...')),
    );
  }

  void _syncToProduction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('同步到生产环境...')),
    );
  }

  void _scanDuplicates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('扫描重复数据...')),
    );
  }

  void _cleanInvalidData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('清理无效数据...')),
    );
  }
}