import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../providers/girlfriend_provider.dart';
import '../models/girlfriend_model.dart';
import '../models/secondary_personality_model.dart';
import '../services/secondary_personality_service.dart';
import '../utils/responsive_utils.dart';
import 'chat_screen.dart';

class CreateGirlfriendScreen extends StatefulWidget {
  const CreateGirlfriendScreen({Key? key}) : super(key: key);

  @override
  State<CreateGirlfriendScreen> createState() => _CreateGirlfriendScreenState();
}

class _CreateGirlfriendScreenState extends State<CreateGirlfriendScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _backgroundController = TextEditingController();
  final _introductionController = TextEditingController();
  
  late TabController _tabController;
  bool _isCreating = false;
  String _selectedAvatarUrl = '';
  
  // 详细配置选项
  String _selectedStyle = '温柔可爱';
  String _selectedAge = '18-22岁';
  String _selectedAppearance = '甜美';
  String _selectedPersonality = '温柔';
  String _selectedOccupation = '学生';
  String _selectedHobby = '阅读';
  String _selectedClothing = '休闲';
  String _selectedVoiceType = '甜美';
  String _selectedChatMode = '日常聊天';
  String _selectedRace = '东亚';
  String _selectedEyeColor = '黑色';
  String _selectedHairstyle = '长直发';
  String _selectedHairColor = '黑色';
  String _selectedBodyType = '匀称';
  String _selectedCupSize = 'C';
  String _selectedHipSize = '适中';
  String _selectedNovelCharacter = '';
  bool _usePublicKnowledge = false;
  
  // 标签相关
  List<String> _selectedTags = [];
  final TextEditingController _tagController = TextEditingController();
  final List<String> _commonTags = [
    '可爱', '温柔', '活泼', '知性', '冷酷', '俏皮', '成熟', '清纯',
    '性感', '甜美', '优雅', '开朗', '内向', '傲娇', '天然呆', '元气',
    '御姐', '萝莉', '邻家', '校花', '女神', '小恶魔', '天使', '公主'
  ];
  
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
  
  // 选项列表
  final List<String> _styles = ['温柔可爱', '活泼开朗', '冷酷御姐', '知性优雅', '俏皮可爱'];
  final List<String> _ages = ['18-22岁', '23-26岁', '27-30岁', '30岁以上'];
  final List<String> _appearances = ['甜美', '清纯', '性感', '可爱', '帅气', '高挑', '娇小'];
  final List<String> _personalities = ['温柔', '活泼', '冷静', '知性', '俏皮', '傲娇', '开朗', '内向'];
  final List<String> _occupations = ['学生', '白领', '医生', '教师', '艺术家', '程序员', '自由职业'];
  final List<String> _hobbies = ['阅读', '运动', '音乐', '电影', '旅行', '烹饪', '游戏', '绘画'];
  final List<String> _clothings = ['休闲', '正式', '运动', '时尚', '复古', '甜美', '性感', '朋克'];
  final List<String> _voiceTypes = ['甜美', '温柔', '活泼', '知性', '冷酷', '俏皮', '成熟', '清纯'];
  final List<String> _chatModes = ['日常聊天', '情感陪伴', '学习助手', '角色扮演', '创意写作', '心理咨询'];
  final List<String> _races = ['东亚', '欧美', '拉丁', '非洲', '中东', '南亚', '混血', '其他'];
  final List<String> _eyeColors = ['黑色', '棕色', '蓝色', '绿色', '灰色', '琥珀色', '紫色', '异色瞳'];
  final List<String> _hairstyles = ['长直发', '长卷发', '短发', '波浪发', '马尾辫', '双马尾', '丸子头', '编发'];
  final List<String> _hairColors = ['黑色', '棕色', '金色', '红色', '银色', '蓝色', '紫色', '粉色'];
  final List<String> _bodyTypes = ['娇小', '苗条', '匀称', '丰满', '高挑', '运动型', '微胖', '性感'];
  final List<String> _cupSizes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  final List<String> _hipSizes = ['小巧', '适中', '丰满', '性感', '圆润'];
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
  
  // 快捷模板数据
  final List<Map<String, dynamic>> _templates = [
    {
      'name': '小雪',
      'avatar': '❄️',
      'style': '温柔可爱',
      'description': '温柔体贴的邻家女孩，总是用最温暖的话语陪伴你',
      'personality': '温柔',
      'age': '18-22岁',
      'appearance': '甜美',
      'occupation': '学生',
      'hobby': '阅读',
      'clothing': '休闲',
      'voiceType': '甜美',
      'chatMode': '日常聊天',
      'race': '东亚',
      'eyeColor': '黑色',
      'hairstyle': '长直发',
      'hairColor': '黑色',
      'bodyType': '苗条',
      'cupSize': 'B',
      'hipSize': '适中',
      'background': '来自书香门第的她，性格温柔善良，喜欢安静地读书和听音乐。',
      'introduction': '你好，我是小雪，很高兴认识你~',
      'colors': [Colors.blue.shade300, Colors.blue.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1494790108755-2616c9c0e8e5?w=400',
      'tags': ['温柔', '甜美', '邻家', '书香'],
    },
    {
      'name': '小樱',
      'avatar': '🌸',
      'style': '活泼开朗',
      'description': '充满活力的阳光女孩，每天都能带给你满满的正能量',
      'personality': '活泼',
      'age': '18-22岁',
      'appearance': '可爱',
      'occupation': '学生',
      'hobby': '运动',
      'clothing': '运动',
      'voiceType': '活泼',
      'chatMode': '日常聊天',
      'race': '东亚',
      'eyeColor': '棕色',
      'hairstyle': '双马尾',
      'hairColor': '棕色',
      'bodyType': '运动型',
      'cupSize': 'C',
      'hipSize': '适中',
      'background': '热爱运动的她总是充满活力，喜欢尝试各种新鲜事物。',
      'introduction': '嗨！我是小樱，让我们一起享受美好的时光吧！',
      'colors': [Colors.pink.shade300, Colors.pink.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
      'tags': ['活泼', '可爱', '元气', '运动'],
    },
    {
      'name': '雅琳',
      'avatar': '💼',
      'style': '知性优雅',
      'description': '成熟知性的职场女性，拥有丰富的人生阅历和深刻的见解',
      'personality': '知性',
      'age': '27-30岁',
      'appearance': '高挑',
      'occupation': '白领',
      'hobby': '阅读',
      'clothing': '正式',
      'voiceType': '知性',
      'chatMode': '学习助手',
      'race': '东亚',
      'eyeColor': '黑色',
      'hairstyle': '短发',
      'hairColor': '黑色',
      'bodyType': '匀称',
      'cupSize': 'C',
      'hipSize': '适中',
      'background': '名牌大学毕业的她在职场上表现出色，拥有丰富的人生阅历。',
      'introduction': '你好，我是雅琳，很高兴为你提供帮助。',
      'colors': [Colors.purple.shade300, Colors.purple.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      'tags': ['知性', '优雅', '成熟', '职场'],
    },
    {
      'name': '小萌',
      'avatar': '🎀',
      'style': '俏皮可爱',
      'description': '古灵精怪的小萝莉，总是能用她的天真烂漫治愈你的心',
      'personality': '俏皮',
      'age': '18-22岁',
      'appearance': '娇小',
      'occupation': '艺术家',
      'hobby': '绘画',
      'clothing': '甜美',
      'voiceType': '俏皮',
      'chatMode': '角色扮演',
      'race': '东亚',
      'eyeColor': '黑色',
      'hairstyle': '丸子头',
      'hairColor': '黑色',
      'bodyType': '娇小',
      'cupSize': 'A',
      'hipSize': '小巧',
      'background': '喜欢画画的她总是充满想象力，用艺术的眼光看待世界。',
      'introduction': '嘿嘿，我是小萌，要和我一起玩吗？',
      'colors': [Colors.orange.shade300, Colors.orange.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      'tags': ['俏皮', '萝莉', '天真', '艺术'],
    },
    {
      'name': '冰儿',
      'avatar': '❄️',
      'style': '冷酷御姐',
      'description': '高冷御姐范的她外表冷酷，内心却有着不为人知的温柔',
      'personality': '冷静',
      'age': '23-26岁',
      'appearance': '性感',
      'occupation': '程序员',
      'hobby': '音乐',
      'clothing': '性感',
      'voiceType': '冷酷',
      'chatMode': '情感陪伴',
      'race': '东亚',
      'eyeColor': '蓝色',
      'hairstyle': '长卷发',
      'hairColor': '银色',
      'bodyType': '高挑',
      'cupSize': 'D',
      'hipSize': '丰满',
      'background': '表面冷酷的她其实内心很温柔，只是不善于表达情感。',
      'introduction': '我是冰儿，如果你能走进我的内心，会发现不一样的我。',
      'colors': [Colors.indigo.shade300, Colors.indigo.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'tags': ['冷酷', '御姐', '神秘', '高挑'],
    },
    {
      'name': '美香',
      'avatar': '🌹',
      'style': '成熟魅惑',
      'description': '风韵犹存的成熟女性，经验丰富，懂得如何照顾人',
      'personality': '成熟',
      'age': '30岁以上',
      'appearance': '性感',
      'occupation': '自由职业',
      'hobby': '烹饪',
      'clothing': '性感',
      'voiceType': '成熟',
      'chatMode': '情感陪伴',
      'race': '东亚',
      'eyeColor': '黑色',
      'hairstyle': '波浪发',
      'hairColor': '棕色',
      'bodyType': '丰满',
      'cupSize': 'D',
      'hipSize': '丰满',
      'background': '离异的她独立自主，有着丰富的人生阅历和成熟的魅力。',
      'introduction': '小弟弟，姐姐来教你一些人生道理~',
      'colors': [Colors.red.shade300, Colors.red.shade500],
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
      'tags': ['成熟', '性感', '魅惑', '女神'],
    },
  ];
  
  // 头像URL列表
  final List<String> _avatarUrls = [
    'https://images.unsplash.com/photo-1494790108755-2616c9c0e8e5?w=400',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedAvatarUrl = _getRandomAvatarUrl();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _backgroundController.dispose();
    _introductionController.dispose();
    super.dispose();
  }

  String _getRandomAvatarUrl() {
    final random = Random();
    return _avatarUrls[random.nextInt(_avatarUrls.length)];
  }

  Future<void> _createGirlfriend() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('请完善必填信息');
      return;
    }

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      _showErrorMessage('请输入女友名字');
      return;
    }

    if (description.isEmpty) {
      _showErrorMessage('请输入女友描述');
      return;
    }

    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    final existingGirlfriends = girlfriendProvider.girlfriends;
    final isDuplicateName = existingGirlfriends.any((gf) => gf.name.toLowerCase() == name.toLowerCase());

    if (isDuplicateName) {
      _showErrorMessage('已存在同名女友，请换个名字');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final newGirlfriend = GirlfriendModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        avatarUrl: _selectedAvatarUrl,
        personality: _selectedStyle,
        description: description,
        intimacy: 0,
        isPremium: false,
        traits: _generateGirlfriendTraits(),
        isOnline: true,
        isCreatedByUser: true,
        createdAt: DateTime.now(),
        usePublicKnowledge: _usePublicKnowledge,
        background: _backgroundController.text.trim(),
        introduction: _introductionController.text.trim(),
        voiceType: _selectedVoiceType,
        chatMode: _selectedChatMode,
        novelCharacter: _selectedNovelCharacter.isEmpty ? null : _selectedNovelCharacter,
        race: _selectedRace,
        eyeColor: _selectedEyeColor,
        hairstyle: _selectedHairstyle,
        hairColor: _selectedHairColor,
        bodyType: _selectedBodyType,
        cupSize: _selectedCupSize,
        hipSize: _selectedHipSize,
        tags: _selectedTags,
      );

      await girlfriendProvider.addGirlfriend(newGirlfriend);
      _showSuccessMessage('${name}创建成功！');
      
      girlfriendProvider.setCurrentGirlfriend(newGirlfriend);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      }
    } catch (error) {
      _showErrorMessage('创建失败: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Map<String, dynamic> _generateGirlfriendTraits() {
    return {
      'style': _selectedStyle,
      'age': _selectedAge,
      'appearance': _selectedAppearance,
      'personality_traits': [_selectedPersonality],
      'occupation': _selectedOccupation,
      'interests': [_selectedHobby],
      'clothing': _selectedClothing,
      'voice_type': _selectedVoiceType,
      'chat_mode': _selectedChatMode,
      'race': _selectedRace,
      'eye_color': _selectedEyeColor,
      'hairstyle': _selectedHairstyle,
      'hair_color': _selectedHairColor,
      'body_type': _selectedBodyType,
      'cup_size': _selectedCupSize,
      'hip_size': _selectedHipSize,
    };
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
      
      // 自动设置名字为王熙凤（如果名字为空）
      if (_nameController.text.isEmpty) {
        _nameController.text = '王熙凤';
      }
      
      // 自动设置描述
      if (_descriptionController.text.isEmpty) {
        _descriptionController.text = _wangXiFengData['personality'];
      }
    });
    
    _showSuccessMessage('已应用王熙凤角色设定！');
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
      
      // 自动设置名字为王熙凤（如果名字为空）
      if (_nameController.text.isEmpty) {
        _nameController.text = '王熙凤';
      }
      
      // 自动设置描述
      if (_descriptionController.text.isEmpty) {
        _descriptionController.text = _wangXiFengData['personality'];
      }
    });
    
    _showSuccessMessage('第二人格系统已应用王熙凤角色设定！');
  }

  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建女友'),
        backgroundColor: Colors.pink.shade400,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.auto_awesome),
              text: '快捷模板',
            ),
            Tab(
              icon: Icon(Icons.tune),
              text: '自定义创建',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 快捷模板页面
                  _buildTemplateTab(),
                  // 自定义创建页面
                  _buildCustomTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildTemplateTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择快捷模板',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '基于预设模板快速创建，一键生成你的专属AI女友',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.getGridColumns(context),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(template);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTemplateCard(Map<String, dynamic> template) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: () => _createFromTemplate(template),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 女性照片背景区域
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // 女性照片背景
                      Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: template['colors'] as List<Color>,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Image.network(
                          template['imageUrl'] as String? ?? _getRandomAvatarUrl(),
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: template['colors'] as List<Color>,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  template['avatar'] as String,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // 渐变遮罩
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                      ),
                      // 风格标签
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            template['style'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: template['colors'][0],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // 名字
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 12,
                        child: Text(
                          template['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 信息区域
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 描述
                      Text(
                        template['description'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 创建按钮
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _createFromTemplate(template),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: template['colors'][0],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            '立即创建',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头像选择
            _buildSection('选择头像', [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarUrls.length,
                  itemBuilder: (context, index) {
                    final avatarUrl = _avatarUrls[index];
                    final isSelected = _selectedAvatarUrl == avatarUrl;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarUrl = avatarUrl;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.pink.shade400 : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey.shade300,
                            child: Image.network(
                              avatarUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, size: 50);
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ]),
            
            // 基本信息
            _buildSection('基本信息', [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名字',
                  hintText: '给你的女友起个好听的名字',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入名字';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '描述你的女友',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入描述';
                  }
                  return null;
                },
              ),
            ]),
            
            // 风格设置
            _buildSection('风格设置', [
              _buildChoiceSection('风格', _styles, _selectedStyle, (value) {
                setState(() {
                  _selectedStyle = value;
                });
              }),
              _buildChoiceSection('年龄', _ages, _selectedAge, (value) {
                setState(() {
                  _selectedAge = value;
                });
              }),
            ]),
            
            // 外观设置
            _buildSection('外观设置', [
              _buildChoiceSection('种族', _races, _selectedRace, (value) {
                setState(() {
                  _selectedRace = value;
                });
              }),
              _buildChoiceSection('外貌特征', _appearances, _selectedAppearance, (value) {
                setState(() {
                  _selectedAppearance = value;
                });
              }),
              _buildChoiceSection('眼睛颜色', _eyeColors, _selectedEyeColor, (value) {
                setState(() {
                  _selectedEyeColor = value;
                });
              }),
              _buildChoiceSection('发型', _hairstyles, _selectedHairstyle, (value) {
                setState(() {
                  _selectedHairstyle = value;
                });
              }),
              _buildChoiceSection('头发颜色', _hairColors, _selectedHairColor, (value) {
                setState(() {
                  _selectedHairColor = value;
                });
              }),
            ]),
            
            // 身材设置
            _buildSection('身材设置', [
              _buildChoiceSection('体型', _bodyTypes, _selectedBodyType, (value) {
                setState(() {
                  _selectedBodyType = value;
                });
              }),
              _buildChoiceSection('罩杯', _cupSizes, _selectedCupSize, (value) {
                setState(() {
                  _selectedCupSize = value;
                });
              }),
              _buildChoiceSection('臀部尺寸', _hipSizes, _selectedHipSize, (value) {
                setState(() {
                  _selectedHipSize = value;
                });
              }),
            ]),
            
            // 性格设置
            _buildSection('性格设置', [
              _buildChoiceSection('性格', _personalities, _selectedPersonality, (value) {
                setState(() {
                  _selectedPersonality = value;
                });
              }),
              _buildChoiceSection('职业', _occupations, _selectedOccupation, (value) {
                setState(() {
                  _selectedOccupation = value;
                });
              }),
              _buildChoiceSection('爱好', _hobbies, _selectedHobby, (value) {
                setState(() {
                  _selectedHobby = value;
                });
              }),
              _buildChoiceSection('服装风格', _clothings, _selectedClothing, (value) {
                setState(() {
                  _selectedClothing = value;
                });
              }),
            ]),
            
            // 交互设置
            _buildSection('交互设置', [
              _buildChoiceSection('声音类型', _voiceTypes, _selectedVoiceType, (value) {
                setState(() {
                  _selectedVoiceType = value;
                });
              }),
              _buildChoiceSection('聊天模式', _chatModes, _selectedChatMode, (value) {
                setState(() {
                  _selectedChatMode = value;
                });
              }),
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
                _buildSection('角色背景', [
                  TextFormField(
                    controller: _backgroundController,
                    decoration: const InputDecoration(
                      labelText: '背景故事（可选）',
                      hintText: '她的背景故事',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _introductionController,
                    decoration: const InputDecoration(
                      labelText: '自我介绍（可选）',
                      hintText: '她会如何介绍自己',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ]),
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
            
            // 标签设置
            _buildSection('角色标签', [
              _buildTagsSection(),
            ]),
            
            const SizedBox(height: 24),
            // 创建按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _createGirlfriend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '创建女友',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildChoiceSection(String title, List<String> options, String selectedValue, Function(String) onChanged) {
    return Column(
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
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.shade400 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.pink.shade400 : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.pink.shade400,
    );
  }
  
  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 自定义标签输入
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: '输入自定义标签',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onFieldSubmitted: (value) {
                  _addCustomTag(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                _addCustomTag(_tagController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('添加'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // 常用标签选择
        const Text(
          '常用标签',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _commonTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                _toggleTag(tag);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.pink.shade400 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.pink.shade400 : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        
        // 已选择的标签
        if (_selectedTags.isNotEmpty) ...[
          const Text(
            '已选择的标签',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.pink.shade200,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        _removeTag(tag);
                      },
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.pink.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
  
  void _addCustomTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_selectedTags.contains(trimmedTag)) {
      setState(() {
        _selectedTags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }
  
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }
  
  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }
  
  Future<void> _createFromTemplate(Map<String, dynamic> template) async {
    setState(() {
      _isCreating = true;
    });

    try {
      final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
      final existingGirlfriends = girlfriendProvider.girlfriends;
      final templateName = template['name'] as String;
      
      // 检查是否已存在同名女友
      String finalName = templateName;
      int counter = 1;
      while (existingGirlfriends.any((gf) => gf.name.toLowerCase() == finalName.toLowerCase())) {
        finalName = '$templateName$counter';
        counter++;
      }

      final newGirlfriend = GirlfriendModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: finalName,
        avatarUrl: _getRandomAvatarUrl(),
        personality: template['style'] as String,
        description: template['description'] as String,
        intimacy: 0,
        isPremium: false,
        traits: {
          'style': template['style'],
          'age': template['age'],
          'appearance': template['appearance'],
          'personality_traits': [template['personality']],
          'occupation': template['occupation'],
          'interests': [template['hobby']],
          'clothing': template['clothing'],
          'voice_type': template['voiceType'],
          'chat_mode': template['chatMode'],
          'race': template['race'],
          'eye_color': template['eyeColor'],
          'hairstyle': template['hairstyle'],
          'hair_color': template['hairColor'],
          'body_type': template['bodyType'],
          'cup_size': template['cupSize'],
          'hip_size': template['hipSize'],
        },
        isOnline: true,
        isCreatedByUser: true,
        createdAt: DateTime.now(),
        usePublicKnowledge: false,
        background: template['background'] as String,
        introduction: template['introduction'] as String,
        voiceType: template['voiceType'] as String,
        chatMode: template['chatMode'] as String,
        race: template['race'] as String,
        eyeColor: template['eyeColor'] as String,
        hairstyle: template['hairstyle'] as String,
        hairColor: template['hairColor'] as String,
        bodyType: template['bodyType'] as String,
        cupSize: template['cupSize'] as String,
        hipSize: template['hipSize'] as String,
        tags: (template['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

      await girlfriendProvider.addGirlfriend(newGirlfriend);
      _showSuccessMessage('${finalName}创建成功！');
      
      girlfriendProvider.setCurrentGirlfriend(newGirlfriend);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          ),
        );
      }
    } catch (error) {
      _showErrorMessage('创建失败: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}