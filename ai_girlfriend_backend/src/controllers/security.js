const { SecurityEvent, SystemLog, AccessLog, ThreatDetectionRule, IpBlacklist } = require('../models/Security');
const User = require('../models/User');
const mongoose = require('mongoose');
const geoip = require('geoip-lite');
const UAParser = require('ua-parser-js');

// @desc    Log security event
// @route   POST /api/security/events
// @access  Private/System
const logSecurityEvent = async (req, res) => {
  try {
    const eventData = req.body;
    
    // 生成事件ID
    eventData.eventId = `sec_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`;
    
    // 获取IP地理位置信息
    if (eventData.network && eventData.network.ipAddress) {
      const geo = geoip.lookup(eventData.network.ipAddress);
      if (geo) {
        eventData.network.country = geo.country;
        eventData.network.region = geo.region;
        eventData.network.city = geo.city;
      }
    }
    
    // 解析User-Agent
    if (eventData.request && eventData.request.userAgent) {
      const parser = new UAParser(eventData.request.userAgent);
      const result = parser.getResult();
      
      eventData.device = {
        platform: result.os.name,
        browser: result.browser.name,
        version: result.browser.version,
        isMobile: result.device.type === 'mobile'
      };
    }
    
    // 检查威胁检测规则
    const threatLevel = await evaluateThreatLevel(eventData);
    eventData.network.riskScore = threatLevel.riskScore;
    eventData.severity = threatLevel.severity;
    
    // 创建安全事件
    const securityEvent = await SecurityEvent.create(eventData);
    
    // 执行自动响应
    const response = await executeAutomaticResponse(securityEvent);
    
    res.status(201).json({
      success: true,
      data: {
        eventId: securityEvent.eventId,
        severity: securityEvent.severity,
        response
      }
    });
  } catch (error) {
    console.error('Log security event error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to log security event'
    });
  }
};

// @desc    Get security events
// @route   GET /api/security/events
// @access  Private/Admin
const getSecurityEvents = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 50,
      eventType,
      severity,
      status,
      startDate,
      endDate,
      ipAddress,
      userId
    } = req.query;

    // 构建查询条件
    const query = {};
    
    if (eventType) query.eventType = eventType;
    if (severity) query.severity = severity;
    if (status) query.status = status;
    if (ipAddress) query['network.ipAddress'] = ipAddress;
    if (userId) query.userId = userId;
    
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const events = await SecurityEvent.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username email')
      .populate('investigation.assignedTo', 'username')
      .populate('investigation.resolvedBy', 'username');

    const total = await SecurityEvent.countDocuments(query);

    res.json({
      success: true,
      data: {
        events,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get security events error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get security events'
    });
  }
};

// @desc    Get security dashboard
// @route   GET /api/security/dashboard
// @access  Private/Admin
const getSecurityDashboard = async (req, res) => {
  try {
    const { timeRange = '24h' } = req.query;
    
    // 获取时间范围
    const endDate = new Date();
    let startDate = new Date();
    
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

    // 并行获取统计数据
    const [eventSummary, topThreats, recentEvents, systemHealth] = await Promise.all([
      getEventSummary(startDate, endDate),
      getTopThreats(startDate, endDate),
      getRecentHighSeverityEvents(10),
      getSystemHealthStatus()
    ]);

    res.json({
      success: true,
      data: {
        summary: eventSummary,
        topThreats,
        recentEvents,
        systemHealth,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get security dashboard error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get security dashboard'
    });
  }
};

// @desc    Update security event status
// @route   PUT /api/security/events/:eventId
// @access  Private/Admin
const updateSecurityEvent = async (req, res) => {
  try {
    const { eventId } = req.params;
    const { status, notes, resolution } = req.body;
    const adminId = req.user._id;

    const event = await SecurityEvent.findOne({ eventId });
    if (!event) {
      return res.status(404).json({
        success: false,
        message: 'Security event not found'
      });
    }

    // 更新事件状态
    event.status = status;
    
    if (status === 'resolved') {
      await event.resolve(adminId, resolution);
    } else if (status === 'false_positive') {
      await event.markAsFalsePositive(adminId, notes);
    } else {
      event.investigation.assignedTo = adminId;
      event.investigation.notes = notes;
      await event.save();
    }

    res.json({
      success: true,
      message: 'Security event updated successfully',
      data: { event }
    });
  } catch (error) {
    console.error('Update security event error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update security event'
    });
  }
};

// @desc    Get system logs
// @route   GET /api/security/logs
// @access  Private/Admin
const getSystemLogs = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 100,
      level,
      service,
      startDate,
      endDate,
      search
    } = req.query;

    const query = {};
    
    if (level) query.level = level;
    if (service) query['source.service'] = service;
    if (search) {
      query.$or = [
        { message: { $regex: search, $options: 'i' } },
        { 'error.message': { $regex: search, $options: 'i' } }
      ];
    }
    
    if (startDate || endDate) {
      query.timestamp = {};
      if (startDate) query.timestamp.$gte = new Date(startDate);
      if (endDate) query.timestamp.$lte = new Date(endDate);
    }

    const logs = await SystemLog.find(query)
      .sort({ timestamp: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await SystemLog.countDocuments(query);

    res.json({
      success: true,
      data: {
        logs,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get system logs error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get system logs'
    });
  }
};

// @desc    Get access logs
// @route   GET /api/security/access-logs
// @access  Private/Admin
const getAccessLogs = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 100,
      userId,
      resource,
      action,
      granted,
      startDate,
      endDate
    } = req.query;

    const query = {};
    
    if (userId) query.userId = userId;
    if (resource) query.resource = resource;
    if (action) query.action = action;
    if (granted !== undefined) query['permission.granted'] = granted === 'true';
    
    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) query.createdAt.$gte = new Date(startDate);
      if (endDate) query.createdAt.$lte = new Date(endDate);
    }

    const logs = await AccessLog.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username email')
      .populate('resourceDetails.owner', 'username');

    const total = await AccessLog.countDocuments(query);

    res.json({
      success: true,
      data: {
        logs,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get access logs error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get access logs'
    });
  }
};

// @desc    Get threat detection rules
// @route   GET /api/security/threat-rules
// @access  Private/Admin
const getThreatDetectionRules = async (req, res) => {
  try {
    const { isActive, threatType } = req.query;

    const query = {};
    if (isActive !== undefined) query.isActive = isActive === 'true';
    if (threatType) query.threatType = threatType;

    const rules = await ThreatDetectionRule.find(query)
      .sort({ priority: -1, createdAt: 1 })
      .populate('createdBy', 'username')
      .populate('updatedBy', 'username');

    res.json({
      success: true,
      data: { rules }
    });
  } catch (error) {
    console.error('Get threat detection rules error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get threat detection rules'
    });
  }
};

// @desc    Create threat detection rule
// @route   POST /api/security/threat-rules
// @access  Private/Admin
const createThreatDetectionRule = async (req, res) => {
  try {
    const ruleData = req.body;
    ruleData.createdBy = req.user._id;

    const rule = await ThreatDetectionRule.create(ruleData);

    res.status(201).json({
      success: true,
      message: 'Threat detection rule created successfully',
      data: { rule }
    });
  } catch (error) {
    console.error('Create threat detection rule error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create threat detection rule'
    });
  }
};

// @desc    Get IP blacklist
// @route   GET /api/security/ip-blacklist
// @access  Private/Admin
const getIpBlacklist = async (req, res) => {
  try {
    const { page = 1, limit = 50, threatLevel, type, search } = req.query;

    const query = { isActive: true };
    
    if (threatLevel) query.threatLevel = threatLevel;
    if (type) query.type = type;
    if (search) {
      query.$or = [
        { ipAddress: { $regex: search, $options: 'i' } },
        { reason: { $regex: search, $options: 'i' } }
      ];
    }

    const blacklist = await IpBlacklist.find(query)
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('createdBy', 'username');

    const total = await IpBlacklist.countDocuments(query);

    res.json({
      success: true,
      data: {
        blacklist,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get IP blacklist error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get IP blacklist'
    });
  }
};

// @desc    Add IP to blacklist
// @route   POST /api/security/ip-blacklist
// @access  Private/Admin
const addIpToBlacklist = async (req, res) => {
  try {
    const ipData = req.body;
    ipData.createdBy = req.user._id;

    // 获取IP地理位置信息
    if (ipData.ipAddress) {
      const geo = geoip.lookup(ipData.ipAddress);
      if (geo) {
        ipData.geolocation = {
          country: geo.country,
          region: geo.region,
          city: geo.city
        };
      }
    }

    const blacklistEntry = await IpBlacklist.create(ipData);

    res.status(201).json({
      success: true,
      message: 'IP added to blacklist successfully',
      data: { blacklistEntry }
    });
  } catch (error) {
    console.error('Add IP to blacklist error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add IP to blacklist'
    });
  }
};

// @desc    Check if IP is blacklisted
// @route   GET /api/security/ip-check/:ipAddress
// @access  Private/System
const checkIpBlacklist = async (req, res) => {
  try {
    const { ipAddress } = req.params;

    const blacklistEntry = await IpBlacklist.isBlacklisted(ipAddress);

    if (blacklistEntry) {
      // 增加命中计数
      await blacklistEntry.incrementHit();
    }

    res.json({
      success: true,
      data: {
        isBlacklisted: !!blacklistEntry,
        entry: blacklistEntry
      }
    });
  } catch (error) {
    console.error('Check IP blacklist error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check IP blacklist'
    });
  }
};

// @desc    Get security statistics
// @route   GET /api/security/statistics
// @access  Private/Admin
const getSecurityStatistics = async (req, res) => {
  try {
    const { timeRange = '7d' } = req.query;
    const { startDate, endDate } = getDateRange(timeRange);

    const [eventStats, logStats, threatStats, accessStats] = await Promise.all([
      getSecurityEventStats(startDate, endDate),
      getSystemLogStats(startDate, endDate),
      getThreatStats(),
      getAccessStats(startDate, endDate)
    ]);

    res.json({
      success: true,
      data: {
        events: eventStats,
        logs: logStats,
        threats: threatStats,
        access: accessStats,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get security statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get security statistics'
    });
  }
};

// Helper functions

// 评估威胁级别
async function evaluateThreatLevel(eventData) {
  let riskScore = 0;
  let severity = 'info';

  // 基于事件类型的基础风险评分
  const eventTypeRisk = {
    'login_failure': 10,
    'brute_force': 80,
    'sql_injection': 90,
    'xss_attempt': 70,
    'ddos_attempt': 85,
    'unauthorized_access': 75,
    'suspicious_activity': 50
  };

  riskScore += eventTypeRisk[eventData.eventType] || 0;

  // 检查IP黑名单
  if (eventData.network && eventData.network.ipAddress) {
    const blacklistEntry = await IpBlacklist.isBlacklisted(eventData.network.ipAddress);
    if (blacklistEntry) {
      riskScore += 50;
    }
  }

  // 检查地理位置风险
  if (eventData.network && eventData.network.country) {
    const highRiskCountries = ['CN', 'RU', 'KP', 'IR']; // 示例高风险国家
    if (highRiskCountries.includes(eventData.network.country)) {
      riskScore += 20;
    }
  }

  // 确定严重级别
  if (riskScore >= 80) {
    severity = 'critical';
  } else if (riskScore >= 60) {
    severity = 'high';
  } else if (riskScore >= 30) {
    severity = 'medium';
  } else if (riskScore >= 10) {
    severity = 'low';
  }

  return { riskScore: Math.min(riskScore, 100), severity };
}

// 执行自动响应
async function executeAutomaticResponse(securityEvent) {
  const responses = [];

  try {
    // 获取适用的威胁检测规则
    const rules = await ThreatDetectionRule.find({
      isActive: true,
      threatType: getEventThreatType(securityEvent.eventType)
    }).sort({ priority: -1 });

    for (const rule of rules) {
      if (await evaluateRuleConditions(rule, securityEvent)) {
        // 执行规则动作
        for (const action of rule.actions) {
          const result = await executeAction(action, securityEvent);
          responses.push(result);
        }
        
        // 更新规则统计
        await rule.incrementTrigger(responses.some(r => r.blocked));
        break; // 只执行第一个匹配的规则
      }
    }
  } catch (error) {
    console.error('Automatic response error:', error);
  }

  return responses;
}

// 获取事件摘要
async function getEventSummary(startDate, endDate) {
  const summary = await SecurityEvent.aggregate([
    { $match: { createdAt: { $gte: startDate, $lte: endDate } } },
    {
      $group: {
        _id: '$severity',
        count: { $sum: 1 },
        blocked: { $sum: { $cond: [{ $eq: ['$response.blocked', true] }, 1, 0] } }
      }
    }
  ]);

  const total = summary.reduce((sum, item) => sum + item.count, 0);
  const totalBlocked = summary.reduce((sum, item) => sum + item.blocked, 0);

  return {
    total,
    totalBlocked,
    bySeverity: summary
  };
}

// 获取热门威胁
async function getTopThreats(startDate, endDate) {
  return await SecurityEvent.aggregate([
    { $match: { createdAt: { $gte: startDate, $lte: endDate } } },
    {
      $group: {
        _id: '$eventType',
        count: { $sum: 1 },
        blocked: { $sum: { $cond: [{ $eq: ['$response.blocked', true] }, 1, 0] } }
      }
    },
    { $sort: { count: -1 } },
    { $limit: 10 }
  ]);
}

// 获取最近高严重性事件
async function getRecentHighSeverityEvents(limit) {
  return await SecurityEvent.find({
    severity: { $in: ['high', 'critical'] }
  })
  .sort({ createdAt: -1 })
  .limit(limit)
  .populate('userId', 'username');
}

// 获取系统健康状态
async function getSystemHealthStatus() {
  const now = new Date();
  const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

  const [errorCount, criticalEvents, activeThreats] = await Promise.all([
    SystemLog.countDocuments({
      level: { $in: ['error', 'fatal'] },
      timestamp: { $gte: oneHourAgo }
    }),
    SecurityEvent.countDocuments({
      severity: 'critical',
      createdAt: { $gte: oneHourAgo }
    }),
    IpBlacklist.countDocuments({
      isActive: true,
      threatLevel: { $in: ['high', 'critical'] }
    })
  ]);

  let status = 'healthy';
  if (criticalEvents > 0 || errorCount > 10) {
    status = 'critical';
  } else if (errorCount > 5 || activeThreats > 100) {
    status = 'warning';
  }

  return {
    status,
    errorCount,
    criticalEvents,
    activeThreats
  };
}

// 获取日期范围
function getDateRange(timeRange) {
  const endDate = new Date();
  let startDate = new Date();
  
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
  
  return { startDate, endDate };
}

// 辅助函数（占位符）
function getEventThreatType(eventType) {
  const mapping = {
    'login_failure': 'brute_force',
    'sql_injection': 'sql_injection',
    'xss_attempt': 'xss',
    'ddos_attempt': 'ddos'
  };
  return mapping[eventType] || 'suspicious_login';
}

async function evaluateRuleConditions(rule, event) {
  // 简化的规则评估逻辑
  return true;
}

async function executeAction(action, event) {
  // 简化的动作执行逻辑
  return { type: action.type, executed: true, blocked: action.type === 'block' };
}

// 统计函数（占位符）
async function getSecurityEventStats() { return {}; }
async function getSystemLogStats() { return {}; }
async function getThreatStats() { return {}; }
async function getAccessStats() { return {}; }

module.exports = {
  logSecurityEvent,
  getSecurityEvents,
  getSecurityDashboard,
  updateSecurityEvent,
  getSystemLogs,
  getAccessLogs,
  getThreatDetectionRules,
  createThreatDetectionRule,
  getIpBlacklist,
  addIpToBlacklist,
  checkIpBlacklist,
  getSecurityStatistics
};