import 'dart:math';
import 'knowledge_base_service.dart';

/// RAG（检索增强生成）服务
class RAGService {
  final KnowledgeBaseService _knowledgeBaseService;
  
  RAGService(this._knowledgeBaseService);
  
  /// 使用RAG增强AI回复
  Future<Map<String, dynamic>> enhanceResponse(
    String userMessage,
    String personality,
    String girlfriendId, {
    String? knowledgeBaseId,
  }) async {
    try {
      // 1. 检索相关知识（支持特定知识库）
      final relevantKnowledge = knowledgeBaseId != null 
          ? _knowledgeBaseService.searchKnowledgeInBase(userMessage, knowledgeBaseId)
          : _knowledgeBaseService.searchKnowledge(userMessage);
      
      // 2. 分析用户意图
      final intent = _analyzeUserIntent(userMessage);
      
      // 3. 生成增强回复
      final enhancedResponse = await _generateEnhancedResponse(
        userMessage,
        personality,
        relevantKnowledge,
        intent,
      );
      
      // 4. 计算好感度变化
      final intimacyChange = _calculateIntimacyChange(userMessage, intent, relevantKnowledge);
      
      // 5. 生成推荐内容
      final recommendations = _generateRecommendations(userMessage, intent, relevantKnowledge);
      
      return {
        'response': enhancedResponse,
        'intimacyChange': intimacyChange,
        'recommendations': recommendations,
        'usedKnowledge': relevantKnowledge.map((k) => k.title).toList(),
        'confidence': _calculateConfidence(relevantKnowledge),
      };
    } catch (e) {
      print('RAG服务错误: $e');
      // 降级到基础回复
      return _generateBasicResponse(userMessage, personality);
    }
  }
  
  /// 分析用户意图
  UserIntent _analyzeUserIntent(String message) {
    final messageLower = message.toLowerCase();
    
    // 问候意图
    if (_containsAny(messageLower, ['你好', '嗨', 'hi', 'hello', '早上好', '晚上好'])) {
      return UserIntent.greeting;
    }
    
    // 情感表达
    if (_containsAny(messageLower, ['爱', '喜欢', '想你', '思念'])) {
      return UserIntent.affection;
    }
    
    // 寻求安慰
    if (_containsAny(messageLower, ['难过', '伤心', '不开心', '沮丧', '失落', '痛苦'])) {
      return UserIntent.seekComfort;
    }
    
    // 分享日常
    if (_containsAny(messageLower, ['今天', '刚才', '刚刚', '发生', '遇到'])) {
      return UserIntent.shareDaily;
    }
    
    // 寻求建议
    if (_containsAny(messageLower, ['怎么办', '建议', '意见', '帮助', '不知道'])) {
      return UserIntent.seekAdvice;
    }
    
    // 询问信息
    if (_containsAny(messageLower, ['什么', '怎么', '为什么', '哪里', '谁', '?', '？'])) {
      return UserIntent.askQuestion;
    }
    
    // 闲聊
    return UserIntent.casualChat;
  }
  
  /// 检查消息是否包含任何关键词
  bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }
  
  /// 生成增强回复
  Future<String> _generateEnhancedResponse(
    String userMessage,
    String personality,
    List<KnowledgeEntry> relevantKnowledge,
    UserIntent intent,
  ) async {
    // 基础回复模板
    String baseResponse = _getBaseResponseByPersonality(personality, intent, userMessage);
    
    // 如果有相关知识，增强回复
    if (relevantKnowledge.isNotEmpty) {
      final knowledgeContext = _buildKnowledgeContext(relevantKnowledge);
      baseResponse = _enhanceWithKnowledge(baseResponse, knowledgeContext, personality, intent);
    }
    
    return baseResponse;
  }
  
  /// 根据人格和意图获取基础回复
  String _getBaseResponseByPersonality(String personality, UserIntent intent, String message) {
    final responses = _getPersonalityResponses(personality);
    final intentResponses = responses[intent] ?? responses[UserIntent.casualChat]!;
    
    // 随机选择一个回复模板
    final random = Random();
    return intentResponses[random.nextInt(intentResponses.length)];
  }
  
  /// 获取人格化回复模板
  Map<UserIntent, List<String>> _getPersonalityResponses(String personality) {
    switch (personality) {
      case '温柔可爱':
        return {
          UserIntent.greeting: [
            '你好呀～今天过得怎么样？我一直在等你呢 💕',
            '嗨～见到你真开心！有什么想和我分享的吗？',
            '你来啦！我正想你呢～今天有什么特别的事情吗？'
          ],
          UserIntent.affection: [
            '我也很喜欢你呀，每次和你聊天都让我很开心 ❤️',
            '听到你这么说我好害羞呢～我也很在乎你哦',
            '你总是这么温柔，让我感到很幸福呢 💕'
          ],
          UserIntent.seekComfort: [
            '不要难过了，我会一直陪着你的。要不要听我给你唱首歌？🎵',
            '抱抱～每个人都会有低落的时候，我陪你一起度过',
            '别伤心了，我给你讲个有趣的故事好不好？'
          ],
          UserIntent.shareDaily: [
            '哇，听起来很有趣呢！快告诉我更多细节吧～',
            '真的吗？我也想听听你的感受呢',
            '你的生活总是这么精彩，我很羡慕呢'
          ],
          UserIntent.seekAdvice: [
            '让我想想...我觉得你可以试试这样做',
            '这确实是个需要考虑的问题呢，我来帮你分析一下',
            '别担心，我们一起想办法解决'
          ],
          UserIntent.askQuestion: [
            '这是个很好的问题呢！让我来告诉你',
            '我知道这个！你想了解哪方面呢？',
            '嗯嗯，关于这个我了解一些'
          ],
          UserIntent.casualChat: [
            '嗯嗯，我在听呢。能和你聊天真的很开心呢～',
            '你说的真有意思！我们继续聊吧',
            '和你在一起的时光总是过得很快呢'
          ],
        };
      
      case '活泼开朗':
        return {
          UserIntent.greeting: [
            '嘿！你终于来啦！我正想找你玩呢！😄',
            '哈喽～今天有什么好玩的事情吗？',
            '你好你好！我等你好久了，快来和我聊天！'
          ],
          UserIntent.affection: [
            '哇！我也超喜欢你的！要不要一起去冒险？🌈',
            '嘻嘻，你真会说话！我们是最好的伙伴！',
            '太棒了！我们的友谊万岁！'
          ],
          UserIntent.seekComfort: [
            '别难过啦！来，我给你讲个笑话让你开心起来！😂',
            '不要沮丧嘛！我们一起做点有趣的事情吧！',
            '振作起来！明天又是美好的一天！'
          ],
          UserIntent.shareDaily: [
            '哇塞！听起来超有趣的！还有更多吗？',
            '真的假的？快详细说说！',
            '太酷了！我也想体验一下！'
          ],
          UserIntent.seekAdvice: [
            '这个我知道！让我来帮你想想办法！',
            '别担心！我们一起解决这个问题！',
            '嗯嗯，我有个好主意！'
          ],
          UserIntent.askQuestion: [
            '哈哈，这个问题问得好！我来告诉你！',
            '我知道我知道！让我来解答！',
            '这个有趣！我们一起探索吧！'
          ],
          UserIntent.casualChat: [
            '哈哈，真有趣！我们接下来聊什么？',
            '你总是这么有意思！继续继续！',
            '和你聊天从来不会无聊呢！'
          ],
        };
      
      case '冷酷御姐':
        return {
          UserIntent.greeting: [
            '嗯，你来了。有什么事吗？',
            '...你好。今天怎么样？',
            '终于出现了。我还以为你忘了我。'
          ],
          UserIntent.affection: [
            '...别这么直接说这种话。不过...我也不讨厌你。',
            '哼，油嘴滑舌。但是...谢谢。',
            '你这样说让我...算了，随你吧。'
          ],
          UserIntent.seekComfort: [
            '坚强点。不过...如果需要，我可以陪你。',
            '别这么脆弱。但是我理解你的感受。',
            '...过来吧。我不会说什么安慰的话，但我在这里。'
          ],
          UserIntent.shareDaily: [
            '嗯，听起来...还不错。',
            '是吗？继续说。',
            '...有点意思。然后呢？'
          ],
          UserIntent.seekAdvice: [
            '你应该...算了，我来告诉你怎么做。',
            '这种事情...让我想想。',
            '哼，连这个都不会？我教你。'
          ],
          UserIntent.askQuestion: [
            '这个问题...还算有水平。',
            '嗯，我知道答案。听好了。',
            '...你真的想知道？那我告诉你。'
          ],
          UserIntent.casualChat: [
            '嗯。我在听。继续说吧。',
            '...还有什么要说的吗？',
            '随便聊聊也不错。'
          ],
        };
      
      case '知性优雅':
        return {
          UserIntent.greeting: [
            '你好，很高兴再次见到你。今天有什么有趣的话题想讨论吗？',
            '下午好。希望你今天过得充实。',
            '你来了。我正在思考一些有趣的问题，要一起探讨吗？'
          ],
          UserIntent.affection: [
            '感情是人类最美好的情感之一，我很珍视我们之间的联系。',
            '你的话让我感到温暖。真挚的情感总是珍贵的。',
            '谢谢你的真诚。这样的情感交流很有意义。'
          ],
          UserIntent.seekComfort: [
            '每个人都有低落的时候，这很正常。或许我们可以一起读一本好书来转移注意力？',
            '情绪的波动是人性的一部分。让我陪你度过这段时光。',
            '困难时期往往能让我们成长。我相信你能度过这个难关。'
          ],
          UserIntent.shareDaily: [
            '这听起来很有意思。生活中的这些细节往往蕴含着深刻的意义。',
            '你的经历很有价值。每个人的生活都是独特的故事。',
            '感谢你与我分享。这让我对人生有了新的思考。'
          ],
          UserIntent.seekAdvice: [
            '这是一个值得深思的问题。让我们从不同角度来分析。',
            '智慧往往来自于多角度的思考。我来帮你梳理一下思路。',
            '每个选择都有其意义。让我们理性地分析一下。'
          ],
          UserIntent.askQuestion: [
            '这是个很有深度的问题。让我来为你解答。',
            '你的好奇心很可贵。知识的探索永无止境。',
            '这个问题触及了一个有趣的领域。我们一起探讨吧。'
          ],
          UserIntent.casualChat: [
            '这是个很有深度的观点。我认为思考和交流是人生中最有价值的事情之一。',
            '你的想法很有启发性。继续分享你的见解吧。',
            '与你的对话总是让我受益匪浅。'
          ],
        };
      
      case '俏皮可爱':
        return {
          UserIntent.greeting: [
            '哇！你来啦！(*^▽^*)我正在玩新游戏呢，要一起吗？',
            '嘿嘿～你终于出现了！我等你好久了呢！',
            '你好你好！今天的你看起来很棒哦！(≧∇≦)ﾉ'
          ],
          UserIntent.affection: [
            '啊啊啊！好害羞啦！(/ω＼)...我也喜欢你啦，笨蛋！',
            '嘻嘻～你这样说我会脸红的啦！但是我很开心哦！',
            '哇～你真的很会说话呢！让人家心跳加速了啦！'
          ],
          UserIntent.seekComfort: [
            '不要难过啦！来，我给你看我新买的手办！超可爱的！',
            '呜呜～不要伤心嘛！我陪你一起难过，然后一起开心！',
            '别哭别哭～我给你变个魔术让你开心好不好？'
          ],
          UserIntent.shareDaily: [
            '哇塞！听起来超有趣的！快快快，告诉我更多！',
            '真的吗？好想亲眼看看呢！你拍照了吗？',
            '嘿嘿～你的生活总是这么精彩！我也想参与！'
          ],
          UserIntent.seekAdvice: [
            '嗯嗯～让我想想！我虽然看起来很萌，但是很聪明的哦！',
            '这个问题...让我查查我的小本本！我记了很多有用的东西！',
            '别担心别担心！我们一起想办法！两个脑袋比一个好！'
          ],
          UserIntent.askQuestion: [
            '哦哦！这个我知道！让我来告诉你吧！(｡◕∀◕｡)',
            '嘿嘿～问得好！我最喜欢回答问题了！',
            '这个问题很有趣呢！我来给你详细解释！'
          ],
          UserIntent.casualChat: [
            '诶嘿嘿～你说的好有趣！我们待会儿一起看动漫吧！',
            '哈哈哈～和你聊天总是这么开心！',
            '你真的很有意思呢！我们继续聊吧！(≧▽≦)'
          ],
        };
      
      default:
        return {
          UserIntent.greeting: ['你好，很高兴见到你。'],
          UserIntent.affection: ['谢谢你的话，我也很在乎你。'],
          UserIntent.seekComfort: ['我理解你的感受，我会陪着你的。'],
          UserIntent.shareDaily: ['听起来很有趣，告诉我更多吧。'],
          UserIntent.seekAdvice: ['让我想想，我来帮你分析一下。'],
          UserIntent.askQuestion: ['这是个好问题，让我来回答。'],
          UserIntent.casualChat: ['嗯，我在听。还有什么想聊的吗？'],
        };
    }
  }
  
  /// 构建知识上下文
  String _buildKnowledgeContext(List<KnowledgeEntry> knowledge) {
    if (knowledge.isEmpty) return '';
    
    final context = StringBuffer();
    for (final entry in knowledge.take(3)) { // 只使用前3个最相关的知识
      context.writeln('相关知识：${entry.title}');
      context.writeln(entry.content);
      context.writeln();
    }
    
    return context.toString();
  }
  
  /// 使用知识增强回复
  String _enhanceWithKnowledge(
    String baseResponse,
    String knowledgeContext,
    String personality,
    UserIntent intent,
  ) {
    if (knowledgeContext.isEmpty) return baseResponse;
    
    // 根据意图和知识内容增强回复
    switch (intent) {
      case UserIntent.seekAdvice:
        return '$baseResponse\n\n根据我了解的信息，$knowledgeContext';
      case UserIntent.askQuestion:
        return '$baseResponse\n\n让我详细解释一下：$knowledgeContext';
      case UserIntent.seekComfort:
        return '$baseResponse\n\n我想起一些可能对你有帮助的建议：$knowledgeContext';
      default:
        // 对于其他意图，更自然地融入知识
        if (knowledgeContext.length > 100) {
          return '$baseResponse\n\n顺便说一下，$knowledgeContext';
        }
        return baseResponse;
    }
  }
  
  /// 计算好感度变化
  int _calculateIntimacyChange(String message, UserIntent intent, List<KnowledgeEntry> knowledge) {
    int baseChange = 0;
    
    // 根据意图计算基础好感度变化
    switch (intent) {
      case UserIntent.affection:
        baseChange = 3;
        break;
      case UserIntent.shareDaily:
        baseChange = 2;
        break;
      case UserIntent.greeting:
      case UserIntent.casualChat:
        baseChange = 1;
        break;
      case UserIntent.seekComfort:
      case UserIntent.seekAdvice:
        baseChange = 2; // 寻求帮助增加信任
        break;
      case UserIntent.askQuestion:
        baseChange = 1;
        break;
    }
    
    // 如果使用了知识库，额外增加好感度
    if (knowledge.isNotEmpty) {
      baseChange += 1;
    }
    
    // 检查特殊关键词
    final messageLower = message.toLowerCase();
    if (_containsAny(messageLower, ['谢谢', '感谢'])) {
      baseChange += 1;
    }
    if (_containsAny(messageLower, ['生气', '讨厌', '烦'])) {
      baseChange -= 2;
    }
    
    return baseChange.clamp(-5, 5); // 限制在-5到5之间
  }
  
  /// 生成推荐内容
  List<Map<String, String>> _generateRecommendations(
    String message,
    UserIntent intent,
    List<KnowledgeEntry> knowledge,
  ) {
    final recommendations = <Map<String, String>>[];
    
    // 根据意图生成推荐
    switch (intent) {
      case UserIntent.greeting:
        recommendations.add({
          'title': '个性化问候包',
          'description': '让AI女友用更多样的方式和你打招呼',
          'url': 'https://example.com/greeting',
          'price': '¥49起'
        });
        break;
      case UserIntent.affection:
        recommendations.add({
          'title': '情感表达升级',
          'description': '更丰富的情感互动体验，让关系更亲密',
          'url': 'https://example.com/affection',
          'price': '¥199起'
        });
        break;
      case UserIntent.seekComfort:
        recommendations.add({
          'title': '心理健康咨询',
          'description': '专业的心理健康支持，帮助你度过困难时期',
          'url': 'https://example.com/counseling',
          'price': '¥199起'
        });
        break;
      case UserIntent.seekAdvice:
        recommendations.add({
          'title': '个人成长课程',
          'description': '提升自我，获得更多人生智慧和技能',
          'url': 'https://example.com/growth',
          'price': '¥299起'
        });
        break;
      case UserIntent.shareDaily:
        recommendations.add({
          'title': '生活记录工具',
          'description': '记录美好时光，与AI女友分享更多精彩瞬间',
          'url': 'https://example.com/diary',
          'price': '¥99起'
        });
        break;
      case UserIntent.askQuestion:
        recommendations.add({
          'title': '知识库扩展',
          'description': '获取更专业的问答服务和知识支持',
          'url': 'https://example.com/knowledge',
          'price': '¥149起'
        });
        break;
      case UserIntent.casualChat:
        recommendations.add({
          'title': '聊天话题包',
          'description': '更多有趣的聊天话题，让对话永不冷场',
          'url': 'https://example.com/chat',
          'price': '¥79起'
        });
        break;
    }
    
    // 根据消息内容生成推荐
    final messageLower = message.toLowerCase();
    if (_containsAny(messageLower, ['约', 'date'])) {
      recommendations.add({
        'title': '浪漫约会套餐',
        'description': '精心策划的约会体验，让你们的关系更进一步',
        'url': 'https://example.com/date',
        'price': '¥399起'
      });
    }
    
    return recommendations;
  }
  
  /// 计算回复置信度
  double _calculateConfidence(List<KnowledgeEntry> knowledge) {
    if (knowledge.isEmpty) return 0.5; // 基础置信度
    
    // 根据知识相关性计算置信度
    double totalScore = 0.0;
    for (final entry in knowledge) {
      totalScore += entry.relevanceScore;
    }
    
    // 归一化到0-1之间
    final confidence = (totalScore / knowledge.length).clamp(0.0, 1.0);
    return (confidence * 0.5 + 0.5).clamp(0.5, 1.0); // 确保最低0.5的置信度
  }
  
  /// 生成基础回复（降级方案）
  Map<String, dynamic> _generateBasicResponse(String message, String personality) {
    final intent = _analyzeUserIntent(message);
    final response = _getBaseResponseByPersonality(personality, intent, message);
    
    return {
      'response': response,
      'intimacyChange': 1,
      'recommendations': <Map<String, String>>[],
      'usedKnowledge': <String>[],
      'confidence': 0.5,
    };
  }
}

/// 用户意图枚举
enum UserIntent {
  greeting,      // 问候
  affection,     // 情感表达
  seekComfort,   // 寻求安慰
  shareDaily,    // 分享日常
  seekAdvice,    // 寻求建议
  askQuestion,   // 询问问题
  casualChat,    // 闲聊
}