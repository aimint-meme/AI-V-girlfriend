import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/content_moderation_model.dart';
import '../../providers/content_moderation_provider.dart';
import 'package:provider/provider.dart';

class ContentModerationScreen extends StatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  State<ContentModerationScreen> createState() => _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();
  String _selectedCategory = '全部';
  String _selectedSeverity = '全部';
  String _selectedStatus = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContentModerationProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/risk-control/content',
      child: Consumer<ContentModerationProvider>(
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
                          '敏感词管理/违规检测',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理敏感词库、违规内容检测和风控规则配置',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showAddKeywordDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('添加敏感词'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showImportDialog(),
                          icon: const Icon(Icons.upload),
                          label: const Text('批量导入'),
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
                        title: '敏感词总数',
                        value: provider.totalKeywords.toString(),
                        subtitle: '启用: ${provider.activeKeywords}',
                        trend: 5.2,
                        icon: Icons.warning,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '今日检测',
                        value: provider.todayDetections.toString(),
                        subtitle: '违规: ${provider.todayViolations}',
                        trend: -8.3,
                        icon: Icons.security,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '拦截率',
                        value: '${provider.blockRate.toStringAsFixed(1)}%',
                        subtitle: '本月统计',
                        trend: 12.5,
                        icon: Icons.block,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '误报率',
                        value: '${provider.falsePositiveRate.toStringAsFixed(1)}%',
                        subtitle: '需要优化',
                        trend: -3.7,
                        icon: Icons.trending_down,
                        color: AppColors.success,
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
                              text: '敏感词库',
                            ),
                            Tab(
                              icon: Icon(Icons.report),
                              text: '违规记录',
                            ),
                            Tab(
                              icon: Icon(Icons.settings),
                              text: '检测规则',
                            ),
                            Tab(
                              icon: Icon(Icons.analytics),
                              text: '统计分析',
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
                            _buildKeywordManagement(provider),
                            _buildViolationRecords(provider),
                            _buildDetectionRules(provider),
                            _buildAnalytics(provider),
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

  Widget _buildKeywordManagement(ContentModerationProvider provider) {
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
                    hintText: '搜索敏感词...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyKeywordFilters(provider),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                  ),
                  items: ['全部', '政治敏感', '色情低俗', '暴力血腥', '违法犯罪', '其他']
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _applyKeywordFilters(provider);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: '严重程度',
                  ),
                  items: ['全部', '高', '中', '低']
                      .map((severity) => DropdownMenuItem(
                            value: severity,
                            child: Text(severity),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeverity = value!;
                    });
                    _applyKeywordFilters(provider);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 敏感词表格
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildKeywordTable(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordTable(ContentModerationProvider provider) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 1000,
      columns: const [
        DataColumn2(
          label: Text('敏感词'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('分类'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('严重程度'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('检测次数'),
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
      rows: provider.filteredKeywords.map((keyword) {
        return DataRow2(
          cells: [
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  keyword.word,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            DataCell(_buildCategoryChip(keyword.category)),
            DataCell(_buildSeverityChip(keyword.severity)),
            DataCell(
              Text(
                NumberFormat('#,###').format(keyword.detectionCount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(_buildStatusChip(keyword.isActive)),
            DataCell(
              Text(DateFormat('yyyy-MM-dd').format(keyword.updatedAt)),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editKeyword(keyword),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  IconButton(
                    onPressed: () => provider.toggleKeywordStatus(keyword.id),
                    icon: Icon(keyword.isActive ? Icons.pause : Icons.play_arrow),
                    tooltip: keyword.isActive ? '禁用' : '启用',
                  ),
                  IconButton(
                    onPressed: () => _deleteKeyword(keyword),
                    icon: const Icon(Icons.delete),
                    tooltip: '删除',
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildViolationRecords(ContentModerationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 违规记录筛选
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '搜索用户ID、内容...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyViolationFilters(provider, value),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '处理状态',
                  ),
                  items: ['全部', '待处理', '已处理', '已忽略']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                    _applyViolationFilters(provider, null);
                  },
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _exportViolations(provider),
                icon: const Icon(Icons.download),
                label: const Text('导出记录'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 违规记录列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.filteredViolations.length,
              itemBuilder: (context, index) {
                final violation = provider.filteredViolations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                                _buildSeverityIcon(violation.severity),
                                const SizedBox(width: 8),
                                Text(
                                  '用户ID: ${violation.userId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                _buildViolationStatusChip(violation.status),
                              ],
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(violation.detectedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '违规内容:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                violation.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (violation.matchedKeywords.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '匹配关键词:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  children: violation.matchedKeywords.map((keyword) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      keyword,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '风险评分: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getRiskScoreColor(violation.riskScore).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${violation.riskScore}/100',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getRiskScoreColor(violation.riskScore),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (violation.status == '待处理')
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => provider.handleViolation(violation.id, '已忽略'),
                                    child: const Text('忽略'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => _showHandleViolationDialog(violation),
                                    child: const Text('处理'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionRules(ContentModerationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 检测规则工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '检测规则配置',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddRuleDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('添加规则'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _testRules(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('测试规则'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 规则列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.detectionRules.length,
              itemBuilder: (context, index) {
                final rule = provider.detectionRules[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: rule.isEnabled ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.rule,
                                    color: rule.isEnabled ? AppColors.success : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rule.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      rule.description,
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: rule.isEnabled,
                                  onChanged: (value) => provider.toggleRuleStatus(rule.id),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) => _handleRuleAction(value, rule),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('编辑规则'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'test',
                                      child: Text('测试规则'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'duplicate',
                                      child: Text('复制规则'),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除规则'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 规则配置
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildRuleParam('类型', rule.type),
                                  const SizedBox(width: 16),
                                  _buildRuleParam('优先级', rule.priority.toString()),
                                  const SizedBox(width: 16),
                                  _buildRuleParam('阈值', rule.threshold.toString()),
                                  const SizedBox(width: 16),
                                  _buildRuleParam('动作', rule.action),
                                ],
                              ),
                              if (rule.conditions.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '条件配置:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rule.conditions.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics(ContentModerationProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 统计概览
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsCard(
                  '检测总量',
                  '${provider.totalDetections}',
                  '今日: ${provider.todayDetections}',
                  Icons.search,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  '违规数量',
                  '${provider.totalViolations}',
                  '今日: ${provider.todayViolations}',
                  Icons.report,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  '准确率',
                  '${(100 - provider.falsePositiveRate).toStringAsFixed(1)}%',
                  '本月统计',
                  Icons.check_circle,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAnalyticsCard(
                  '响应时间',
                  '${provider.avgResponseTime}ms',
                  '平均检测时间',
                  Icons.speed,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 详细统计
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧统计
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildTopKeywordsCard(provider),
                      const SizedBox(height: 16),
                      _buildViolationTrendCard(provider),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 右侧统计
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildCategoryDistributionCard(provider),
                      const SizedBox(height: 16),
                      _buildRecentActivityCard(provider),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopKeywordsCard(ContentModerationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门敏感词 TOP 10',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.topKeywords.take(10).map((keyword) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      keyword.word,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${keyword.detectionCount}',
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
    );
  }

  Widget _buildViolationTrendCard(ContentModerationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '违规趋势（最近7天）',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: const Center(
                child: Text(
                  '趋势图表\n（此处可集成图表库）',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionCard(ContentModerationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '违规分类分布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.categoryDistribution.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    '${entry.value}',
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
    );
  }

  Widget _buildRecentActivityCard(ContentModerationProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最近活动',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.recentActivities.take(5).map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.action,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MM-dd HH:mm').format(activity.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case '政治敏感':
        color = AppColors.error;
        break;
      case '色情低俗':
        color = AppColors.warning;
        break;
      case '暴力血腥':
        color = AppColors.secondary;
        break;
      case '违法犯罪':
        color = Colors.red.shade800;
        break;
      default:
        color = AppColors.info;
    }

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

  Widget _buildSeverityChip(String severity) {
    Color color;
    switch (severity) {
      case '高':
        color = AppColors.error;
        break;
      case '中':
        color = AppColors.warning;
        break;
      case '低':
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
        severity,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? '启用' : '禁用',
        style: TextStyle(
          color: isActive ? AppColors.success : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildViolationStatusChip(String status) {
    Color color;
    switch (status) {
      case '待处理':
        color = AppColors.warning;
        break;
      case '已处理':
        color = AppColors.success;
        break;
      case '已忽略':
        color = Colors.grey;
        break;
      default:
        color = AppColors.info;
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

  Widget _buildSeverityIcon(String severity) {
    IconData icon;
    Color color;
    switch (severity) {
      case '高':
        icon = Icons.error;
        color = AppColors.error;
        break;
      case '中':
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case '低':
        icon = Icons.info;
        color = AppColors.info;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 20);
  }

  Widget _buildRuleParam(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getRiskScoreColor(int score) {
    if (score >= 80) return AppColors.error;
    if (score >= 60) return AppColors.warning;
    if (score >= 40) return AppColors.info;
    return AppColors.success;
  }

  void _applyKeywordFilters(ContentModerationProvider provider) {
    provider.applyKeywordFilters(
      searchQuery: _searchController.text,
      category: _selectedCategory == '全部' ? null : _selectedCategory,
      severity: _selectedSeverity == '全部' ? null : _selectedSeverity,
    );
  }

  void _applyViolationFilters(ContentModerationProvider provider, String? searchQuery) {
    provider.applyViolationFilters(
      searchQuery: searchQuery,
      status: _selectedStatus == '全部' ? null : _selectedStatus,
    );
  }

  void _showAddKeywordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加敏感词'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: '敏感词',
                hintText: '请输入敏感词',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '分类',
              ),
              items: ['政治敏感', '色情低俗', '暴力血腥', '违法犯罪', '其他']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '严重程度',
              ),
              items: ['高', '中', '低']
                  .map((severity) => DropdownMenuItem(
                        value: severity,
                        child: Text(severity),
                      ))
                  .toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 添加敏感词逻辑
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('敏感词添加功能开发中...')),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量导入功能开发中...')),
    );
  }

  void _editKeyword(SensitiveKeyword keyword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑敏感词: ${keyword.word}')),
    );
  }

  void _deleteKeyword(SensitiveKeyword keyword) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除敏感词 "${keyword.word}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ContentModerationProvider>().deleteKeyword(keyword.id);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _exportViolations(ContentModerationProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出违规记录功能开发中...')),
    );
  }

  void _showHandleViolationDialog(ViolationRecord violation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('处理违规记录: ${violation.id}')),
    );
  }

  void _showAddRuleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加检测规则功能开发中...')),
    );
  }

  void _testRules() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试检测规则功能开发中...')),
    );
  }

  void _handleRuleAction(String action, DetectionRule rule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对规则 ${rule.name} 执行操作: $action')),
    );
  }
}