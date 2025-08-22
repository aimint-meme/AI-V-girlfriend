import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/secondary_personality_model.dart';
import '../models/girlfriend_model.dart';

class SecondaryPersonalityService {
  static const String _storageKey = 'secondary_personalities';
  static const String _knowledgeBaseKey = 'knowledge_bases';
  
  // 获取所有第二人格
  Future<List<SecondaryPersonalityModel>> getAllPersonalities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final personalitiesJson = prefs.getString(_storageKey);
      
      if (personalitiesJson == null) return [];
      
      final List<dynamic> personalitiesList = json.decode(personalitiesJson);
      return personalitiesList
          .map((json) => SecondaryPersonalityModel.fromJson(json))
          .toList();
    } catch (e) {
      print('获取第二人格失败: $e');
      return [];
    }
  }
  
  // 根据ID获取第二人格
  Future<SecondaryPersonalityModel?> getPersonalityById(String id) async {
    final personalities = await getAllPersonalities();
    try {
      return personalities.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 保存第二人格
  Future<void> savePersonality(SecondaryPersonalityModel personality) async {
    try {
      final personalities = await getAllPersonalities();
      final index = personalities.indexWhere((p) => p.id == personality.id);
      
      if (index >= 0) {
        personalities[index] = personality;
      } else {
        personalities.add(personality);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final personalitiesJson = json.encode(
        personalities.map((p) => p.toJson()).toList()
      );
      await prefs.setString(_storageKey, personalitiesJson);
    } catch (e) {
      print('保存第二人格失败: $e');
      throw Exception('保存第二人格失败');
    }
  }
  
  // 删除第二人格
  Future<void> deletePersonality(String id) async {
    try {
      final personalities = await getAllPersonalities();
      personalities.removeWhere((p) => p.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final personalitiesJson = json.encode(
        personalities.map((p) => p.toJson()).toList()
      );
      await prefs.setString(_storageKey, personalitiesJson);
    } catch (e) {
      print('删除第二人格失败: $e');
      throw Exception('删除第二人格失败');
    }
  }
  
  // 获取角色的第二人格列表
  Future<List<SecondaryPersonalityModel>> getPersonalitiesForGirlfriend(
    GirlfriendModel girlfriend
  ) async {
    if (girlfriend.secondaryPersonalityIds == null) return [];
    
    final allPersonalities = await getAllPersonalities();
    return allPersonalities
        .where((p) => girlfriend.secondaryPersonalityIds!.contains(p.id))
        .toList();
  }
  
  // 检查用户是否有权限使用某个第二人格
  bool checkPersonalityAccess(
    SecondaryPersonalityModel personality, 
    String userMembershipLevel
  ) {
    return personality.checkMembershipRequirement(userMembershipLevel);
  }
  
  // 根据消息内容选择合适的第二人格
  Future<SecondaryPersonalityModel?> selectPersonalityForMessage(
    String message,
    GirlfriendModel girlfriend,
    String userMembershipLevel
  ) async {
    final personalities = await getPersonalitiesForGirlfriend(girlfriend);
    
    // 过滤有权限且激活的人格
    final availablePersonalities = personalities
        .where((p) => p.isActive && checkPersonalityAccess(p, userMembershipLevel))
        .toList();
    
    if (availablePersonalities.isEmpty) return null;
    
    // 查找被触发的人格
    final triggeredPersonalities = availablePersonalities
        .where((p) => p.shouldTrigger(message))
        .toList();
    
    if (triggeredPersonalities.isEmpty) {
      // 如果没有被触发的人格，返回当前激活的人格
      if (girlfriend.activeSecondaryPersonalityId != null) {
        return availablePersonalities
            .where((p) => p.id == girlfriend.activeSecondaryPersonalityId)
            .firstOrNull;
      }
      return null;
    }
    
    // 如果有多个被触发的人格，选择权重最高的
    triggeredPersonalities.sort((a, b) => b.influenceWeight.compareTo(a.influenceWeight));
    return triggeredPersonalities.first;
  }
  
  // 混合原始人格和第二人格生成回复
  Future<Map<String, dynamic>> generateMixedResponse(
    String message,
    GirlfriendModel girlfriend,
    String userMembershipLevel,
    {SecondaryPersonalityModel? forcedPersonality}
  ) async {
    final selectedPersonality = forcedPersonality ?? 
        await selectPersonalityForMessage(message, girlfriend, userMembershipLevel);
    
    if (selectedPersonality == null) {
      return {
        'useSecondaryPersonality': false,
        'personalityName': null,
        'mixConfig': null,
        'responseStyle': girlfriend.personality,
        'knowledgeBaseId': null,
      };
    }
    
    // 获取混合配置
    final mixConfig = girlfriend.personalityMixConfig ?? {
      'primaryWeight': 0.6,
      'secondaryWeight': 0.4,
      'blendMode': 'balanced', // balanced, dominant, subtle
    };
    
    return {
      'useSecondaryPersonality': true,
      'personalityName': selectedPersonality.name,
      'personalityType': selectedPersonality.personalityType,
      'mixConfig': mixConfig,
      'responseStyle': selectedPersonality.responseStyle,
      'knowledgeBaseId': selectedPersonality.knowledgeBaseId,
      'influenceWeight': selectedPersonality.influenceWeight,
      'personalityTraits': selectedPersonality.personalityTraits,
    };
  }
  
  // 获取可用的知识库列表
  Future<List<Map<String, dynamic>>> getAvailableKnowledgeBases() async {
    // 这里应该从实际的知识库服务获取，现在返回模拟数据
    return [
      {
        'id': 'general_knowledge',
        'name': '通用知识库',
        'description': '包含常识、百科知识等通用信息',
        'membershipLevel': 'free',
        'category': 'general',
      },
      {
        'id': 'literature_classics',
        'name': '文学经典',
        'description': '包含古今中外文学作品和文学知识',
        'membershipLevel': 'premium',
        'category': 'literature',
      },
      {
        'id': 'science_tech',
        'name': '科学技术',
        'description': '包含科学原理、技术发展等专业知识',
        'membershipLevel': 'premium',
        'category': 'science',
      },
      {
        'id': 'psychology_philosophy',
        'name': '心理哲学',
        'description': '包含心理学理论、哲学思想等深度内容',
        'membershipLevel': 'vip',
        'category': 'psychology',
      },
      {
        'id': 'entertainment_pop',
        'name': '娱乐流行',
        'description': '包含影视、音乐、游戏等娱乐资讯',
        'membershipLevel': 'free',
        'category': 'entertainment',
      },
      {
        'id': 'history_culture',
        'name': '历史文化',
        'description': '包含历史事件、文化传统等人文知识',
        'membershipLevel': 'premium',
        'category': 'culture',
      },
    ];
  }
  
  // 根据会员等级过滤知识库
  Future<List<Map<String, dynamic>>> getAccessibleKnowledgeBases(
    String userMembershipLevel
  ) async {
    final allKnowledgeBases = await getAvailableKnowledgeBases();
    const levelHierarchy = {
      'free': 0,
      'premium': 1,
      'vip': 2,
    };
    
    final userLevel = levelHierarchy[userMembershipLevel] ?? 0;
    
    return allKnowledgeBases.where((kb) {
      final requiredLevel = levelHierarchy[kb['membershipLevel']] ?? 0;
      return userLevel >= requiredLevel;
    }).toList();
  }
  
  // 创建预设第二人格
  Future<SecondaryPersonalityModel> createPresetPersonality(
    String templateName,
    String knowledgeBaseId
  ) async {
    final personality = SecondaryPersonalityTemplates.createFromTemplate(
      templateName, 
      knowledgeBaseId
    );
    
    await savePersonality(personality);
    return personality;
  }
  
  // 创建自定义第二人格
  Future<SecondaryPersonalityModel> createCustomPersonality({
    required String name,
    required String description,
    required String personalityType,
    required String knowledgeBaseId,
    required String membershipLevel,
    double influenceWeight = 0.5,
    Map<String, dynamic> personalityTraits = const {},
    List<String> triggerKeywords = const [],
    String responseStyle = 'balanced',
  }) async {
    final personality = SecondaryPersonalityModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      personalityType: personalityType,
      knowledgeBaseId: knowledgeBaseId,
      membershipLevel: membershipLevel,
      influenceWeight: influenceWeight,
      personalityTraits: personalityTraits,
      triggerKeywords: triggerKeywords,
      responseStyle: responseStyle,
      createdAt: DateTime.now(),
    );
    
    await savePersonality(personality);
    return personality;
  }
  
  // 为角色绑定第二人格
  Future<GirlfriendModel> bindPersonalityToGirlfriend(
    GirlfriendModel girlfriend,
    String personalityId
  ) async {
    final currentIds = girlfriend.secondaryPersonalityIds ?? [];
    if (!currentIds.contains(personalityId)) {
      final newIds = [...currentIds, personalityId];
      return girlfriend.copyWith(
        secondaryPersonalityIds: newIds,
        activeSecondaryPersonalityId: girlfriend.activeSecondaryPersonalityId ?? personalityId,
      );
    }
    return girlfriend;
  }
  
  // 从角色解绑第二人格
  Future<GirlfriendModel> unbindPersonalityFromGirlfriend(
    GirlfriendModel girlfriend,
    String personalityId
  ) async {
    final currentIds = girlfriend.secondaryPersonalityIds ?? [];
    final newIds = currentIds.where((id) => id != personalityId).toList();
    
    String? newActiveId = girlfriend.activeSecondaryPersonalityId;
    if (newActiveId == personalityId) {
      newActiveId = newIds.isNotEmpty ? newIds.first : null;
    }
    
    return girlfriend.copyWith(
      secondaryPersonalityIds: newIds,
      activeSecondaryPersonalityId: newActiveId,
    );
  }
  
  // 设置角色的激活第二人格
  Future<GirlfriendModel> setActivePersonality(
    GirlfriendModel girlfriend,
    String? personalityId
  ) async {
    return girlfriend.copyWith(
      activeSecondaryPersonalityId: personalityId,
    );
  }
  
  // 更新人格混合配置
  Future<GirlfriendModel> updatePersonalityMixConfig(
    GirlfriendModel girlfriend,
    Map<String, dynamic> mixConfig
  ) async {
    return girlfriend.copyWith(
      personalityMixConfig: mixConfig,
    );
  }
}

// 扩展方法
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}