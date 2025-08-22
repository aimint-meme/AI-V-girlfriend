import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/character_model.dart';
import '../../providers/character_config_provider.dart';
import 'package:provider/provider.dart';

class CharacterConfigScreen extends StatefulWidget {
  const CharacterConfigScreen({super.key});

  @override
  State<CharacterConfigScreen> createState() => _CharacterConfigScreenState();
}

class _CharacterConfigScreenState extends State<CharacterConfigScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '全部';
  String _selectedType = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterConfigProvider>().loadCharacters();
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
      currentRoute: '/content/character',
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
                          '人设配置/模型管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理AI角色配置、模型参数、语音库和场景库',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateCharacterDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('创建角色'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showImportDialog(),
                          icon: const Icon(Icons.upload),
                          label: const Text('导入配置'),
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
                        title: '总角色数',
                        value: provider.totalCharacters.toString(),
                        subtitle: '活跃: ${provider.activeCharacters}',
                        trend: 12.5,
                        icon: Icons.person,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '模型配置',
                        value: provider.totalModels.toString(),
                        subtitle: '在线: ${provider.onlineModels}',
                        trend: 8.3,
                        icon: Icons.psychology,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '语音库',
                        value: provider.totalVoices.toString(),
                        subtitle: '可用: ${provider.availableVoices}',
                        trend: 15.7,
                        icon: Icons.record_voice_over,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '场景库',
                        value: provider.totalScenes.toString(),
                        subtitle: '启用: ${provider.enabledScenes}',
                        trend: 6.2,
                        icon: Icons.landscape,
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
                              icon: Icon(Icons.person),
                              text: '角色管理',
                            ),
                            Tab(
                              icon: Icon(Icons.psychology),
                              text: '模型配置',
                            ),
                            Tab(
                              icon: Icon(Icons.record_voice_over),
                              text: '语音库',
                            ),
                            Tab(
                              icon: Icon(Icons.landscape),
                              text: '场景库',
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
                            _buildCharacterManagement(provider),
                            _buildModelConfiguration(provider),
                            _buildVoiceLibrary(provider),
                            _buildSceneLibrary(provider),
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

  Widget _buildCharacterManagement(CharacterConfigProvider provider) {
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
                    hintText: '搜索角色名称、描述...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => _applyFilters(provider),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                  ),
                  items: ['全部', '活跃', '禁用', '开发中']
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
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: '类型',
                  ),
                  items: ['全部', '温柔型', '活泼型', '知性型', '冷酷型', '可爱型']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
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
      minWidth: 1000,
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
          label: Text('状态'),
          size: ColumnSize.S,
        ),
        DataColumn2(
          label: Text('使用次数'),
          size: ColumnSize.S,
          numeric: true,
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
      rows: provider.filteredCharacters.map((character) {
        return DataRow2(
          cells: [
            DataCell(
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: character.avatar.isNotEmpty
                        ? NetworkImage(character.avatar)
                        : null,
                    backgroundColor: AppColors.primary,
                    child: character.avatar.isEmpty
                        ? Text(
                            character.name.isNotEmpty ? character.name[0] : 'C',
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          character.description,
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
            DataCell(_buildTypeChip(character.type)),
            DataCell(_buildStatusChip(character.status)),
            DataCell(
              Text(
                NumberFormat('#,###').format(character.usageCount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            DataCell(
              Text(DateFormat('yyyy-MM-dd').format(character.updatedAt)),
            ),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _showCharacterDetail(character),
                    icon: const Icon(Icons.visibility),
                    tooltip: '查看详情',
                  ),
                  IconButton(
                    onPressed: () => _editCharacter(character),
                    icon: const Icon(Icons.edit),
                    tooltip: '编辑',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleCharacterAction(value, character),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'clone',
                        child: Text('克隆角色'),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Text('导出配置'),
                      ),
                      const PopupMenuItem(
                        value: 'toggle_status',
                        child: Text('切换状态'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('删除角色'),
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

  Widget _buildModelConfiguration(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 模型配置工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '模型配置管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAddModelDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('添加模型'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _testAllModels(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('测试模型'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 模型列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.models.length,
              itemBuilder: (context, index) {
                final model = provider.models[index];
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
                                    color: model.isOnline ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.psychology,
                                    color: model.isOnline ? AppColors.success : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      model.description,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: model.isOnline ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    model.isOnline ? '在线' : '离线',
                                    style: TextStyle(
                                      color: model.isOnline ? AppColors.success : Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                PopupMenuButton<String>(
                                  onSelected: (value) => _handleModelAction(value, model),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('编辑配置'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'test',
                                      child: Text('测试模型'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'toggle',
                                      child: Text('切换状态'),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('删除模型'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 模型参数
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildModelParam('类型', model.type),
                            _buildModelParam('版本', model.version),
                            _buildModelParam('温度', model.temperature.toString()),
                            _buildModelParam('最大长度', model.maxTokens.toString()),
                            _buildModelParam('响应时间', '${model.avgResponseTime}ms'),
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

  Widget _buildVoiceLibrary(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 语音库工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '语音库管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showUploadVoiceDialog(),
                    icon: const Icon(Icons.upload),
                    label: const Text('上传语音'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _generateVoice(),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI生成'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 语音库网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.voices.length,
              itemBuilder: (context, index) {
                final voice = provider.voices[index];
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
                              Icons.record_voice_over,
                              color: voice.isAvailable ? AppColors.primary : Colors.grey,
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleVoiceAction(value, voice),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'play',
                                  child: Text('试听'),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('编辑'),
                                ),
                                const PopupMenuItem(
                                  value: 'download',
                                  child: Text('下载'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          voice.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voice.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                voice.type,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.info,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${voice.duration}s',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondaryColor,
                              ),
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

  Widget _buildSceneLibrary(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 场景库工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '场景库管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreateSceneDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('创建场景'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _importScenes(),
                    icon: const Icon(Icons.download),
                    label: const Text('导入场景'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 场景库列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.scenes.length,
              itemBuilder: (context, index) {
                final scene = provider.scenes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: scene.thumbnail.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(scene.thumbnail),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: scene.thumbnail.isEmpty ? AppColors.primary.withOpacity(0.1) : null,
                      ),
                      child: scene.thumbnail.isEmpty
                          ? Icon(
                              Icons.landscape,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    title: Text(
                      scene.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(scene.description),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scene.isEnabled ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                scene.isEnabled ? '启用' : '禁用',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: scene.isEnabled ? AppColors.success : Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '使用 ${scene.usageCount} 次',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _handleSceneAction(value, scene),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'preview',
                          child: Text('预览场景'),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('编辑场景'),
                        ),
                        const PopupMenuItem(
                          value: 'toggle',
                          child: Text('切换状态'),
                        ),
                        const PopupMenuItem(
                          value: 'export',
                          child: Text('导出场景'),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('删除场景'),
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

  Widget _buildTypeChip(String type) {
    Color color;
    switch (type) {
      case '温柔型':
        color = AppColors.success;
        break;
      case '活泼型':
        color = AppColors.warning;
        break;
      case '知性型':
        color = AppColors.info;
        break;
      case '冷酷型':
        color = AppColors.secondary;
        break;
      case '可爱型':
        color = AppColors.primary;
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
      case '活跃':
        color = AppColors.success;
        break;
      case '禁用':
        color = AppColors.error;
        break;
      case '开发中':
        color = AppColors.warning;
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

  Widget _buildModelParam(String label, String value) {
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

  void _applyFilters(CharacterConfigProvider provider) {
    provider.applyFilters(
      searchQuery: _searchController.text,
      status: _selectedStatus == '全部' ? null : _selectedStatus,
      type: _selectedType == '全部' ? null : _selectedType,
    );
  }

  void _showCreateCharacterDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建角色功能开发中...')),
    );
  }

  void _showImportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入配置功能开发中...')),
    );
  }

  void _showCharacterDetail(CharacterModel character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看角色 ${character.name} 的详情')),
    );
  }

  void _editCharacter(CharacterModel character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑角色 ${character.name}')),
    );
  }

  void _handleCharacterAction(String action, CharacterModel character) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对角色 ${character.name} 执行操作: $action')),
    );
  }

  void _showAddModelDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('添加模型功能开发中...')),
    );
  }

  void _testAllModels() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('测试所有模型功能开发中...')),
    );
  }

  void _handleModelAction(String action, ModelConfig model) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对模型 ${model.name} 执行操作: $action')),
    );
  }

  void _showUploadVoiceDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('上传语音功能开发中...')),
    );
  }

  void _generateVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI生成语音功能开发中...')),
    );
  }

  void _handleVoiceAction(String action, VoiceModel voice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对语音 ${voice.name} 执行操作: $action')),
    );
  }

  void _showCreateSceneDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建场景功能开发中...')),
    );
  }

  void _importScenes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入场景功能开发中...')),
    );
  }

  void _handleSceneAction(String action, SceneModel scene) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对场景 ${scene.name} 执行操作: $action')),
    );
  }
}