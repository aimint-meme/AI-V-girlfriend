import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/girlfriend_model.dart';
import '../providers/girlfriend_provider.dart';

class CharacterSettingsScreen extends StatefulWidget {
  final GirlfriendModel girlfriend;
  
  const CharacterSettingsScreen({Key? key, required this.girlfriend}) : super(key: key);
  
  @override
  State<CharacterSettingsScreen> createState() => _CharacterSettingsScreenState();
}

class _CharacterSettingsScreenState extends State<CharacterSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _backgroundController;
  late TextEditingController _introductionController;
  
  late String _selectedStyle;
  late String _selectedRace;
  late String _selectedAge;
  late String _selectedEyeColor;
  late String _selectedHairstyle;
  late String _selectedHairColor;
  late String _selectedAppearance;
  late String _selectedPersonality;
  late String _selectedOccupation;
  late String _selectedHobby;
  late String _selectedClothing;
  late String _selectedVoiceType;
  late String _selectedBodyType;
  late String _selectedCupSize;
  late String _selectedHipSize;
  late String _selectedChatMode;
  late String _selectedNovelCharacter;
  late bool _usePublicKnowledge;
  
  // 第二人格系统相关
  bool _enableSecondaryPersonality = false;
  String _secondaryKnowledgeType = ''; // 第二人格知识库类型
  String _secondaryKnowledgeCategory = ''; // 第二人格知识库分类
  String _secondaryNovel = ''; // 第二人格选择的小说
  String _secondaryCharacter = ''; // 第二人格选择的角色
  
  // 知识库选择相关
  bool _enableKnowledgeBase = false;
  String _selectedKnowledgeType = ''; // 知识库类型：公开/付费/高阶
  String _selectedKnowledgeCategory = ''; // 知识库分类
  String _selectedKnowledgeDocument = ''; // 具体文档
  String _selectedClassicNovel = '';
  String _selectedCharacter = '';
  
  bool _isUpdating = false;
  
  // 选项列表
  final List<String> _styles = ['温柔可爱', '活泼开朗', '冷酷御姐', '知性优雅', '俏皮可爱'];
  final List<String> _races = ['东亚', '欧美', '拉丁', '非洲', '中东', '南亚', '混血', '其他'];
  final List<String> _ages = ['18-22岁', '23-26岁', '27-30岁', '30岁以上'];
  final List<String> _eyeColors = ['黑色', '棕色', '蓝色', '绿色', '灰色', '琥珀色', '紫色', '异色瞳'];
  final List<String> _hairstyles = ['长直发', '长卷发', '短发', '波浪发', '马尾辫', '双马尾', '丸子头', '编发'];
  final List<String> _hairColors = ['黑色', '棕色', '金色', '红色', '银色', '蓝色', '紫色', '粉色'];
  final List<String> _appearances = ['甜美', '清纯', '性感', '可爱', '帅气', '高挑', '娇小'];
  final List<String> _personalities = ['温柔', '活泼', '冷静', '知性', '俏皮', '傲娇', '开朗', '内向'];
  final List<String> _occupations = ['学生', '白领', '医生', '教师', '艺术家', '程序员', '自由职业'];
  final List<String> _hobbies = ['阅读', '运动', '音乐', '电影', '旅行', '烹饪', '游戏', '绘画'];
  final List<String> _clothings = ['休闲', '正式', '运动', '时尚', '复古', '甜美', '性感', '朋克'];
  final List<String> _voiceTypes = ['甜美', '温柔', '活泼', '知性', '冷酷', '俏皮', '成熟', '清纯'];
  final List<String> _bodyTypes = ['娇小', '苗条', '匀称', '丰满', '高挑', '运动型', '微胖', '性感'];
  final List<String> _cupSizes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final List<String> _hipSizes = ['小巧', '适中', '丰满', '性感', '圆润'];
  final List<String> _chatModes = ['日常聊天', '情感陪伴', '学习助手', '角色扮演', '创意写作', '心理咨询'];
  final List<String> _novelCharacters = ['林黛玉', '王熙凤', '薛宝钗', '史湘云', '妙玉', '迎春', '探春', '惜春', '自定义角色'];
  
  // 知识库相关选项
  final List<String> _knowledgeTypes = ['公开知识库', '付费知识库', '高阶知识库'];
  final List<String> _knowledgeCategories = ['四大名著', '历史人物', '现代文学', '影视作品'];
  final List<String> _classicNovels = ['红楼梦', '西游记', '水浒传', '三国演义'];
  
  // 知识库文档映射
  final Map<String, Map<String, List<String>>> _knowledgeDocuments = {
    '公开知识库': {
      '情商类': ['1000句高情商问答.pdf'],
      '心理学类': ['心理学基础.pdf'],
      '文学艺术': ['红楼梦人物志', '西游记人物志', '水浒传人物志', '三国演义人物志'],
    },
    '付费知识库': {
      '沟通技巧类': ['高级沟通技巧手册.pdf', '谈判心理学.pdf'],
      '情商类': ['情商修炼大全.pdf'],
    },
    '高阶知识库': {
      '心理学类': ['心理治疗技术大全.pdf', '心理评估工具手册.pdf'],
      '管理学类': ['领导力心理学精要.pdf'],
    },
  };
  final Map<String, List<String>> _novelCharacters_new = {
    '红楼梦': ['王熙凤', '林黛玉', '薛宝钗', '贾宝玉', '史湘云', '妙玉', '迎春', '探春', '惜春'],
    '西游记': ['孙悟空', '唐僧', '猪八戒', '沙僧', '白骨精', '铁扇公主', '嫦娥', '观音菩萨'],
    '水浒传': ['林冲', '武松', '鲁智深', '李逵', '宋江', '吴用', '花荣', '扈三娘'],
    '三国演义': ['诸葛亮', '刘备', '关羽', '张飞', '曹操', '孙权', '周瑜', '貂蝉', '小乔', '大乔'],
  };
  
  // 王熙凤角色预设数据
  final Map<String, dynamic> _wangXiFengData = {
    'background': '王熙凤，贾琏之妻，王夫人的内侄女。她精明强干，深得贾母欢心，在贾府中有很高的地位和权力。她善于理财，管理能力出众，但同时也心机深沉，手段毒辣。外表美丽动人，内心却工于心计，是《红楼梦》中最具争议性的人物之一。',
    'introduction': '我是王熙凤，人称凤辣子。在这贾府中，上上下下的事务都要经过我的手。我虽是女儿身，但论起精明能干来，府中男子也未必比得过我。你若是诚心与我相交，我自然待你不薄；若是想在我面前耍什么心机，那可就要掂量掂量了。',
    'personality': '精明能干，口才出众，心机深沉，外表美丽',
    'traits': {
      'style': '知性优雅',
      'age': '23-26岁',
      'appearance': '性感',
      'personality_traits': ['知性', '冷静'],
      'occupation': '管家',
      'interests': ['理财', '管理'],
      'clothing': '正式',
      'voice_type': '知性',
      'chat_mode': '角色扮演',
      'race': '东亚',
      'eye_color': '黑色',
      'hairstyle': '编发',
      'hair_color': '黑色',
      'body_type': '匀称',
      'cup_size': 'C',
      'hip_size': '适中',
    },
   };
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.girlfriend.name);
    _descriptionController = TextEditingController(text: widget.girlfriend.description);
    _backgroundController = TextEditingController(text: widget.girlfriend.background ?? '');
    _introductionController = TextEditingController(text: widget.girlfriend.introduction ?? '');
    
    _selectedStyle = widget.girlfriend.personality;
    _selectedRace = widget.girlfriend.race ?? '东亚';
    _selectedAge = _getTraitValue('age', '18-22岁');
    _selectedEyeColor = widget.girlfriend.eyeColor ?? '黑色';
    _selectedHairstyle = widget.girlfriend.hairstyle ?? '长直发';
    _selectedHairColor = widget.girlfriend.hairColor ?? '黑色';
    _selectedAppearance = _getTraitValue('appearance', '甜美');
    _selectedPersonality = _getTraitValue('personality_traits', '温柔');
    _selectedOccupation = _getTraitValue('occupation', '学生');
    _selectedHobby = _getTraitValue('interests', '阅读');
    _selectedClothing = _getTraitValue('clothing', '休闲');
    _selectedVoiceType = widget.girlfriend.voiceType ?? '甜美';
    _selectedBodyType = widget.girlfriend.bodyType ?? '匀称';
    _selectedCupSize = widget.girlfriend.cupSize ?? 'C';
    _selectedHipSize = widget.girlfriend.hipSize ?? '适中';
    _selectedChatMode = widget.girlfriend.chatMode ?? '日常聊天';
    _selectedNovelCharacter = widget.girlfriend.novelCharacter ?? '';
    _usePublicKnowledge = widget.girlfriend.usePublicKnowledge;
  }
  
  String _getTraitValue(String key, String defaultValue) {
    final traits = widget.girlfriend.traits;
    if (traits.containsKey(key)) {
      final value = traits[key];
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      } else if (value is String) {
        return value;
      }
    }
    return defaultValue;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _backgroundController.dispose();
    _introductionController.dispose();
    super.dispose();
  }
  
  // 处理角色选择和自动填充
  void _onCharacterSelected(String character) {
    setState(() {
      _selectedCharacter = character;
    });
    
    // 如果选择的是王熙凤，自动填充角色信息
    if (character == '王熙凤') {
      _applyWangXiFengData();
    }
  }
  
  // 应用王熙凤角色数据
  void _applyWangXiFengData() {
    setState(() {
      // 填充背景和介绍
      _backgroundController.text = _wangXiFengData['background'];
      _introductionController.text = _wangXiFengData['introduction'];
      
      // 应用角色特征
      final traits = _wangXiFengData['traits'] as Map<String, dynamic>;
      _selectedStyle = traits['style'];
      _selectedAge = traits['age'];
      _selectedAppearance = traits['appearance'];
      _selectedPersonality = traits['personality_traits'][0];
      _selectedOccupation = traits['occupation'];
      _selectedHobby = traits['interests'][0];
      _selectedClothing = traits['clothing'];
      _selectedVoiceType = traits['voice_type'];
      _selectedChatMode = traits['chat_mode'];
      _selectedRace = traits['race'];
      _selectedEyeColor = traits['eye_color'];
      _selectedHairstyle = traits['hairstyle'];
      _selectedHairColor = traits['hair_color'];
      _selectedBodyType = traits['body_type'];
      _selectedCupSize = traits['cup_size'];
      _selectedHipSize = traits['hip_size'];
      
      // 自动设置描述
      _descriptionController.text = _wangXiFengData['personality'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已应用王熙凤角色设定！'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // 处理第二人格系统的角色选择
  void _onSecondaryCharacterSelected(String character) {
    setState(() {
      _secondaryCharacter = character;
    });
    
    // 如果选择的是王熙凤，自动填充角色信息
    if (character == '王熙凤') {
      _applyWangXiFengDataForSecondary();
    }
  }
  
  // 为第二人格系统应用王熙凤角色数据
  void _applyWangXiFengDataForSecondary() {
    setState(() {
      // 填充背景和介绍
      _backgroundController.text = _wangXiFengData['background'];
      _introductionController.text = _wangXiFengData['introduction'];
      
      // 应用角色特征
      final traits = _wangXiFengData['traits'] as Map<String, dynamic>;
      _selectedStyle = traits['style'];
      _selectedAge = traits['age'];
      _selectedAppearance = traits['appearance'];
      _selectedPersonality = traits['personality_traits'][0];
      _selectedOccupation = traits['occupation'];
      _selectedHobby = traits['interests'][0];
      _selectedClothing = traits['clothing'];
      _selectedVoiceType = traits['voice_type'];
      _selectedChatMode = traits['chat_mode'];
      _selectedRace = traits['race'];
      _selectedEyeColor = traits['eye_color'];
      _selectedHairstyle = traits['hairstyle'];
      _selectedHairColor = traits['hair_color'];
      _selectedBodyType = traits['body_type'];
      _selectedCupSize = traits['cup_size'];
      _selectedHipSize = traits['hip_size'];
      
      // 自动设置描述
      _descriptionController.text = _wangXiFengData['personality'];
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('第二人格系统已应用王熙凤角色设定！'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _updateCharacter() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入角色名字')),
      );
      return;
    }
    
    setState(() {
      _isUpdating = true;
    });
    
    try {
      final updatedGirlfriend = widget.girlfriend.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        background: _backgroundController.text.trim(),
        introduction: _introductionController.text.trim(),
        personality: _selectedStyle,
        race: _selectedRace,
        eyeColor: _selectedEyeColor,
        hairstyle: _selectedHairstyle,
        hairColor: _selectedHairColor,
        voiceType: _selectedVoiceType,
        bodyType: _selectedBodyType,
        cupSize: _selectedCupSize,
        hipSize: _selectedHipSize,
        chatMode: _selectedChatMode,
        novelCharacter: _selectedNovelCharacter.isEmpty ? null : _selectedNovelCharacter,
        usePublicKnowledge: _usePublicKnowledge,
        traits: {
          ...widget.girlfriend.traits,
          'age': _selectedAge,
          'appearance': _selectedAppearance,
          'personality_traits': [_selectedPersonality],
          'occupation': _selectedOccupation,
          'interests': [_selectedHobby],
          'clothing': _selectedClothing,
        },
      );
      
      final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
      await girlfriendProvider.updateGirlfriend(updatedGirlfriend);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('角色设置已更新'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.girlfriend.name} - 角色设置'),
        backgroundColor: Colors.pink.shade400,
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _updateCharacter,
            child: Text(
              _isUpdating ? '保存中...' : '保存',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('基本信息', [
                    _buildTextField('名字', _nameController),
                    _buildTextField('描述', _descriptionController, maxLines: 3),
                  ]),
                  
                  _buildSection('外观设置', [
                    _buildChoiceSection('风格', _styles, _selectedStyle, (value) => _selectedStyle = value),
                    _buildChoiceSection('种族', _races, _selectedRace, (value) => _selectedRace = value),
                    _buildChoiceSection('年龄', _ages, _selectedAge, (value) => _selectedAge = value),
                    _buildChoiceSection('眼睛颜色', _eyeColors, _selectedEyeColor, (value) => _selectedEyeColor = value),
                    _buildChoiceSection('发型', _hairstyles, _selectedHairstyle, (value) => _selectedHairstyle = value),
                    _buildChoiceSection('头发颜色', _hairColors, _selectedHairColor, (value) => _selectedHairColor = value),
                    _buildChoiceSection('外貌特征', _appearances, _selectedAppearance, (value) => _selectedAppearance = value),
                  ]),
                  
                  _buildSection('身材设置', [
                    _buildChoiceSection('体型', _bodyTypes, _selectedBodyType, (value) => _selectedBodyType = value),
                    _buildChoiceSection('罩杯', _cupSizes, _selectedCupSize, (value) => _selectedCupSize = value),
                    _buildChoiceSection('臀部尺寸', _hipSizes, _selectedHipSize, (value) => _selectedHipSize = value),
                  ]),
                  
                  _buildSection('性格设置', [
                    _buildChoiceSection('性格', _personalities, _selectedPersonality, (value) => _selectedPersonality = value),
                    _buildChoiceSection('职业', _occupations, _selectedOccupation, (value) => _selectedOccupation = value),
                    _buildChoiceSection('爱好', _hobbies, _selectedHobby, (value) => _selectedHobby = value),
                    _buildChoiceSection('服装风格', _clothings, _selectedClothing, (value) => _selectedClothing = value),
                  ]),
                  
                  _buildSection('交互设置', [
                    _buildChoiceSection('声音类型', _voiceTypes, _selectedVoiceType, (value) => _selectedVoiceType = value),
                    _buildChoiceSection('聊天模式', _chatModes, _selectedChatMode, (value) => _selectedChatMode = value),
                    _buildSwitchTile('知识库', _enableKnowledgeBase, (value) {
                      setState(() {
                        _enableKnowledgeBase = value;
                        if (!value) {
                          // 如果关闭知识库，清空相关选择
                          _selectedKnowledgeType = '';
                          _selectedKnowledgeCategory = '';
                          _selectedKnowledgeDocument = '';
                        }
                      });
                    }),
                    // 知识库类型选择
                    if (_enableKnowledgeBase) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedKnowledgeType.isEmpty ? null : _selectedKnowledgeType,
                        decoration: const InputDecoration(
                          labelText: '选择知识库类型',
                          border: OutlineInputBorder(),
                        ),
                        items: _knowledgeTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKnowledgeType = value ?? '';
                            _selectedKnowledgeCategory = '';
                            _selectedKnowledgeDocument = '';
                          });
                        },
                      ),
                    ],
                    // 知识库分类选择
                    if (_enableKnowledgeBase && _selectedKnowledgeType.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedKnowledgeCategory.isEmpty ? null : _selectedKnowledgeCategory,
                        decoration: const InputDecoration(
                          labelText: '选择知识库分类',
                          border: OutlineInputBorder(),
                        ),
                        items: (_knowledgeDocuments[_selectedKnowledgeType]?.keys.toList() ?? []).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKnowledgeCategory = value ?? '';
                            _selectedKnowledgeDocument = '';
                          });
                        },
                      ),
                    ],
                    // 文档选择
                    if (_enableKnowledgeBase && _selectedKnowledgeType.isNotEmpty && _selectedKnowledgeCategory.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedKnowledgeDocument.isEmpty ? null : _selectedKnowledgeDocument,
                        decoration: const InputDecoration(
                          labelText: '选择文档',
                          border: OutlineInputBorder(),
                        ),
                        items: (_knowledgeDocuments[_selectedKnowledgeType]?[_selectedKnowledgeCategory] ?? []).map((document) {
                          return DropdownMenuItem(
                            value: document,
                            child: Text(document),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedKnowledgeDocument = value ?? '';
                          });
                        },
                      ),
                    ],
                  ]),
                  
                  // 高级功能设置
                  _buildSection('高级功能', [
                    _buildSwitchTile('启用第二人格系统', _enableSecondaryPersonality, (value) {
                      setState(() {
                        _enableSecondaryPersonality = value;
                        if (!value) {
                          // 如果关闭第二人格系统，清空相关选择
                          _secondaryKnowledgeType = '';
                          _secondaryKnowledgeCategory = '';
                          _secondaryNovel = '';
                          _secondaryCharacter = '';
                        }
                      });
                    }),
                    // 第二人格系统的知识库选择
                    if (_enableSecondaryPersonality) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _secondaryKnowledgeType.isEmpty ? null : _secondaryKnowledgeType,
                        decoration: const InputDecoration(
                          labelText: '选择知识库',
                          border: OutlineInputBorder(),
                        ),
                        items: _knowledgeTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _secondaryKnowledgeType = value ?? '';
                            _secondaryKnowledgeCategory = '';
                            _secondaryNovel = '';
                            _secondaryCharacter = '';
                          });
                        },
                      ),
                    ],
                    // 知识库分类选择
                    if (_enableSecondaryPersonality && _secondaryKnowledgeType.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _secondaryKnowledgeCategory.isEmpty ? null : _secondaryKnowledgeCategory,
                        decoration: const InputDecoration(
                          labelText: '选择知识库分类',
                          border: OutlineInputBorder(),
                        ),
                        items: (_knowledgeDocuments[_secondaryKnowledgeType]?.keys.toList() ?? []).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _secondaryKnowledgeCategory = value ?? '';
                            _secondaryNovel = '';
                            _secondaryCharacter = '';
                          });
                        },
                      ),
                    ],
                    // 四大名著选择
                    if (_enableSecondaryPersonality && _secondaryKnowledgeType == '公开知识库' && _secondaryKnowledgeCategory == '文学艺术') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _secondaryNovel.isEmpty ? null : _secondaryNovel,
                        decoration: const InputDecoration(
                          labelText: '选择名著',
                          border: OutlineInputBorder(),
                        ),
                        items: _classicNovels.map((novel) {
                          return DropdownMenuItem(
                            value: novel,
                            child: Text(novel),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _secondaryNovel = value ?? '';
                            _secondaryCharacter = '';
                          });
                        },
                      ),
                    ],
                    // 角色选择
                    if (_enableSecondaryPersonality && _secondaryNovel.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _secondaryCharacter.isEmpty ? null : _secondaryCharacter,
                        decoration: const InputDecoration(
                          labelText: '选择人物',
                          border: OutlineInputBorder(),
                        ),
                        items: (_novelCharacters_new[_secondaryNovel] ?? []).map((character) {
                          return DropdownMenuItem(
                            value: character,
                            child: Text(character),
                          );
                        }).toList(),
                        onChanged: (value) {
                           if (value != null) {
                             _onSecondaryCharacterSelected(value);
                           }
                         },
                       ),
                     ],
                     // 角色背景（只有选择了角色后才显示）
                     if (_enableSecondaryPersonality && _secondaryCharacter.isNotEmpty) ...[
                       const SizedBox(height: 16),
                       _buildTextField('角色背景', _backgroundController, maxLines: 4),
                       const SizedBox(height: 16),
                       _buildTextField('角色简介', _introductionController, maxLines: 2),
                     ],
                    // 四大名著选择
                    if (_enableKnowledgeBase && _selectedKnowledgeCategory == '四大名著') ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedClassicNovel.isEmpty ? null : _selectedClassicNovel,
                        decoration: const InputDecoration(
                          labelText: '选择名著',
                          border: OutlineInputBorder(),
                        ),
                        items: _classicNovels.map((novel) {
                          return DropdownMenuItem(
                            value: novel,
                            child: Text(novel),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedClassicNovel = value ?? '';
                            _selectedCharacter = '';
                          });
                        },
                      ),
                    ],
                    // 角色选择
                    if (_enableKnowledgeBase && _selectedClassicNovel.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCharacter.isEmpty ? null : _selectedCharacter,
                        decoration: const InputDecoration(
                          labelText: '选择角色',
                          border: OutlineInputBorder(),
                        ),
                        items: (_novelCharacters_new[_selectedClassicNovel] ?? []).map((character) {
                          return DropdownMenuItem(
                            value: character,
                            child: Text(character),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _onCharacterSelected(value);
                          }
                        },
                      ),
                    ],
                  ]),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        maxLines: maxLines,
      ),
    );
  }
  
  Widget _buildChoiceSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedValue == option,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      onChanged(option);
                    });
                  }
                },
                selectedColor: Colors.pink.shade400,
                backgroundColor: Colors.grey.shade100,
                labelStyle: TextStyle(
                  color: selectedValue == option ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: (newValue) {
          setState(() {
            onChanged(newValue);
          });
        },
        activeColor: Colors.pink.shade400,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}