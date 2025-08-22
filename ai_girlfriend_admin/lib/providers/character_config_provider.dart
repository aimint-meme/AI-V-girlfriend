import 'package:flutter/foundation.dart';
import '../models/character_model.dart';

class CharacterConfigProvider extends ChangeNotifier {
  List<CharacterModel> _characters = [];
  List<CharacterModel> _filteredCharacters = [];
  List<ModelConfig> _models = [];
  List<VoiceModel> _voices = [];
  List<SceneModel> _scenes = [];
  CharacterConfigStats? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CharacterModel> get characters => _characters;
  List<CharacterModel> get filteredCharacters => _filteredCharacters;
  List<ModelConfig> get models => _models;
  List<VoiceModel> get voices => _voices;
  List<SceneModel> get scenes => _scenes;
  CharacterConfigStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 统计数据快捷访问
  int get totalCharacters => _stats?.totalCharacters ?? 0;
  int get activeCharacters => _stats?.activeCharacters ?? 0;
  int get totalModels => _stats?.totalModels ?? 0;
  int get onlineModels => _stats?.onlineModels ?? 0;
  int get totalVoices => _stats?.totalVoices ?? 0;
  int get availableVoices => _stats?.availableVoices ?? 0;
  int get totalScenes => _stats?.totalScenes ?? 0;
  int get enabledScenes => _stats?.enabledScenes ?? 0;

  // 角色数据管理相关数据
  double get characterGrowth => 15.8;
  int get totalInteractions => 156420;
  double get interactionTrend => 23.5;
  double get averageRating => 4.7;
  double get ratingTrend => 8.2;
  double get dataCompleteness => 92.3;
  double get completenessTrend => 5.1;
  double get dataAccuracy => 94.8;
  double get dataConsistency => 89.6;
  double get dataTimeliness => 87.2;

  // 角色创建相关数据
  int get totalCreated => 83;
  int get monthlyCreated => 12;
  double get creationTrend => 18.7;
  int get templatesUsed => 45;
  double get templateTrend => 12.3;
  double get avgCompletionRate => 88.5;
  double get completionTrend => 6.8;
  double get successRate => 94.2;
  double get successTrend => 3.4;

  // 角色能力配置相关数据
  double get configCompleteness => 91.7;
  double get responseAccuracy => 89.3;
  double get accuracyTrend => 7.2;
  int get activeInteractionModes => 6;
  double get learningCapacity => 85.4;
  double get learningTrend => 9.1;

  // 加载角色数据
  Future<void> loadCharacters() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _characters = _generateMockCharacters();
      _filteredCharacters = List.from(_characters);
      _models = _generateMockModels();
      _voices = _generateMockVoices();
      _scenes = _generateMockScenes();
      _stats = _generateMockStats();
      
    } catch (e) {
      _error = '加载角色数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载角色数据管理数据
  Future<void> loadCharacterData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载角色数据相关的信息
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载角色数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载角色创建数据
  Future<void> loadCharacterCreationData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载角色创建相关的数据
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载角色创建数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 加载角色能力配置数据
  Future<void> loadCharacterAbilities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里可以加载角色能力配置相关的数据
      // 目前使用getter中的模拟数据
      
    } catch (e) {
      _error = '加载角色能力数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 应用筛选条件
  void applyFilters({
    String? searchQuery,
    String? status,
    String? type,
  }) {
    _filteredCharacters = _characters.where((character) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!character.name.toLowerCase().contains(query) &&
            !character.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态筛选
      if (status != null && character.status != status) {
        return false;
      }

      // 类型筛选
      if (type != null && character.type != type) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 添加角色
  Future<bool> addCharacter(CharacterModel character) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _characters.add(character);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '添加角色失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新角色
  Future<bool> updateCharacter(CharacterModel character) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _characters.indexWhere((c) => c.id == character.id);
      if (index != -1) {
        _characters[index] = character;
        applyFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '更新角色失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除角色
  Future<bool> deleteCharacter(String characterId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _characters.removeWhere((character) => character.id == characterId);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '删除角色失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换角色状态
  Future<bool> toggleCharacterStatus(String characterId) async {
    try {
      final characterIndex = _characters.indexWhere((c) => c.id == characterId);
      if (characterIndex == -1) return false;
      
      final character = _characters[characterIndex];
      final newStatus = character.status == '活跃' ? '禁用' : '活跃';
      
      _characters[characterIndex] = character.copyWith(status: newStatus);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '切换角色状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 克隆角色
  Future<bool> cloneCharacter(String characterId) async {
    try {
      final character = _characters.firstWhere((c) => c.id == characterId);
      final clonedCharacter = character.copyWith(
        id: 'clone_${DateTime.now().millisecondsSinceEpoch}',
        name: '${character.name}_副本',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        usageCount: 0,
      );
      
      return await addCharacter(clonedCharacter);
    } catch (e) {
      _error = '克隆角色失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 添加模型配置
  Future<bool> addModel(ModelConfig model) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _models.add(model);
      
      return true;
    } catch (e) {
      _error = '添加模型失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 测试模型
  Future<bool> testModel(String modelId) async {
    try {
      // 模拟模型测试
      await Future.delayed(const Duration(seconds: 2));
      
      debugPrint('测试模型 $modelId');
      
      return true;
    } catch (e) {
      _error = '测试模型失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 切换模型状态
  Future<bool> toggleModelStatus(String modelId) async {
    try {
      final modelIndex = _models.indexWhere((m) => m.id == modelId);
      if (modelIndex == -1) return false;
      
      final model = _models[modelIndex];
      _models[modelIndex] = ModelConfig(
        id: model.id,
        name: model.name,
        description: model.description,
        type: model.type,
        version: model.version,
        endpoint: model.endpoint,
        parameters: model.parameters,
        temperature: model.temperature,
        maxTokens: model.maxTokens,
        isOnline: !model.isOnline,
        avgResponseTime: model.avgResponseTime,
        successRate: model.successRate,
        createdAt: model.createdAt,
        updatedAt: DateTime.now(),
        metadata: model.metadata,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '切换模型状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 添加语音
  Future<bool> addVoice(VoiceModel voice) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _voices.add(voice);
      
      return true;
    } catch (e) {
      _error = '添加语音失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 播放语音
  Future<bool> playVoice(String voiceId) async {
    try {
      // 模拟播放语音
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint('播放语音 $voiceId');
      
      return true;
    } catch (e) {
      _error = '播放语音失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 添加场景
  Future<bool> addScene(SceneModel scene) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _scenes.add(scene);
      
      return true;
    } catch (e) {
      _error = '添加场景失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换场景状态
  Future<bool> toggleSceneStatus(String sceneId) async {
    try {
      final sceneIndex = _scenes.indexWhere((s) => s.id == sceneId);
      if (sceneIndex == -1) return false;
      
      final scene = _scenes[sceneIndex];
      _scenes[sceneIndex] = SceneModel(
        id: scene.id,
        name: scene.name,
        description: scene.description,
        category: scene.category,
        thumbnail: scene.thumbnail,
        backgrounds: scene.backgrounds,
        settings: scene.settings,
        props: scene.props,
        atmosphere: scene.atmosphere,
        musicIds: scene.musicIds,
        isEnabled: !scene.isEnabled,
        usageCount: scene.usageCount,
        rating: scene.rating,
        createdAt: scene.createdAt,
        updatedAt: DateTime.now(),
        createdBy: scene.createdBy,
        metadata: scene.metadata,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '切换场景状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 获取角色详情
  CharacterModel? getCharacterById(String characterId) {
    try {
      return _characters.firstWhere((character) => character.id == characterId);
    } catch (e) {
      return null;
    }
  }

  // 导出角色配置
  Future<Map<String, dynamic>> exportCharacterConfig(String characterId) async {
    try {
      final character = getCharacterById(characterId);
      if (character == null) return {};
      
      return {
        'character': character.toJson(),
        'model': _models.firstWhere((m) => m.id == character.modelId, orElse: () => _models.first).toJson(),
        'voice': _voices.firstWhere((v) => v.id == character.voiceId, orElse: () => _voices.first).toJson(),
        'scenes': _scenes.where((s) => character.sceneIds.contains(s.id)).map((s) => s.toJson()).toList(),
        'exportTime': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _error = '导出配置失败: $e';
      debugPrint(_error);
      return {};
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟角色数据
  List<CharacterModel> _generateMockCharacters() {
    final characters = <CharacterModel>[];
    final names = ['小雪', '小美', '小智', '小萌', '小柔', '小酷', '小甜', '小慧'];
    final types = ['温柔型', '活泼型', '知性型', '冷酷型', '可爱型'];
    final statuses = ['活跃', '禁用', '开发中'];
    
    for (int i = 0; i < names.length; i++) {
      final createdAt = DateTime.now().subtract(Duration(days: i * 5));
      
      characters.add(CharacterModel(
        id: 'char_${(i + 1).toString().padLeft(3, '0')}',
        name: names[i],
        description: '这是一个${types[i % types.length]}的AI角色，具有独特的个性和魅力。',
        avatar: 'https://example.com/avatar_${i + 1}.jpg',
        type: types[i % types.length],
        status: statuses[i % statuses.length],
        tags: ['热门', '推荐', '新角色'].take(i % 3 + 1).toList(),
        personality: {
          '温柔度': 60 + (i * 10) % 40,
          '活泼度': 50 + (i * 15) % 50,
          '智慧度': 70 + (i * 8) % 30,
          '幽默感': 40 + (i * 12) % 60,
        },
        appearance: {
          '身高': '160-170cm',
          '发色': ['黑色', '棕色', '金色'][i % 3],
          '眼色': ['黑色', '棕色', '蓝色'][i % 3],
        },
        background: {
          '职业': ['学生', '白领', '艺术家', '教师'][i % 4],
          '爱好': ['阅读', '音乐', '绘画', '运动'][i % 4],
        },
        skills: ['聊天', '情感支持', '知识问答', '娱乐互动'].take(i % 4 + 1).toList(),
        voiceId: 'voice_${(i % 3 + 1).toString().padLeft(3, '0')}',
        sceneIds: ['scene_001', 'scene_002'].take(i % 2 + 1).toList(),
        modelId: 'model_${(i % 2 + 1).toString().padLeft(3, '0')}',
        usageCount: (i + 1) * 150 + (i * 50),
        rating: 3.5 + (i * 0.3) % 1.5,
        createdAt: createdAt,
        updatedAt: createdAt.add(Duration(days: i)),
        createdBy: 'admin',
      ));
    }
    
    return characters;
  }

  // 生成模拟模型数据
  List<ModelConfig> _generateMockModels() {
    return [
      ModelConfig(
        id: 'model_001',
        name: 'GPT-3.5 Turbo',
        description: '快速响应的对话模型，适合日常聊天',
        type: 'GPT',
        version: '3.5-turbo',
        endpoint: 'https://api.openai.com/v1/chat/completions',
        temperature: 0.7,
        maxTokens: 2048,
        isOnline: true,
        avgResponseTime: 800,
        successRate: 95.5,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ModelConfig(
        id: 'model_002',
        name: 'GPT-4',
        description: '高质量的对话模型，适合复杂对话',
        type: 'GPT',
        version: '4.0',
        endpoint: 'https://api.openai.com/v1/chat/completions',
        temperature: 0.8,
        maxTokens: 4096,
        isOnline: true,
        avgResponseTime: 1200,
        successRate: 98.2,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ModelConfig(
        id: 'model_003',
        name: 'Claude-2',
        description: 'Anthropic的对话模型，注重安全性',
        type: 'Claude',
        version: '2.0',
        endpoint: 'https://api.anthropic.com/v1/messages',
        temperature: 0.6,
        maxTokens: 3000,
        isOnline: false,
        avgResponseTime: 1500,
        successRate: 92.8,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  // 生成模拟语音数据
  List<VoiceModel> _generateMockVoices() {
    return [
      VoiceModel(
        id: 'voice_001',
        name: '甜美女声',
        description: '温柔甜美的女性声音，适合温柔型角色',
        type: '甜美',
        gender: '女',
        language: 'zh-CN',
        audioUrl: 'https://example.com/voice_001.mp3',
        duration: 15,
        sampleRate: 44100,
        format: 'mp3',
        isAvailable: true,
        usageCount: 1250,
        rating: 4.6,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VoiceModel(
        id: 'voice_002',
        name: '活泼女声',
        description: '充满活力的女性声音，适合活泼型角色',
        type: '活泼',
        gender: '女',
        language: 'zh-CN',
        audioUrl: 'https://example.com/voice_002.mp3',
        duration: 12,
        sampleRate: 44100,
        format: 'mp3',
        isAvailable: true,
        usageCount: 980,
        rating: 4.4,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      VoiceModel(
        id: 'voice_003',
        name: '知性女声',
        description: '成熟知性的女性声音，适合知性型角色',
        type: '知性',
        gender: '女',
        language: 'zh-CN',
        audioUrl: 'https://example.com/voice_003.mp3',
        duration: 18,
        sampleRate: 48000,
        format: 'wav',
        isAvailable: true,
        usageCount: 756,
        rating: 4.7,
        createdAt: DateTime.now().subtract(const Duration(days: 18)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  // 生成模拟场景数据
  List<SceneModel> _generateMockScenes() {
    return [
      SceneModel(
        id: 'scene_001',
        name: '温馨咖啡厅',
        description: '安静舒适的咖啡厅环境，适合日常聊天',
        category: '日常',
        thumbnail: 'https://example.com/scene_001_thumb.jpg',
        backgrounds: ['https://example.com/cafe_bg1.jpg', 'https://example.com/cafe_bg2.jpg'],
        settings: {
          '时间': '下午',
          '天气': '晴朗',
          '氛围': '温馨',
        },
        props: ['咖啡杯', '书籍', '笔记本'],
        atmosphere: {
          '光线': '柔和',
          '音量': '安静',
          '温度': '适中',
        },
        musicIds: ['music_001', 'music_002'],
        isEnabled: true,
        usageCount: 2340,
        rating: 4.5,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        createdBy: 'admin',
      ),
      SceneModel(
        id: 'scene_002',
        name: '浪漫海滩',
        description: '美丽的海滩日落场景，适合浪漫对话',
        category: '浪漫',
        thumbnail: 'https://example.com/scene_002_thumb.jpg',
        backgrounds: ['https://example.com/beach_bg1.jpg'],
        settings: {
          '时间': '黄昏',
          '天气': '晴朗',
          '氛围': '浪漫',
        },
        props: ['沙滩椅', '遮阳伞', '贝壳'],
        atmosphere: {
          '光线': '金黄',
          '音量': '海浪声',
          '温度': '温暖',
        },
        musicIds: ['music_003'],
        isEnabled: true,
        usageCount: 1890,
        rating: 4.8,
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdBy: 'admin',
      ),
      SceneModel(
        id: 'scene_003',
        name: '现代图书馆',
        description: '安静的图书馆环境，适合学习讨论',
        category: '学习',
        thumbnail: 'https://example.com/scene_003_thumb.jpg',
        backgrounds: ['https://example.com/library_bg1.jpg'],
        settings: {
          '时间': '上午',
          '天气': '室内',
          '氛围': '专注',
        },
        props: ['书架', '桌子', '台灯'],
        atmosphere: {
          '光线': '明亮',
          '音量': '极安静',
          '温度': '凉爽',
        },
        musicIds: [],
        isEnabled: false,
        usageCount: 567,
        rating: 4.2,
        createdAt: DateTime.now().subtract(const Duration(days: 28)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
        createdBy: 'admin',
      ),
    ];
  }

  // 生成模拟统计数据
  CharacterConfigStats _generateMockStats() {
    return CharacterConfigStats(
      totalCharacters: _characters.length,
      activeCharacters: _characters.where((c) => c.status == '活跃').length,
      totalModels: _models.length,
      onlineModels: _models.where((m) => m.isOnline).length,
      totalVoices: _voices.length,
      availableVoices: _voices.where((v) => v.isAvailable).length,
      totalScenes: _scenes.length,
      enabledScenes: _scenes.where((s) => s.isEnabled).length,
      characterTypeDistribution: {
        '温柔型': _characters.where((c) => c.type == '温柔型').length,
        '活泼型': _characters.where((c) => c.type == '活泼型').length,
        '知性型': _characters.where((c) => c.type == '知性型').length,
        '冷酷型': _characters.where((c) => c.type == '冷酷型').length,
        '可爱型': _characters.where((c) => c.type == '可爱型').length,
      },
      modelTypeDistribution: {
        'GPT': _models.where((m) => m.type == 'GPT').length,
        'Claude': _models.where((m) => m.type == 'Claude').length,
      },
      voiceTypeDistribution: {
        '甜美': _voices.where((v) => v.type == '甜美').length,
        '活泼': _voices.where((v) => v.type == '活泼').length,
        '知性': _voices.where((v) => v.type == '知性').length,
      },
      sceneTypeDistribution: {
        '日常': _scenes.where((s) => s.category == '日常').length,
        '浪漫': _scenes.where((s) => s.category == '浪漫').length,
        '学习': _scenes.where((s) => s.category == '学习').length,
      },
    );
  }
}