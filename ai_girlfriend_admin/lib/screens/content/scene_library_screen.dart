import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../constants/app_theme.dart';
import '../../providers/content_analysis_provider.dart';

class SceneLibraryScreen extends StatefulWidget {
  const SceneLibraryScreen({super.key});

  @override
  State<SceneLibraryScreen> createState() => _SceneLibraryScreenState();
}

class _SceneLibraryScreenState extends State<SceneLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';

  // 模拟场景数据
  final List<Map<String, dynamic>> _sceneData = [
    {
      'id': 'scene_001',
      'name': '浪漫咖啡厅',
      'category': '约会场景',
      'description': '温馨的咖啡厅环境，适合浪漫约会对话',
      'thumbnail': 'https://example.com/scene_001_thumb.jpg',
      'status': '已发布',
      'createTime': DateTime.now().subtract(const Duration(days: 2)),
      'useCount': 3200,
      'rating': 4.7,
      'tags': ['浪漫', '咖啡厅', '约会'],
    },
    {
      'id': 'scene_002',
      'name': '校园图书馆',
      'category': '学习场景',
      'description': '安静的图书馆环境，适合学习讨论',
      'thumbnail': 'https://example.com/scene_002_thumb.jpg',
      'status': '审核中',
      'createTime': DateTime.now().subtract(const Duration(hours: 8)),
      'useCount': 1850,
      'rating': 4.5,
      'tags': ['学习', '图书馆', '校园'],
    },
    {
      'id': 'scene_003',
      'name': '海边夕阳',
      'category': '自然场景',
      'description': '美丽的海边夕阳景色，营造浪漫氛围',
      'thumbnail': 'https://example.com/scene_003_thumb.jpg',
      'status': '已发布',
      'createTime': DateTime.now().subtract(const Duration(days: 5)),
      'useCount': 4500,
      'rating': 4.9,
      'tags': ['海边', '夕阳', '浪漫'],
    },
    {
      'id': 'scene_004',
      'name': '现代办公室',
      'category': '工作场景',
      'description': '现代化办公环境，适合职场对话',
      'thumbnail': 'https://example.com/scene_004_thumb.jpg',
      'status': '已下架',
      'createTime': DateTime.now().subtract(const Duration(days: 10)),
      'useCount': 980,
      'rating': 4.2,
      'tags': ['办公室', '职场', '现代'],
    },
  ];

  List<Map<String, dynamic>> get _filteredScenes {
    return _sceneData.where((scene) {
      final matchesSearch = scene['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
                           scene['description'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == '全部' || scene['category'] == _selectedCategory;
      final matchesStatus = _selectedStatus == '全部' || scene['status'] == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/content/scene',
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
                          '场景库管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理对话场景库，包括场景创建、分类、审核和发布',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('创建场景'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportScenes(),
                          icon: const Icon(Icons.download),
                          label: const Text('导出数据'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 统计卡片
                Row(
                  children: [
                    _buildStatCard('总场景数', '${_sceneData.length}', Icons.movie, AppColors.primary),
                    const SizedBox(width: 16),
                    _buildStatCard('已发布', '${_sceneData.where((s) => s['status'] == '已发布').length}', Icons.check_circle, AppColors.success),
                    const SizedBox(width: 16),
                    _buildStatCard('审核中', '${_sceneData.where((s) => s['status'] == '审核中').length}', Icons.pending, AppColors.warning),
                    const SizedBox(width: 16),
                    _buildStatCard('总使用量', '${_sceneData.fold(0, (sum, s) => sum + (s['useCount'] as int))}', Icons.visibility, AppColors.info),
                  ],
                ),
                const SizedBox(height: 24),

                // 搜索和筛选
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // 搜索框
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: '搜索场景名称或描述...',
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 分类筛选
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: '分类',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: ['全部', '约会场景', '学习场景', '自然场景', '工作场景', '娱乐场景'].map((category) {
                              return DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 状态筛选
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: '状态',
                              prefixIcon: Icon(Icons.info),
                            ),
                            items: ['全部', '已发布', '审核中', '已下架', '草稿'].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 场景列表
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        // 表格标题
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '场景列表 (${_filteredScenes.length})',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => setState(() {}),
                                    icon: const Icon(Icons.refresh),
                                    tooltip: '刷新数据',
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'batch_publish':
                                          _batchPublish();
                                          break;
                                        case 'batch_delete':
                                          _batchDelete();
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'batch_publish',
                                        child: Row(
                                          children: [
                                            Icon(Icons.publish),
                                            SizedBox(width: 8),
                                            Text('批量发布'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'batch_delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete),
                                            SizedBox(width: 8),
                                            Text('批量删除'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 数据表格
                        Expanded(
                          child: _buildSceneTable(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSceneTable() {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 900,
      columns: const [
        DataColumn2(
          label: Text('场景信息'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('分类'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('标签'),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('使用量'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('评分'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('操作'),
          size: ColumnSize.M,
        ),
      ],
      rows: _filteredScenes.map((scene) {
        return DataRow2(
          cells: [
            DataCell(
              Row(
                children: [
                  // 缩略图
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 场景信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          scene['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          scene['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'ID: ${scene['id']} • ${DateFormat('MM-dd HH:mm').format(scene['createTime'])}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DataCell(_buildCategoryChip(scene['category'])),
            DataCell(
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (scene['tags'] as List<String>).take(2).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            DataCell(_buildStatusChip(scene['status'])),
            DataCell(Text('${scene['useCount']}')),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text('${scene['rating']}'),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _previewScene(scene),
                    icon: const Icon(Icons.visibility),
                    tooltip: '预览',
                  ),
                  IconButton(
                    onPressed: () => _editScene(scene),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleSceneAction(value, scene),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Text('复制'),
                      ),
                      const PopupMenuItem(
                        value: 'publish',
                        child: Text('发布'),
                      ),
                      const PopupMenuItem(
                        value: 'unpublish',
                        child: Text('下架'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除'),
                      ),
                    ],
                    child: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case '约会场景':
        color = Colors.pink;
        break;
      case '学习场景':
        color = Colors.blue;
        break;
      case '自然场景':
        color = Colors.green;
        break;
      case '工作场景':
        color = Colors.orange;
        break;
      case '娱乐场景':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '已发布':
        color = AppColors.success;
        break;
      case '审核中':
        color = AppColors.warning;
        break;
      case '已下架':
        color = AppColors.error;
        break;
      default:
        color = AppTheme.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showCreateDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建场景功能开发中...')),
    );
  }

  void _exportScenes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出场景数据功能开发中...')),
    );
  }

  void _batchPublish() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量发布功能开发中...')),
    );
  }

  void _batchDelete() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量删除功能开发中...')),
    );
  }

  void _previewScene(Map<String, dynamic> scene) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预览场景: ${scene['name']}')),
    );
  }

  void _editScene(Map<String, dynamic> scene) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑场景: ${scene['name']}')),
    );
  }

  void _handleSceneAction(String action, Map<String, dynamic> scene) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对场景 ${scene['name']} 执行操作: $action')),
    );
  }
}