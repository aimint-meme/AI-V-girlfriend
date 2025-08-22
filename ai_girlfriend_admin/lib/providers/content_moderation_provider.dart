import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/content_moderation_model.dart';

class ContentModerationProvider extends ChangeNotifier {
  List<SensitiveKeyword> _keywords = [];
  List<SensitiveKeyword> _filteredKeywords = [];
  List<ViolationRecord> _violations = [];
  List<ViolationRecord> _filteredViolations = [];
  List<DetectionRule> _detectionRules = [];
  ContentModerationStats? _stats;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SensitiveKeyword> get keywords => _keywords;
  List<SensitiveKeyword> get filteredKeywords => _filteredKeywords;
  List<ViolationRecord> get violations => _violations;
  List<ViolationRecord> get filteredViolations => _filteredViolations;
  List<DetectionRule> get detectionRules => _detectionRules;
  ContentModerationStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 统计数据快捷访问
  int get totalKeywords => _stats?.totalKeywords ?? 0;
  int get activeKeywords => _stats?.activeKeywords ?? 0;
  int get totalDetections => _stats?.totalDetections ?? 0;
  int get todayDetections => _stats?.todayDetections ?? 0;
  int get totalViolations => _stats?.totalViolations ?? 0;
  int get todayViolations => _stats?.todayViolations ?? 0;
  double get blockRate => _stats?.blockRate ?? 0.0;
  double get falsePositiveRate => _stats?.falsePositiveRate ?? 0.0;
  int get avgResponseTime => _stats?.avgResponseTime ?? 0;
  Map<String, int> get categoryDistribution => _stats?.categoryDistribution ?? {};
  List<SensitiveKeyword> get topKeywords => _stats?.topKeywords ?? [];
  List<ActivityRecord> get recentActivities => _stats?.recentActivities ?? [];

  // 加载数据
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _keywords = _generateMockKeywords();
      _filteredKeywords = List.from(_keywords);
      _violations = _generateMockViolations();
      _filteredViolations = List.from(_violations);
      _detectionRules = _generateMockDetectionRules();
      _stats = _generateMockStats();
      
    } catch (e) {
      _error = '加载数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 应用敏感词筛选条件
  void applyKeywordFilters({
    String? searchQuery,
    String? category,
    String? severity,
  }) {
    _filteredKeywords = _keywords.where((keyword) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!keyword.word.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 分类筛选
      if (category != null && keyword.category != category) {
        return false;
      }

      // 严重程度筛选
      if (severity != null && keyword.severity != severity) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 应用违规记录筛选条件
  void applyViolationFilters({
    String? searchQuery,
    String? status,
  }) {
    _filteredViolations = _violations.where((violation) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!violation.userId.toLowerCase().contains(query) &&
            !violation.content.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态筛选
      if (status != null && violation.status != status) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 添加敏感词
  Future<bool> addKeyword(SensitiveKeyword keyword) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _keywords.add(keyword);
      applyKeywordFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '添加敏感词失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新敏感词
  Future<bool> updateKeyword(SensitiveKeyword keyword) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _keywords.indexWhere((k) => k.id == keyword.id);
      if (index != -1) {
        _keywords[index] = keyword;
        applyKeywordFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '更新敏感词失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除敏感词
  Future<bool> deleteKeyword(String keywordId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _keywords.removeWhere((keyword) => keyword.id == keywordId);
      applyKeywordFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '删除敏感词失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换敏感词状态
  Future<bool> toggleKeywordStatus(String keywordId) async {
    try {
      final keywordIndex = _keywords.indexWhere((k) => k.id == keywordId);
      if (keywordIndex == -1) return false;
      
      final keyword = _keywords[keywordIndex];
      _keywords[keywordIndex] = keyword.copyWith(
        isActive: !keyword.isActive,
        updatedAt: DateTime.now(),
      );
      
      applyKeywordFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '切换敏感词状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 批量导入敏感词
  Future<bool> importKeywords(List<SensitiveKeyword> keywords) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      _keywords.addAll(keywords);
      applyKeywordFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '批量导入敏感词失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 处理违规记录
  Future<bool> handleViolation(String violationId, String newStatus, {String? action, String? handledBy}) async {
    try {
      final violationIndex = _violations.indexWhere((v) => v.id == violationId);
      if (violationIndex == -1) return false;
      
      final violation = _violations[violationIndex];
      _violations[violationIndex] = violation.copyWith(
        status: newStatus,
        action: action ?? violation.action,
        handledBy: handledBy ?? 'admin',
        handledAt: DateTime.now(),
      );
      
      applyViolationFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '处理违规记录失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 批量处理违规记录
  Future<bool> batchHandleViolations(List<String> violationIds, String newStatus, {String? action}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      for (final violationId in violationIds) {
        final violationIndex = _violations.indexWhere((v) => v.id == violationId);
        if (violationIndex != -1) {
          final violation = _violations[violationIndex];
          _violations[violationIndex] = violation.copyWith(
            status: newStatus,
            action: action ?? violation.action,
            handledBy: 'admin',
            handledAt: DateTime.now(),
          );
        }
      }
      
      applyViolationFilters(); // 重新应用筛选
      
      return true;
    } catch (e) {
      _error = '批量处理违规记录失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 添加检测规则
  Future<bool> addDetectionRule(DetectionRule rule) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _detectionRules.add(rule);
      
      return true;
    } catch (e) {
      _error = '添加检测规则失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新检测规则
  Future<bool> updateDetectionRule(DetectionRule rule) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _detectionRules.indexWhere((r) => r.id == rule.id);
      if (index != -1) {
        _detectionRules[index] = rule;
      }
      
      return true;
    } catch (e) {
      _error = '更新检测规则失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 删除检测规则
  Future<bool> deleteDetectionRule(String ruleId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _detectionRules.removeWhere((rule) => rule.id == ruleId);
      
      return true;
    } catch (e) {
      _error = '删除检测规则失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换检测规则状态
  Future<bool> toggleRuleStatus(String ruleId) async {
    try {
      final ruleIndex = _detectionRules.indexWhere((r) => r.id == ruleId);
      if (ruleIndex == -1) return false;
      
      final rule = _detectionRules[ruleIndex];
      _detectionRules[ruleIndex] = rule.copyWith(
        isEnabled: !rule.isEnabled,
        updatedAt: DateTime.now(),
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = '切换检测规则状态失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 测试检测规则
  Future<Map<String, dynamic>> testDetectionRule(String ruleId, String testContent) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final rule = _detectionRules.firstWhere((r) => r.id == ruleId);
      
      // 模拟检测结果
      final random = Random();
      final isMatch = random.nextBool();
      final confidence = random.nextDouble();
      
      return {
        'isMatch': isMatch,
        'confidence': confidence,
        'matchedKeywords': isMatch ? ['测试词'] : [],
        'riskScore': isMatch ? (confidence * 100).round() : 0,
        'processingTime': random.nextInt(500) + 50, // 50-550ms
      };
    } catch (e) {
      _error = '测试检测规则失败: $e';
      debugPrint(_error);
      return {};
    }
  }

  // 获取敏感词详情
  SensitiveKeyword? getKeywordById(String keywordId) {
    try {
      return _keywords.firstWhere((keyword) => keyword.id == keywordId);
    } catch (e) {
      return null;
    }
  }

  // 获取违规记录详情
  ViolationRecord? getViolationById(String violationId) {
    try {
      return _violations.firstWhere((violation) => violation.id == violationId);
    } catch (e) {
      return null;
    }
  }

  // 获取检测规则详情
  DetectionRule? getDetectionRuleById(String ruleId) {
    try {
      return _detectionRules.firstWhere((rule) => rule.id == ruleId);
    } catch (e) {
      return null;
    }
  }

  // 导出敏感词
  Future<List<Map<String, dynamic>>> exportKeywords() async {
    try {
      return _keywords.map((keyword) => keyword.toJson()).toList();
    } catch (e) {
      _error = '导出敏感词失败: $e';
      debugPrint(_error);
      return [];
    }
  }

  // 导出违规记录
  Future<List<Map<String, dynamic>>> exportViolations() async {
    try {
      return _violations.map((violation) => violation.toJson()).toList();
    } catch (e) {
      _error = '导出违规记录失败: $e';
      debugPrint(_error);
      return [];
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟敏感词数据
  List<SensitiveKeyword> _generateMockKeywords() {
    final keywords = <SensitiveKeyword>[];
    final words = [
      '政治敏感词1', '政治敏感词2', '色情词汇1', '色情词汇2', '暴力词汇1', 
      '暴力词汇2', '违法词汇1', '违法词汇2', '其他敏感词1', '其他敏感词2',
      '赌博相关', '毒品相关', '诈骗相关', '恐怖主义', '分裂主义',
    ];
    final categories = ['政治敏感', '色情低俗', '暴力血腥', '违法犯罪', '其他'];
    final severities = ['高', '中', '低'];
    
    for (int i = 0; i < words.length; i++) {
      final createdAt = DateTime.now().subtract(Duration(days: i * 2));
      
      keywords.add(SensitiveKeyword(
        id: 'keyword_${(i + 1).toString().padLeft(3, '0')}',
        word: words[i],
        category: categories[i % categories.length],
        severity: severities[i % severities.length],
        isActive: i % 4 != 0, // 75%启用
        detectionCount: (i + 1) * 25 + Random().nextInt(100),
        aliases: i % 3 == 0 ? ['${words[i]}_变体1', '${words[i]}_变体2'] : [],
        regex: i % 5 == 0 ? '.*${words[i]}.*' : '',
        createdAt: createdAt,
        updatedAt: createdAt.add(Duration(days: i)),
        createdBy: 'admin',
      ));
    }
    
    return keywords;
  }

  // 生成模拟违规记录数据
  List<ViolationRecord> _generateMockViolations() {
    final violations = <ViolationRecord>[];
    final contents = [
      '这是一条包含敏感词的消息内容',
      '用户发布了不当言论',
      '涉及政治敏感话题的讨论',
      '包含色情低俗内容的文本',
      '暴力血腥内容描述',
      '违法犯罪相关信息',
      '其他违规内容示例',
    ];
    final categories = ['政治敏感', '色情低俗', '暴力血腥', '违法犯罪', '其他'];
    final severities = ['高', '中', '低'];
    final statuses = ['待处理', '已处理', '已忽略'];
    
    for (int i = 0; i < 20; i++) {
      final detectedAt = DateTime.now().subtract(Duration(hours: i * 2));
      final isHandled = i % 3 != 0;
      
      violations.add(ViolationRecord(
        id: 'violation_${(i + 1).toString().padLeft(3, '0')}',
        userId: 'user_${(i % 10 + 1).toString().padLeft(3, '0')}',
        content: contents[i % contents.length],
        contentType: 'text',
        matchedKeywords: ['敏感词${i + 1}', '违规词${i + 1}'],
        category: categories[i % categories.length],
        severity: severities[i % severities.length],
        riskScore: 30 + Random().nextInt(70), // 30-100
        status: statuses[i % statuses.length],
        action: isHandled ? ['警告', '禁言', '删除内容'][i % 3] : '',
        handledBy: isHandled ? 'admin' : '',
        detectedAt: detectedAt,
        handledAt: isHandled ? detectedAt.add(Duration(minutes: 30 + i * 10)) : null,
      ));
    }
    
    return violations;
  }

  // 生成模拟检测规则数据
  List<DetectionRule> _generateMockDetectionRules() {
    return [
      DetectionRule(
        id: 'rule_001',
        name: '关键词匹配规则',
        description: '基于敏感词库的关键词匹配检测',
        type: 'keyword',
        isEnabled: true,
        priority: 10,
        threshold: 0.8,
        action: 'block',
        conditions: {
          'matchType': 'exact',
          'caseSensitive': false,
        },
        config: {
          'keywordList': 'default',
          'ignoreWhitespace': true,
        },
        matchCount: 1250,
        accuracy: 0.92,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        createdBy: 'admin',
      ),
      DetectionRule(
        id: 'rule_002',
        name: '正则表达式规则',
        description: '使用正则表达式进行模式匹配检测',
        type: 'regex',
        isEnabled: true,
        priority: 8,
        threshold: 0.7,
        action: 'warn',
        conditions: {
          'pattern': r'\b(敏感|违规)\w*\b',
          'flags': 'i',
        },
        config: {
          'timeout': 1000,
          'maxMatches': 10,
        },
        matchCount: 890,
        accuracy: 0.85,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        createdBy: 'admin',
      ),
      DetectionRule(
        id: 'rule_003',
        name: 'AI智能检测规则',
        description: '基于机器学习的智能内容检测',
        type: 'ai',
        isEnabled: false,
        priority: 15,
        threshold: 0.9,
        action: 'review',
        conditions: {
          'model': 'bert-base',
          'confidence': 0.85,
        },
        config: {
          'batchSize': 32,
          'maxLength': 512,
        },
        matchCount: 456,
        accuracy: 0.94,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
        createdBy: 'admin',
      ),
      DetectionRule(
        id: 'rule_004',
        name: '频率限制规则',
        description: '检测用户发布频率异常行为',
        type: 'custom',
        isEnabled: true,
        priority: 5,
        threshold: 0.6,
        action: 'log',
        conditions: {
          'timeWindow': 300, // 5分钟
          'maxMessages': 10,
        },
        config: {
          'cooldown': 600, // 10分钟冷却
          'escalation': true,
        },
        matchCount: 234,
        accuracy: 0.78,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        createdBy: 'admin',
      ),
    ];
  }

  // 生成模拟统计数据
  ContentModerationStats _generateMockStats() {
    final random = Random();
    
    return ContentModerationStats(
      totalKeywords: _keywords.length,
      activeKeywords: _keywords.where((k) => k.isActive).length,
      totalDetections: 15420,
      todayDetections: 234,
      totalViolations: 1890,
      todayViolations: 28,
      blockRate: 78.5,
      falsePositiveRate: 8.2,
      avgResponseTime: 150,
      categoryDistribution: {
        '政治敏感': _violations.where((v) => v.category == '政治敏感').length,
        '色情低俗': _violations.where((v) => v.category == '色情低俗').length,
        '暴力血腥': _violations.where((v) => v.category == '暴力血腥').length,
        '违法犯罪': _violations.where((v) => v.category == '违法犯罪').length,
        '其他': _violations.where((v) => v.category == '其他').length,
      },
      severityDistribution: {
        '高': _violations.where((v) => v.severity == '高').length,
        '中': _violations.where((v) => v.severity == '中').length,
        '低': _violations.where((v) => v.severity == '低').length,
      },
      topKeywords: _keywords.where((k) => k.isPopular).take(10).toList(),
      recentActivities: _generateRecentActivities(),
    );
  }

  // 生成最近活动记录
  List<ActivityRecord> _generateRecentActivities() {
    final activities = <ActivityRecord>[];
    final actions = [
      '添加敏感词',
      '处理违规记录',
      '更新检测规则',
      '批量导入敏感词',
      '启用检测规则',
      '禁用敏感词',
      '导出违规记录',
    ];
    
    for (int i = 0; i < 10; i++) {
      activities.add(ActivityRecord(
        id: 'activity_${i + 1}',
        action: actions[i % actions.length],
        target: '目标对象_${i + 1}',
        operator: 'admin',
        timestamp: DateTime.now().subtract(Duration(minutes: i * 15)),
      ));
    }
    
    return activities;
  }
}