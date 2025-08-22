const Character = require('../models/Character');
const User = require('../models/User');
const { Conversation } = require('../models/Chat');
const mongoose = require('mongoose');

// @desc    Create new character
// @route   POST /api/characters
// @access  Private
const createCharacter = async (req, res) => {
  try {
    const userId = req.user._id;
    const characterData = req.body;

    // Check if user has reached character limit
    const userCharacterCount = await Character.countDocuments({
      userId,
      'settings.isActive': true
    });

    const maxCharacters = getMaxCharactersForUser(req.user.membershipType);
    if (userCharacterCount >= maxCharacters) {
      return res.status(400).json({
        success: false,
        message: `Maximum ${maxCharacters} characters allowed for ${req.user.membershipType} membership`,
        currentCount: userCharacterCount,
        maxAllowed: maxCharacters
      });
    }

    // Create character with user ID
    const character = await Character.create({
      ...characterData,
      userId
    });

    // Populate user information
    await character.populate('userId', 'username email membershipType');

    res.status(201).json({
      success: true,
      message: 'Character created successfully',
      data: {
        character
      }
    });
  } catch (error) {
    console.error('Create character error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create character',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get user's characters
// @route   GET /api/characters
// @access  Private
const getUserCharacters = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 10, active, search, sortBy = 'createdAt', sortOrder = 'desc' } = req.query;

    const query = { userId };
    
    if (active !== undefined) {
      query['settings.isActive'] = active === 'true';
    }
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { 'personality.description': { $regex: search, $options: 'i' } }
      ];
    }

    const sortOptions = {};
    sortOptions[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const characters = await Character.find(query)
      .sort(sortOptions)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username membershipType');

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
    console.error('Get user characters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get characters'
    });
  }
};

// @desc    Get character by ID
// @route   GET /api/characters/:characterId
// @access  Private
const getCharacterById = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;

    const character = await Character.findOne({
      _id: characterId,
      userId
    }).populate('userId', 'username membershipType');

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    // Get character statistics
    const conversationCount = await Conversation.countDocuments({
      'participants.character': characterId
    });

    const characterWithStats = {
      ...character.toObject(),
      additionalStats: {
        conversationCount
      }
    };

    res.json({
      success: true,
      data: {
        character: characterWithStats
      }
    });
  } catch (error) {
    console.error('Get character by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get character'
    });
  }
};

// @desc    Update character
// @route   PUT /api/characters/:characterId
// @access  Private
const updateCharacter = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.userId;
    delete updateData.statistics;
    delete updateData._id;

    const character = await Character.findOneAndUpdate(
      {
        _id: characterId,
        userId
      },
      { $set: updateData },
      { new: true, runValidators: true }
    ).populate('userId', 'username membershipType');

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    res.json({
      success: true,
      message: 'Character updated successfully',
      data: {
        character
      }
    });
  } catch (error) {
    console.error('Update character error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update character'
    });
  }
};

// @desc    Delete character
// @route   DELETE /api/characters/:characterId
// @access  Private
const deleteCharacter = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;

    const character = await Character.findOne({
      _id: characterId,
      userId
    });

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    // Soft delete - deactivate character
    character.settings.isActive = false;
    await character.save();

    // Deactivate related conversations
    await Conversation.updateMany(
      { 'participants.character': characterId },
      { 'settings.isActive': false }
    );

    res.json({
      success: true,
      message: 'Character deleted successfully'
    });
  } catch (error) {
    console.error('Delete character error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete character'
    });
  }
};

// @desc    Clone character
// @route   POST /api/characters/:characterId/clone
// @access  Private
const cloneCharacter = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;
    const { name } = req.body;

    // Check character limit
    const userCharacterCount = await Character.countDocuments({
      userId,
      'settings.isActive': true
    });

    const maxCharacters = getMaxCharactersForUser(req.user.membershipType);
    if (userCharacterCount >= maxCharacters) {
      return res.status(400).json({
        success: false,
        message: `Maximum ${maxCharacters} characters allowed for ${req.user.membershipType} membership`
      });
    }

    // Find original character
    const originalCharacter = await Character.findOne({
      _id: characterId,
      $or: [
        { userId }, // User's own character
        { 'settings.isPublic': true } // Public character
      ]
    });

    if (!originalCharacter) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    // Create cloned character
    const clonedData = originalCharacter.toObject();
    delete clonedData._id;
    delete clonedData.statistics;
    delete clonedData.relationship;
    delete clonedData.createdAt;
    delete clonedData.updatedAt;

    const clonedCharacter = await Character.create({
      ...clonedData,
      userId,
      name: name || `${originalCharacter.name} (Copy)`,
      settings: {
        ...clonedData.settings,
        isPublic: false // Cloned characters are private by default
      }
    });

    res.status(201).json({
      success: true,
      message: 'Character cloned successfully',
      data: {
        character: clonedCharacter
      }
    });
  } catch (error) {
    console.error('Clone character error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to clone character'
    });
  }
};

// @desc    Get public characters
// @route   GET /api/characters/public
// @access  Public
const getPublicCharacters = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category, sortBy = 'statistics.totalMessages', sortOrder = 'desc' } = req.query;

    const query = {
      'settings.isActive': true,
      'settings.isPublic': true
    };
    
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { 'personality.description': { $regex: search, $options: 'i' } }
      ];
    }
    
    if (category) {
      query['personality.interests'] = { $in: [category] };
    }

    const sortOptions = {};
    sortOptions[sortBy] = sortOrder === 'desc' ? -1 : 1;

    const characters = await Character.find(query)
      .sort(sortOptions)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('userId', 'username')
      .select('-knowledgeBase -relationship.memories'); // Hide sensitive data

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
    console.error('Get public characters error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get public characters'
    });
  }
};

// @desc    Update character avatar
// @route   POST /api/characters/:characterId/avatar
// @access  Private
const updateCharacterAvatar = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No avatar file uploaded'
      });
    }

    // In production, upload to cloud storage
    const avatarUrl = `/uploads/characters/${req.file.filename}`;

    const character = await Character.findOneAndUpdate(
      {
        _id: characterId,
        userId
      },
      { avatar: avatarUrl },
      { new: true }
    );

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    res.json({
      success: true,
      message: 'Character avatar updated successfully',
      data: {
        avatarUrl: character.avatar
      }
    });
  } catch (error) {
    console.error('Update character avatar error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update character avatar'
    });
  }
};

// @desc    Get character interaction history
// @route   GET /api/characters/:characterId/interactions
// @access  Private
const getCharacterInteractions = async (req, res) => {
  try {
    const { characterId } = req.params;
    const userId = req.user._id;
    const { days = 30 } = req.query;

    // Verify character ownership
    const character = await Character.findOne({
      _id: characterId,
      userId
    });

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    // Get daily interaction stats
    const dailyInteractions = await Conversation.aggregate([
      {
        $match: {
          'participants.character': new mongoose.Types.ObjectId(characterId),
          'statistics.lastMessageAt': { $gte: startDate }
        }
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$statistics.lastMessageAt'
            }
          },
          conversationCount: { $sum: 1 },
          totalMessages: { $sum: '$statistics.messageCount' },
          totalDuration: { $sum: '$statistics.duration' }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    res.json({
      success: true,
      data: {
        dailyInteractions,
        character: {
          id: character._id,
          name: character.name,
          totalStats: character.statistics
        }
      }
    });
  } catch (error) {
    console.error('Get character interactions error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get character interactions'
    });
  }
};

// Helper function to get max characters for user membership
function getMaxCharactersForUser(membershipType) {
  const limits = {
    'free': 1,
    'premium': 5,
    'vip': 15,
    'lifetime': 50
  };
  
  return limits[membershipType] || limits['free'];
}

// @desc    Get character templates
// @route   GET /api/characters/templates
// @access  Public
const getCharacterTemplates = async (req, res) => {
  try {
    const templates = [
      {
        id: 'friendly_companion',
        name: '友善伙伴',
        description: '温暖友善，善于倾听和陪伴的AI女友',
        personality: {
          traits: [
            { name: 'friendliness', value: 90 },
            { name: 'empathy', value: 85 },
            { name: 'patience', value: 80 }
          ],
          speaking_style: 'casual',
          interests: ['music', 'movies', 'books', 'travel']
        },
        appearance: {
          age: 25,
          hairColor: 'brown',
          eyeColor: 'brown'
        }
      },
      {
        id: 'intellectual_partner',
        name: '知性伴侣',
        description: '聪明睿智，喜欢深度交流的AI女友',
        personality: {
          traits: [
            { name: 'intelligence', value: 95 },
            { name: 'curiosity', value: 90 },
            { name: 'analytical', value: 85 }
          ],
          speaking_style: 'formal',
          interests: ['science', 'philosophy', 'literature', 'art']
        },
        appearance: {
          age: 28,
          hairColor: 'black',
          eyeColor: 'blue'
        }
      },
      {
        id: 'playful_spirit',
        name: '活泼精灵',
        description: '活泼可爱，充满活力的AI女友',
        personality: {
          traits: [
            { name: 'playfulness', value: 95 },
            { name: 'energy', value: 90 },
            { name: 'optimism', value: 88 }
          ],
          speaking_style: 'cute',
          interests: ['games', 'anime', 'sports', 'food']
        },
        appearance: {
          age: 22,
          hairColor: 'pink',
          eyeColor: 'green'
        }
      }
    ];

    res.json({
      success: true,
      data: {
        templates
      }
    });
  } catch (error) {
    console.error('Get character templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get character templates'
    });
  }
};

module.exports = {
  createCharacter,
  getUserCharacters,
  getCharacterById,
  updateCharacter,
  deleteCharacter,
  cloneCharacter,
  getPublicCharacters,
  updateCharacterAvatar,
  getCharacterInteractions,
  getCharacterTemplates
};