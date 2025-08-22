import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/character_config_provider.dart';

class CharacterAbilityScreen extends StatefulWidget {
  const CharacterAbilityScreen({super.key});

  @override
  State<CharacterAbilityScreen> createState() => _CharacterAbilityScreenState();
}

class _CharacterAbilityScreenState extends State<CharacterAbilityScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCharacter = '小雪';
  String _selectedAbilityType = '全部';
  String _selectedInteractionMode = '全部';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterConfigProvider>().loadCharacterAbilities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/characters/config',
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
                          '角色能力配置',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '配置AI角色的对话能力、互动模式和智能行为',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedCharacter,
                          items: ['小雪', '小樱', '小慧', '小冰', '小萌']
                              .map((character) => DropdownMenuItem(
                                    value: character,
                                    child: Text('当前角色: $character'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCharacter = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () => _testAbilities(),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('测试能力'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _saveConfiguration(),
                          icon: const Icon(Icons.save),
                          label: const Text('保存配置'),
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
                        title: '配置完成度',
                        value: '${provider.configCompleteness.toStringAsFixed(1)}%',
                        subtitle: '能力配置完整性',
                        trend: provider.completenessTrend,
                        icon: Icons.settings,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '响应准确率',
                        value: '${provider.responseAccuracy.toStringAsFixed(1)}%',
                        subtitle: '对话响应准确性',
                        trend: provider.accuracyTrend,
                        icon: Icons.check_circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '互动模式',
                        value: '${provider.activeInteractionModes}',
                        subtitle: '已启用的互动模式',
                        trend: provider.interactionTrend,
                        icon: Icons.chat,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '学习能力',
                        value: '${provider.learningCapacity.toStringAsFixed(1)}%',
                        subtitle: '自适应学习能力',
                        trend: provider.learningTrend,
                        icon: Icons.psychology,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 标签页
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
                              icon: Icon(Icons.chat),
                              text: '对话能力',
                            ),
                            Tab(
                              icon: Icon(Icons.touch_app),
                              text: '互动模式',
                            ),
                            Tab(
                              icon: Icon(Icons.psychology),
                              text: '智能行为',
                            ),
                            Tab(
                              icon: Icon(Icons.tune),
                              text: '高级设置',
                            ),
                          ],
                        ),
                      ),
                      // 标签页内容
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDialogueAbilities(provider),
                            _buildInteractionModes(provider),
                            _buildIntelligentBehavior(provider),
                            _buildAdvancedSettings(provider),
                          ],
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

  Widget _buildDialogueAbilities(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 对话能力配置
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
                          '语言理解能力',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAbilitySlider('语义理解', 85.0, Icons.translate),
                        _buildAbilitySlider('情感识别', 78.0, Icons.sentiment_satisfied),
                        _buildAbilitySlider('意图识别', 82.0, Icons.psychology),
                        _buildAbilitySlider('上下文理解', 75.0, Icons.history),
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
                        Text(
                          '回复生成能力',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildAbilitySlider('创造性', 70.0, Icons.lightbulb),
                        _buildAbilitySlider('逻辑性', 88.0, Icons.account_tree),
                        _buildAbilitySlider('情感表达', 92.0, Icons.favorite),
                        _buildAbilitySlider('个性化', 85.0, Icons.person),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 对话主题配置
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '对话主题配置',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _generateDialogueTopics().map((topic) {
                      return FilterChip(
                        label: Text(topic['name']),
                        selected: topic['enabled'],
                        onSelected: (selected) {
                          setState(() {
                            topic['enabled'] = selected;
                          });
                        },
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        checkmarkColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionModes(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 互动模式列表
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _generateInteractionModes().length,
              itemBuilder: (context, index) {
                final mode = _generateInteractionModes()[index];
                return _buildInteractionModeCard(mode);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligentBehavior(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 智能行为配置
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
                          '学习能力',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBehaviorSwitch('自适应学习', true, '根据用户偏好调整回复风格'),
                        _buildBehaviorSwitch('记忆学习', true, '记住用户的个人信息和偏好'),
                        _buildBehaviorSwitch('情感学习', false, '学习用户的情感模式'),
                        _buildBehaviorSwitch('行为预测', false, '预测用户可能的行为'),
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
                        Text(
                          '主动行为',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBehaviorSwitch('主动问候', true, '在适当时机主动向用户问候'),
                        _buildBehaviorSwitch('话题引导', true, '主动引导有趣的话题'),
                        _buildBehaviorSwitch('关怀提醒', false, '关心用户的日常生活'),
                        _buildBehaviorSwitch('情感支持', true, '在用户需要时提供情感支持'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 行为触发条件
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '行为触发条件',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._generateTriggerConditions().map((condition) {
                    return _buildTriggerConditionItem(condition);
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings(CharacterConfigProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 高级参数配置
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
                          '模型参数',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildParameterSlider('Temperature', 0.7, 0.0, 1.0, '控制回复的创造性'),
                        _buildParameterSlider('Top-p', 0.9, 0.0, 1.0, '控制词汇选择的多样性'),
                        _buildParameterSlider('Max Tokens', 150.0, 50.0, 500.0, '最大回复长度'),
                        _buildParameterSlider('Frequency Penalty', 0.3, 0.0, 2.0, '减少重复内容'),
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
                        Text(
                          '安全设置',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSafetySwitch('内容过滤', true, '过滤不当内容'),
                        _buildSafetySwitch('敏感词检测', true, '检测敏感词汇'),
                        _buildSafetySwitch('情感保护', true, '避免负面情感影响'),
                        _buildSafetySwitch('隐私保护', true, '保护用户隐私信息'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 性能优化
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '性能优化',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOptimizationCard(
                          '响应速度',
                          '平均 1.2s',
                          Icons.speed,
                          AppColors.success,
                          '优化模型推理速度',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptimizationCard(
                          '内存使用',
                          '256 MB',
                          Icons.memory,
                          AppColors.warning,
                          '优化内存占用',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildOptimizationCard(
                          '并发处理',
                          '50 用户',
                          Icons.people,
                          AppColors.info,
                          '支持并发用户数',
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

  Widget _buildAbilitySlider(String label, double value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionModeCard(Map<String, dynamic> mode) {
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
                      mode['icon'],
                      color: mode['color'],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mode['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: mode['enabled'],
                  onChanged: (value) {
                    setState(() {
                      mode['enabled'] = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              mode['description'],
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
                  '使用率: ${mode['usage']}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _configureMode(mode),
                  child: const Text('配置'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorSwitch(String title, bool value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                // 更新状态
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerConditionItem(Map<String, dynamic> condition) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              condition['icon'],
              color: condition['color'],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    condition['description'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: condition['enabled'],
              onChanged: (value) {
                setState(() {
                  condition['enabled'] = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterSlider(String label, double value, double min, double max, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: 20,
            onChanged: (newValue) {
              setState(() {
                // 更新参数值
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetySwitch(String title, bool value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                // 更新安全设置
              });
            },
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizationCard(String title, String value, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateDialogueTopics() {
    return [
      {'name': '日常聊天', 'enabled': true},
      {'name': '情感交流', 'enabled': true},
      {'name': '兴趣爱好', 'enabled': true},
      {'name': '学习工作', 'enabled': false},
      {'name': '娱乐休闲', 'enabled': true},
      {'name': '健康生活', 'enabled': false},
      {'name': '旅行分享', 'enabled': false},
      {'name': '美食推荐', 'enabled': true},
    ];
  }

  List<Map<String, dynamic>> _generateInteractionModes() {
    return [
      {
        'name': '文字对话',
        'description': '基础的文字聊天互动',
        'icon': Icons.chat,
        'color': AppColors.primary,
        'enabled': true,
        'usage': 95,
      },
      {
        'name': '语音互动',
        'description': '支持语音输入和语音回复',
        'icon': Icons.mic,
        'color': AppColors.success,
        'enabled': true,
        'usage': 68,
      },
      {
        'name': '表情互动',
        'description': '丰富的表情和动作表达',
        'icon': Icons.emoji_emotions,
        'color': AppColors.warning,
        'enabled': true,
        'usage': 72,
      },
      {
        'name': '图片分享',
        'description': '支持图片的发送和识别',
        'icon': Icons.image,
        'color': AppColors.info,
        'enabled': false,
        'usage': 35,
      },
      {
        'name': '游戏互动',
        'description': '内置小游戏和互动娱乐',
        'icon': Icons.games,
        'color': Colors.purple,
        'enabled': false,
        'usage': 28,
      },
      {
        'name': '学习模式',
        'description': '教学和知识问答功能',
        'icon': Icons.school,
        'color': Colors.orange,
        'enabled': false,
        'usage': 15,
      },
    ];
  }

  List<Map<String, dynamic>> _generateTriggerConditions() {
    return [
      {
        'name': '用户长时间未回复',
        'description': '超过5分钟未收到用户消息时主动问候',
        'icon': Icons.schedule,
        'color': AppColors.warning,
        'enabled': true,
      },
      {
        'name': '检测到负面情绪',
        'description': '识别用户负面情绪时提供安慰',
        'icon': Icons.sentiment_dissatisfied,
        'color': AppColors.error,
        'enabled': true,
      },
      {
        'name': '特殊节日问候',
        'description': '在节日或纪念日主动送上祝福',
        'icon': Icons.celebration,
        'color': AppColors.success,
        'enabled': true,
      },
      {
        'name': '用户生日提醒',
        'description': '在用户生日时主动祝贺',
        'icon': Icons.cake,
        'color': Colors.pink,
        'enabled': false,
      },
    ];
  }

  void _testAbilities() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始测试角色能力...')),
    );
  }

  void _saveConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('角色 $_selectedCharacter 的能力配置已保存'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _configureMode(Map<String, dynamic> mode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('配置互动模式: ${mode['name']}')),
    );
  }
}