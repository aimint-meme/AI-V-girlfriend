const User = require('../models/User');
const Character = require('../models/Character');
const { ChatMessage, Conversation } = require('../models/Chat');
const mongoose = require('mongoose');

// @desc    Get dashboard statistics
// @route   GET /api/admin/dashboard/stats
// @access  Private/Admin
const getDashboardStats = async (req, res) => {
  try {
    const today = new Date();
    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const lastWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);
    const lastMonth = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

    // User statistics
    const totalUsers = await User.countDocuments({ isActive: true });
    const newUsersToday = await User.countDocuments({
      createdAt: { $gte: yesterday },
      isActive: true
    });
    const activeUsersWeek = await User.countDocuments({
      'statistics.lastActiveAt': { $gte: lastWeek },
      isActive: true
    });

    // Character statistics
    const totalCharacters = await Character.countDocuments({ 'settings.isActive': true });
    const newCharactersToday = await Character.countDocuments({
      createdAt: { $gte: yesterday },
      'settings.isActive': true
    });

    // Conversation statistics
    const totalConversations = await Conversation.countDocuments({ 'settings.isActive': true });
    const activeConversationsToday = await Conversation.countDocuments({
      'statistics.lastMessageAt': { $gte: yesterday },
      'settings.isActive': true
    });

    // Message statistics
    const totalMessages = await ChatMessage.countDocuments({ isDeleted: false });
    const messagesToday = await ChatMessage.countDocuments({
      createdAt: { $gte: yesterday },
      isDeleted: false
    });

    // Revenue statistics (mock data - implement based on your payment system)
    const revenue = {
      today: 1250.50,
      week: 8750.25,
      month: 35420.75,
      total: 125680.90
    };

    // System health
    const systemHealth = {
      status: 'healthy',
      uptime: process.uptime(),
      memoryUsage: process.memoryUsage(),
      cpuUsage: process.cpuUsage()
    };

    res.json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          newToday: newUsersToday,
          activeWeek: activeUsersWeek
        },
        characters: {
          total: totalCharacters,
          newToday: newCharactersToday
        },
        conversations: {
          total: totalConversations,
          activeToday: activeConversationsToday
        },
        messages: {
          total: totalMessages,
          today: messagesToday
        },
        revenue,
        systemHealth
      }
    });
  } catch (error) {
    console.error('Get dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard statistics'
    });
  }
};

// @desc    Get analytics data
// @route   GET /api/admin/dashboard/analytics
// @access  Private/Admin
const getAnalytics = async (req, res) => {
  try {
    const { period = '7d' } = req.query;
    
    let startDate;
    switch (period) {
      case '24h':
        startDate = new Date(Date.now() - 24 * 60 * 60 * 1000);
        break;
      case '7d':
        startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        break;
      case '30d':
        startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
        break;
      case '90d':
        startDate = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    }

    // User growth analytics
    const userGrowth = await User.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          isActive: true
        }
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt'
            }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Message volume analytics
    const messageVolume = await ChatMessage.aggregate([
      {
        $match: {
          createdAt: { $gte: startDate },
          isDeleted: false
        }
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt'
            }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Popular characters
    const popularCharacters = await Character.aggregate([
      {
        $match: {
          'settings.isActive': true
        }
      },
      {
        $sort: {
          'statistics.totalMessages': -1
        }
      },
      {
        $limit: 10
      },
      {
        $project: {
          name: 1,
          'statistics.totalMessages': 1,
          'statistics.totalConversations': 1
        }
      }
    ]);

    res.json({
      success: true,
      data: {
        userGrowth,
        messageVolume,
        popularCharacters
      }
    });
  } catch (error) {
    console.error('Get analytics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get analytics data'
    });
  }
};

// @desc    Get all users
// @route   GET /api/admin/users
// @access  Private/Admin
const getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, membershipType, status } = req.query;

    const query = {};
    
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (membershipType && membershipType !== 'all') {
      query.membershipType = membershipType;
    }
    
    if (status && status !== 'all') {
      query.isActive = status === 'active';
    }

    const users = await User.find(query)
      .select('-password -refreshTokens')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await User.countDocuments(query);

    res.json({
      success: true,
      data: {
        users,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
};

// @desc    Get user by ID
// @route   GET /api/admin/users/:userId
// @access  Private/Admin
const getUserById = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId).select('-password -refreshTokens');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's characters
    const characters = await Character.find({ userId }).select('name avatar statistics');

    // Get user's conversations
    const conversations = await Conversation.find({ 'participants.user': userId })
      .populate('participants.character', 'name avatar')
      .sort({ 'statistics.lastMessageAt': -1 })
      .limit(10);

    // Get recent messages
    const recentMessages = await ChatMessage.find({ userId, isDeleted: false })
      .populate('characterId', 'name avatar')
      .sort({ createdAt: -1 })
      .limit(20);

    res.json({
      success: true,
      data: {
        user,
        characters,
        conversations,
        recentMessages
      }
    });
  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user'
    });
  }
};

// @desc    Update user
// @route   PUT /api/admin/users/:userId
// @access  Private/Admin
const updateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const updateData = req.body;

    // Remove sensitive fields
    delete updateData.password;
    delete updateData.refreshTokens;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    ).select('-password -refreshTokens');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'User updated successfully',
      data: { user }
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user'
    });
  }
};

// @desc    Delete user
// @route   DELETE /api/admin/users/:userId
// @access  Private/Admin
const deleteUser = async (req, res) => {
  try {
    const { userId } = req.params;

    // Soft delete - deactivate user
    const user = await User.findByIdAndUpdate(
      userId,
      { 
        isActive: false,
        refreshTokens: []
      },
      { new: true }
    ).select('-password -refreshTokens');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Deactivate user's characters
    await Character.updateMany(
      { userId },
      { 'settings.isActive': false }
    );

    res.json({
      success: true,
      message: 'User deactivated successfully'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete user'
    });
  }
};

// @desc    Toggle user status
// @route   PUT /api/admin/users/:userId/status
// @access  Private/Admin
const toggleUserStatus = async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.isActive = !user.isActive;
    if (!user.isActive) {
      user.refreshTokens = []; // Force logout
    }
    await user.save();

    res.json({
      success: true,
      message: `User ${user.isActive ? 'activated' : 'deactivated'} successfully`,
      data: {
        isActive: user.isActive
      }
    });
  } catch (error) {
    console.error('Toggle user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to toggle user status'
    });
  }
};

// @desc    Get user activity
// @route   GET /api/admin/users/:userId/activity
// @access  Private/Admin
const getUserActivity = async (req, res) => {
  try {
    const { userId } = req.params;
    const { days = 30 } = req.query;

    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    // Get daily message counts
    const dailyActivity = await ChatMessage.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          createdAt: { $gte: startDate },
          isDeleted: false
        }
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$createdAt'
            }
          },
          messageCount: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      success: true,
      data: {
        dailyActivity
      }
    });
  } catch (error) {
    console.error('Get user activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user activity'
    });
  }
};

// Placeholder functions for other admin operations
const getCharacters = async (req, res) => {
  res.json({ success: true, message: 'Get characters - to be implemented' });
};

const getCharacterById = async (req, res) => {
  res.json({ success: true, message: 'Get character by ID - to be implemented' });
};

const updateCharacter = async (req, res) => {
  res.json({ success: true, message: 'Update character - to be implemented' });
};

const deleteCharacter = async (req, res) => {
  res.json({ success: true, message: 'Delete character - to be implemented' });
};

const getChats = async (req, res) => {
  res.json({ success: true, message: 'Get chats - to be implemented' });
};

const getFlaggedChats = async (req, res) => {
  res.json({ success: true, message: 'Get flagged chats - to be implemented' });
};

const flagMessage = async (req, res) => {
  res.json({ success: true, message: 'Flag message - to be implemented' });
};

const deleteMessage = async (req, res) => {
  res.json({ success: true, message: 'Delete message - to be implemented' });
};

const getUserAnalytics = async (req, res) => {
  res.json({ success: true, message: 'Get user analytics - to be implemented' });
};

const getConversationAnalytics = async (req, res) => {
  res.json({ success: true, message: 'Get conversation analytics - to be implemented' });
};

const getRevenueAnalytics = async (req, res) => {
  res.json({ success: true, message: 'Get revenue analytics - to be implemented' });
};

const getPerformanceAnalytics = async (req, res) => {
  res.json({ success: true, message: 'Get performance analytics - to be implemented' });
};

const getSystemHealth = async (req, res) => {
  res.json({ success: true, message: 'Get system health - to be implemented' });
};

const getSystemLogs = async (req, res) => {
  res.json({ success: true, message: 'Get system logs - to be implemented' });
};

const getSystemMetrics = async (req, res) => {
  res.json({ success: true, message: 'Get system metrics - to be implemented' });
};

const getModerationReports = async (req, res) => {
  res.json({ success: true, message: 'Get moderation reports - to be implemented' });
};

const handleModerationReport = async (req, res) => {
  res.json({ success: true, message: 'Handle moderation report - to be implemented' });
};

module.exports = {
  getDashboardStats,
  getAnalytics,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  toggleUserStatus,
  getUserActivity,
  getCharacters,
  getCharacterById,
  updateCharacter,
  deleteCharacter,
  getChats,
  getFlaggedChats,
  flagMessage,
  deleteMessage,
  getUserAnalytics,
  getConversationAnalytics,
  getRevenueAnalytics,
  getPerformanceAnalytics,
  getSystemHealth,
  getSystemLogs,
  getSystemMetrics,
  getModerationReports,
  handleModerationReport
};