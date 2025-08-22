const mongoose = require('mongoose');

// 用户行为分析模式
const userBehaviorSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  date: {
    type: Date,
    required: true,
    index: true
  },
  metrics: {
    // 登录相关
    loginCount: {
      type: Number,
      default: 0
    },
    sessionDuration: {
      type: Number, // 总会话时长（分钟）
      default: 0
    },
    
    // 聊天相关
    conversationsStarted: {
      type: Number,
      default: 0
    },
    messagesSent: {
      type: Number,
      default: 0
    },
    messagesReceived: {
      type: Number,
      default: 0
    },
    avgMessageLength: {
      type: Number,
      default: 0
    },
    
    // 角色相关
    charactersCreated: {
      type: Number,
      default: 0
    },
    charactersInteracted: {
      type: Number,
      default: 0
    },
    
    // 知识库相关
    knowledgeBasesCreated: {
      type: Number,
      default: 0
    },
    knowledgeItemsAdded: {
      type: Number,
      default: 0
    },
    
    // 支付相关
    ordersCreated: {
      type: Number,
      default: 0
    },
    totalSpent: {
      type: Number,
      default: 0
    },
    
    // 功能使用
    featuresUsed: [{
      feature: String,
      count: Number
    }]
  },
  
  // 设备和环境信息
  deviceInfo: {
    platform: String, // 'web', 'mobile', 'desktop'
    browser: String,
    os: String,
    screenResolution: String,
    language: String,
    timezone: String
  },
  
  // 地理位置信息（匿名化）
  location: {
    country: String,
    region: String,
    city: String
  }
}, {
  timestamps: true
});

// 系统性能指标模式
const systemMetricsSchema = new mongoose.Schema({
  timestamp: {
    type: Date,
    required: true,
    index: true
  },
  
  // API性能指标
  api: {
    totalRequests: {
      type: Number,
      default: 0
    },
    successfulRequests: {
      type: Number,
      default: 0
    },
    failedRequests: {
      type: Number,
      default: 0
    },
    avgResponseTime: {
      type: Number, // 毫秒
      default: 0
    },
    p95ResponseTime: {
      type: Number,
      default: 0
    },
    p99ResponseTime: {
      type: Number,
      default: 0
    },
    
    // 按端点分组的指标
    endpoints: [{
      path: String,
      method: String,
      requests: Number,
      avgResponseTime: Number,
      errorRate: Number
    }]
  },
  
  // 数据库性能
  database: {
    connections: {
      active: Number,
      idle: Number,
      total: Number
    },
    queries: {
      total: Number,
      slow: Number, // 慢查询数量
      avgExecutionTime: Number
    },
    collections: [{
      name: String,
      documentCount: Number,
      avgDocumentSize: Number,
      indexCount: Number
    }]
  },
  
  // 系统资源
  system: {
    cpu: {
      usage: Number, // 百分比
      loadAverage: [Number] // 1分钟、5分钟、15分钟负载
    },
    memory: {
      used: Number, // MB
      free: Number,
      total: Number,
      usage: Number // 百分比
    },
    disk: {
      used: Number, // GB
      free: Number,
      total: Number,
      usage: Number // 百分比
    }
  },
  
  // 业务指标
  business: {
    activeUsers: {
      type: Number,
      default: 0
    },
    newUsers: {
      type: Number,
      default: 0
    },
    totalConversations: {
      type: Number,
      default: 0
    },
    totalMessages: {
      type: Number,
      default: 0
    },
    revenue: {
      type: Number,
      default: 0
    }
  }
}, {
  timestamps: true
});

// 报表配置模式
const reportConfigSchema = new mongoose.Schema({
  reportId: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  description: String,
  
  // 报表类型
  type: {
    type: String,
    enum: ['user_behavior', 'system_performance', 'business_metrics', 'custom'],
    required: true
  },
  
  // 数据源配置
  dataSource: {
    collections: [String], // 数据来源集合
    timeRange: {
      type: String,
      enum: ['1h', '24h', '7d', '30d', '90d', '1y', 'custom'],
      default: '24h'
    },
    filters: mongoose.Schema.Types.Mixed,
    aggregation: mongoose.Schema.Types.Mixed
  },
  
  // 图表配置
  visualization: {
    chartType: {
      type: String,
      enum: ['line', 'bar', 'pie', 'area', 'scatter', 'heatmap', 'table'],
      default: 'line'
    },
    dimensions: [String], // X轴维度
    metrics: [String], // Y轴指标
    colors: [String],
    options: mongoose.Schema.Types.Mixed
  },
  
  // 调度配置
  schedule: {
    enabled: {
      type: Boolean,
      default: false
    },
    frequency: {
      type: String,
      enum: ['hourly', 'daily', 'weekly', 'monthly']
    },
    time: String, // HH:MM格式
    timezone: {
      type: String,
      default: 'Asia/Shanghai'
    },
    recipients: [String] // 邮箱列表
  },
  
  // 权限配置
  access: {
    public: {
      type: Boolean,
      default: false
    },
    roles: [{
      type: String,
      enum: ['admin', 'analyst', 'manager', 'viewer']
    }],
    users: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }]
  },
  
  // 缓存配置
  cache: {
    enabled: {
      type: Boolean,
      default: true
    },
    ttl: {
      type: Number, // 秒
      default: 3600
    }
  },
  
  isActive: {
    type: Boolean,
    default: true
  },
  
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true
});

// 报表执行历史模式
const reportExecutionSchema = new mongoose.Schema({
  reportId: {
    type: String,
    required: true,
    index: true
  },
  
  executionId: {
    type: String,
    required: true,
    unique: true
  },
  
  // 执行参数
  parameters: {
    timeRange: {
      start: Date,
      end: Date
    },
    filters: mongoose.Schema.Types.Mixed,
    requestedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }
  },
  
  // 执行状态
  status: {
    type: String,
    enum: ['pending', 'running', 'completed', 'failed', 'cancelled'],
    default: 'pending'
  },
  
  // 执行结果
  result: {
    data: mongoose.Schema.Types.Mixed,
    rowCount: Number,
    executionTime: Number, // 毫秒
    cacheHit: {
      type: Boolean,
      default: false
    }
  },
  
  // 错误信息
  error: {
    message: String,
    stack: String,
    code: String
  },
  
  // 执行时间
  startedAt: Date,
  completedAt: Date
}, {
  timestamps: true
});

// 数据导出任务模式
const dataExportSchema = new mongoose.Schema({
  exportId: {
    type: String,
    required: true,
    unique: true
  },
  
  // 导出配置
  config: {
    type: {
      type: String,
      enum: ['user_data', 'chat_history', 'analytics', 'system_logs', 'custom'],
      required: true
    },
    format: {
      type: String,
      enum: ['csv', 'json', 'xlsx', 'pdf'],
      default: 'csv'
    },
    compression: {
      type: String,
      enum: ['none', 'zip', 'gzip'],
      default: 'zip'
    },
    
    // 数据范围
    dateRange: {
      start: Date,
      end: Date
    },
    filters: mongoose.Schema.Types.Mixed,
    
    // 字段选择
    fields: [String],
    includeDeleted: {
      type: Boolean,
      default: false
    }
  },
  
  // 请求信息
  requestedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // 执行状态
  status: {
    type: String,
    enum: ['queued', 'processing', 'completed', 'failed', 'expired'],
    default: 'queued'
  },
  
  // 进度信息
  progress: {
    current: {
      type: Number,
      default: 0
    },
    total: {
      type: Number,
      default: 0
    },
    percentage: {
      type: Number,
      default: 0
    },
    message: String
  },
  
  // 结果信息
  result: {
    fileUrl: String,
    fileName: String,
    fileSize: Number, // 字节
    recordCount: Number,
    expiresAt: Date // 文件过期时间
  },
  
  // 错误信息
  error: {
    message: String,
    code: String
  },
  
  // 时间戳
  startedAt: Date,
  completedAt: Date
}, {
  timestamps: true
});

// 索引
userBehaviorSchema.index({ userId: 1, date: -1 });
userBehaviorSchema.index({ date: -1 });

systemMetricsSchema.index({ timestamp: -1 });

reportConfigSchema.index({ reportId: 1 });
reportConfigSchema.index({ type: 1 });
reportConfigSchema.index({ isActive: 1 });
reportConfigSchema.index({ createdBy: 1 });

reportExecutionSchema.index({ reportId: 1, createdAt: -1 });
reportExecutionSchema.index({ status: 1 });
reportExecutionSchema.index({ executionId: 1 });

dataExportSchema.index({ exportId: 1 });
dataExportSchema.index({ requestedBy: 1, createdAt: -1 });
dataExportSchema.index({ status: 1 });
dataExportSchema.index({ 'result.expiresAt': 1 }, { expireAfterSeconds: 0 });

// 虚拟字段
reportExecutionSchema.virtual('duration').get(function() {
  if (this.startedAt && this.completedAt) {
    return this.completedAt - this.startedAt;
  }
  return null;
});

dataExportSchema.virtual('isExpired').get(function() {
  return this.result.expiresAt && this.result.expiresAt < new Date();
});

// 实例方法
userBehaviorSchema.methods.incrementMetric = function(metricName, value = 1) {
  if (this.metrics[metricName] !== undefined) {
    this.metrics[metricName] += value;
  }
  return this.save();
};

reportExecutionSchema.methods.markAsRunning = function() {
  this.status = 'running';
  this.startedAt = new Date();
  return this.save();
};

reportExecutionSchema.methods.markAsCompleted = function(result) {
  this.status = 'completed';
  this.completedAt = new Date();
  this.result = result;
  return this.save();
};

reportExecutionSchema.methods.markAsFailed = function(error) {
  this.status = 'failed';
  this.completedAt = new Date();
  this.error = error;
  return this.save();
};

dataExportSchema.methods.updateProgress = function(current, total, message) {
  this.progress.current = current;
  this.progress.total = total;
  this.progress.percentage = total > 0 ? Math.round((current / total) * 100) : 0;
  if (message) this.progress.message = message;
  return this.save();
};

dataExportSchema.methods.markAsCompleted = function(result) {
  this.status = 'completed';
  this.completedAt = new Date();
  this.result = {
    ...result,
    expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7天后过期
  };
  this.progress.percentage = 100;
  return this.save();
};

// 静态方法
userBehaviorSchema.statics.getDateRangeData = function(userId, startDate, endDate) {
  return this.find({
    userId,
    date: {
      $gte: startDate,
      $lte: endDate
    }
  }).sort({ date: 1 });
};

userBehaviorSchema.statics.aggregateMetrics = function(startDate, endDate, groupBy = 'day') {
  const groupFormat = {
    day: '%Y-%m-%d',
    week: '%Y-%U',
    month: '%Y-%m',
    year: '%Y'
  };
  
  return this.aggregate([
    {
      $match: {
        date: {
          $gte: startDate,
          $lte: endDate
        }
      }
    },
    {
      $group: {
        _id: {
          $dateToString: {
            format: groupFormat[groupBy],
            date: '$date'
          }
        },
        totalUsers: { $addToSet: '$userId' },
        totalLogins: { $sum: '$metrics.loginCount' },
        totalMessages: { $sum: '$metrics.messagesSent' },
        totalConversations: { $sum: '$metrics.conversationsStarted' },
        totalRevenue: { $sum: '$metrics.totalSpent' }
      }
    },
    {
      $project: {
        _id: 1,
        totalUsers: { $size: '$totalUsers' },
        totalLogins: 1,
        totalMessages: 1,
        totalConversations: 1,
        totalRevenue: 1
      }
    },
    { $sort: { _id: 1 } }
  ]);
};

systemMetricsSchema.statics.getLatestMetrics = function() {
  return this.findOne().sort({ timestamp: -1 });
};

systemMetricsSchema.statics.getTimeSeriesData = function(startDate, endDate, interval = '1h') {
  const intervalMs = {
    '5m': 5 * 60 * 1000,
    '15m': 15 * 60 * 1000,
    '1h': 60 * 60 * 1000,
    '6h': 6 * 60 * 60 * 1000,
    '1d': 24 * 60 * 60 * 1000
  };
  
  return this.aggregate([
    {
      $match: {
        timestamp: {
          $gte: startDate,
          $lte: endDate
        }
      }
    },
    {
      $group: {
        _id: {
          $toDate: {
            $subtract: [
              { $toLong: '$timestamp' },
              { $mod: [{ $toLong: '$timestamp' }, intervalMs[interval]] }
            ]
          }
        },
        avgResponseTime: { $avg: '$api.avgResponseTime' },
        totalRequests: { $sum: '$api.totalRequests' },
        errorRate: {
          $avg: {
            $divide: ['$api.failedRequests', '$api.totalRequests']
          }
        },
        cpuUsage: { $avg: '$system.cpu.usage' },
        memoryUsage: { $avg: '$system.memory.usage' }
      }
    },
    { $sort: { _id: 1 } }
  ]);
};

reportConfigSchema.statics.findByType = function(type) {
  return this.find({ type, isActive: true }).sort({ name: 1 });
};

reportConfigSchema.statics.findAccessibleReports = function(userId, roles = []) {
  return this.find({
    isActive: true,
    $or: [
      { 'access.public': true },
      { 'access.users': userId },
      { 'access.roles': { $in: roles } }
    ]
  }).sort({ name: 1 });
};

const UserBehavior = mongoose.model('UserBehavior', userBehaviorSchema);
const SystemMetrics = mongoose.model('SystemMetrics', systemMetricsSchema);
const ReportConfig = mongoose.model('ReportConfig', reportConfigSchema);
const ReportExecution = mongoose.model('ReportExecution', reportExecutionSchema);
const DataExport = mongoose.model('DataExport', dataExportSchema);

module.exports = {
  UserBehavior,
  SystemMetrics,
  ReportConfig,
  ReportExecution,
  DataExport
};