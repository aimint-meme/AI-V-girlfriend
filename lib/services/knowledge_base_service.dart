import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/knowledge_payment_model.dart';

/// 知识库类型枚举（已废弃，使用KnowledgePaymentTier替代）
@Deprecated('Use KnowledgePaymentTier instead')
enum KnowledgeType {
  free,      // 免费
  premium,   // 付费（999金币）
  advanced,  // 高阶（需要会员）
}

/// 知识库文档
class KnowledgeDocument {
  final String id;
  final String title;
  final String content;
  final bool isUnlocked;
  
  KnowledgeDocument({
    required this.id,
    required this.title,
    required this.content,
    this.isUnlocked = true,
  });
  
  /// 获取预览内容（前200个字符）
  String get previewContent {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'isUnlocked': isUnlocked,
  };
  
  factory KnowledgeDocument.fromJson(Map<String, dynamic> json) => KnowledgeDocument(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    isUnlocked: json['isUnlocked'] ?? true,
  );
  
  KnowledgeDocument copyWith({
    String? id,
    String? title,
    String? content,
    bool? isUnlocked,
  }) => KnowledgeDocument(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    isUnlocked: isUnlocked ?? this.isUnlocked,
  );
}

/// 知识库条目
class KnowledgeEntry {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final double relevanceScore;
  final String category;
  @Deprecated('Use paymentTier instead')
  final KnowledgeType type;
  final int unlockCost;
  final bool isUnlocked;
  final List<KnowledgeDocument> documents;
  
  // 新的付费体系字段
  final KnowledgePaymentTier paymentTier;
  final Set<AdvancedContentTag> requiredTags; // 高阶内容需要的标签
  final bool requiresMembership; // 是否需要会员
  final UnlockMethod preferredUnlockMethod; // 推荐的解锁方式

  KnowledgeEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.tags,
    required this.createdAt,
    this.relevanceScore = 0.0,
    required this.category,
    @Deprecated('Use paymentTier instead')
    this.type = KnowledgeType.free,
    this.unlockCost = 0,
    this.isUnlocked = true,
    this.documents = const [],
    this.paymentTier = KnowledgePaymentTier.free,
    this.requiredTags = const {},
    this.requiresMembership = false,
    this.preferredUnlockMethod = UnlockMethod.free,
  });
  
  /// 获取预览内容（前200个字符）
  String get previewContent {
    if (content.length <= 200) return content;
    return '${content.substring(0, 200)}...';
  }
  
  /// 获取知识库类型的显示名称
  @Deprecated('Use paymentTierDisplayName instead')
  String get typeDisplayName {
    switch (type) {
      case KnowledgeType.free:
        return '免费';
      case KnowledgeType.premium:
        return '付费';
      case KnowledgeType.advanced:
        return '高阶';
    }
  }
  
  /// 获取付费层级的显示名称
  String get paymentTierDisplayName {
    return KnowledgePaymentConfig.getPaymentTierName(paymentTier);
  }
  
  /// 获取解锁状态的显示文本
  String get unlockStatusText {
    if (isUnlocked) return '已解锁';
    
    switch (paymentTier) {
      case KnowledgePaymentTier.free:
        return '免费';
      case KnowledgePaymentTier.premium:
        if (unlockCost > 0) {
          return '需要 $unlockCost 金币';
        }
        return '需要 ${KnowledgePaymentConfig.singleDocumentCost} 金币';
      case KnowledgePaymentTier.advanced:
        if (requiresMembership) {
          return '需要会员';
        }
        return '需要 ${KnowledgePaymentConfig.advancedMembershipCost} 金币';
    }
  }
  
  /// 获取解锁价格
  int get unlockPrice {
    switch (paymentTier) {
      case KnowledgePaymentTier.free:
        return 0;
      case KnowledgePaymentTier.premium:
        return unlockCost > 0 ? unlockCost : KnowledgePaymentConfig.singleDocumentCost;
      case KnowledgePaymentTier.advanced:
        return KnowledgePaymentConfig.advancedMembershipCost;
    }
  }
  
  /// 检查用户是否可以访问此知识库
  bool canUserAccess({
    required bool isMember,
    required MembershipType membershipType,
    required Set<AdvancedContentTag> unlockedTags,
    required Set<String> purchasedKnowledgeIds,
  }) {
    if (isUnlocked) return true;
    
    switch (paymentTier) {
      case KnowledgePaymentTier.free:
        return true;
      case KnowledgePaymentTier.premium:
        return purchasedKnowledgeIds.contains(id) || 
               (isMember && membershipType != MembershipType.none);
      case KnowledgePaymentTier.advanced:
        if (membershipType == MembershipType.lifetime || 
            membershipType == MembershipType.supreme) {
          return true;
        }
        if (requiredTags.isNotEmpty) {
          return requiredTags.every((tag) => unlockedTags.contains(tag));
        }
        return isMember && membershipType == MembershipType.premium;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'tags': tags,
    'createdAt': createdAt.toIso8601String(),
    'relevanceScore': relevanceScore,
    'category': category,
    'type': type.index, // 保持向后兼容
    'unlockCost': unlockCost,
    'isUnlocked': isUnlocked,
    'documents': documents.map((doc) => doc.toJson()).toList(),
    // 新的付费体系字段
    'paymentTier': paymentTier.index,
    'requiredTags': requiredTags.map((tag) => tag.index).toList(),
    'requiresMembership': requiresMembership,
    'preferredUnlockMethod': preferredUnlockMethod.index,
  };
  
  /// 从类型索引获取KnowledgeType
  static KnowledgeType _getTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return KnowledgeType.free;
      case 1:
        return KnowledgeType.premium;
      case 2:
        return KnowledgeType.advanced;
      default:
        return KnowledgeType.free;
    }
  }

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) => KnowledgeEntry(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    tags: List<String>.from(json['tags']),
    createdAt: DateTime.parse(json['createdAt']),
    relevanceScore: json['relevanceScore']?.toDouble() ?? 0.0,
    category: json['category'],
    type: _getTypeFromIndex(json['type'] ?? 0),
    unlockCost: json['unlockCost'] ?? 0,
    isUnlocked: json['isUnlocked'] ?? true,
    documents: json['documents'] != null 
        ? (json['documents'] as List).map((doc) => KnowledgeDocument.fromJson(doc)).toList()
        : [],
    // 新的付费体系字段
    paymentTier: json['paymentTier'] != null 
        ? KnowledgePaymentTier.values[json['paymentTier']] 
        : KnowledgePaymentTier.free,
    requiredTags: json['requiredTags'] != null 
        ? (json['requiredTags'] as List<dynamic>)
            .map((index) => AdvancedContentTag.values[index])
            .toSet()
        : {},
    requiresMembership: json['requiresMembership'] ?? false,
    preferredUnlockMethod: json['preferredUnlockMethod'] != null 
        ? UnlockMethod.values[json['preferredUnlockMethod']] 
        : UnlockMethod.free,
  );

  KnowledgeEntry copyWith({
    double? relevanceScore,
    bool? isUnlocked,
    List<KnowledgeDocument>? documents,
    KnowledgePaymentTier? paymentTier,
    Set<AdvancedContentTag>? requiredTags,
    bool? requiresMembership,
    UnlockMethod? preferredUnlockMethod,
  }) => KnowledgeEntry(
    id: id,
    title: title,
    content: content,
    tags: tags,
    createdAt: createdAt,
    relevanceScore: relevanceScore ?? this.relevanceScore,
    category: category,
    type: type,
    unlockCost: unlockCost,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    documents: documents ?? this.documents,
    paymentTier: paymentTier ?? this.paymentTier,
    requiredTags: requiredTags ?? this.requiredTags,
    requiresMembership: requiresMembership ?? this.requiresMembership,
    preferredUnlockMethod: preferredUnlockMethod ?? this.preferredUnlockMethod,
  );
}

/// 知识库服务
class KnowledgeBaseService {
  static const String _knowledgeKey = 'knowledge_base';
  static const String _publicKnowledgeKey = 'public_knowledge_base';
  
  List<KnowledgeEntry> _knowledgeBase = [];
  List<KnowledgeEntry> _publicKnowledgeBase = [];
  
  /// 初始化知识库
  Future<void> initialize() async {
    await _loadKnowledgeBase();
    await _loadPublicKnowledgeBase();
    
    // 如果知识库为空，添加默认内容
    if (_knowledgeBase.isEmpty) {
      await _addDefaultKnowledge();
    }
    
    if (_publicKnowledgeBase.isEmpty) {
      await _addDefaultPublicKnowledge();
    }
  }
  
  /// 加载私有知识库
  Future<void> _loadKnowledgeBase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_knowledgeKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _knowledgeBase = jsonList.map((json) => KnowledgeEntry.fromJson(json)).toList();
      }
    } catch (e) {
      print('加载知识库失败: $e');
    }
  }
  
  /// 加载公开知识库
  Future<void> _loadPublicKnowledgeBase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_publicKnowledgeKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _publicKnowledgeBase = jsonList.map((json) => KnowledgeEntry.fromJson(json)).toList();
      }
    } catch (e) {
      print('加载公开知识库失败: $e');
    }
  }
  
  /// 保存私有知识库
  Future<void> _saveKnowledgeBase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_knowledgeBase.map((entry) => entry.toJson()).toList());
      await prefs.setString(_knowledgeKey, jsonString);
    } catch (e) {
      print('保存知识库失败: $e');
    }
  }
  
  /// 保存公开知识库
  Future<void> _savePublicKnowledgeBase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_publicKnowledgeBase.map((entry) => entry.toJson()).toList());
      await prefs.setString(_publicKnowledgeKey, jsonString);
    } catch (e) {
      print('保存公开知识库失败: $e');
    }
  }
  
  /// 添加默认知识
  Future<void> _addDefaultKnowledge() async {
    final defaultEntries = [
      KnowledgeEntry(
        id: 'default_1',
        title: '日常问候',
        content: '当用户说你好、嗨、hi等问候语时，应该热情回应，询问用户的近况，表达关心。',
        tags: ['问候', '日常', '交流'],
        createdAt: DateTime.now(),
        category: '社交礼仪',
      ),
      KnowledgeEntry(
        id: 'default_2',
        title: '情感支持',
        content: '当用户表达负面情绪如难过、伤心、不开心时，应该给予安慰和支持，可以建议一些放松的活动。',
        tags: ['情感', '支持', '安慰'],
        createdAt: DateTime.now(),
        category: '情感关怀',
      ),
      KnowledgeEntry(
        id: 'default_3',
        title: '兴趣爱好',
        content: '了解用户的兴趣爱好，如音乐、电影、游戏、运动等，可以进行相关话题的深入交流。',
        tags: ['兴趣', '爱好', '娱乐'],
        createdAt: DateTime.now(),
        category: '个人兴趣',
      ),
      KnowledgeEntry(
        id: 'default_4',
        title: '工作学习',
        content: '关心用户的工作和学习情况，提供鼓励和建议，帮助缓解压力。',
        tags: ['工作', '学习', '压力'],
        createdAt: DateTime.now(),
        category: '生活支持',
      ),
    ];
    
    _knowledgeBase.addAll(defaultEntries);
    await _saveKnowledgeBase();
  }
  
  /// 添加默认公开知识
  Future<void> _addDefaultPublicKnowledge() async {
    final defaultPublicEntries = [
      // 免费知识库
      KnowledgeEntry(
        id: 'public_1',
        title: '健康生活基础',
        content: '保持规律作息，均衡饮食，适量运动，充足睡眠是健康生活的基础。建议每天至少运动30分钟，保证7-8小时睡眠。',
        tags: ['健康', '生活', '运动', '睡眠'],
        createdAt: DateTime.now(),
        category: '健康知识',
        type: KnowledgeType.free,
        paymentTier: KnowledgePaymentTier.free,
        unlockCost: 0,
        isUnlocked: true,
      ),
      
      // 付费知识库
      KnowledgeEntry(
        id: 'premium_1',
        title: '高级沟通技巧',
        content: '掌握高级沟通技巧，包括非暴力沟通、情感表达、冲突解决等方法。学会倾听、共情和有效反馈，提升人际关系质量。',
        tags: ['沟通', '技巧', '人际关系', '情商'],
        createdAt: DateTime.now(),
        category: '沟通技巧',
        type: KnowledgeType.premium,
        paymentTier: KnowledgePaymentTier.premium,
        unlockCost: 99,
        isUnlocked: false,
      ),
      
      KnowledgeEntry(
        id: 'premium_2',
        title: '情感管理秘籍',
        content: '深入了解情感管理的核心原理，学习情绪调节技巧，掌握压力释放方法，建立健康的情感表达模式。',
        tags: ['情感', '管理', '情绪', '压力'],
        createdAt: DateTime.now(),
        category: '心理健康',
        type: KnowledgeType.premium,
        paymentTier: KnowledgePaymentTier.premium,
        unlockCost: 99,
        isUnlocked: false,
      ),
      
      // 高阶知识库
      KnowledgeEntry(
        id: 'advanced_1',
        title: '深度心理分析',
        content: '运用专业心理学理论进行深度心理分析，包括人格类型识别、潜意识探索、行为模式分析等高级技能。',
        tags: ['心理学', '分析', '人格', '潜意识'],
        createdAt: DateTime.now(),
        category: '心理学',
        type: KnowledgeType.advanced,
        paymentTier: KnowledgePaymentTier.advanced,
        requiresMembership: true,
        requiredTags: {AdvancedContentTag.psychology, AdvancedContentTag.assessment},
        unlockCost: 0,
        isUnlocked: false,
      ),
      
      KnowledgeEntry(
        id: 'advanced_2',
        title: '关系治疗技术',
        content: '专业的关系治疗技术，包括夫妻治疗、家庭治疗、团体治疗等方法，帮助修复和改善各种人际关系。',
        tags: ['治疗', '关系', '夫妻', '家庭'],
        createdAt: DateTime.now(),
        category: '心理治疗',
        type: KnowledgeType.advanced,
        paymentTier: KnowledgePaymentTier.advanced,
        requiresMembership: true,
        requiredTags: {AdvancedContentTag.therapy, AdvancedContentTag.relationship},
        unlockCost: 0,
        isUnlocked: false,
      ),
      
      KnowledgeEntry(
        id: 'advanced_3',
        title: '领导力心理学',
        content: '基于心理学原理的领导力发展，包括团队动力学、决策心理学、影响力技巧等高级管理知识。',
        tags: ['领导力', '管理', '团队', '决策'],
        createdAt: DateTime.now(),
        category: '管理心理学',
        type: KnowledgeType.advanced,
        paymentTier: KnowledgePaymentTier.advanced,
        requiresMembership: true,
        requiredTags: {AdvancedContentTag.leadership, AdvancedContentTag.psychology},
        unlockCost: 0,
        isUnlocked: false,
      ),
      KnowledgeEntry(
        id: 'public_2',
        title: '情绪管理',
        content: '学会识别和管理情绪很重要。可以通过深呼吸、冥想、运动、与朋友交流等方式来调节情绪。',
        tags: ['情绪', '管理', '心理健康'],
        createdAt: DateTime.now(),
        category: '心理健康',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
      ),
      
      // 付费知识库（999金币）
      KnowledgeEntry(
        id: 'public_premium_1',
        title: '高效学习法',
        content: '费曼学习法：通过教授他人来检验自己的理解。间隔重复：利用遗忘曲线优化记忆。主动回忆：不看资料尝试回忆知识点。',
        tags: ['学习', '方法', '效率', '记忆'],
        createdAt: DateTime.now(),
        category: '学习技巧',
        type: KnowledgeType.premium,
        unlockCost: 999,
        isUnlocked: false,
        documents: [
          KnowledgeDocument(
            id: 'doc_premium_1_1',
            title: '费曼学习法详解',
            content: '费曼学习法是一种通过教授他人来检验和加深自己理解的学习方法。这种方法由诺贝尔物理学奖得主理查德·费曼提出，核心思想是"如果你不能简单地解释一个概念，那么你就没有真正理解它"。\n\n实施步骤：\n1. 选择一个你想要学习的概念\n2. 假设你要向一个完全不懂这个领域的人解释这个概念\n3. 用最简单的语言写下你的解释\n4. 识别出你解释中的薄弱环节\n5. 回到原始资料，重新学习这些薄弱环节\n6. 简化你的解释，使用类比和例子\n\n费曼学习法的优势：\n- 强迫你真正理解概念，而不是死记硬背\n- 帮助识别知识盲点\n- 提高表达和沟通能力\n- 加深记忆，提高学习效率',
            isUnlocked: false,
          ),
          KnowledgeDocument(
            id: 'doc_premium_1_2',
            title: '间隔重复记忆法',
            content: '间隔重复是一种基于遗忘曲线的学习技巧，通过在特定的时间间隔内重复学习材料来优化长期记忆。这种方法由德国心理学家赫尔曼·艾宾浩斯的遗忘曲线理论支持。\n\n核心原理：\n- 人类的遗忘是有规律的，刚学完的内容会快速遗忘\n- 通过在遗忘临界点进行复习，可以显著提高记忆保持率\n- 每次成功回忆后，下次复习的间隔可以延长\n\n实施方法：\n1. 第一次学习后1天复习\n2. 第二次复习后3天再复习\n3. 第三次复习后7天再复习\n4. 第四次复习后15天再复习\n5. 第五次复习后30天再复习\n\n现代工具：\n- Anki：最流行的间隔重复软件\n- Quizlet：在线学习卡片工具\n- SuperMemo：间隔重复算法的鼻祖\n\n适用场景：\n- 语言学习（单词、语法）\n- 医学术语记忆\n- 历史日期和事件\n- 数学公式和定理',
            isUnlocked: false,
          ),
          KnowledgeDocument(
            id: 'doc_premium_1_3',
            title: '主动回忆训练',
            content: '主动回忆是一种学习策略，指在不看资料的情况下，主动尝试从记忆中提取信息。这种方法比被动重读材料更有效，能显著提高学习效果和记忆保持。\n\n科学依据：\n- 提取练习效应：主动回忆比重复阅读更能加强记忆\n- 困难理论：适度的困难能促进更深层的学习\n- 神经可塑性：主动回忆能强化神经连接\n\n实践技巧：\n1. 合上书本，尝试回忆刚学的内容\n2. 用自己的话重新组织信息\n3. 制作思维导图或概念图\n4. 向他人解释学到的概念\n5. 做练习题而不是重读笔记\n\n常见误区：\n- 认为重读比回忆更容易，实际上容易产生"熟悉感错觉"\n- 害怕回忆不出来，实际上"困难"是学习的标志\n- 只在考试前才使用，应该在日常学习中持续应用\n\n提高效果的方法：\n- 设置定时器，限制回忆时间\n- 记录回忆的准确性，追踪进步\n- 结合间隔重复，在不同时间点进行回忆\n- 使用多种感官，如口述、书写、绘图',
            isUnlocked: false,
          ),
        ],
      ),
      KnowledgeEntry(
        id: 'public_premium_2',
        title: '深度沟通技巧',
        content: '非暴力沟通四要素：观察、感受、需要、请求。积极倾听技巧：全神贯注、适时回应、情感共鸣。冲突解决策略：寻找共同点、换位思考、双赢思维。',
        tags: ['沟通', '人际关系', '冲突解决'],
        createdAt: DateTime.now(),
        category: '社交技能',
        type: KnowledgeType.premium,
        unlockCost: 999,
        isUnlocked: false,
      ),
      KnowledgeEntry(
        id: 'public_premium_3',
        title: '时间管理大师',
        content: 'GTD方法：收集、处理、组织、回顾、执行。四象限法则：重要紧急矩阵。番茄工作法：25分钟专注+5分钟休息。时间审计：记录时间使用情况。',
        tags: ['时间管理', '效率', '生产力'],
        createdAt: DateTime.now(),
        category: '个人发展',
        type: KnowledgeType.premium,
        unlockCost: 999,
        isUnlocked: false,
      ),
      
      // 高阶知识库（需要会员）
      KnowledgeEntry(
        id: 'public_advanced_1',
        title: '心理学高阶技巧',
        content: '认知行为疗法（CBT）：识别和改变负面思维模式。正念冥想：培养当下意识，减少焦虑。情绪调节策略：认知重评、注意力转移、情境选择。神经可塑性：大脑重塑的科学原理。',
        tags: ['心理学', '认知', '情绪调节', '正念'],
        createdAt: DateTime.now(),
        category: '心理健康',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
      ),
      KnowledgeEntry(
        id: 'public_advanced_2',
        title: '领导力精髓',
        content: '变革型领导：愿景激励、个性化关怀、智力激发。情商领导：自我认知、自我管理、社会认知、关系管理。授权艺术：明确期望、提供资源、定期反馈。团队动力学：角色分工、冲突管理、协作机制。',
        tags: ['领导力', '管理', '团队', '情商'],
        createdAt: DateTime.now(),
        category: '职场发展',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
      ),
      KnowledgeEntry(
        id: 'public_advanced_3',
        title: '创新思维训练',
        content: '设计思维：同理心、定义问题、创意构思、原型制作、测试迭代。SCAMPER技法：替代、组合、适应、修改、其他用途、消除、重新排列。六顶思考帽：全面思考问题的不同角度。',
        tags: ['创新', '思维', '设计思维', '创意'],
        createdAt: DateTime.now(),
        category: '创新思维',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
      ),
      KnowledgeEntry(
        id: 'public_advanced_4',
        title: '投资理财进阶',
        content: '价值投资原理：内在价值评估、安全边际、长期持有。资产配置策略：股债平衡、风险分散、定期再平衡。行为金融学：认知偏差、情绪影响、理性决策。复利效应：时间价值、复合增长、财富积累。',
        tags: ['投资', '理财', '价值投资', '资产配置'],
        createdAt: DateTime.now(),
        category: '财务管理',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
      ),
      
      // 四大名著知识库
      KnowledgeEntry(
        id: 'classics_hongloumeng',
        title: '红楼梦人物志',
        content: '《红楼梦》是中国古典文学四大名著之一，描绘了贾、史、王、薛四大家族的兴衰史。主要人物包括贾宝玉、林黛玉、薛宝钗、王熙凤等，每个人物都有鲜明的性格特征和深刻的文化内涵。',
        tags: ['红楼梦', '古典文学', '人物', '四大名著'],
        createdAt: DateTime.now(),
        category: '文学艺术',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
        documents: [
          KnowledgeDocument(
            id: 'doc_wangxifeng',
            title: '王熙凤人物档案',
            content: '王熙凤，贾琏之妻，王夫人的内侄女。她精明强干，深得贾母欢心，在贾府中有很高的地位和权力。她善于理财，管理能力出众，但同时也心机深沉，手段毒辣。外表美丽动人，内心却工于心计，是《红楼梦》中最具争议性的人物之一。\n\n性格特征：\n- 精明能干，善于管理\n- 口才出众，能言善辩\n- 心机深沉，手段毒辣\n- 贪财好利，权欲熏心\n- 外表美丽，内心复杂\n\n经典语录：\n"我从来不信什么阴司地狱，凭什么事，我说行就行！"\n"大有大的难处，小有小的难处。"\n\n人物关系：\n- 丈夫：贾琏\n- 女儿：巧姐\n- 婆婆：邢夫人\n- 姑母：王夫人',
            isUnlocked: true,
          ),
        ],
      ),
      KnowledgeEntry(
        id: 'classics_xiyouji',
        title: '西游记人物志',
        content: '《西游记》讲述了唐僧师徒四人西天取经的故事。孙悟空机智勇敢，猪八戒憨厚可爱，沙僧忠诚老实，唐僧慈悲为怀。每个角色都有独特的性格魅力。',
        tags: ['西游记', '古典文学', '神话', '四大名著'],
        createdAt: DateTime.now(),
        category: '文学艺术',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
      ),
      KnowledgeEntry(
        id: 'classics_shuihuzhuan',
        title: '水浒传人物志',
        content: '《水浒传》描写了108位梁山好汉的英雄事迹。宋江仁义为先，武松勇猛无敌，林冲逼上梁山，鲁智深嫉恶如仇。每位好汉都有自己的传奇故事。',
        tags: ['水浒传', '古典文学', '英雄', '四大名著'],
        createdAt: DateTime.now(),
        category: '文学艺术',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
      ),
      KnowledgeEntry(
        id: 'classics_sanguo',
        title: '三国演义人物志',
        content: '《三国演义》展现了三国时期的历史风云。刘备仁德爱民，关羽忠义无双，张飞勇猛粗犷，诸葛亮智谋超群，曹操雄才大略，孙权英明果断。',
        tags: ['三国演义', '古典文学', '历史', '四大名著'],
        createdAt: DateTime.now(),
        category: '文学艺术',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
      ),
      
      // 公开知识库 - 情商类
      KnowledgeEntry(
        id: 'public_eq_qa',
        title: '1000句高情商问答',
        content: '收录了1000句高情商的对话技巧和回应方式，帮助提升沟通能力和人际关系处理技巧。包含各种场景下的智慧回应和情商表达方式。',
        tags: ['情商', '沟通技巧', '人际关系', '对话艺术'],
        createdAt: DateTime.now(),
        category: '情商类',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
        documents: [
          KnowledgeDocument(
            id: 'doc_eq_qa_1',
            title: '1000句高情商问答.pdf',
            content: '高情商对话示例：\n1. 当别人批评你时："谢谢你的提醒，我会认真考虑的。"\n2. 当别人夸奖你时："谢谢你的认可，这也离不开大家的支持。"\n3. 当遇到分歧时："我理解你的观点，我们可以从不同角度来看这个问题。"\n4. 当需要拒绝时："我很想帮你，但目前的情况可能不太合适。"\n5. 当安慰他人时："我能理解你现在的感受，需要我陪你聊聊吗？"',
            isUnlocked: true,
          ),
        ],
      ),
      KnowledgeEntry(
        id: 'public_psychology_basic',
        title: '心理学基础知识',
        content: '涵盖基础心理学概念、情绪管理、认知偏差、行为心理学等内容，帮助理解人类心理活动规律。',
        tags: ['心理学', '情绪管理', '认知', '行为'],
        createdAt: DateTime.now(),
        category: '心理学类',
        type: KnowledgeType.free,
        unlockCost: 0,
        isUnlocked: true,
        documents: [
          KnowledgeDocument(
            id: 'doc_psychology_basic',
            title: '心理学基础.pdf',
            content: '心理学基础概念：\n1. 情绪调节：识别、理解和管理情绪的能力\n2. 认知偏差：思维中的系统性错误\n3. 行为强化：通过奖励或惩罚改变行为\n4. 社会认知：理解他人想法和感受的能力\n5. 压力管理：应对生活压力的策略和技巧',
            isUnlocked: true,
          ),
        ],
      ),
      
      // 付费知识库 - 高级沟通技巧
      KnowledgeEntry(
        id: 'premium_communication_advanced',
        title: '高级沟通与谈判技巧',
        content: '深度解析高级沟通策略、谈判心理学、说服技巧、冲突化解等专业内容，适合职场精英和管理者。',
        tags: ['沟通', '谈判', '说服', '管理'],
        createdAt: DateTime.now(),
        category: '沟通技巧类',
        type: KnowledgeType.premium,
        unlockCost: 999,
        isUnlocked: false,
        documents: [
          KnowledgeDocument(
            id: 'doc_communication_advanced',
            title: '高级沟通技巧手册.pdf',
            content: '高级沟通策略：\n1. 镜像技巧：模仿对方的语调和肢体语言建立信任\n2. 框架重构：改变问题的表述方式影响对方认知\n3. 情感锚定：在关键时刻建立情感连接\n4. 认知负荷管理：控制信息量避免对方决策疲劳\n5. 双赢思维：寻找互利共赢的解决方案',
            isUnlocked: false,
          ),
          KnowledgeDocument(
            id: 'doc_negotiation_psychology',
            title: '谈判心理学.pdf',
            content: '谈判心理要点：\n1. 锚定效应：首次报价对最终结果的影响\n2. 损失厌恶：人们更害怕失去而非获得\n3. 互惠原理：给予对方小恩惠获得更大回报\n4. 稀缺性原理：限量和时限增加吸引力\n5. 社会认同：利用他人行为影响决策',
            isUnlocked: false,
          ),
        ],
      ),
      KnowledgeEntry(
        id: 'premium_emotional_intelligence',
        title: '情商修炼与人际关系',
        content: '系统性情商提升方法、深度人际关系分析、社交心理学应用等高价值内容。',
        tags: ['情商', '人际关系', '社交心理', '个人成长'],
        createdAt: DateTime.now(),
        category: '情商类',
        type: KnowledgeType.premium,
        unlockCost: 1299,
        isUnlocked: false,
        documents: [
          KnowledgeDocument(
            id: 'doc_eq_mastery',
            title: '情商修炼大全.pdf',
            content: '情商修炼体系：\n1. 自我觉察：识别自己的情绪模式和触发点\n2. 自我管理：控制冲动，保持情绪稳定\n3. 社会觉察：敏锐察觉他人的情绪变化\n4. 关系管理：建立和维护良好的人际关系\n5. 影响力：通过情商影响和激励他人',
            isUnlocked: false,
          ),
        ],
      ),
      
      // 高阶知识库 - 心理学专业内容
      KnowledgeEntry(
        id: 'advanced_psychology_therapy',
        title: '心理治疗与咨询技术',
        content: '专业级心理治疗方法、咨询技术、心理评估工具等，需要会员权限访问的高端内容。',
        tags: ['心理治疗', '咨询技术', '心理评估', '专业技能'],
        createdAt: DateTime.now(),
        category: '心理学类',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
        documents: [
          KnowledgeDocument(
            id: 'doc_therapy_techniques',
            title: '心理治疗技术大全.pdf',
            content: '专业治疗技术：\n1. 认知行为疗法(CBT)：改变负面思维模式\n2. 正念疗法：培养当下意识和接纳态度\n3. 家庭系统治疗：从系统角度解决问题\n4. 精神分析：探索潜意识动机和冲突\n5. 人本主义疗法：激发个人成长潜能',
            isUnlocked: false,
          ),
          KnowledgeDocument(
            id: 'doc_psychological_assessment',
            title: '心理评估工具手册.pdf',
            content: '评估工具应用：\n1. MMPI-2：多相人格测验\n2. 16PF：卡特尔16种人格因素\n3. SCL-90：症状自评量表\n4. SAS/SDS：焦虑/抑郁自评量表\n5. 投射测验：罗夏墨迹测验等',
            isUnlocked: false,
          ),
        ],
      ),
      KnowledgeEntry(
        id: 'advanced_leadership_psychology',
        title: '领导力心理学',
        content: '高级领导力理论、组织心理学、团队动力学等企业管理核心内容，仅限VIP会员访问。',
        tags: ['领导力', '组织心理学', '团队管理', '企业文化'],
        createdAt: DateTime.now(),
        category: '管理学类',
        type: KnowledgeType.advanced,
        unlockCost: 0,
        isUnlocked: false,
        documents: [
          KnowledgeDocument(
            id: 'doc_leadership_psychology',
            title: '领导力心理学精要.pdf',
            content: '领导力核心要素：\n1. 变革型领导：激发下属超越期望的表现\n2. 情境领导：根据情况调整领导风格\n3. 魅力型领导：通过个人魅力影响他人\n4. 服务型领导：以服务他人为核心理念\n5. 分布式领导：在组织中分享领导责任',
            isUnlocked: false,
          ),
        ],
      ),
    ];
    
    _publicKnowledgeBase.addAll(defaultPublicEntries);
    await _savePublicKnowledgeBase();
  }
  
  /// 搜索相关知识
  List<KnowledgeEntry> searchKnowledge(String query, {bool includePublic = true}) {
    final results = <KnowledgeEntry>[];
    final queryLower = query.toLowerCase();
    
    // 搜索私有知识库
    for (final entry in _knowledgeBase) {
      final score = _calculateRelevanceScore(entry, queryLower);
      if (score > 0.1) {
        results.add(entry.copyWith(relevanceScore: score));
      }
    }
    
    // 搜索公开知识库
    if (includePublic) {
      for (final entry in _publicKnowledgeBase) {
        final score = _calculateRelevanceScore(entry, queryLower);
        if (score > 0.1) {
          results.add(entry.copyWith(relevanceScore: score));
        }
      }
    }
    
    // 按相关性排序
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return results.take(5).toList(); // 返回前5个最相关的结果
  }
  
  /// 在特定知识库中搜索
  List<KnowledgeEntry> searchKnowledgeInBase(String query, String knowledgeBaseId) {
    final results = <KnowledgeEntry>[];
    final queryLower = query.toLowerCase();
    
    // 根据知识库ID确定搜索范围
    List<KnowledgeEntry> targetEntries = [];
    
    // 映射知识库ID到类别或特定条目
    switch (knowledgeBaseId) {
      case 'general_knowledge':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '通用知识' || e.category == '生活技能').toList();
        break;
      case 'literature_classics':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '文学艺术' || e.category == '文化历史').toList();
        break;
      case 'science_tech':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '科学技术' || e.category == '学习方法').toList();
        break;
      case 'psychology_philosophy':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '心理健康' || e.category == '个人发展').toList();
        break;
      case 'entertainment_pop':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '娱乐休闲' || e.category == '流行文化').toList();
        break;
      case 'history_culture':
        targetEntries = _publicKnowledgeBase.where((e) => e.category == '文化历史' || e.category == '传统文化').toList();
        break;
      default:
        // 如果没有匹配的知识库ID，搜索所有公开知识库
        targetEntries = _publicKnowledgeBase;
        break;
    }
    
    // 在目标条目中搜索
    for (final entry in targetEntries) {
      final score = _calculateRelevanceScore(entry, queryLower);
      if (score > 0.1) {
        results.add(entry.copyWith(relevanceScore: score));
      }
    }
    
    // 按相关性排序
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    
    return results.take(3).toList(); // 返回前3个最相关的结果
  }
  
  /// 计算相关性分数
  double _calculateRelevanceScore(KnowledgeEntry entry, String query) {
    double score = 0.0;
    
    // 标题匹配（权重最高）
    if (entry.title.toLowerCase().contains(query)) {
      score += 1.0;
    }
    
    // 内容匹配
    if (entry.content.toLowerCase().contains(query)) {
      score += 0.7;
    }
    
    // 标签匹配
    for (final tag in entry.tags) {
      if (tag.toLowerCase().contains(query)) {
        score += 0.5;
      }
    }
    
    // 关键词匹配
    final keywords = query.split(' ');
    for (final keyword in keywords) {
      if (keyword.isNotEmpty) {
        if (entry.title.toLowerCase().contains(keyword)) score += 0.3;
        if (entry.content.toLowerCase().contains(keyword)) score += 0.2;
        for (final tag in entry.tags) {
          if (tag.toLowerCase().contains(keyword)) score += 0.1;
        }
      }
    }
    
    return score;
  }
  
  /// 添加知识条目
  Future<void> addKnowledgeEntry(KnowledgeEntry entry, {bool isPublic = false}) async {
    if (isPublic) {
      _publicKnowledgeBase.add(entry);
      await _savePublicKnowledgeBase();
    } else {
      _knowledgeBase.add(entry);
      await _saveKnowledgeBase();
    }
  }
  
  /// 删除知识条目
  Future<void> removeKnowledgeEntry(String id, {bool isPublic = false}) async {
    if (isPublic) {
      _publicKnowledgeBase.removeWhere((entry) => entry.id == id);
      await _savePublicKnowledgeBase();
    } else {
      _knowledgeBase.removeWhere((entry) => entry.id == id);
      await _saveKnowledgeBase();
    }
  }
  
  /// 获取所有知识条目
  List<KnowledgeEntry> getAllKnowledge({bool includePublic = true}) {
    final results = <KnowledgeEntry>[..._knowledgeBase];
    if (includePublic) {
      results.addAll(_publicKnowledgeBase);
    }
    return results;
  }
  
  /// 获取知识库统计信息
  Map<String, int> getStatistics() {
    return {
      'private_count': _knowledgeBase.length,
      'public_count': _publicKnowledgeBase.length,
      'total_count': _knowledgeBase.length + _publicKnowledgeBase.length,
    };
  }
  
  /// 根据知识库类型获取知识条目
  List<KnowledgeEntry> getKnowledgeByType(KnowledgeType type) {
    return _publicKnowledgeBase.where((entry) => entry.type == type).toList();
  }
  
  /// 获取公开知识库
  List<KnowledgeEntry> getPublicKnowledge() {
    return getKnowledgeByType(KnowledgeType.free);
  }
  
  /// 获取付费知识库
  List<KnowledgeEntry> getPremiumKnowledge() {
    return getKnowledgeByType(KnowledgeType.premium);
  }
  
  /// 获取高阶知识库
  List<KnowledgeEntry> getAdvancedKnowledge() {
    return getKnowledgeByType(KnowledgeType.advanced);
  }
  
  /// 根据知识库类型和分类获取知识条目
  List<KnowledgeEntry> getKnowledgeByTypeAndCategory(KnowledgeType type, String category) {
    return _publicKnowledgeBase
        .where((entry) => entry.type == type && entry.category == category)
        .toList();
  }
  
  /// 获取知识库类型的显示名称
  String getKnowledgeTypeDisplayName(KnowledgeType type) {
    switch (type) {
      case KnowledgeType.free:
        return '公开知识库';
      case KnowledgeType.premium:
        return '付费知识库';
      case KnowledgeType.advanced:
        return '高阶知识库';
    }
  }
  
  /// 获取所有知识库类型
  List<KnowledgeType> getAllKnowledgeTypes() {
    return [KnowledgeType.free, KnowledgeType.premium, KnowledgeType.advanced];
  }
  
  /// 获取指定类型知识库的所有分类
  List<String> getCategoriesByType(KnowledgeType type) {
    final categories = <String>{};
    for (final entry in _publicKnowledgeBase) {
      if (entry.type == type) {
        categories.add(entry.category);
      }
    }
    return categories.toList();
  }
  
  /// 按类别获取知识
  List<KnowledgeEntry> getKnowledgeByCategory(String category, {bool includePublic = true}) {
    final results = <KnowledgeEntry>[];
    
    results.addAll(_knowledgeBase.where((entry) => entry.category == category));
    
    if (includePublic) {
      results.addAll(_publicKnowledgeBase.where((entry) => entry.category == category));
    }
    
    return results;
  }
  
  /// 获取所有类别
  List<String> getAllCategories({bool includePublic = true}) {
    final categories = <String>{};
    
    for (final entry in _knowledgeBase) {
      categories.add(entry.category);
    }
    
    if (includePublic) {
      for (final entry in _publicKnowledgeBase) {
        categories.add(entry.category);
      }
    }
    
    return categories.toList()..sort();
  }
  
  /// 解锁知识库文档
  Future<bool> unlockKnowledgeDocument(String entryId, String documentId, bool isPublic, int userCoins, bool isMember) async {
    List<KnowledgeEntry> targetList = isPublic ? _publicKnowledgeBase : _knowledgeBase;
    
    final entryIndex = targetList.indexWhere((entry) => entry.id == entryId);
    if (entryIndex == -1) return false;
    
    final entry = targetList[entryIndex];
    final docIndex = entry.documents.indexWhere((doc) => doc.id == documentId);
    if (docIndex == -1) return false;
    
    // 检查解锁条件
    switch (entry.type) {
      case KnowledgeType.free:
        // 免费知识库，直接解锁
        break;
      case KnowledgeType.premium:
        // 付费知识库，检查金币
        if (userCoins < entry.unlockCost) {
          return false;
        }
        break;
      case KnowledgeType.advanced:
        // 高阶知识库，需要会员
        if (!isMember) {
          return false;
        }
        break;
    }
    
    // 解锁文档
    final updatedDocuments = List<KnowledgeDocument>.from(entry.documents);
    updatedDocuments[docIndex] = updatedDocuments[docIndex].copyWith(isUnlocked: true);
    
    final updatedEntry = entry.copyWith(documents: updatedDocuments);
    targetList[entryIndex] = updatedEntry;
    
    // 保存到本地存储
    if (isPublic) {
      await _savePublicKnowledgeBase();
    } else {
      await _saveKnowledgeBase();
    }
    
    return true;
  }
  
  /// 解锁知识库条目（包括所有文档）
  Future<bool> unlockKnowledgeEntry(String entryId, bool isPublic, int userCoins, bool isMember) async {
    List<KnowledgeEntry> targetList = isPublic ? _publicKnowledgeBase : _knowledgeBase;
    
    final entryIndex = targetList.indexWhere((entry) => entry.id == entryId);
    if (entryIndex == -1) return false;
    
    final entry = targetList[entryIndex];
    
    // 检查解锁条件
    switch (entry.type) {
      case KnowledgeType.free:
        // 免费知识库，直接解锁
        break;
      case KnowledgeType.premium:
        // 付费知识库，检查金币
        if (userCoins < entry.unlockCost) {
          return false;
        }
        break;
      case KnowledgeType.advanced:
        // 高阶知识库，需要会员
        if (!isMember) {
          return false;
        }
        break;
    }
    
    // 解锁知识库
    final unlockedEntry = entry.copyWith(isUnlocked: true);
    targetList[entryIndex] = unlockedEntry;
    
    // 保存到本地存储
    if (isPublic) {
      await _savePublicKnowledgeBase();
    } else {
      await _saveKnowledgeBase();
    }
    
    return true;
  }
  
  /// 检查用户是否可以访问知识库
  bool canAccessKnowledge(KnowledgeEntry entry, bool isMember) {
    if (entry.isUnlocked) return true;
    
    switch (entry.type) {
      case KnowledgeType.free:
        return true;
      case KnowledgeType.premium:
        return false; // 需要付费解锁
      case KnowledgeType.advanced:
        return isMember; // 需要会员
    }
  }
  
  /// 获取用户可访问的知识库列表
  List<KnowledgeEntry> getAccessibleKnowledge(bool isMember, {bool includePublic = true}) {
    final results = <KnowledgeEntry>[];
    
    // 私有知识库
    for (final entry in _knowledgeBase) {
      if (canAccessKnowledge(entry, isMember)) {
        results.add(entry);
      }
    }
    
    // 公开知识库
    if (includePublic) {
      for (final entry in _publicKnowledgeBase) {
        if (canAccessKnowledge(entry, isMember)) {
          results.add(entry);
        }
      }
    }
    
    return results;
  }
  
  /// 获取需要解锁的知识库数量
  Map<String, int> getUnlockStatistics(bool isMember) {
    int lockedPremium = 0;
    int lockedAdvanced = 0;
    
    final allKnowledge = getAllKnowledge();
    
    for (final entry in allKnowledge) {
      if (!entry.isUnlocked) {
        switch (entry.type) {
          case KnowledgeType.premium:
            lockedPremium++;
            break;
          case KnowledgeType.advanced:
            if (!isMember) lockedAdvanced++;
            break;
          case KnowledgeType.free:
            break;
        }
      }
    }
    
    return {
      'locked_premium': lockedPremium,
      'locked_advanced': lockedAdvanced,
    };
  }
}