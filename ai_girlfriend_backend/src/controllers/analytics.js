const { UserBehavior, SystemMetrics, ReportConfig, ReportExecution, DataExport } = require('../models/Analytics');
const User = require('../models/User');
const Character = require('../models/Character');
const { ChatMessage, Conversation } = require('../models/Chat');
const { Order } = require('../models/Payment');
const mongoose = require('mongoose');

// @desc    Get dashboard analytics
// @route   GET /api/analytics/dashboard
// @access  Private/Admin
const getDashboardAnalytics = async (req, res) => {
  try {
    const { timeRange = '7d' } = req.query;
    
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
      case '90d':
        startDate = new Date(endDate.getTime() - 90 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
    }

    // 并行获取各种统计数据
    const [userStats, conversationStats, messageStats, revenueStats, systemHealth] = await Promise.all([
      getUserStats(startDate, endDate),
      getConversationStats(startDate, endDate),
      getMessageStats(startDate, endDate),
      getRevenueStats(startDate, endDate),
      getSystemHealth()
    ]);

    // 获取趋势数据
    const trends = await getTrendData(startDate, endDate, timeRange);

    res.json({
      success: true,
      data: {
        overview: {
          users: userStats,
          conversations: conversationStats,
          messages: messageStats,
          revenue: revenueStats,
          system: systemHealth
        },
        trends,
        timeRange,
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get dashboard analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard analytics'
    });
  }
};

// @desc    Get user behavior analytics
// @route   GET /api/analytics/users
// @access  Private/Admin
const getUserAnalytics = async (req, res) => {
  try {
    const { 
      timeRange = '30d', 
      groupBy = 'day',
      segment,
      page = 1,
      limit = 100
    } = req.query;

    const { startDate, endDate } = getDateRange(timeRange);

    // 用户行为聚合数据
    const behaviorData = await UserBehavior.aggregateMetrics(startDate, endDate, groupBy);

    // 用户分群分析
    const segmentAnalysis = await getUserSegmentAnalysis(startDate, endDate, segment);

    // 用户留存分析
    const retentionData = await getUserRetentionAnalysis(startDate, endDate);

    // 活跃用户分析
    const activeUserData = await getActiveUserAnalysis(startDate, endDate);

    res.json({
      success: true,
      data: {
        behaviorTrends: behaviorData,
        segmentAnalysis,
        retention: retentionData,
        activeUsers: activeUserData,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get user analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user analytics'
    });
  }
};

// @desc    Get system performance analytics
// @route   GET /api/analytics/system
// @access  Private/Admin
const getSystemAnalytics = async (req, res) => {
  try {
    const { timeRange = '24h', interval = '1h' } = req.query;
    const { startDate, endDate } = getDateRange(timeRange);

    // 系统性能时序数据
    const performanceData = await SystemMetrics.getTimeSeriesData(startDate, endDate, interval);

    // 最新系统指标
    const latestMetrics = await SystemMetrics.getLatestMetrics();

    // API端点性能分析
    const apiAnalysis = await getAPIPerformanceAnalysis(startDate, endDate);

    // 数据库性能分析
    const dbAnalysis = await getDatabasePerformanceAnalysis(startDate, endDate);

    // 错误率分析
    const errorAnalysis = await getErrorRateAnalysis(startDate, endDate);

    res.json({
      success: true,
      data: {
        timeSeries: performanceData,
        current: latestMetrics,
        apiPerformance: apiAnalysis,
        databasePerformance: dbAnalysis,
        errorAnalysis,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get system analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get system analytics'
    });
  }
};

// @desc    Get business metrics analytics
// @route   GET /api/analytics/business
// @access  Private/Admin
const getBusinessAnalytics = async (req, res) => {
  try {
    const { timeRange = '30d', groupBy = 'day' } = req.query;
    const { startDate, endDate } = getDateRange(timeRange);

    // 收入分析
    const revenueAnalysis = await getDetailedRevenueAnalysis(startDate, endDate, groupBy);

    // 转化漏斗分析
    const funnelAnalysis = await getConversionFunnelAnalysis(startDate, endDate);

    // 用户生命周期价值
    const ltv = await getUserLifetimeValueAnalysis(startDate, endDate);

    // 产品使用分析
    const productUsage = await getProductUsageAnalysis(startDate, endDate);

    // 会员分析
    const membershipAnalysis = await getMembershipAnalysis(startDate, endDate);

    res.json({
      success: true,
      data: {
        revenue: revenueAnalysis,
        conversionFunnel: funnelAnalysis,
        lifetimeValue: ltv,
        productUsage,
        membership: membershipAnalysis,
        timeRange: { startDate, endDate },
        generatedAt: new Date()
      }
    });
  } catch (error) {
    console.error('Get business analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get business analytics'
    });
  }
};

// @desc    Create custom report
// @route   POST /api/analytics/reports
// @access  Private/Admin
const createReport = async (req, res) => {
  try {
    const reportData = req.body;
    reportData.createdBy = req.user._id;

    const report = await ReportConfig.create(reportData);

    res.status(201).json({
      success: true,
      message: 'Report created successfully',
      data: {
        report
      }
    });
  } catch (error) {
    console.error('Create report error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create report'
    });
  }
};

// @desc    Get reports list
// @route   GET /api/analytics/reports
// @access  Private/Admin
const getReports = async (req, res) => {
  try {
    const { type, page = 1, limit = 20 } = req.query;
    const userId = req.user._id;
    const userRoles = req.user.roles || ['viewer'];

    let reports;
    if (type) {
      reports = await ReportConfig.findByType(type);
    } else {
      reports = await ReportConfig.findAccessibleReports(userId, userRoles);
    }

    const total = reports.length;
    const paginatedReports = reports.slice((page - 1) * limit, page * limit);

    res.json({
      success: true,
      data: {
        reports: paginatedReports,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get reports'
    });
  }
};

// @desc    Execute report
// @route   POST /api/analytics/reports/:reportId/execute
// @access  Private/Admin
const executeReport = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { parameters = {} } = req.body;
    const userId = req.user._id;

    const report = await ReportConfig.findOne({ reportId, isActive: true });
    if (!report) {
      return res.status(404).json({
        success: false,
        message: 'Report not found'
      });
    }

    // 创建执行记录
    const execution = await ReportExecution.create({
      reportId,
      executionId: `exec_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`,
      parameters: {
        ...parameters,
        requestedBy: userId
      }
    });

    // 异步执行报表
    executeReportAsync(execution, report);

    res.status(202).json({
      success: true,
      message: 'Report execution started',
      data: {
        executionId: execution.executionId,
        status: execution.status
      }
    });
  } catch (error) {
    console.error('Execute report error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to execute report'
    });
  }
};

// @desc    Get report execution status
// @route   GET /api/analytics/reports/executions/:executionId
// @access  Private/Admin
const getReportExecution = async (req, res) => {
  try {
    const { executionId } = req.params;

    const execution = await ReportExecution.findOne({ executionId })
      .populate('parameters.requestedBy', 'username email');

    if (!execution) {
      return res.status(404).json({
        success: false,
        message: 'Report execution not found'
      });
    }

    res.json({
      success: true,
      data: {
        execution
      }
    });
  } catch (error) {
    console.error('Get report execution error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get report execution'
    });
  }
};

// @desc    Create data export
// @route   POST /api/analytics/export
// @access  Private/Admin
const createDataExport = async (req, res) => {
  try {
    const exportConfig = req.body;
    const userId = req.user._id;

    const dataExport = await DataExport.create({
      exportId: `export_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`,
      config: exportConfig,
      requestedBy: userId
    });

    // 异步处理导出
    processDataExportAsync(dataExport);

    res.status(202).json({
      success: true,
      message: 'Data export started',
      data: {
        exportId: dataExport.exportId,
        status: dataExport.status
      }
    });
  } catch (error) {
    console.error('Create data export error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create data export'
    });
  }
};

// @desc    Get data export status
// @route   GET /api/analytics/export/:exportId
// @access  Private/Admin
const getDataExport = async (req, res) => {
  try {
    const { exportId } = req.params;
    const userId = req.user._id;

    const dataExport = await DataExport.findOne({
      exportId,
      requestedBy: userId
    });

    if (!dataExport) {
      return res.status(404).json({
        success: false,
        message: 'Data export not found'
      });
    }

    res.json({
      success: true,
      data: {
        export: dataExport
      }
    });
  } catch (error) {
    console.error('Get data export error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get data export'
    });
  }
};

// Helper functions

// 获取用户统计数据
async function getUserStats(startDate, endDate) {
  const [totalUsers, newUsers, activeUsers, memberUsers] = await Promise.all([
    User.countDocuments({ isActive: true }),
    User.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
      isActive: true
    }),
    User.countDocuments({
      'statistics.lastActiveAt': { $gte: startDate },
      isActive: true
    }),
    User.countDocuments({
      membershipType: { $ne: 'free' },
      isActive: true
    })
  ]);

  return {
    total: totalUsers,
    new: newUsers,
    active: activeUsers,
    members: memberUsers,
    membershipRate: totalUsers > 0 ? (memberUsers / totalUsers * 100).toFixed(2) : 0
  };
}

// 获取对话统计数据
async function getConversationStats(startDate, endDate) {
  const [totalConversations, newConversations, activeConversations] = await Promise.all([
    Conversation.countDocuments({ 'settings.isActive': true }),
    Conversation.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
      'settings.isActive': true
    }),
    Conversation.countDocuments({
      'statistics.lastMessageAt': { $gte: startDate },
      'settings.isActive': true
    })
  ]);

  return {
    total: totalConversations,
    new: newConversations,
    active: activeConversations
  };
}

// 获取消息统计数据
async function getMessageStats(startDate, endDate) {
  const [totalMessages, newMessages] = await Promise.all([
    ChatMessage.countDocuments({ isDeleted: false }),
    ChatMessage.countDocuments({
      createdAt: { $gte: startDate, $lte: endDate },
      isDeleted: false
    })
  ]);

  return {
    total: totalMessages,
    new: newMessages
  };
}

// 获取收入统计数据
async function getRevenueStats(startDate, endDate) {
  const revenueData = await Order.aggregate([
    {
      $match: {
        status: 'completed',
        'paymentDetails.paidAt': { $gte: startDate, $lte: endDate }
      }
    },
    {
      $group: {
        _id: null,
        totalRevenue: { $sum: '$amount.final' },
        orderCount: { $sum: 1 },
        avgOrderValue: { $avg: '$amount.final' }
      }
    }
  ]);

  const result = revenueData[0] || {
    totalRevenue: 0,
    orderCount: 0,
    avgOrderValue: 0
  };

  return {
    total: result.totalRevenue,
    orders: result.orderCount,
    averageOrderValue: result.avgOrderValue
  };
}

// 获取系统健康状态
async function getSystemHealth() {
  const latestMetrics = await SystemMetrics.getLatestMetrics();
  
  if (!latestMetrics) {
    return {
      status: 'unknown',
      uptime: process.uptime(),
      memory: process.memoryUsage(),
      cpu: { usage: 0 }
    };
  }

  return {
    status: 'healthy',
    uptime: process.uptime(),
    memory: latestMetrics.system.memory,
    cpu: latestMetrics.system.cpu,
    api: {
      responseTime: latestMetrics.api.avgResponseTime,
      errorRate: latestMetrics.api.failedRequests / latestMetrics.api.totalRequests * 100
    }
  };
}

// 获取趋势数据
async function getTrendData(startDate, endDate, timeRange) {
  const groupBy = timeRange === '24h' ? 'hour' : 'day';
  
  const userTrends = await UserBehavior.aggregateMetrics(startDate, endDate, groupBy);
  
  return {
    users: userTrends,
    groupBy
  };
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
    case '90d':
      startDate = new Date(endDate.getTime() - 90 * 24 * 60 * 60 * 1000);
      break;
    case '1y':
      startDate = new Date(endDate.getTime() - 365 * 24 * 60 * 60 * 1000);
      break;
    default:
      startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
  }
  
  return { startDate, endDate };
}

// 异步执行报表（简化版）
async function executeReportAsync(execution, report) {
  try {
    await execution.markAsRunning();
    
    // 模拟报表执行
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const mockResult = {
      data: [
        { date: '2024-01-01', users: 100, revenue: 1000 },
        { date: '2024-01-02', users: 120, revenue: 1200 }
      ],
      rowCount: 2,
      executionTime: 2000
    };
    
    await execution.markAsCompleted(mockResult);
  } catch (error) {
    await execution.markAsFailed({
      message: error.message,
      code: 'EXECUTION_ERROR'
    });
  }
}

// 异步处理数据导出（简化版）
async function processDataExportAsync(dataExport) {
  try {
    dataExport.status = 'processing';
    dataExport.startedAt = new Date();
    await dataExport.save();
    
    // 模拟数据导出处理
    await dataExport.updateProgress(0, 100, 'Starting export...');
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await dataExport.updateProgress(50, 100, 'Processing data...');
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await dataExport.updateProgress(100, 100, 'Export completed');
    
    await dataExport.markAsCompleted({
      fileUrl: '/exports/sample_export.csv',
      fileName: 'sample_export.csv',
      fileSize: 1024,
      recordCount: 100
    });
  } catch (error) {
    dataExport.status = 'failed';
    dataExport.error = {
      message: error.message,
      code: 'EXPORT_ERROR'
    };
    await dataExport.save();
  }
}

// 占位符函数（待实现）
async function getUserSegmentAnalysis() { return {}; }
async function getUserRetentionAnalysis() { return {}; }
async function getActiveUserAnalysis() { return {}; }
async function getAPIPerformanceAnalysis() { return {}; }
async function getDatabasePerformanceAnalysis() { return {}; }
async function getErrorRateAnalysis() { return {}; }
async function getDetailedRevenueAnalysis() { return {}; }
async function getConversionFunnelAnalysis() { return {}; }
async function getUserLifetimeValueAnalysis() { return {}; }
async function getProductUsageAnalysis() { return {}; }
async function getMembershipAnalysis() { return {}; }

module.exports = {
  getDashboardAnalytics,
  getUserAnalytics,
  getSystemAnalytics,
  getBusinessAnalytics,
  createReport,
  getReports,
  executeReport,
  getReportExecution,
  createDataExport,
  getDataExport
};