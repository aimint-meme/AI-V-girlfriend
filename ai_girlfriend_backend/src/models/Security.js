const mongoose = require('mongoose');

// 安全事件日志模式
const securityEventSchema = new mongoose.Schema({
  eventId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  
  // 事件基本信息
  eventType: {
    type: String,
    enum: [
      'login_attempt', 'login_success', 'login_failure', 'logout',
      'password_change', 'account_locked', 'account_unlocked',
      'suspicious_activity', 'rate_limit_exceeded', 'api_abuse',
      'unauthorized_access', 'privilege_escalation', 'data_breach',
      'malicious_request', 'sql_injection', 'xss_attempt',
      'csrf_attempt', 'brute_force', 'ddos_attempt', 'other'
    ],
    required: true,
    index: true
  },
  
  severity: {
    type: String,
    enum: ['info', 'low', 'medium', 'high', 'critical'],
    default: 'info',
    index: true
  },
  
  status: {
    type: String,
    enum: ['detected', 'investigating', 'resolved', 'false_positive', 'ignored'],
    default: 'detected'
  },
  
  // 用户和会话信息
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true
  },
  
  sessionId: {
    type: String,
    index: true
  },
  
  // 请求信息
  request: {
    method: String,
    url: String,
    userAgent: String,
    referer: String,
    headers: mongoose.Schema.Types.Mixed,
    body: mongoose.Schema.Types.Mixed,
    query: mongoose.Schema.Types.Mixed,
    params: mongoose.Schema.Types.Mixed
  },
  
  // 网络信息
  network: {
    ipAddress: {
      type: String,
      required: true,
      index: true
    },
    country: String,
    region: String,
    city: String,
    isp: String,
    isProxy: {
      type: Boolean,
      default: false
    },
    isTor: {
      type: Boolean,
      default: false
    },
    isVpn: {
      type: Boolean,
      default: false
    },
    riskScore: {
      type: Number,
      min: 0,
      max: 100,
      default: 0
    }
  },
  
  // 设备信息
  device: {
    fingerprint: String,
    platform: String,
    browser: String,
    version: String,
    isMobile: Boolean,
    screenResolution: String,
    timezone: String,
    language: String
  },
  
  // 事件详情
  details: {
    description: String,
    evidence: mongoose.Schema.Types.Mixed,
    context: mongoose.Schema.Types.Mixed,
    ruleTriggered: String,
    confidence: {
      type: Number,
      min: 0,
      max: 1,
      default: 0
    }
  },
  
  // 响应信息
  response: {
    action: {
      type: String,
      enum: ['allow', 'block', 'challenge', 'log_only', 'rate_limit', 'captcha']
    },
    statusCode: Number,
    message: String,
    blocked: {
      type: Boolean,
      default: false
    },
    blockedReason: String
  },
  
  // 处理信息
  investigation: {
    assignedTo: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    notes: String,
    resolution: String,
    resolvedAt: Date,
    resolvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  },
  
  // 关联事件
  relatedEvents: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SecurityEvent'
  }],
  
  // 标签和分类
  tags: [String],
  
  // 自动化处理
  automated: {
    type: Boolean,
    default: true
  },
  
  // 通知状态
  notifications: {
    sent: {
      type: Boolean,
      default: false
    },
    sentAt: Date,
    recipients: [String]
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 系统日志模式
const systemLogSchema = new mongoose.Schema({
  logId: {
    type: String,
    required: true,
    unique: true
  },
  
  // 日志级别
  level: {
    type: String,
    enum: ['debug', 'info', 'warn', 'error', 'fatal'],
    required: true,
    index: true
  },
  
  // 日志来源
  source: {
    service: {
      type: String,
      required: true
    },
    module: String,
    function: String,
    file: String,
    line: Number
  },
  
  // 日志内容
  message: {
    type: String,
    required: true
  },
  
  // 错误信息
  error: {
    name: String,
    message: String,
    stack: String,
    code: String
  },
  
  // 上下文信息
  context: {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    sessionId: String,
    requestId: String,
    traceId: String,
    correlationId: String
  },
  
  // 请求信息
  request: {
    method: String,
    url: String,
    headers: mongoose.Schema.Types.Mixed,
    body: mongoose.Schema.Types.Mixed,
    query: mongoose.Schema.Types.Mixed,
    params: mongoose.Schema.Types.Mixed,
    ipAddress: String,
    userAgent: String
  },
  
  // 响应信息
  response: {
    statusCode: Number,
    headers: mongoose.Schema.Types.Mixed,
    body: mongoose.Schema.Types.Mixed,
    duration: Number // 毫秒
  },
  
  // 性能指标
  performance: {
    executionTime: Number, // 毫秒
    memoryUsage: Number,   // MB
    cpuUsage: Number,      // 百分比
    dbQueries: Number,
    cacheHits: Number,
    cacheMisses: Number
  },
  
  // 业务数据
  business: {
    operation: String,
    entityType: String,
    entityId: String,
    before: mongoose.Schema.Types.Mixed,
    after: mongoose.Schema.Types.Mixed
  },
  
  // 标签和元数据
  tags: [String],
  metadata: mongoose.Schema.Types.Mixed,
  
  // 环境信息
  environment: {
    type: String,
    enum: ['development', 'testing', 'staging', 'production'],
    default: 'production'
  },
  
  // 时间戳
  timestamp: {
    type: Date,
    default: Date.now,
    index: true
  }
}, {
  timestamps: true
});

// 访问控制日志模式
const accessLogSchema = new mongoose.Schema({
  // 用户信息
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true
  },
  
  // 访问信息
  resource: {
    type: String,
    required: true,
    index: true
  },
  
  action: {
    type: String,
    required: true,
    enum: ['create', 'read', 'update', 'delete', 'execute', 'access']
  },
  
  // 权限检查结果
  permission: {
    granted: {
      type: Boolean,
      required: true
    },
    reason: String,
    requiredRoles: [String],
    userRoles: [String],
    requiredPermissions: [String],
    userPermissions: [String]
  },
  
  // 请求上下文
  context: {
    ipAddress: String,
    userAgent: String,
    sessionId: String,
    requestId: String,
    method: String,
    url: String,
    referer: String
  },
  
  // 资源详情
  resourceDetails: {
    id: String,
    type: String,
    owner: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    sensitivity: {
      type: String,
      enum: ['public', 'internal', 'confidential', 'restricted'],
      default: 'internal'
    }
  },
  
  // 结果信息
  result: {
    success: Boolean,
    statusCode: Number,
    message: String,
    duration: Number // 毫秒
  }
}, {
  timestamps: true
});

// 威胁检测规则模式
const threatDetectionRuleSchema = new mongoose.Schema({
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
  
  // 规则类型
  type: {
    type: String,
    enum: ['rate_limit', 'anomaly', 'signature', 'behavioral', 'ml_based'],
    required: true
  },
  
  // 威胁类型
  threatType: {
    type: String,
    enum: [
      'brute_force', 'ddos', 'sql_injection', 'xss', 'csrf',
      'account_takeover', 'data_exfiltration', 'privilege_escalation',
      'malware', 'phishing', 'bot_activity', 'suspicious_login'
    ],
    required: true
  },
  
  // 规则条件
  conditions: {
    // 时间窗口
    timeWindow: {
      value: Number,
      unit: {
        type: String,
        enum: ['seconds', 'minutes', 'hours', 'days']
      }
    },
    
    // 阈值
    threshold: {
      count: Number,
      rate: Number,
      percentage: Number
    },
    
    // 匹配条件
    matches: {
      ipAddress: [String],
      userAgent: [String],
      url: [String],
      method: [String],
      statusCode: [Number],
      headers: mongoose.Schema.Types.Mixed,
      body: mongoose.Schema.Types.Mixed
    },
    
    // 正则表达式
    patterns: [{
      field: String,
      regex: String,
      flags: String
    }],
    
    // 地理位置
    geolocation: {
      countries: [String],
      regions: [String],
      excludeCountries: [String]
    },
    
    // 用户行为
    userBehavior: {
      newUser: Boolean,
      suspiciousActivity: Boolean,
      multipleFailedLogins: Boolean,
      unusualLocation: Boolean,
      deviceChange: Boolean
    }
  },
  
  // 响应动作
  actions: [{
    type: {
      type: String,
      enum: ['block', 'challenge', 'log', 'alert', 'rate_limit', 'captcha', 'notify']
    },
    parameters: mongoose.Schema.Types.Mixed,
    delay: Number // 延迟执行（秒）
  }],
  
  // 规则配置
  severity: {
    type: String,
    enum: ['info', 'low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  
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
    triggered: {
      type: Number,
      default: 0
    },
    blocked: {
      type: Number,
      default: 0
    },
    falsePositives: {
      type: Number,
      default: 0
    },
    lastTriggered: Date,
    accuracy: {
      type: Number,
      min: 0,
      max: 1,
      default: 0
    }
  },
  
  // 创建和更新信息
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  updatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, {
  timestamps: true
});

// IP黑名单模式
const ipBlacklistSchema = new mongoose.Schema({
  ipAddress: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  
  // IP范围（CIDR格式）
  cidr: String,
  
  // 黑名单类型
  type: {
    type: String,
    enum: ['manual', 'automatic', 'threat_intelligence', 'reputation'],
    default: 'manual'
  },
  
  // 威胁级别
  threatLevel: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  
  // 原因和来源
  reason: {
    type: String,
    required: true
  },
  
  source: {
    type: String,
    enum: ['internal', 'threat_feed', 'honeypot', 'user_report', 'automated_detection'],
    default: 'internal'
  },
  
  // 地理信息
  geolocation: {
    country: String,
    region: String,
    city: String,
    isp: String,
    organization: String
  },
  
  // 威胁信息
  threatInfo: {
    categories: [String],
    malwareFamily: String,
    botnet: String,
    firstSeen: Date,
    lastSeen: Date,
    confidence: {
      type: Number,
      min: 0,
      max: 1
    }
  },
  
  // 统计信息
  statistics: {
    hitCount: {
      type: Number,
      default: 0
    },
    lastHit: Date,
    blockedRequests: {
      type: Number,
      default: 0
    }
  },
  
  // 过期时间
  expiresAt: Date,
  
  // 状态
  isActive: {
    type: Boolean,
    default: true
  },
  
  // 创建信息
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  
  // 备注
  notes: String
}, {
  timestamps: true
});

// 索引
securityEventSchema.index({ eventType: 1, createdAt: -1 });
securityEventSchema.index({ severity: 1, createdAt: -1 });
securityEventSchema.index({ 'network.ipAddress': 1, createdAt: -1 });
securityEventSchema.index({ userId: 1, createdAt: -1 });
securityEventSchema.index({ status: 1 });
securityEventSchema.index({ createdAt: -1 });

systemLogSchema.index({ level: 1, timestamp: -1 });
systemLogSchema.index({ 'source.service': 1, timestamp: -1 });
systemLogSchema.index({ 'context.userId': 1, timestamp: -1 });
systemLogSchema.index({ timestamp: -1 });

accessLogSchema.index({ userId: 1, createdAt: -1 });
accessLogSchema.index({ resource: 1, action: 1, createdAt: -1 });
accessLogSchema.index({ 'permission.granted': 1, createdAt: -1 });
accessLogSchema.index({ createdAt: -1 });

threatDetectionRuleSchema.index({ ruleId: 1 });
threatDetectionRuleSchema.index({ threatType: 1, isActive: 1 });
threatDetectionRuleSchema.index({ isActive: 1, priority: -1 });

ipBlacklistSchema.index({ ipAddress: 1 });
ipBlacklistSchema.index({ type: 1, isActive: 1 });
ipBlacklistSchema.index({ threatLevel: 1 });
ipBlacklistSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// 虚拟字段
securityEventSchema.virtual('isHighSeverity').get(function() {
  return ['high', 'critical'].includes(this.severity);
});

securityEventSchema.virtual('isResolved').get(function() {
  return ['resolved', 'false_positive', 'ignored'].includes(this.status);
});

ipBlacklistSchema.virtual('isExpired').get(function() {
  return this.expiresAt && this.expiresAt < new Date();
});

// 实例方法
securityEventSchema.methods.resolve = function(resolvedBy, resolution) {
  this.status = 'resolved';
  this.investigation.resolvedBy = resolvedBy;
  this.investigation.resolution = resolution;
  this.investigation.resolvedAt = new Date();
  return this.save();
};

securityEventSchema.methods.markAsFalsePositive = function(resolvedBy, notes) {
  this.status = 'false_positive';
  this.investigation.resolvedBy = resolvedBy;
  this.investigation.notes = notes;
  this.investigation.resolvedAt = new Date();
  return this.save();
};

securityEventSchema.methods.addRelatedEvent = function(eventId) {
  if (!this.relatedEvents.includes(eventId)) {
    this.relatedEvents.push(eventId);
    return this.save();
  }
};

ipBlacklistSchema.methods.incrementHit = function() {
  this.statistics.hitCount += 1;
  this.statistics.lastHit = new Date();
  return this.save();
};

threatDetectionRuleSchema.methods.incrementTrigger = function(blocked = false) {
  this.statistics.triggered += 1;
  if (blocked) {
    this.statistics.blocked += 1;
  }
  this.statistics.lastTriggered = new Date();
  return this.save();
};

// 静态方法
securityEventSchema.statics.findByTimeRange = function(startDate, endDate, options = {}) {
  const { eventType, severity, userId, ipAddress } = options;
  
  const query = {
    createdAt: { $gte: startDate, $lte: endDate }
  };
  
  if (eventType) query.eventType = eventType;
  if (severity) query.severity = severity;
  if (userId) query.userId = userId;
  if (ipAddress) query['network.ipAddress'] = ipAddress;
  
  return this.find(query).sort({ createdAt: -1 });
};

securityEventSchema.statics.getSecuritySummary = function(timeRange = '24h') {
  const startDate = new Date();
  switch (timeRange) {
    case '1h':
      startDate.setHours(startDate.getHours() - 1);
      break;
    case '24h':
      startDate.setDate(startDate.getDate() - 1);
      break;
    case '7d':
      startDate.setDate(startDate.getDate() - 7);
      break;
    case '30d':
      startDate.setDate(startDate.getDate() - 30);
      break;
  }
  
  return this.aggregate([
    { $match: { createdAt: { $gte: startDate } } },
    {
      $group: {
        _id: {
          eventType: '$eventType',
          severity: '$severity'
        },
        count: { $sum: 1 },
        blocked: {
          $sum: { $cond: [{ $eq: ['$response.blocked', true] }, 1, 0] }
        }
      }
    },
    { $sort: { count: -1 } }
  ]);
};

systemLogSchema.statics.findErrors = function(timeRange = '1h', limit = 100) {
  const startDate = new Date();
  startDate.setHours(startDate.getHours() - parseInt(timeRange));
  
  return this.find({
    level: { $in: ['error', 'fatal'] },
    timestamp: { $gte: startDate }
  })
  .sort({ timestamp: -1 })
  .limit(limit);
};

accessLogSchema.statics.findUnauthorizedAccess = function(timeRange = '24h') {
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - parseInt(timeRange.replace('h', '')) / 24);
  
  return this.find({
    'permission.granted': false,
    createdAt: { $gte: startDate }
  })
  .sort({ createdAt: -1 })
  .populate('userId', 'username email');
};

threatDetectionRuleSchema.statics.getActiveRules = function() {
  return this.find({ isActive: true }).sort({ priority: -1, createdAt: 1 });
};

ipBlacklistSchema.statics.isBlacklisted = function(ipAddress) {
  return this.findOne({
    $or: [
      { ipAddress },
      { cidr: { $regex: this.ipToCidrRegex(ipAddress) } }
    ],
    isActive: true,
    $or: [
      { expiresAt: null },
      { expiresAt: { $gt: new Date() } }
    ]
  });
};

// 辅助方法
ipBlacklistSchema.statics.ipToCidrRegex = function(ip) {
  // 简化的IP到CIDR匹配，实际应用中需要更复杂的逻辑
  return `^${ip.split('.').slice(0, 3).join('\\.')}\\.`;
};

const SecurityEvent = mongoose.model('SecurityEvent', securityEventSchema);
const SystemLog = mongoose.model('SystemLog', systemLogSchema);
const AccessLog = mongoose.model('AccessLog', accessLogSchema);
const ThreatDetectionRule = mongoose.model('ThreatDetectionRule', threatDetectionRuleSchema);
const IpBlacklist = mongoose.model('IpBlacklist', ipBlacklistSchema);

module.exports = {
  SecurityEvent,
  SystemLog,
  AccessLog,
  ThreatDetectionRule,
  IpBlacklist
};