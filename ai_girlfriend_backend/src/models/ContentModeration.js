const mongoose = require('mongoose');

// 敏感词库模式
const sensitiveWordSchema = new mongoose.Schema({
  word: {
    type: String,
    required: true,
    trim: true,
    index: true
  },
  category: {
    type: String,
    enum: [
      'profanity', 'violence', 'sexual', 'political', 'religious',
      'discrimination', 'harassment', 'spam', 'personal_info', 'custom'
    ],
    required: true
  },
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  action: {
    type: String,
    enum: ['warn', 'filter', 'block', 'review'],
    default: 'filter'
  },
  language: {
    type: String,
    default: 'zh-CN'
  },
  isRegex: {
    type: Boolean,
    default: false
  },
  replacement: {
    type: String,
    default: '***'
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  usage: {
    hitCount: {
      type: Number,
      default: 0
    },
    lastHit: Date
  }
}, {
  timestamps: true
});

// 内容审核记录模式
const contentModerationSchema = new mongoose.Schema({
  contentId: {
    type: String,
    required: true,
    index: true
  },
  contentType: {
    type: String,
    enum: ['message', 'character_name', 'character_description', 'knowledge_item', 'user_profile', 'custom'],
    required: true
  },
  originalContent: {
    type: String,
    required: true
  },
  processedContent: {
    type: String
  },
  
  // 审核结果
  moderationResult: {
    status: {
      type: String,
      enum: ['approved', 'filtered', 'blocked', 'pending_review', 'rejected'],
      default: 'pending_review'
    },
    confidence: {
      type: Number,
      min: 0,
      max: 1,
      default: 0
    },
    
    // 检测到的问题
    violations: [{
      type: {
        type: String,
        enum: [
          'sensitive_word', 'spam', 'personal_info', 'inappropriate_content',
          'violence', 'sexual_content', 'harassment', 'hate_speech', 'custom'
        ]
      },
      severity: {
        type: String,
        enum: ['low', 'medium', 'high', 'critical']
      },
      confidence: {
        type: Number,
        min: 0,
        max: 1
      },
      details: {
        matchedWords: [String],
        position: {
          start: Number,
          end: Number
        },
        context: String,
        reason: String
      }
    }],
    
    // AI审核结果
    aiAnalysis: {
      toxicity: {
        type: Number,
        min: 0,
        max: 1
      },
      sentiment: {
        type: String,
        enum: ['positive', 'neutral', 'negative']
      },
      topics: [String],
      language: String,
      isSpam: {
        type: Boolean,
        default: false
      },
      containsPersonalInfo: {
        type: Boolean,
        default: false
      }
    }
  },
  
  // 用户和上下文信息
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  contextInfo: {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Conversation'
    },
    characterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Character'
    },
    ipAddress: String,
    userAgent: String,
    timestamp: {
      type: Date,
      default: Date.now
    }
  },
  
  // 人工审核信息
  humanReview: {
    isReviewed: {
      type: Boolean,
      default: false
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reviewedAt: Date,
    decision: {
      type: String,
      enum: ['approve', 'reject', 'modify', 'escalate']
    },
    notes: String,
    modifiedContent: String
  },
  
  // 处理动作
  actions: [{
    type: {
      type: String,
      enum: ['filter_content', 'warn_user', 'suspend_user', 'block_content', 'escalate', 'notify_admin']
    },
    executedAt: {
      type: Date,
      default: Date.now
    },
    executedBy: {
      type: String,
      enum: ['system', 'ai', 'human']
    },
    details: String
  }],
  
  // 申诉信息
  appeal: {
    isAppealed: {
      type: Boolean,
      default: false
    },
    appealedAt: Date,
    appealReason: String,
    appealStatus: {
      type: String,
      enum: ['pending', 'approved', 'rejected']
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reviewNotes: String
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 用户违规记录模式
const userViolationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  violationType: {
    type: String,
    enum: [
      'inappropriate_content', 'spam', 'harassment', 'impersonation',
      'copyright_violation', 'terms_violation', 'repeated_violations', 'other'
    ],
    required: true
  },
  severity: {
    type: String,
    enum: ['minor', 'moderate', 'severe', 'critical'],
    required: true
  },
  description: {
    type: String,
    required: true
  },
  evidence: {
    contentModerationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'ContentModeration'
    },
    screenshots: [String],
    additionalInfo: String
  },
  
  // 处罚信息
  penalty: {
    type: {
      type: String,
      enum: ['warning', 'content_removal', 'temporary_suspension', 'permanent_ban', 'feature_restriction'],
      required: true
    },
    duration: {
      type: Number, // 小时数，0表示永久
      default: 0
    },
    startDate: {
      type: Date,
      default: Date.now
    },
    endDate: Date,
    restrictions: [{
      feature: String, // 'chat', 'character_creation', 'knowledge_base', etc.
      restricted: Boolean
    }]
  },
  
  // 状态信息
  status: {
    type: String,
    enum: ['active', 'resolved', 'appealed', 'overturned'],
    default: 'active'
  },
  
  // 处理信息
  handledBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // 申诉信息
  appeal: {
    isAppealed: {
      type: Boolean,
      default: false
    },
    appealDate: Date,
    appealReason: String,
    appealStatus: {
      type: String,
      enum: ['pending', 'approved', 'rejected']
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    reviewDate: Date,
    reviewNotes: String
  }
}, {
  timestamps: true
});

// 审核规则模式
const moderationRuleSchema = new mongoose.Schema({
  ruleId: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  description: String,
  
  // 规则条件
  conditions: {
    contentTypes: [{
      type: String,
      enum: ['message', 'character_name', 'character_description', 'knowledge_item', 'user_profile']
    }],
    
    // 触发条件
    triggers: {
      sensitiveWords: {
        enabled: {
          type: Boolean,
          default: true
        },
        categories: [String],
        minSeverity: {
          type: String,
          enum: ['low', 'medium', 'high', 'critical'],
          default: 'medium'
        }
      },
      
      aiToxicity: {
        enabled: {
          type: Boolean,
          default: true
        },
        threshold: {
          type: Number,
          min: 0,
          max: 1,
          default: 0.7
        }
      },
      
      spamDetection: {
        enabled: {
          type: Boolean,
          default: true
        },
        threshold: {
          type: Number,
          min: 0,
          max: 1,
          default: 0.8
        }
      },
      
      personalInfoDetection: {
        enabled: {
          type: Boolean,
          default: true
        },
        types: [{
          type: String,
          enum: ['phone', 'email', 'id_card', 'address', 'bank_card']
        }]
      },
      
      userBehavior: {
        enabled: {
          type: Boolean,
          default: false
        },
        rapidPosting: {
          enabled: Boolean,
          threshold: Number, // 每分钟消息数
          timeWindow: Number // 时间窗口（分钟）
        },
        repeatedContent: {
          enabled: Boolean,
          threshold: Number // 重复内容阈值
        }
      }
    }
  },
  
  // 执行动作
  actions: {
    automatic: [{
      type: {
        type: String,
        enum: ['filter', 'block', 'warn', 'flag_for_review', 'auto_reject']
      },
      severity: {
        type: String,
        enum: ['low', 'medium', 'high', 'critical']
      },
      parameters: mongoose.Schema.Types.Mixed
    }],
    
    escalation: {
      enabled: {
        type: Boolean,
        default: true
      },
      conditions: {
        severityThreshold: {
          type: String,
          enum: ['medium', 'high', 'critical'],
          default: 'high'
        },
        confidenceThreshold: {
          type: Number,
          min: 0,
          max: 1,
          default: 0.9
        }
      }
    }
  },
  
  // 规则配置
  priority: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  },
  
  // 统计信息
  statistics: {
    totalTriggers: {
      type: Number,
      default: 0
    },
    accurateDetections: {
      type: Number,
      default: 0
    },
    falsePositives: {
      type: Number,
      default: 0
    },
    lastTriggered: Date
  },
  
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

// 索引
sensitiveWordSchema.index({ word: 'text' });
sensitiveWordSchema.index({ category: 1, isActive: 1 });
sensitiveWordSchema.index({ severity: 1 });

contentModerationSchema.index({ userId: 1, createdAt: -1 });
contentModerationSchema.index({ contentType: 1, 'moderationResult.status': 1 });
contentModerationSchema.index({ 'moderationResult.status': 1 });
contentModerationSchema.index({ 'humanReview.isReviewed': 1 });
contentModerationSchema.index({ contentId: 1, contentType: 1 });

userViolationSchema.index({ userId: 1, createdAt: -1 });
userViolationSchema.index({ status: 1 });
userViolationSchema.index({ violationType: 1, severity: 1 });
userViolationSchema.index({ 'penalty.endDate': 1 });

moderationRuleSchema.index({ ruleId: 1 });
moderationRuleSchema.index({ isActive: 1, priority: -1 });

// 虚拟字段
contentModerationSchema.virtual('needsHumanReview').get(function() {
  return this.moderationResult.status === 'pending_review' && !this.humanReview.isReviewed;
});

contentModerationSchema.virtual('isHighRisk').get(function() {
  return this.moderationResult.violations.some(v => v.severity === 'critical' || v.severity === 'high');
});

userViolationSchema.virtual('isActive').get(function() {
  if (this.status !== 'active') return false;
  if (this.penalty.duration === 0) return true; // 永久处罚
  return this.penalty.endDate && this.penalty.endDate > new Date();
});

// 实例方法
sensitiveWordSchema.methods.incrementHit = function() {
  this.usage.hitCount += 1;
  this.usage.lastHit = new Date();
  return this.save();
};

contentModerationSchema.methods.approve = function(reviewerId, notes) {
  this.moderationResult.status = 'approved';
  this.humanReview.isReviewed = true;
  this.humanReview.reviewedBy = reviewerId;
  this.humanReview.reviewedAt = new Date();
  this.humanReview.decision = 'approve';
  this.humanReview.notes = notes;
  return this.save();
};

contentModerationSchema.methods.reject = function(reviewerId, notes, modifiedContent) {
  this.moderationResult.status = 'rejected';
  this.humanReview.isReviewed = true;
  this.humanReview.reviewedBy = reviewerId;
  this.humanReview.reviewedAt = new Date();
  this.humanReview.decision = 'reject';
  this.humanReview.notes = notes;
  if (modifiedContent) {
    this.humanReview.modifiedContent = modifiedContent;
  }
  return this.save();
};

contentModerationSchema.methods.addAction = function(actionType, executedBy, details) {
  this.actions.push({
    type: actionType,
    executedBy,
    details
  });
  return this.save();
};

userViolationSchema.methods.resolve = function() {
  this.status = 'resolved';
  return this.save();
};

userViolationSchema.methods.appeal = function(reason) {
  this.appeal.isAppealed = true;
  this.appeal.appealDate = new Date();
  this.appeal.appealReason = reason;
  this.appeal.appealStatus = 'pending';
  this.status = 'appealed';
  return this.save();
};

// 静态方法
sensitiveWordSchema.statics.findByCategory = function(category, isActive = true) {
  return this.find({ category, isActive }).sort({ severity: -1, word: 1 });
};

sensitiveWordSchema.statics.searchWords = function(text) {
  return this.find({
    $or: [
      { word: { $regex: text, $options: 'i' } },
      { word: text }
    ],
    isActive: true
  });
};

contentModerationSchema.statics.findPendingReview = function(limit = 50) {
  return this.find({
    'moderationResult.status': 'pending_review',
    'humanReview.isReviewed': false
  })
  .sort({ createdAt: 1 })
  .limit(limit)
  .populate('userId', 'username email')
  .populate('contextInfo.characterId', 'name');
};

contentModerationSchema.statics.findByUser = function(userId, options = {}) {
  const { status, limit = 20, page = 1 } = options;
  
  const query = { userId };
  if (status) query['moderationResult.status'] = status;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .limit(limit)
    .skip((page - 1) * limit);
};

userViolationSchema.statics.findActiveViolations = function(userId) {
  return this.find({
    userId,
    status: 'active',
    $or: [
      { 'penalty.duration': 0 }, // 永久处罚
      { 'penalty.endDate': { $gt: new Date() } } // 未过期的临时处罚
    ]
  });
};

userViolationSchema.statics.getUserViolationHistory = function(userId, limit = 10) {
  return this.find({ userId })
    .sort({ createdAt: -1 })
    .limit(limit)
    .populate('handledBy', 'username')
    .populate('evidence.contentModerationId');
};

moderationRuleSchema.statics.getActiveRules = function() {
  return this.find({ isActive: true }).sort({ priority: -1, createdAt: 1 });
};

moderationRuleSchema.methods.incrementTrigger = function(isAccurate = true) {
  this.statistics.totalTriggers += 1;
  if (isAccurate) {
    this.statistics.accurateDetections += 1;
  } else {
    this.statistics.falsePositives += 1;
  }
  this.statistics.lastTriggered = new Date();
  return this.save();
};

const SensitiveWord = mongoose.model('SensitiveWord', sensitiveWordSchema);
const ContentModeration = mongoose.model('ContentModeration', contentModerationSchema);
const UserViolation = mongoose.model('UserViolation', userViolationSchema);
const ModerationRule = mongoose.model('ModerationRule', moderationRuleSchema);

module.exports = {
  SensitiveWord,
  ContentModeration,
  UserViolation,
  ModerationRule
};