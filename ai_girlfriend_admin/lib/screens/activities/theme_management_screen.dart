import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../models/theme_model.dart';
import '../../providers/theme_management_provider.dart';
import 'package:provider/provider.dart';

class ThemeManagementScreen extends StatefulWidget {
  const ThemeManagementScreen({super.key});

  @override
  State<ThemeManagementScreen> createState() => _ThemeManagementScreenState();
}

class _ThemeManagementScreenState extends State<ThemeManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '全部';
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeManagementProvider>().loadThemes();
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
      currentRoute: '/activities/themes',
      child: Consumer<ThemeManagementProvider>(
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
                          '节日主题/皮肤管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理节日主题、皮肤上线和活动策划',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showCreateThemeDialog(),
                          icon: const Icon(Icons.add),
                          label: const Text('创建主题'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _showImportDialog(),
                          icon: const Icon(Icons.upload),
                          label: const Text('导入资源'),
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
                        title: '总主题数',
                        value: provider.totalThemes.toString(),
                        subtitle: '活跃: ${provider.activeThemes}',
                        trend: 8.5,
                        icon: Icons.palette,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '节日主题',
                        value: provider.festivalThemes.toString(),
                        subtitle: '进行中: ${provider.activeFestivals}',
                        trend: 15.2,
                        icon: Icons.celebration,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '皮肤资源',
                        value: provider.totalSkins.toString(),
                        subtitle: '可用: ${provider.availableSkins}',
                        trend: 12.3,
                        icon: Icons.brush,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '用户使用率',
                        value: '${provider.usageRate.toStringAsFixed(1)}%',
                        subtitle: '本月统计',
                        trend: 6.8,
                        icon: Icons.trending_up,
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
                              icon: Icon(Icons.palette),
                              text: '主题管理',
                            ),
                            Tab(
                              icon: Icon(Icons.celebration),
                              text: '节日活动',
                            ),
                            Tab(
                              icon: Icon(Icons.brush),
                              text: '皮肤库',
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
                            _buildThemeManagement(provider),
                            _buildFestivalActivities(provider),
                            _buildSkinLibrary(provider),
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

  Widget _buildThemeManagement(ThemeManagementProvider provider) {
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
                    hintText: '搜索主题名称、描述...',
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
                  items: ['全部', '活跃', '禁用', '草稿', '已过期']
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
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: '分类',
                  ),
                  items: ['全部', '节日', '季节', '特殊活动', '常规主题']
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
            ],
          ),
          const SizedBox(height: 20),
          
          // 主题网格
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildThemeGrid(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeGrid(ThemeManagementProvider provider) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: provider.filteredThemes.length,
      itemBuilder: (context, index) {
        final theme = provider.filteredThemes[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 主题预览图
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: theme.previewImage.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(theme.previewImage),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient: theme.previewImage.isEmpty
                        ? LinearGradient(
                            colors: [
                              Color(int.parse(theme.primaryColor.replaceAll('#', '0xFF'))),
                              Color(int.parse(theme.secondaryColor.replaceAll('#', '0xFF'))),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // 状态标签
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildStatusChip(theme.status),
                      ),
                      // 操作按钮
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: PopupMenuButton<String>(
                          onSelected: (value) => _handleThemeAction(value, theme),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'preview',
                              child: Text('预览主题'),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('编辑主题'),
                            ),
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Text('复制主题'),
                            ),
                            const PopupMenuItem(
                              value: 'export',
                              child: Text('导出主题'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'toggle_status',
                              child: Text('切换状态'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除主题'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 主题信息
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        theme.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.description,
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
                              color: _getCategoryColor(theme.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              theme.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: _getCategoryColor(theme.category),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility,
                                size: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${theme.usageCount}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondaryColor,
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildFestivalActivities(ThemeManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 节日活动工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '节日活动管理',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showCreateFestivalDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('创建活动'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showFestivalCalendar(),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('活动日历'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 节日活动列表
          Expanded(
            child: ListView.builder(
              itemCount: provider.festivals.length,
              itemBuilder: (context, index) {
                final festival = provider.festivals[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: festival.icon.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(festival.icon),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                                color: festival.icon.isEmpty ? AppColors.primary.withOpacity(0.1) : null,
                              ),
                              child: festival.icon.isEmpty
                                  ? Icon(
                                      Icons.celebration,
                                      color: AppColors.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        festival.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      _buildFestivalStatusChip(festival.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    festival.description,
                                    style: TextStyle(
                                      color: AppTheme.textSecondaryColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${DateFormat('MM-dd').format(festival.startDate)} - ${DateFormat('MM-dd').format(festival.endDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.people,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${festival.participantCount} 参与',
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
                            PopupMenuButton<String>(
                              onSelected: (value) => _handleFestivalAction(value, festival),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('查看详情'),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('编辑活动'),
                                ),
                                const PopupMenuItem(
                                  value: 'participants',
                                  child: Text('参与用户'),
                                ),
                                const PopupMenuItem(
                                  value: 'analytics',
                                  child: Text('数据分析'),
                                ),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                  value: 'toggle',
                                  child: Text('切换状态'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除活动'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (festival.rewards.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            '活动奖励:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: festival.rewards.map((reward) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.success.withOpacity(0.3)),
                              ),
                              child: Text(
                                reward,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
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

  Widget _buildSkinLibrary(ThemeManagementProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 皮肤库工具栏
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '皮肤资源库',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showUploadSkinDialog(),
                    icon: const Icon(Icons.upload),
                    label: const Text('上传皮肤'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showSkinGenerator(),
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI生成'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // 皮肤分类标签
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['全部', '背景', '按钮', '图标', '字体', '动效'].map((category) {
                final isSelected = provider.selectedSkinCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      provider.setSkinCategory(category);
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          
          // 皮肤网格
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: provider.filteredSkins.length,
              itemBuilder: (context, index) {
                final skin = provider.filteredSkins[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // 皮肤预览
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          image: skin.previewUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(skin.previewUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: skin.previewUrl.isEmpty ? Colors.grey.shade200 : null,
                        ),
                        child: skin.previewUrl.isEmpty
                            ? Icon(
                                Icons.image,
                                color: Colors.grey.shade400,
                                size: 32,
                              )
                            : null,
                      ),
                      // 皮肤信息覆盖层
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skin.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    skin.category,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.download,
                                        color: Colors.white70,
                                        size: 10,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${skin.downloadCount}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 操作按钮
                      Positioned(
                        top: 4,
                        right: 4,
                        child: PopupMenuButton<String>(
                          onSelected: (value) => _handleSkinAction(value, skin),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'preview',
                              child: Text('预览'),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: Text('下载'),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('编辑'),
                            ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('删除'),
                            ),
                          ],
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
      case '草稿':
        color = AppColors.warning;
        break;
      case '已过期':
        color = Colors.grey;
        break;
      default:
        color = AppColors.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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

  Widget _buildFestivalStatusChip(String status) {
    Color color;
    String displayText;
    switch (status) {
      case 'upcoming':
        color = AppColors.info;
        displayText = '即将开始';
        break;
      case 'active':
        color = AppColors.success;
        displayText = '进行中';
        break;
      case 'ended':
        color = Colors.grey;
        displayText = '已结束';
        break;
      case 'cancelled':
        color = AppColors.error;
        displayText = '已取消';
        break;
      default:
        color = AppColors.warning;
        displayText = '草稿';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '节日':
        return AppColors.warning;
      case '季节':
        return AppColors.info;
      case '特殊活动':
        return AppColors.secondary;
      case '常规主题':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  void _applyFilters(ThemeManagementProvider provider) {
    provider.applyFilters(
      searchQuery: _searchController.text,
      status: _selectedStatus == '全部' ? null : _selectedStatus,
      category: _selectedCategory == '全部' ? null : _selectedCategory,
    );
  }

  void _showCreateThemeDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建主题功能开发中...')),
    );
  }

  void _showImportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入资源功能开发中...')),
    );
  }

  void _handleThemeAction(String action, ThemeModel theme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对主题 ${theme.name} 执行操作: $action')),
    );
  }

  void _showCreateFestivalDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('创建节日活动功能开发中...')),
    );
  }

  void _showFestivalCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('活动日历功能开发中...')),
    );
  }

  void _handleFestivalAction(String action, FestivalModel festival) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对活动 ${festival.name} 执行操作: $action')),
    );
  }

  void _showUploadSkinDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('上传皮肤功能开发中...')),
    );
  }

  void _showSkinGenerator() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI皮肤生成功能开发中...')),
    );
  }

  void _handleSkinAction(String action, SkinModel skin) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对皮肤 ${skin.name} 执行操作: $action')),
    );
  }
}