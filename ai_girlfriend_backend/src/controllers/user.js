const User = require('../models/User');
const Character = require('../models/Character');
const { ChatMessage, Conversation } = require('../models/Chat');

// @desc    Get user profile
// @route   GET /api/user/profile
// @access  Private
const getProfile = async (req, res) => {
  try {
    const user = req.user;
    
    res.json({
      success: true,
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user profile'
    });
  }
};

// @desc    Update user profile
// @route   PUT /api/user/profile
// @access  Private
const updateProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const updateData = req.body;

    // Remove sensitive fields that shouldn't be updated via this endpoint
    delete updateData.password;
    delete updateData.email;
    delete updateData.membershipType;
    delete updateData.coins;
    delete updateData.refreshTokens;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        user
      }
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile'
    });
  }
};

// @desc    Get user statistics
// @route   GET /api/user/statistics
// @access  Private
const getStatistics = async (req, res) => {
  try {
    const userId = req.user._id;

    // Get user's characters
    const characters = await Character.find({ userId });
    const characterIds = characters.map(c => c._id);

    // Get conversation statistics
    const conversations = await Conversation.find({
      'participants.user': userId
    });

    // Get message statistics
    const messageStats = await ChatMessage.aggregate([
      {
        $match: {
          userId: userId,
          isDeleted: false
        }
      },
      {
        $group: {
          _id: null,
          totalMessages: { $sum: 1 },
          avgMessageLength: { $avg: { $strLenCP: '$message.content' } }
        }
      }
    ]);

    // Calculate total session time
    const totalSessionTime = conversations.reduce((total, conv) => {
      return total + (conv.statistics.duration || 0);
    }, 0);

    // Get recent activity
    const recentMessages = await ChatMessage.find({
      userId: userId,
      isDeleted: false
    })
    .sort({ createdAt: -1 })
    .limit(10)
    .populate('characterId', 'name avatar');

    const statistics = {
      characters: {
        total: characters.length,
        active: characters.filter(c => c.settings.isActive).length
      },
      conversations: {
        total: conversations.length,
        active: conversations.filter(c => c.settings.isActive).length
      },
      messages: {
        total: messageStats[0]?.totalMessages || 0,
        averageLength: Math.round(messageStats[0]?.avgMessageLength || 0)
      },
      sessions: {
        totalTime: totalSessionTime, // in minutes
        averageTime: conversations.length > 0 ? Math.round(totalSessionTime / conversations.length) : 0
      },
      recentActivity: recentMessages
    };

    res.json({
      success: true,
      data: {
        statistics
      }
    });
  } catch (error) {
    console.error('Get statistics error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user statistics'
    });
  }
};

// @desc    Get user's characters
// @route   GET /api/user/characters
// @access  Private
const getCharacters = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 10, active } = req.query;

    const query = { userId };
    if (active !== undefined) {
      query['settings.isActive'] = active === 'true';
    }

    const characters = await Character.find(query)
      .sort({ 'statistics.lastInteractionAt': -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Character.countDocuments(query);

    res.json({
      success: true,
      data: {
        characters,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get characters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get characters'
    });
  }
};

// @desc    Get user's conversations
// @route   GET /api/user/conversations
// @access  Private
const getConversations = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20, archived } = req.query;

    const conversations = await Conversation.findByUser(userId, {
      includeArchived: archived === 'true',
      limit: parseInt(limit)
    })
    .skip((page - 1) * limit);

    const query = {
      'participants.user': userId,
      'settings.isArchived': archived === 'true'
    };
    const total = await Conversation.countDocuments(query);

    res.json({
      success: true,
      data: {
        conversations,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get conversations'
    });
  }
};

// @desc    Update user preferences
// @route   PUT /api/user/preferences
// @access  Private
const updatePreferences = async (req, res) => {
  try {
    const userId = req.user._id;
    const { preferences } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: { preferences } },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      message: 'Preferences updated successfully',
      data: {
        preferences: user.preferences
      }
    });
  } catch (error) {
    console.error('Update preferences error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update preferences'
    });
  }
};

// @desc    Upload avatar
// @route   POST /api/user/avatar
// @access  Private
const uploadAvatar = async (req, res) => {
  try {
    const userId = req.user._id;
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    // In production, upload to cloud storage (AWS S3, Cloudinary, etc.)
    const avatarUrl = `/uploads/avatars/${req.file.filename}`;

    const user = await User.findByIdAndUpdate(
      userId,
      { avatar: avatarUrl },
      { new: true }
    );

    res.json({
      success: true,
      message: 'Avatar uploaded successfully',
      data: {
        avatarUrl: user.avatar
      }
    });
  } catch (error) {
    console.error('Upload avatar error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload avatar'
    });
  }
};

// @desc    Delete user account
// @route   DELETE /api/user/account
// @access  Private
const deleteAccount = async (req, res) => {
  try {
    const userId = req.user._id;
    const { password } = req.body;

    // Verify password
    const user = await User.findById(userId).select('+password');
    const isPasswordValid = await user.comparePassword(password);

    if (!isPasswordValid) {
      return res.status(400).json({
        success: false,
        message: 'Invalid password'
      });
    }

    // Soft delete - deactivate account
    await User.findByIdAndUpdate(userId, {
      isActive: false,
      refreshTokens: []
    });

    // Deactivate user's characters
    await Character.updateMany(
      { userId },
      { 'settings.isActive': false }
    );

    res.json({
      success: true,
      message: 'Account deactivated successfully'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete account'
    });
  }
};

module.exports = {
  getProfile,
  updateProfile,
  getStatistics,
  getCharacters,
  getConversations,
  updatePreferences,
  uploadAvatar,
  deleteAccount
};