import 'dart:math';
import '../models/hot_topic_model.dart';
import '../models/girlfriend_model.dart';

class HotTopicService {
  static final HotTopicService _instance = HotTopicService._internal();
  factory HotTopicService() => _instance;
  HotTopicService._internal();

  // 模拟热门话题数据
  final List<HotTopic> _demoTopics = [
    HotTopic(
      id: 'topic_1',
      title: '二次元萌妹',
      description: '可爱的二次元风格女孩，喜欢动漫和游戏，总是充满活力',
      category: '二次元',
      popularity: 9500,
      tags: ['可爱', '二次元', '动漫', '游戏'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      imageUrl: 'https://i.pravatar.cc/300?img=10',
      characterTemplate: {
        'personality': '可爱活泼',
        'description': '充满活力的二次元女孩，喜欢动漫和游戏，说话时经常使用可爱的语气词',
        'interests': ['动漫', '游戏', 'cosplay', '手办'],
        'personality_traits': ['可爱', '活泼', '天真', '热情'],
        'communication_style': '可爱',
        'background': '来自二次元世界的可爱女孩，对现实世界充满好奇',
        'voice_type': '甜美',
        'age': 18,
        'height': 155,
        'cupSize': 'B',
      },
    ),
    HotTopic(
      id: 'topic_2',
      title: '霸道总裁',
      description: '成熟干练的职场女性，事业有成，有着强烈的领导气质',
      category: '职场',
      popularity: 8800,
      tags: ['成熟', '职场', '霸道', '总裁'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      imageUrl: 'https://i.pravatar.cc/300?img=11',
      characterTemplate: {
        'personality': '霸道总裁',
        'description': '成功的企业家，拥有敏锐的商业嗅觉和强烈的领导欲望',
        'interests': ['商业', '投资', '管理', '奢侈品'],
        'personality_traits': ['自信', '果断', '霸道', '聪明'],
        'communication_style': '直接',
        'background': '白手起家的成功女企业家，掌管着庞大的商业帝国',
        'voice_type': '知性',
        'age': 28,
        'height': 170,
        'cupSize': 'C',
      },
    ),
    HotTopic(
      id: 'topic_3',
      title: '温柔学姐',
      description: '知性温柔的学姐，学识渊博，总是耐心地帮助他人',
      category: '校园',
      popularity: 7600,
      tags: ['温柔', '学姐', '知性', '校园'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      imageUrl: 'https://i.pravatar.cc/300?img=12',
      characterTemplate: {
        'personality': '温柔知性',
        'description': '优秀的大学生，成绩优异，性格温和，喜欢帮助学弟学妹',
        'interests': ['读书', '学习', '音乐', '绘画'],
        'personality_traits': ['温柔', '知性', '耐心', '善良'],
        'communication_style': '温和',
        'background': '名牌大学的优秀学生，担任学生会干部，深受同学喜爱',
        'voice_type': '温柔',
        'age': 22,
        'height': 165,
        'cupSize': 'C',
      },
    ),
    HotTopic(
      id: 'topic_4',
      title: '冷酷御姐',
      description: '外表冷酷但内心火热的御姐，有着神秘的魅力',
      category: '御姐',
      popularity: 9200,
      tags: ['冷酷', '御姐', '神秘', '魅力'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      imageUrl: 'https://i.pravatar.cc/300?img=13',
      characterTemplate: {
        'personality': '冷酷御姐',
        'description': '外表冷漠但内心温柔的女性，拥有强大的气场和神秘的魅力',
        'interests': ['艺术', '音乐', '红酒', '时尚'],
        'personality_traits': ['冷静', '神秘', '优雅', '强势'],
        'communication_style': '含蓄',
        'background': '来自名门望族的神秘女子，有着不为人知的过去',
        'voice_type': '磁性',
        'age': 26,
        'height': 168,
        'cupSize': 'D',
      },
    ),
    HotTopic(
      id: 'topic_5',
      title: '邻家妹妹',
      description: '青梅竹马的邻家女孩，纯真可爱，充满青春活力',
      category: '青春',
      popularity: 8500,
      tags: ['邻家', '青春', '纯真', '活力'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      imageUrl: 'https://i.pravatar.cc/300?img=14',
      characterTemplate: {
        'personality': '纯真可爱',
        'description': '从小一起长大的邻家女孩，性格开朗纯真，充满青春活力',
        'interests': ['运动', '美食', '旅行', '摄影'],
        'personality_traits': ['纯真', '开朗', '活泼', '善良'],
        'communication_style': '自然',
        'background': '普通家庭出身的阳光女孩，有着美好的童年回忆',
        'voice_type': '清甜',
        'age': 20,
        'height': 160,
        'cupSize': 'B',
      },
    ),
    HotTopic(
      id: 'topic_6',
      title: '古风仙女',
      description: '仿佛从古代穿越而来的仙女，优雅脱俗，气质出尘',
      category: '古风',
      popularity: 7800,
      tags: ['古风', '仙女', '优雅', '脱俗'],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      imageUrl: 'https://i.pravatar.cc/300?img=15',
      characterTemplate: {
        'personality': '优雅脱俗',
        'description': '拥有古典美的女子，举手投足间透露着优雅和仙气',
        'interests': ['古典文学', '书法', '茶道', '古琴'],
        'personality_traits': ['优雅', '文静', '脱俗', '温婉'],
        'communication_style': '文雅',
        'background': '书香门第出身，自幼熟读诗书，气质如兰',
        'voice_type': '空灵',
        'age': 24,
        'height': 163,
        'cupSize': 'B',
      },
    ),
  ];

  // 获取所有热门话题
  List<HotTopic> getAllTopics() {
    return List.from(_demoTopics);
  }

  // 按热度排序获取话题
  List<HotTopic> getTopicsByPopularity({int? limit}) {
    final topics = List<HotTopic>.from(_demoTopics);
    topics.sort((a, b) => b.popularity.compareTo(a.popularity));
    if (limit != null && limit > 0) {
      return topics.take(limit).toList();
    }
    return topics;
  }

  // 按分类获取话题
  List<HotTopic> getTopicsByCategory(String category) {
    return _demoTopics.where((topic) => topic.category == category).toList();
  }

  // 搜索话题
  List<HotTopic> searchTopics(String query) {
    final lowerQuery = query.toLowerCase();
    return _demoTopics.where((topic) {
      return topic.title.toLowerCase().contains(lowerQuery) ||
             topic.description.toLowerCase().contains(lowerQuery) ||
             topic.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // 获取所有分类
  List<String> getAllCategories() {
    return _demoTopics.map((topic) => topic.category).toSet().toList();
  }

  // 根据话题创建虚拟女友
  GirlfriendModel createGirlfriendFromTopic(HotTopic topic) {
    final template = topic.characterTemplate;
    final random = Random();
    
    return GirlfriendModel(
      id: 'gf_topic_${topic.id}_${DateTime.now().millisecondsSinceEpoch}',
      name: _generateRandomName(),
      avatarUrl: topic.imageUrl ?? 'https://i.pravatar.cc/300?img=${random.nextInt(50)}',
      personality: template['personality'] ?? topic.title,
      description: template['description'] ?? topic.description,
      intimacy: 0, // 新创建的角色亲密度为0
      isPremium: false,
      isVirtual: true, // 基于话题创建的都是虚拟女友
      createdAt: DateTime.now(),
      usePublicKnowledge: true,
      background: template['background'],
      introduction: template['description'],
      voiceType: template['voice_type'],
      chatMode: 'normal',
      race: '人类',
      eyeColor: _getRandomEyeColor(),
      hairstyle: _getRandomHairstyle(),
      hairColor: _getRandomHairColor(),
      bodyType: 'standard',
      cupSize: template['cupSize'],
      traits: {
        'interests': template['interests'] ?? [],
        'personality_traits': template['personality_traits'] ?? [],
        'communication_style': template['communication_style'] ?? 'normal',
        'age': template['age'] ?? 22,
        'height': template['height'] ?? 165,
        'topic_id': topic.id,
        'topic_title': topic.title,
      },
    );
  }

  // 生成随机名字
  String _generateRandomName() {
    final names = [
      '小雪', '小樱', '小美', '小琳', '小菲', '小冰', '小雨', '小月',
      '小星', '小花', '小草', '小云', '小风', '小夏', '小秋', '小冬',
      '小晴', '小阳', '小露', '小霜', '小虹', '小梦', '小希', '小爱'
    ];
    final random = Random();
    return names[random.nextInt(names.length)];
  }

  // 获取随机眼色
  String _getRandomEyeColor() {
    final colors = ['黑色', '棕色', '蓝色', '绿色', '灰色'];
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  // 获取随机发型
  String _getRandomHairstyle() {
    final styles = ['长直发', '短发', '卷发', '马尾', '双马尾', '丸子头'];
    final random = Random();
    return styles[random.nextInt(styles.length)];
  }

  // 获取随机发色
  String _getRandomHairColor() {
    final colors = ['黑色', '棕色', '金色', '银色', '粉色', '蓝色'];
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }
}