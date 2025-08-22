import 'package:flutter/foundation.dart';
import '../models/theme_model.dart';

class ThemeManagementProvider extends ChangeNotifier {
  List<ThemeModel> _themes = [];
  List<ThemeModel> _filteredThemes = [];
  List<FestivalModel> _festivals = [];
  List<SkinModel> _skins = [];
  List<SkinModel> _filteredSkins = [];
  ThemeManagementStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _selectedSkinCategory = '全部';

  // Getters
  List<ThemeModel> get themes => _themes;
  List<ThemeModel> get filteredThemes => _filteredThemes;
  List<FestivalModel> get festivals => _festivals;
  List<SkinModel> get skins => _skins;
  List<SkinModel> get filteredSkins => _filteredSkins;
  ThemeManagementStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedSkinCategory => _selectedSkinCategory;

  // 统计数据快捷访问
  int get totalThemes => _stats?.totalThemes ?? 0;
  int get activeThemes => _stats?.activeThemes ?? 0;
  int get festivalThemes => _stats?.festivalThemes ?? 0;
  int get activeFestivals => _stats?.activeFestivals ?? 0;
  int get totalSkins => _stats?.totalSkins ?? 0;
  int get availableSkins => _stats?.availableSkins ?? 0;
  double get usageRate => _stats?.usageRate ?? 0.0;

  // 加载主题数据
  Future<void> loadThemes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _themes = _generateMockThemes();
      _filteredThemes = List.from(_themes);
      _festivals = _generateMockFestivals();
      _skins = _generateMockSkins();
      _filteredSkins = List.from(_skins);
      _stats = _generateMockStats();
      
    } catch (e) {
      _error = '加载主题数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 应用主题筛选条件
  void applyFilters({
    String? searchQuery,
    String? status,
    String? category,
  }) {
    _filteredThemes = _themes.where((theme) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!theme.name.toLowerCase().contains(query) &&
            !theme.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态筛选
      if (status != null && theme.status != status) {
        return false;
      }

      // 分类筛选
      if (category != null && theme.category != category) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 设置皮肤分类筛选
  void setSkinCategory(String category) {
    _selectedSkinCategory = category;
    _filterSkins();
    notifyListeners();
  }

  // 筛选皮肤
  void _filterSkins() {
    if (_selectedSkinCategory == '全部') {
      _filteredSkins = List.from(_skins);
    } else {
      _filteredSkins = _skins.where((skin) => skin.category == _selectedSkinCategory).toList();
    }
  }

  // 添加主题
  Future<bool> addTheme(ThemeModel theme) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _themes.add(theme);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '添加主题失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新主题
  Future<bool> updateTheme(ThemeModel theme) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _themes.indexWhere((t) => t.id == theme.id);
      if (index != -1) {
        _themes[index] = theme;
        applyFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '更新主题失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除主题
  Future<bool> deleteTheme(String themeId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _themes.removeWhere((theme) => theme.id == themeId);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '删除主题失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换主题状态
  Future<bool> toggleThemeStatus(String themeId) async {
    try {
      final themeIndex = _themes.indexWhere((t) => t.id == themeId);
      if (themeIndex == -1) return false;
      
      final theme = _themes[themeIndex];
      final newStatus = theme.status == '活跃' ? '禁用' : '活跃';
      
      _themes[themeIndex] = theme.copyWith(status: newStatus);
      applyFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '切换主题状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 复制主题
  Future<bool> duplicateTheme(String themeId) async {
    try {
      final theme = _themes.firstWhere((t) => t.id == themeId);
      final duplicatedTheme = theme.copyWith(
        id: 'theme_${DateTime.now().millisecondsSinceEpoch}',
        name: '${theme.name}_副本',
        status: '草稿',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        usageCount: 0,
      );
      
      return await addTheme(duplicatedTheme);
    } catch (e) {
      _error = '复制主题失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 添加节日活动
  Future<bool> addFestival(FestivalModel festival) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _festivals.add(festival);
      
      return true;
    } catch (e) {
      _error = '添加节日活动失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新节日活动
  Future<bool> updateFestival(FestivalModel festival) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _festivals.indexWhere((f) => f.id == festival.id);
      if (index != -1) {
        _festivals[index] = festival;
      }
      
      return true;
    } catch (e) {
      _error = '更新节日活动失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除节日活动
  Future<bool> deleteFestival(String festivalId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _festivals.removeWhere((festival) => festival.id == festivalId);
      
      return true;
    } catch (e) {
      _error = '删除节日活动失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换节日活动状态
  Future<bool> toggleFestivalStatus(String festivalId) async {
    try {
      final festivalIndex = _festivals.indexWhere((f) => f.id == festivalId);
      if (festivalIndex == -1) return false;
      
      final festival = _festivals[festivalIndex];
      String newStatus;
      
      switch (festival.status) {
        case 'draft':
          newStatus = 'upcoming';
          break;
        case 'upcoming':
          newStatus = 'active';
          break;
        case 'active':
          newStatus = 'ended';
          break;
        case 'ended':
          newStatus = 'active';
          break;
        case 'cancelled':
          newStatus = 'upcoming';
          break;
        default:
          newStatus = 'draft';
      }
      
      _festivals[festivalIndex] = FestivalModel(
        id: festival.id,
        name: festival.name,
        description: festival.description,
        icon: festival.icon,
        bannerImage: festival.bannerImage,
        startDate: festival.startDate,
        endDate: festival.endDate,
        status: newStatus,
        themes: festival.themes,
        rewards: festival.rewards,
        rules: festival.rules,
        participantCount: festival.participantCount,
        maxParticipants: festival.maxParticipants,
        isPublic: festival.isPublic,
        config: festival.config,
        createdAt: festival.createdAt,
        updatedAt: DateTime.now(),
        createdBy: festival.createdBy,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '切换节日活动状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 添加皮肤
  Future<bool> addSkin(SkinModel skin) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _skins.add(skin);
      _filterSkins();
      
      return true;
    } catch (e) {
      _error = '添加皮肤失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除皮肤
  Future<bool> deleteSkin(String skinId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await Future.delayed(const Duration(seconds: 1));
      
      _skins.removeWhere((skin) => skin.id == skinId);
      _filterSkins();
      
      return true;
    } catch (e) {
      _error = '删除皮肤失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 下载皮肤
  Future<bool> downloadSkin(String skinId) async {
    try {
      final skinIndex = _skins.indexWhere((s) => s.id == skinId);
      if (skinIndex == -1) return false;
      
      final skin = _skins[skinIndex];
      _skins[skinIndex] = SkinModel(
        id: skin.id,
        name: skin.name,
        description: skin.description,
        category: skin.category,
        previewUrl: skin.previewUrl,
        downloadUrl: skin.downloadUrl,
        thumbnailUrl: skin.thumbnailUrl,
        tags: skin.tags,
        format: skin.format,
        fileSize: skin.fileSize,
        resolution: skin.resolution,
        isPremium: skin.isPremium,
        price: skin.price,
        downloadCount: skin.downloadCount + 1,
        rating: skin.rating,
        author: skin.author,
        license: skin.license,
        createdAt: skin.createdAt,
        updatedAt: DateTime.now(),
        metadata: skin.metadata,
      );
      
      _filterSkins();
      
      return true;
    } catch (e) {
      _error = '下载皮肤失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 获取主题详情
  ThemeModel? getThemeById(String themeId) {
    try {
      return _themes.firstWhere((theme) => theme.id == themeId);
    } catch (e) {
      return null;
    }
  }

  // 获取节日活动详情
  FestivalModel? getFestivalById(String festivalId) {
    try {
      return _festivals.firstWhere((festival) => festival.id == festivalId);
    } catch (e) {
      return null;
    }
  }

  // 获取皮肤详情
  SkinModel? getSkinById(String skinId) {
    try {
      return _skins.firstWhere((skin) => skin.id == skinId);
    } catch (e) {
      return null;
    }
  }

  // 导出主题配置
  Future<Map<String, dynamic>> exportTheme(String themeId) async {
    try {
      final theme = getThemeById(themeId);
      if (theme == null) return {};
      
      return {
        'theme': theme.toJson(),
        'exportTime': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      _error = '导出主题失败: $e';
      debugPrint(_error);
      return {};
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟主题数据
  List<ThemeModel> _generateMockThemes() {
    final themes = <ThemeModel>[];
    final names = ['春节主题', '情人节主题', '夏日清新', '秋叶飘零', '圣诞节主题', '万圣节主题', '简约现代', '复古怀旧'];
    final categories = ['节日', '季节', '特殊活动', '常规主题'];
    final statuses = ['活跃', '禁用', '草稿', '已过期'];
    final colors = [
      ['#FF6B6B', '#4ECDC4', '#45B7D1'],
      ['#FF9FF3', '#F368E0', '#FD79A8'],
      ['#00B894', '#00CEC9', '#6C5CE7'],
      ['#FDCB6E', '#E17055', '#D63031'],
      ['#74B9FF', '#0984E3', '#6C5CE7'],
      ['#FD79A8', '#FDCB6E', '#E17055'],
      ['#636E72', '#2D3436', '#DDD'],
      ['#8B4513', '#D2691E', '#F4A460'],
    ];
    
    for (int i = 0; i < names.length; i++) {
      final createdAt = DateTime.now().subtract(Duration(days: i * 10));
      final colorSet = colors[i % colors.length];
      
      themes.add(ThemeModel(
        id: 'theme_${(i + 1).toString().padLeft(3, '0')}',
        name: names[i],
        description: '这是一个${names[i]}，为用户提供独特的视觉体验和节日氛围。',
        category: categories[i % categories.length],
        status: statuses[i % statuses.length],
        previewImage: i % 2 == 0 ? 'https://example.com/theme_${i + 1}_preview.jpg' : '',
        primaryColor: colorSet[0],
        secondaryColor: colorSet[1],
        accentColor: colorSet[2],
        colorScheme: {
          'background': colorSet[0],
          'surface': colorSet[1],
          'primary': colorSet[2],
          'text': '#FFFFFF',
        },
        assets: [
          'background.jpg',
          'button_normal.png',
          'button_pressed.png',
          'icon_set.svg',
        ],
        config: {
          'animation': true,
          'sound': true,
          'particles': i % 3 == 0,
        },
        startDate: createdAt,
        endDate: createdAt.add(Duration(days: 30 + (i * 10))),
        isLimited: i % 4 == 0,
        usageCount: (i + 1) * 200 + (i * 100),
        rating: 3.5 + (i * 0.2) % 1.5,
        tags: ['热门', '推荐', '限时'].take(i % 3 + 1).toList(),
        createdAt: createdAt,
        updatedAt: createdAt.add(Duration(days: i)),
        createdBy: 'admin',
      ));
    }
    
    return themes;
  }

  // 生成模拟节日活动数据
  List<FestivalModel> _generateMockFestivals() {
    return [
      FestivalModel(
        id: 'festival_001',
        name: '春节大联欢',
        description: '欢度春节，与AI女友一起体验传统节日的温馨与快乐',
        icon: 'https://example.com/spring_festival_icon.png',
        bannerImage: 'https://example.com/spring_festival_banner.jpg',
        startDate: DateTime(2024, 2, 10),
        endDate: DateTime(2024, 2, 17),
        status: 'active',
        themes: ['theme_001'],
        rewards: ['专属头像框', '节日表情包', '红包雨特效', '限定称号'],
        rules: {
          'dailyCheckin': true,
          'chatMinutes': 30,
          'shareRequired': false,
        },
        participantCount: 15420,
        maxParticipants: 20000,
        isPublic: true,
        config: {
          'showCountdown': true,
          'enableNotifications': true,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'admin',
      ),
      FestivalModel(
        id: 'festival_002',
        name: '情人节甜蜜时光',
        description: '与你的AI女友共度浪漫情人节，解锁专属情侣互动',
        icon: 'https://example.com/valentine_icon.png',
        bannerImage: 'https://example.com/valentine_banner.jpg',
        startDate: DateTime(2024, 2, 14),
        endDate: DateTime(2024, 2, 14),
        status: 'ended',
        themes: ['theme_002'],
        rewards: ['情侣头像', '爱心特效', '甜蜜对话包'],
        rules: {
          'coupleMode': true,
          'giftExchange': true,
        },
        participantCount: 8750,
        maxParticipants: 10000,
        isPublic: true,
        config: {},
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
        createdBy: 'admin',
      ),
      FestivalModel(
        id: 'festival_003',
        name: '夏日清凉节',
        description: '炎炎夏日，与AI女友一起享受清凉夏日时光',
        icon: 'https://example.com/summer_icon.png',
        bannerImage: 'https://example.com/summer_banner.jpg',
        startDate: DateTime(2024, 6, 21),
        endDate: DateTime(2024, 8, 31),
        status: 'upcoming',
        themes: ['theme_003'],
        rewards: ['夏日泳装', '清凉背景', '冰淇淋道具'],
        rules: {
          'seasonalContent': true,
          'weatherInteraction': true,
        },
        participantCount: 0,
        maxParticipants: 15000,
        isPublic: true,
        config: {
          'weatherSync': true,
        },
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'admin',
      ),
    ];
  }

  // 生成模拟皮肤数据
  List<SkinModel> _generateMockSkins() {
    final skins = <SkinModel>[];
    final categories = ['背景', '按钮', '图标', '字体', '动效'];
    final formats = ['png', 'svg', 'gif', 'css', 'json'];
    
    for (int i = 0; i < 20; i++) {
      final category = categories[i % categories.length];
      final format = formats[i % formats.length];
      
      skins.add(SkinModel(
        id: 'skin_${(i + 1).toString().padLeft(3, '0')}',
        name: '${category}皮肤_${i + 1}',
        description: '精美的${category}皮肤，提升用户界面体验',
        category: category,
        previewUrl: 'https://example.com/skin_${i + 1}_preview.${format}',
        downloadUrl: 'https://example.com/skin_${i + 1}.${format}',
        thumbnailUrl: 'https://example.com/skin_${i + 1}_thumb.jpg',
        tags: ['精美', '热门', '推荐'].take((i % 3) + 1).toList(),
        format: format,
        fileSize: 1024 * (50 + (i * 20)), // 50KB - 430KB
        resolution: format == 'svg' ? 'vector' : '${800 + (i * 100)}x${600 + (i * 75)}',
        isPremium: i % 5 == 0,
        price: i % 5 == 0 ? 9.9 + (i * 2) : 0.0,
        downloadCount: (i + 1) * 50 + (i * 25),
        rating: 3.5 + (i * 0.15) % 1.5,
        author: i % 3 == 0 ? 'AI设计师' : '用户投稿',
        license: i % 4 == 0 ? 'Premium' : 'Free',
        createdAt: DateTime.now().subtract(Duration(days: i * 2)),
        updatedAt: DateTime.now().subtract(Duration(days: i)),
      ));
    }
    
    return skins;
  }

  // 生成模拟统计数据
  ThemeManagementStats _generateMockStats() {
    return ThemeManagementStats(
      totalThemes: _themes.length,
      activeThemes: _themes.where((t) => t.status == '活跃').length,
      festivalThemes: _themes.where((t) => t.category == '节日').length,
      activeFestivals: _festivals.where((f) => f.status == 'active').length,
      totalSkins: _skins.length,
      availableSkins: _skins.where((s) => !s.isPremium || s.price == 0).length,
      usageRate: 78.5,
      themesByCategory: {
        '节日': _themes.where((t) => t.category == '节日').length,
        '季节': _themes.where((t) => t.category == '季节').length,
        '特殊活动': _themes.where((t) => t.category == '特殊活动').length,
        '常规主题': _themes.where((t) => t.category == '常规主题').length,
      },
      skinsByCategory: {
        '背景': _skins.where((s) => s.category == '背景').length,
        '按钮': _skins.where((s) => s.category == '按钮').length,
        '图标': _skins.where((s) => s.category == '图标').length,
        '字体': _skins.where((s) => s.category == '字体').length,
        '动效': _skins.where((s) => s.category == '动效').length,
      },
      festivalsByStatus: {
        'active': _festivals.where((f) => f.status == 'active').length,
        'upcoming': _festivals.where((f) => f.status == 'upcoming').length,
        'ended': _festivals.where((f) => f.status == 'ended').length,
        'cancelled': _festivals.where((f) => f.status == 'cancelled').length,
        'draft': _festivals.where((f) => f.status == 'draft').length,
      },
      popularThemes: _themes.where((t) => t.isPopular).take(5).toList(),
      popularSkins: _skins.where((s) => s.isPopular).take(5).toList(),
    );
  }
}