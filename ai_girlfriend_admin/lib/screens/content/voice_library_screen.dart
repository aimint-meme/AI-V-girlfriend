import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../constants/app_theme.dart';
import '../../providers/content_analysis_provider.dart';

class VoiceLibraryScreen extends StatefulWidget {
  const VoiceLibraryScreen({super.key});

  @override
  State<VoiceLibraryScreen> createState() => _VoiceLibraryScreenState();
}

class _VoiceLibraryScreenState extends State<VoiceLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '全部';
  String _selectedStatus = '全部';

  // 模拟语音数据
  final List<Map<String, dynamic>> _voiceData = [
    {
      'id': 'voice_001',
      'name': '温柔女声',
      'category': '情感类',
      'duration': '00:15',
      'size': '2.3MB',
      'format': 'MP3',
      'status': '已发布',
      'uploadTime': DateTime.now().subtract(const Duration(days: 1)),
      'downloadCount': 1250,
      'rating': 4.8,
    },
    {
      'id': 'voice_002',
      'name': '活泼少女音',
      'category': '角色类',
      'duration': '00:12',
      'size': '1.8MB',
      'format': 'WAV',
      'status': '审核中',
      'uploadTime': DateTime.now().subtract(const Duration(hours: 6)),
      'downloadCount': 890,
      'rating': 4.6,
    },
    {
      'id': 'voice_003',
      'name': '知性御姐音',
      'category': '情感类',
      'duration': '00:18',
      'size': '3.1MB',
      'format': 'MP3',
      'status': '已发布',
      'uploadTime': DateTime.now().subtract(const Duration(days: 3)),
      'downloadCount': 2100,
      'rating': 4.9,
    },
    {
      'id': 'voice_004',
      'name': '甜美萝莉音',
      'category': '角色类',
      'duration': '00:10',
      'size': '1.5MB',
      'format': 'MP3',
      'status': '已下架',
      'uploadTime': DateTime.now().subtract(const Duration(days: 7)),
      'downloadCount': 650,
      'rating': 4.3,
    },
  ];

  List<Map<String, dynamic>> get _filteredVoices {
    return _voiceData.where((voice) {
      final matchesSearch = voice['name'].toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesCategory = _selectedCategory == '全部' || voice['category'] == _selectedCategory;
      final matchesStatus = _selectedStatus == '全部' || voice['status'] == _selectedStatus;
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
      currentRoute: '/content/voice',
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
                          '语音库管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理语音资源库，包括语音上传、分类、审核和发布',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showUploadDialog(),
                          icon: const Icon(Icons.upload),
                          label: const Text('上传语音'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _exportVoices(),
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
                    _buildStatCard('总语音数', '${_voiceData.length}', Icons.audiotrack, AppColors.primary),
                    const SizedBox(width: 16),
                    _buildStatCard('已发布', '${_voiceData.where((v) => v['status'] == '已发布').length}', Icons.check_circle, AppColors.success),
                    const SizedBox(width: 16),
                    _buildStatCard('审核中', '${_voiceData.where((v) => v['status'] == '审核中').length}', Icons.pending, AppColors.warning),
                    const SizedBox(width: 16),
                    _buildStatCard('总下载量', '${_voiceData.fold(0, (sum, v) => sum + (v['downloadCount'] as int))}', Icons.download, AppColors.info),
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
                              hintText: '搜索语音名称...',
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
                            items: ['全部', '情感类', '角色类', '场景类', '其他'].map((category) {
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

                // 语音列表
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
                                '语音列表 (${_filteredVoices.length})',
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
                          child: _buildVoiceTable(),
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

  Widget _buildVoiceTable() {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 800,
      columns: const [
        DataColumn2(
          label: Text('语音信息'),
          size: ColumnSize.L,
        ),
        DataColumn2(
          label: Text('分类'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('时长'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('大小'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('下载量'),
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
      rows: _filteredVoices.map((voice) {
        return DataRow2(
          cells: [
            DataCell(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    voice['name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'ID: ${voice['id']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  Text(
                    '${voice['format']} • ${DateFormat('MM-dd HH:mm').format(voice['uploadTime'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            DataCell(_buildCategoryChip(voice['category'])),
            DataCell(Text(voice['duration'])),
            DataCell(Text(voice['size'])),
            DataCell(_buildStatusChip(voice['status'])),
            DataCell(Text('${voice['downloadCount']}')),
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
                  Text('${voice['rating']}'),
                ],
              ),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _playVoice(voice),
                    icon: const Icon(Icons.play_arrow),
                    tooltip: '播放',
                  ),
                  IconButton(
                    onPressed: () => _editVoice(voice),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleVoiceAction(value, voice),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'download',
                        child: Text('下载'),
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
      case '情感类':
        color = Colors.pink;
        break;
      case '角色类':
        color = Colors.blue;
        break;
      case '场景类':
        color = Colors.green;
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

  void _showUploadDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('上传语音功能开发中...')),
    );
  }

  void _exportVoices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出语音数据功能开发中...')),
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

  void _playVoice(Map<String, dynamic> voice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('播放语音: ${voice['name']}')),
    );
  }

  void _editVoice(Map<String, dynamic> voice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑语音: ${voice['name']}')),
    );
  }

  void _handleVoiceAction(String action, Map<String, dynamic> voice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对语音 ${voice['name']} 执行操作: $action')),
    );
  }
}