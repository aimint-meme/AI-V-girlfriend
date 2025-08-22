import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/character_config_provider.dart';

class CharacterCreationScreen extends StatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  State<CharacterCreationScreen> createState() => _CharacterCreationScreenState();
}

class _CharacterCreationScreenState extends State<CharacterCreationScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // 基础信息控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _backgroundController = TextEditingController();
  
  // 外观属性控制器
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // 性格特征控制器
  final TextEditingController _personalityController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _specialSkillsController = TextEditingController();
  
  // 选择项
  String _selectedType = '温柔型';
  String _selectedGender = '女性';
  String _selectedHairColor = '黑色';
  String _selectedEyeColor = '黑色';
  String _selectedStyle = '邻家女孩';
  String _selectedVoiceType = '甜美';
  
  // 性格滑块值
  double _gentleness = 80.0;
  double _liveliness = 60.0;
  double _intelligence = 70.0;
  double _independence = 50.0;
  double _humor = 65.0;
  double _romance = 75.0;
  
  bool _isEditing = false;
  String? _editingCharacterId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterConfigProvider>().loadCharacterCreationData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _backgroundController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _personalityController.dispose();
    _hobbiesController.dispose();
    _specialSkillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/characters/create',
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
                          _isEditing ? '编辑角色' : '角色创建与编辑',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditing ? '编辑现有角色的属性和配置' : '创建新的AI角色并配置其属性特征',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (_isEditing) ...[
                          OutlinedButton.icon(
                            onPressed: () => _cancelEdit(),
                            icon: const Icon(Icons.cancel),
                            label: const Text('取消编辑'),
                          ),
                          const SizedBox(width: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: () => _previewCharacter(),
                          icon: const Icon(Icons.visibility),
                          label: const Text('预览角色'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _saveCharacter(),
                          icon: Icon(_isEditing ? Icons.save : Icons.add),
                          label: Text(_isEditing ? '保存修改' : '创建角色'),
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
                        title: '创建总数',
                        value: '${provider.totalCreated}',
                        subtitle: '本月新增: ${provider.monthlyCreated}',
                        trend: provider.creationTrend,
                        icon: Icons.add_circle,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '模板使用',
                        value: '${provider.templatesUsed}',
                        subtitle: '热门模板使用次数',
                        trend: provider.templateTrend,
                        icon: Icons.content_copy,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均完成度',
                        value: '${provider.avgCompletionRate.toStringAsFixed(1)}%',
                        subtitle: '角色信息完整性',
                        trend: provider.completionTrend,
                        icon: Icons.check_circle,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '成功率',
                        value: '${provider.successRate.toStringAsFixed(1)}%',
                        subtitle: '角色创建成功率',
                        trend: provider.successTrend,
                        icon: Icons.trending_up,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 创建表单
                Expanded(
                  child: Container(
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
                                icon: Icon(Icons.info),
                                text: '基础信息',
                              ),
                              Tab(
                                icon: Icon(Icons.face),
                                text: '外观设定',
                              ),
                              Tab(
                                icon: Icon(Icons.psychology),
                                text: '性格特征',
                              ),
                              Tab(
                                icon: Icon(Icons.preview),
                                text: '预览确认',
                              ),
                            ],
                          ),
                        ),
                        // 表单内容
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildBasicInfoTab(),
                                _buildAppearanceTab(),
                                _buildPersonalityTab(),
                                _buildPreviewTab(),
                              ],
                            ),
                          ),
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

  Widget _buildBasicInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基础信息设定',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '角色名称 *',
                      hintText: '请输入角色名称',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入角色名称';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: '角色类型 *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ['温柔型', '活泼型', '知性型', '冷酷型', '神秘型', '可爱型']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '角色描述 *',
                hintText: '请输入角色的简短描述',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入角色描述';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _backgroundController,
              decoration: const InputDecoration(
                labelText: '背景故事',
                hintText: '请输入角色的背景故事（可选）',
                prefixIcon: Icon(Icons.auto_stories),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            
            // 快速模板选择
            Text(
              '快速模板',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _generateTemplates().map((template) {
                return InkWell(
                  onTap: () => _applyTemplate(template),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          template['icon'],
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template['name'],
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '外观设定',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // 基本信息
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: '性别',
                      prefixIcon: Icon(Icons.wc),
                    ),
                    items: ['女性', '男性']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: '年龄',
                      hintText: '18-30',
                      prefixIcon: Icon(Icons.cake),
                      suffixText: '岁',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: '身高',
                      hintText: '160-175',
                      prefixIcon: Icon(Icons.height),
                      suffixText: 'cm',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 外观特征
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedHairColor,
                    decoration: const InputDecoration(
                      labelText: '发色',
                      prefixIcon: Icon(Icons.palette),
                    ),
                    items: ['黑色', '棕色', '金色', '银色', '粉色', '蓝色']
                        .map((color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedHairColor = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEyeColor,
                    decoration: const InputDecoration(
                      labelText: '瞳色',
                      prefixIcon: Icon(Icons.remove_red_eye),
                    ),
                    items: ['黑色', '棕色', '蓝色', '绿色', '灰色', '紫色']
                        .map((color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEyeColor = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStyle,
                    decoration: const InputDecoration(
                      labelText: '风格',
                      prefixIcon: Icon(Icons.style),
                    ),
                    items: ['邻家女孩', '职场精英', '学院风', '甜美公主', '酷炫女王', '文艺少女']
                        .map((style) => DropdownMenuItem(
                              value: style,
                              child: Text(style),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStyle = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 声音设定
            Text(
              '声音设定',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedVoiceType,
              decoration: const InputDecoration(
                labelText: '声音类型',
                prefixIcon: Icon(Icons.record_voice_over),
              ),
              items: ['甜美', '温柔', '活泼', '知性', '冷酷', '神秘']
                  .map((voice) => DropdownMenuItem(
                        value: voice,
                        child: Text(voice),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVoiceType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // 外观预览区域
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '角色外观预览',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '（此处可集成3D角色预览）',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性格特征',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // 性格滑块
            _buildPersonalitySlider('温柔度', _gentleness, (value) {
              setState(() {
                _gentleness = value;
              });
            }, Icons.favorite, AppColors.success),
            
            _buildPersonalitySlider('活泼度', _liveliness, (value) {
              setState(() {
                _liveliness = value;
              });
            }, Icons.celebration, AppColors.warning),
            
            _buildPersonalitySlider('智慧度', _intelligence, (value) {
              setState(() {
                _intelligence = value;
              });
            }, Icons.psychology, AppColors.primary),
            
            _buildPersonalitySlider('独立性', _independence, (value) {
              setState(() {
                _independence = value;
              });
            }, Icons.person_pin, AppColors.info),
            
            _buildPersonalitySlider('幽默感', _humor, (value) {
              setState(() {
                _humor = value;
              });
            }, Icons.sentiment_very_satisfied, Colors.orange),
            
            _buildPersonalitySlider('浪漫度', _romance, (value) {
              setState(() {
                _romance = value;
              });
            }, Icons.favorite_border, Colors.pink),
            
            const SizedBox(height: 24),
            
            // 详细描述
            TextFormField(
              controller: _personalityController,
              decoration: const InputDecoration(
                labelText: '性格描述',
                hintText: '详细描述角色的性格特点...',
                prefixIcon: Icon(Icons.psychology),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _hobbiesController,
              decoration: const InputDecoration(
                labelText: '兴趣爱好',
                hintText: '角色的兴趣爱好，用逗号分隔',
                prefixIcon: Icon(Icons.interests),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _specialSkillsController,
              decoration: const InputDecoration(
                labelText: '特殊技能',
                hintText: '角色的特殊技能或才艺',
                prefixIcon: Icon(Icons.star),
              ),
            ),
            const SizedBox(height: 24),
            
            // 性格雷达图预览
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.radar,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '性格雷达图',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '（此处可集成雷达图表）',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '角色预览',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // 角色卡片预览
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // 头像区域
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      _nameController.text.isNotEmpty ? _nameController.text[0] : '?',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 基础信息
                  Text(
                    _nameController.text.isNotEmpty ? _nameController.text : '角色名称',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTypeChip(_selectedType),
                  const SizedBox(height: 16),
                  
                  Text(
                    _descriptionController.text.isNotEmpty 
                        ? _descriptionController.text 
                        : '角色描述将在这里显示',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // 属性展示
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttributeItem('温柔', _gentleness, AppColors.success),
                      _buildAttributeItem('活泼', _liveliness, AppColors.warning),
                      _buildAttributeItem('智慧', _intelligence, AppColors.primary),
                      _buildAttributeItem('独立', _independence, AppColors.info),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 详细信息表格
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '详细信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('角色类型', _selectedType),
                    _buildInfoRow('性别', _selectedGender),
                    _buildInfoRow('年龄', _ageController.text.isNotEmpty ? '${_ageController.text}岁' : '未设置'),
                    _buildInfoRow('身高', _heightController.text.isNotEmpty ? '${_heightController.text}cm' : '未设置'),
                    _buildInfoRow('发色', _selectedHairColor),
                    _buildInfoRow('瞳色', _selectedEyeColor),
                    _buildInfoRow('风格', _selectedStyle),
                    _buildInfoRow('声音', _selectedVoiceType),
                    _buildInfoRow('兴趣爱好', _hobbiesController.text.isNotEmpty ? _hobbiesController.text : '未设置'),
                    _buildInfoRow('特殊技能', _specialSkillsController.text.isNotEmpty ? _specialSkillsController.text : '未设置'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySlider(String label, double value, ValueChanged<double> onChanged, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: onChanged,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildAttributeItem(String label, double value, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                value: value / 100,
                strokeWidth: 4,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateTemplates() {
    return [
      {
        'name': '邻家女孩',
        'description': '温柔可爱的邻家女孩',
        'icon': Icons.home,
        'data': {
          'type': '温柔型',
          'description': '温柔可爱，善解人意的邻家女孩',
          'gentleness': 85.0,
          'liveliness': 60.0,
          'intelligence': 70.0,
        },
      },
      {
        'name': '活力少女',
        'description': '充满活力的阳光少女',
        'icon': Icons.wb_sunny,
        'data': {
          'type': '活泼型',
          'description': '充满活力，积极向上的阳光少女',
          'gentleness': 60.0,
          'liveliness': 90.0,
          'intelligence': 65.0,
        },
      },
      {
        'name': '知性美女',
        'description': '聪明睿智的知性美女',
        'icon': Icons.school,
        'data': {
          'type': '知性型',
          'description': '聪明睿智，博学多才的知性美女',
          'gentleness': 70.0,
          'liveliness': 50.0,
          'intelligence': 95.0,
        },
      },
      {
        'name': '冰山美人',
        'description': '高冷神秘的冰山美人',
        'icon': Icons.ac_unit,
        'data': {
          'type': '冷酷型',
          'description': '高冷神秘，外冷内热的冰山美人',
          'gentleness': 40.0,
          'liveliness': 30.0,
          'intelligence': 85.0,
        },
      },
    ];
  }

  void _applyTemplate(Map<String, dynamic> template) {
    final data = template['data'] as Map<String, dynamic>;
    setState(() {
      _selectedType = data['type'];
      _descriptionController.text = data['description'];
      _gentleness = data['gentleness'];
      _liveliness = data['liveliness'];
      _intelligence = data['intelligence'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已应用模板: ${template['name']}')),
    );
  }

  void _previewCharacter() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入角色名称')),
      );
      return;
    }
    
    _tabController.animateTo(3);
  }

  void _saveCharacter() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? '角色修改成功！' : '角色创建成功！'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // 重置表单
      _resetForm();
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingCharacterId = null;
    });
    _resetForm();
  }

  void _resetForm() {
    _nameController.clear();
    _descriptionController.clear();
    _backgroundController.clear();
    _ageController.clear();
    _heightController.clear();
    _weightController.clear();
    _personalityController.clear();
    _hobbiesController.clear();
    _specialSkillsController.clear();
    
    setState(() {
      _selectedType = '温柔型';
      _selectedGender = '女性';
      _selectedHairColor = '黑色';
      _selectedEyeColor = '黑色';
      _selectedStyle = '邻家女孩';
      _selectedVoiceType = '甜美';
      _gentleness = 80.0;
      _liveliness = 60.0;
      _intelligence = 70.0;
      _independence = 50.0;
      _humor = 65.0;
      _romance = 75.0;
    });
    
    _tabController.animateTo(0);
  }
}