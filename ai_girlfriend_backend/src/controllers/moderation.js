const { SensitiveWord, ContentModeration, UserViolation, ModerationRule } = require('../models/ContentModeration');
const User = require('../models/User');
const { ChatMessage } = require('../models/Chat');
const mongoose = require('mongoose');

// @desc    Check content for moderation
// @route   POST /api/moderation/check
// @access  Private
const checkContent = async (req, res) => {
  try {
    const { content, contentType, contentId, contextInfo = {} } = req.body;
    const userId = req.user._id;

    // 创建审核记录
    const moderation = await ContentModeration.create({
      contentId: contentId || `temp_${Date.now()}`,
      contentType,
      originalContent: content,
      userId,
      contextInfo: {
        ...contextInfo,
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        timestamp: new Date()
      }
    });

    // 执行内容审核
    const moderationResult = await performContentModeration(content, contentType, userId);
    
    // 更新审核结果
    moderation.moderationResult = moderationResult;
    moderation.processedContent = moderationResult.processedContent || content;
    await moderation.save();

    // 根据审核结果执行相应动作
    await executeActions(moderation, moderationResult);

    res.json({
      success: true,
      data: {
        moderationId: moderation._id,
        status: moderationResult.status,
        processedContent: moderation.processedContent,
        violations: moderationResult.violations,
        confidence: moderationResult.confidence
      }
    });
  } catch (error) {
    console.error('Content moderation check error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check content'
    });
  }
};

// @desc    Get pending moderation items
// @route   GET /api/moderation/pending
// @access  Private/Admin
const getPendingModerations = async (req, res) => {
  try {
    const { page = 1, limit = 20, contentType, severity } = req.query;

    let query = {
      'moderationResult.status': 'pending_review',
      'humanReview.isReviewed': false
    };

    if (contentType) {
      query.contentType = contentType;
    }

    if (severity) {
      query['moderationResult.violations.severity'] = severity;
    }

    const moderations = await ContentModeration.find(query)
      .sort({ createdAt: 1 }) // 先进先出
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username email membershipType')
      .populate('contextInfo.characterId', 'name')
      .populate('contextInfo.conversationId', 'title');

    const total = await ContentModeration.countDocuments(query);

    res.json({
      success: true,
      data: {
        moderations,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get pending moderations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pending moderations'
    });
  }
};

// @desc    Approve moderation
// @route   PUT /api/moderation/:moderationId/approve
// @access  Private/Admin
const approveModerationItem = async (req, res) => {
  try {
    const { moderationId } = req.params;
    const { notes } = req.body;
    const reviewerId = req.user._id;

    const moderation = await ContentModeration.findById(moderationId);
    if (!moderation) {
      return res.status(404).json({
        success: false,
        message: 'Moderation item not found'
      });
    }

    await moderation.approve(reviewerId, notes);
    await moderation.addAction('approve_content', 'human', `Approved by ${req.user.username}`);

    res.json({
      success: true,
      message: 'Content approved successfully'
    });
  } catch (error) {
    console.error('Approve moderation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to approve content'
    });
  }
};

// @desc    Reject moderation
// @route   PUT /api/moderation/:moderationId/reject
// @access  Private/Admin
const rejectModerationItem = async (req, res) => {
  try {
    const { moderationId } = req.params;
    const { notes, modifiedContent, createViolation = false, violationType, severity } = req.body;
    const reviewerId = req.user._id;

    const moderation = await ContentModeration.findById(moderationId)
      .populate('userId', 'username email');
    
    if (!moderation) {
      return res.status(404).json({
        success: false,
        message: 'Moderation item not found'
      });
    }

    await moderation.reject(reviewerId, notes, modifiedContent);
    await moderation.addAction('reject_content', 'human', `Rejected by ${req.user.username}`);

    // 如果需要创建违规记录
    if (createViolation && violationType && severity) {
      await createUserViolation({
        userId: moderation.userId._id,
        violationType,
        severity,
        description: notes || 'Content violation detected',
        evidence: {
          contentModerationId: moderation._id
        },
        handledBy: reviewerId
      });
    }

    res.json({
      success: true,
      message: 'Content rejected successfully'
    });
  } catch (error) {
    console.error('Reject moderation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to reject content'
    });
  }
};

// @desc    Get sensitive words
// @route   GET /api/moderation/sensitive-words
// @access  Private/Admin
const getSensitiveWords = async (req, res) => {
  try {
    const { category, page = 1, limit = 50, search } = req.query;

    let query = { isActive: true };
    
    if (category) {
      query.category = category;
    }
    
    if (search) {
      query.word = { $regex: search, $options: 'i' };
    }

    const words = await SensitiveWord.find(query)
      .sort({ category: 1, severity: -1, word: 1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await SensitiveWord.countDocuments(query);

    // 获取分类统计
    const categoryStats = await SensitiveWord.aggregate([
      { $match: { isActive: true } },
      {
        $group: {
          _id: '$category',
          count: { $sum: 1 },
          avgSeverity: { $avg: { $switch: {
            branches: [
              { case: { $eq: ['$severity', 'low'] }, then: 1 },
              { case: { $eq: ['$severity', 'medium'] }, then: 2 },
              { case: { $eq: ['$severity', 'high'] }, then: 3 },
              { case: { $eq: ['$severity', 'critical'] }, then: 4 }
            ],
            default: 2
          }}}
        }
      },
      { $sort: { count: -1 } }
    ]);

    res.json({
      success: true,
      data: {
        words,
        categoryStats,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get sensitive words error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get sensitive words'
    });
  }
};

// @desc    Add sensitive word
// @route   POST /api/moderation/sensitive-words
// @access  Private/Admin
const addSensitiveWord = async (req, res) => {
  try {
    const wordData = req.body;
    wordData.createdBy = req.user._id;

    // 检查是否已存在
    const existingWord = await SensitiveWord.findOne({
      word: wordData.word,
      category: wordData.category
    });

    if (existingWord) {
      return res.status(400).json({
        success: false,
        message: 'Sensitive word already exists in this category'
      });
    }

    const sensitiveWord = await SensitiveWord.create(wordData);

    res.status(201).json({
      success: true,
      message: 'Sensitive word added successfully',
      data: {
        word: sensitiveWord
      }
    });
  } catch (error) {
    console.error('Add sensitive word error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add sensitive word'
    });
  }
};

// @desc    Update sensitive word
// @route   PUT /api/moderation/sensitive-words/:wordId
// @access  Private/Admin
const updateSensitiveWord = async (req, res) => {
  try {
    const { wordId } = req.params;
    const updateData = req.body;

    const sensitiveWord = await SensitiveWord.findByIdAndUpdate(
      wordId,
      updateData,
      { new: true, runValidators: true }
    );

    if (!sensitiveWord) {
      return res.status(404).json({
        success: false,
        message: 'Sensitive word not found'
      });
    }

    res.json({
      success: true,
      message: 'Sensitive word updated successfully',
      data: {
        word: sensitiveWord
      }
    });
  } catch (error) {
    console.error('Update sensitive word error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update sensitive word'
    });
  }
};

// @desc    Delete sensitive word
// @route   DELETE /api/moderation/sensitive-words/:wordId
// @access  Private/Admin
const deleteSensitiveWord = async (req, res) => {
  try {
    const { wordId } = req.params;

    const sensitiveWord = await SensitiveWord.findByIdAndUpdate(
      wordId,
      { isActive: false },
      { new: true }
    );

    if (!sensitiveWord) {
      return res.status(404).json({
        success: false,
        message: 'Sensitive word not found'
      });
    }

    res.json({
      success: true,
      message: 'Sensitive word deleted successfully'
    });
  } catch (error) {
    console.error('Delete sensitive word error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete sensitive word'
    });
  }
};

// @desc    Get moderation rules
// @route   GET /api/moderation/rules
// @access  Private/Admin
const getModerationRules = async (req, res) => {
  try {
    const { isActive } = req.query;

    let query = {};
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    const rules = await ModerationRule.find(query)
      .sort({ priority: -1, createdAt: 1 })
      .populate('createdBy', 'username');

    res.json({
      success: true,
      data: {
        rules
      }
    });
  } catch (error) {
    console.error('Get moderation rules error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get moderation rules'
    });
  }
};

// @desc    Create moderation rule
// @route   POST /api/moderation/rules
// @access  Private/Admin
const createModerationRule = async (req, res) => {
  try {
    const ruleData = req.body;
    ruleData.createdBy = req.user._id;

    const rule = await ModerationRule.create(ruleData);

    res.status(201).json({
      success: true,
      message: 'Moderation rule created successfully',
      data: {
        rule
      }
    });
  } catch (error) {
    console.error('Create moderation rule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create moderation rule'
    });
  }
};

// @desc    Get user violations
// @route   GET /api/moderation/violations
// @access  Private/Admin
const getUserViolations = async (req, res) => {
  try {
    const { userId, status, page = 1, limit = 20 } = req.query;

    let query = {};
    if (userId) query.userId = userId;
    if (status) query.status = status;

    const violations = await UserViolation.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username email')
      .populate('handledBy', 'username')
      .populate('evidence.contentModerationId');

    const total = await UserViolation.countDocuments(query);

    res.json({
      success: true,
      data: {
        violations,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get user violations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user violations'
    });
  }
};

// @desc    Create user violation
// @route   POST /api/moderation/violations
// @access  Private/Admin
const createUserViolationRecord = async (req, res) => {
  try {
    const violationData = req.body;
    violationData.handledBy = req.user._id;

    const violation = await createUserViolation(violationData);

    res.status(201).json({
      success: true,
      message: 'User violation recorded successfully',
      data: {
        violation
      }
    });
  } catch (error) {
    console.error('Create user violation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create user violation'
    });
  }
};

// @desc    Get moderation statistics
// @route   GET /api/moderation/statistics
// @access  Private/Admin
const getModerationStatistics = async (req, res) => {
  try {
    const { timeRange = '7d' } = req.query;
    const { startDate, endDate } = getDateRange(timeRange);

    // 并行获取统计数据
    const [contentStats, violationStats, ruleStats, reviewStats] = await Promise.all([
      getContentModerationStats(startDate, endDate),
      getUserViolationStats(startDate, endDate),
      getRuleEffectivenessStats(),
      getReviewStats(startDate, endDate)
    ]);

    res.json({
      success: true,
      data: {
        content: contentStats,
        violations: violationStats,
        rules: ruleStats,
        reviews: reviewStats,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get moderation statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get moderation statistics'
    });
  }
};

// Helper functions

// 执行内容审核
async function performContentModeration(content, contentType, userId) {
  const result = {
    status: 'approved',
    confidence: 0,
    violations: [],
    processedContent: content,
    aiAnalysis: {}
  };

  try {
    // 1. 敏感词检测
    const sensitiveWordResult = await checkSensitiveWords(content);
    if (sensitiveWordResult.violations.length > 0) {
      result.violations.push(...sensitiveWordResult.violations);
      result.processedContent = sensitiveWordResult.processedContent;
    }

    // 2. AI毒性检测（模拟）
    const aiResult = await performAIModeration(content);
    result.aiAnalysis = aiResult;
    
    if (aiResult.toxicity > 0.7) {
      result.violations.push({
        type: 'inappropriate_content',
        severity: aiResult.toxicity > 0.9 ? 'critical' : 'high',
        confidence: aiResult.toxicity,
        details: {
          reason: 'High toxicity detected by AI',
          context: content.substring(0, 100)
        }
      });
    }

    // 3. 个人信息检测
    const personalInfoResult = checkPersonalInfo(content);
    if (personalInfoResult.detected) {
      result.violations.push({
        type: 'personal_info',
        severity: 'medium',
        confidence: 0.8,
        details: personalInfoResult.details
      });
    }

    // 4. 垃圾内容检测
    const spamResult = await checkSpamContent(content, userId);
    if (spamResult.isSpam) {
      result.violations.push({
        type: 'spam',
        severity: 'medium',
        confidence: spamResult.confidence,
        details: spamResult.details
      });
    }

    // 确定最终状态
    if (result.violations.length > 0) {
      const maxSeverity = getMaxSeverity(result.violations);
      
      switch (maxSeverity) {
        case 'critical':
          result.status = 'blocked';
          break;
        case 'high':
          result.status = 'pending_review';
          break;
        case 'medium':
          result.status = 'filtered';
          break;
        default:
          result.status = 'approved';
      }
    }

    // 计算总体置信度
    if (result.violations.length > 0) {
      result.confidence = result.violations.reduce((sum, v) => sum + v.confidence, 0) / result.violations.length;
    }

  } catch (error) {
    console.error('Content moderation error:', error);
    result.status = 'pending_review';
    result.violations.push({
      type: 'system_error',
      severity: 'medium',
      confidence: 0.5,
      details: {
        reason: 'Moderation system error',
        error: error.message
      }
    });
  }

  return result;
}

// 敏感词检测
async function checkSensitiveWords(content) {
  const result = {
    violations: [],
    processedContent: content
  };

  try {
    const sensitiveWords = await SensitiveWord.find({ isActive: true });
    
    for (const wordObj of sensitiveWords) {
      let regex;
      if (wordObj.isRegex) {
        regex = new RegExp(wordObj.word, 'gi');
      } else {
        regex = new RegExp(`\\b${wordObj.word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\b`, 'gi');
      }

      const matches = content.match(regex);
      if (matches) {
        // 记录命中
        await wordObj.incrementHit();

        result.violations.push({
          type: 'sensitive_word',
          severity: wordObj.severity,
          confidence: 1.0,
          details: {
            matchedWords: matches,
            category: wordObj.category,
            reason: `Sensitive word detected: ${wordObj.category}`
          }
        });

        // 根据动作处理内容
        if (wordObj.action === 'filter') {
          result.processedContent = result.processedContent.replace(regex, wordObj.replacement);
        }
      }
    }
  } catch (error) {
    console.error('Sensitive word check error:', error);
  }

  return result;
}

// AI审核（模拟）
async function performAIModeration(content) {
  // 模拟AI审核结果
  await new Promise(resolve => setTimeout(resolve, 100));
  
  return {
    toxicity: Math.random() * 0.3, // 大部分内容毒性较低
    sentiment: Math.random() > 0.3 ? 'positive' : Math.random() > 0.5 ? 'neutral' : 'negative',
    topics: ['general'],
    language: 'zh-CN',
    isSpam: Math.random() < 0.05, // 5%概率是垃圾内容
    containsPersonalInfo: Math.random() < 0.02 // 2%概率包含个人信息
  };
}

// 个人信息检测
function checkPersonalInfo(content) {
  const patterns = {
    phone: /1[3-9]\d{9}/g,
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
    idCard: /\d{17}[\dXx]/g,
    bankCard: /\d{16,19}/g
  };

  const detected = [];
  
  for (const [type, pattern] of Object.entries(patterns)) {
    const matches = content.match(pattern);
    if (matches) {
      detected.push({ type, matches });
    }
  }

  return {
    detected: detected.length > 0,
    details: {
      types: detected.map(d => d.type),
      reason: 'Personal information detected'
    }
  };
}

// 垃圾内容检测
async function checkSpamContent(content, userId) {
  // 简单的垃圾内容检测逻辑
  const spamIndicators = [
    /加微信/gi,
    /联系我/gi,
    /优惠/gi,
    /免费/gi,
    /赚钱/gi
  ];

  let spamScore = 0;
  const matchedPatterns = [];

  for (const pattern of spamIndicators) {
    if (pattern.test(content)) {
      spamScore += 0.3;
      matchedPatterns.push(pattern.source);
    }
  }

  // 检查重复内容
  const recentMessages = await ChatMessage.find({
    'sender.userId': userId,
    createdAt: { $gte: new Date(Date.now() - 60 * 60 * 1000) } // 1小时内
  }).limit(10);

  const duplicateCount = recentMessages.filter(msg => 
    msg.content.text === content
  ).length;

  if (duplicateCount > 2) {
    spamScore += 0.4;
    matchedPatterns.push('duplicate_content');
  }

  return {
    isSpam: spamScore > 0.5,
    confidence: Math.min(spamScore, 1.0),
    details: {
      score: spamScore,
      indicators: matchedPatterns,
      reason: 'Spam patterns detected'
    }
  };
}

// 获取最高严重级别
function getMaxSeverity(violations) {
  const severityOrder = { 'low': 1, 'medium': 2, 'high': 3, 'critical': 4 };
  
  return violations.reduce((max, violation) => {
    return severityOrder[violation.severity] > severityOrder[max] ? violation.severity : max;
  }, 'low');
}

// 执行审核动作
async function executeActions(moderation, result) {
  try {
    switch (result.status) {
      case 'blocked':
        await moderation.addAction('block_content', 'system', 'Content blocked due to critical violations');
        break;
      case 'filtered':
        await moderation.addAction('filter_content', 'system', 'Content filtered due to policy violations');
        break;
      case 'pending_review':
        await moderation.addAction('flag_for_review', 'system', 'Content flagged for human review');
        break;
    }
  } catch (error) {
    console.error('Execute actions error:', error);
  }
}

// 创建用户违规记录
async function createUserViolation(violationData) {
  // 计算处罚结束时间
  if (violationData.penalty && violationData.penalty.duration > 0) {
    violationData.penalty.endDate = new Date(
      Date.now() + violationData.penalty.duration * 60 * 60 * 1000
    );
  }

  const violation = await UserViolation.create(violationData);
  
  // 应用处罚到用户账户
  await applyPenaltyToUser(violationData.userId, violation.penalty);
  
  return violation;
}

// 应用处罚到用户
async function applyPenaltyToUser(userId, penalty) {
  try {
    const updateData = {};
    
    switch (penalty.type) {
      case 'temporary_suspension':
        updateData.suspendedUntil = penalty.endDate;
        break;
      case 'permanent_ban':
        updateData.isActive = false;
        updateData.bannedAt = new Date();
        break;
      case 'feature_restriction':
        // 实现功能限制逻辑
        break;
    }
    
    if (Object.keys(updateData).length > 0) {
      await User.findByIdAndUpdate(userId, updateData);
    }
  } catch (error) {
    console.error('Apply penalty error:', error);
  }
}

// 获取日期范围
function getDateRange(timeRange) {
  const endDate = new Date();
  let startDate;
  
  switch (timeRange) {
    case '24h':
      startDate = new Date(endDate.getTime() - 24 * 60 * 60 * 1000);
      break;
    case '7d':
      startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
      break;
    case '30d':
      startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);
      break;
    default:
      startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
  }
  
  return { startDate, endDate };
}

// 统计函数（占位符）
async function getContentModerationStats() { return {}; }
async function getUserViolationStats() { return {}; }
async function getRuleEffectivenessStats() { return {}; }
async function getReviewStats() { return {}; }

module.exports = {
  checkContent,
  getPendingModerations,
  approveModerationItem,
  rejectModerationItem,
  getSensitiveWords,
  addSensitiveWord,
  updateSensitiveWord,
  deleteSensitiveWord,
  getModerationRules,
  createModerationRule,
  getUserViolations,
  createUserViolationRecord,
  getModerationStatistics
};