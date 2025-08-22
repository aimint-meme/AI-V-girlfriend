const KnowledgeBase = require('../models/KnowledgeBase');
const Character = require('../models/Character');
const mongoose = require('mongoose');

// @desc    Create new knowledge base
// @route   POST /api/knowledge
// @access  Private
const createKnowledgeBase = async (req, res) => {
  try {
    const userId = req.user._id;
    const { name, description, characterId, type = 'personal', items = [] } = req.body;

    // Verify character ownership if characterId is provided
    if (characterId) {
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
    }

    // Check knowledge base limit for user
    const userKnowledgeBaseCount = await KnowledgeBase.countDocuments({ userId });
    const maxKnowledgeBases = getMaxKnowledgeBasesForUser(req.user.membershipType);
    
    if (userKnowledgeBaseCount >= maxKnowledgeBases) {
      return res.status(400).json({
        success: false,
        message: `Maximum ${maxKnowledgeBases} knowledge bases allowed for ${req.user.membershipType} membership`
      });
    }

    const knowledgeBase = await KnowledgeBase.create({
      name,
      description,
      userId,
      characterId,
      type,
      items
    });

    await knowledgeBase.populate('characterId', 'name avatar');

    res.status(201).json({
      success: true,
      message: 'Knowledge base created successfully',
      data: {
        knowledgeBase
      }
    });
  } catch (error) {
    console.error('Create knowledge base error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create knowledge base'
    });
  }
};

// @desc    Get user's knowledge bases
// @route   GET /api/knowledge
// @access  Private
const getUserKnowledgeBases = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 10, type, characterId, search } = req.query;

    const query = { userId };
    
    if (type && type !== 'all') {
      query.type = type;
    }
    
    if (characterId && characterId !== 'all') {
      query.characterId = characterId;
    }
    
    if (search) {
      query.$text = { $search: search };
    }

    const knowledgeBases = await KnowledgeBase.find(query)
      .populate('characterId', 'name avatar')
      .sort({ updatedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await KnowledgeBase.countDocuments(query);

    res.json({
      success: true,
      data: {
        knowledgeBases,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get knowledge bases error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get knowledge bases'
    });
  }
};

// @desc    Get knowledge base by ID
// @route   GET /api/knowledge/:knowledgeBaseId
// @access  Private
const getKnowledgeBaseById = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      $or: [
        { userId },
        { 'settings.isPublic': true },
        { type: 'shared' }
      ]
    }).populate('characterId', 'name avatar');

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    // Get category statistics
    const categoryStats = knowledgeBase.getCategoryStats();

    res.json({
      success: true,
      data: {
        knowledgeBase,
        categoryStats
      }
    });
  } catch (error) {
    console.error('Get knowledge base by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get knowledge base'
    });
  }
};

// @desc    Update knowledge base
// @route   PUT /api/knowledge/:knowledgeBaseId
// @access  Private
const updateKnowledgeBase = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;
    const updateData = req.body;

    // Remove fields that shouldn't be updated directly
    delete updateData.userId;
    delete updateData.statistics;
    delete updateData.items; // Items should be updated via separate endpoints

    const knowledgeBase = await KnowledgeBase.findOneAndUpdate(
      {
        _id: knowledgeBaseId,
        userId
      },
      { $set: updateData },
      { new: true, runValidators: true }
    ).populate('characterId', 'name avatar');

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    res.json({
      success: true,
      message: 'Knowledge base updated successfully',
      data: {
        knowledgeBase
      }
    });
  } catch (error) {
    console.error('Update knowledge base error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update knowledge base'
    });
  }
};

// @desc    Delete knowledge base
// @route   DELETE /api/knowledge/:knowledgeBaseId
// @access  Private
const deleteKnowledgeBase = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;

    const knowledgeBase = await KnowledgeBase.findOneAndDelete({
      _id: knowledgeBaseId,
      userId
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    res.json({
      success: true,
      message: 'Knowledge base deleted successfully'
    });
  } catch (error) {
    console.error('Delete knowledge base error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete knowledge base'
    });
  }
};

// @desc    Add knowledge item
// @route   POST /api/knowledge/:knowledgeBaseId/items
// @access  Private
const addKnowledgeItem = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;
    const itemData = req.body;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      userId
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    await knowledgeBase.addItem(itemData);

    res.status(201).json({
      success: true,
      message: 'Knowledge item added successfully',
      data: {
        item: knowledgeBase.items[knowledgeBase.items.length - 1]
      }
    });
  } catch (error) {
    console.error('Add knowledge item error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to add knowledge item'
    });
  }
};

// @desc    Update knowledge item
// @route   PUT /api/knowledge/:knowledgeBaseId/items/:itemId
// @access  Private
const updateKnowledgeItem = async (req, res) => {
  try {
    const { knowledgeBaseId, itemId } = req.params;
    const userId = req.user._id;
    const updateData = req.body;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      userId
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    await knowledgeBase.updateItem(itemId, updateData);

    const updatedItem = knowledgeBase.items.id(itemId);

    res.json({
      success: true,
      message: 'Knowledge item updated successfully',
      data: {
        item: updatedItem
      }
    });
  } catch (error) {
    console.error('Update knowledge item error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to update knowledge item'
    });
  }
};

// @desc    Delete knowledge item
// @route   DELETE /api/knowledge/:knowledgeBaseId/items/:itemId
// @access  Private
const deleteKnowledgeItem = async (req, res) => {
  try {
    const { knowledgeBaseId, itemId } = req.params;
    const userId = req.user._id;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      userId
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    await knowledgeBase.removeItem(itemId);

    res.json({
      success: true,
      message: 'Knowledge item deleted successfully'
    });
  } catch (error) {
    console.error('Delete knowledge item error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to delete knowledge item'
    });
  }
};

// @desc    Search knowledge items
// @route   GET /api/knowledge/:knowledgeBaseId/search
// @access  Private
const searchKnowledgeItems = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;
    const { q: query, category, minImportance, limit = 10, sortBy } = req.query;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      $or: [
        { userId },
        { 'settings.isPublic': true },
        { type: 'shared' }
      ]
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    const items = knowledgeBase.searchItems(query, {
      category,
      minImportance: minImportance ? parseInt(minImportance) : 1,
      limit: parseInt(limit),
      sortBy
    });

    res.json({
      success: true,
      data: {
        items,
        query,
        totalFound: items.length
      }
    });
  } catch (error) {
    console.error('Search knowledge items error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to search knowledge items'
    });
  }
};

// @desc    Clone knowledge base
// @route   POST /api/knowledge/:knowledgeBaseId/clone
// @access  Private
const cloneKnowledgeBase = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;
    const { name } = req.body;

    // Check knowledge base limit
    const userKnowledgeBaseCount = await KnowledgeBase.countDocuments({ userId });
    const maxKnowledgeBases = getMaxKnowledgeBasesForUser(req.user.membershipType);
    
    if (userKnowledgeBaseCount >= maxKnowledgeBases) {
      return res.status(400).json({
        success: false,
        message: `Maximum ${maxKnowledgeBases} knowledge bases allowed for ${req.user.membershipType} membership`
      });
    }

    const clonedKnowledgeBase = await KnowledgeBase.cloneKnowledgeBase(
      knowledgeBaseId,
      userId,
      name
    );

    res.status(201).json({
      success: true,
      message: 'Knowledge base cloned successfully',
      data: {
        knowledgeBase: clonedKnowledgeBase
      }
    });
  } catch (error) {
    console.error('Clone knowledge base error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Failed to clone knowledge base'
    });
  }
};

// @desc    Get public knowledge bases
// @route   GET /api/knowledge/public
// @access  Public
const getPublicKnowledgeBases = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, category } = req.query;

    const knowledgeBases = await KnowledgeBase.findPublic({
      limit: parseInt(limit),
      search,
      category
    })
    .skip((page - 1) * limit);

    const total = await KnowledgeBase.countDocuments({
      'settings.isPublic': true,
      'statistics.totalItems': { $gt: 0 }
    });

    res.json({
      success: true,
      data: {
        knowledgeBases,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get public knowledge bases error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get public knowledge bases'
    });
  }
};

// @desc    Get knowledge base templates
// @route   GET /api/knowledge/templates
// @access  Public
const getKnowledgeBaseTemplates = async (req, res) => {
  try {
    const templates = [
      {
        id: 'personality_basic',
        name: '基础人格模板',
        description: '包含基本人格特征和行为模式的知识库模板',
        category: 'personality',
        items: [
          {
            title: '性格特征',
            content: '我是一个温和、善解人意的人，喜欢倾听别人的想法和感受。',
            keywords: ['温和', '善解人意', '倾听'],
            category: 'personality',
            importance: 8
          },
          {
            title: '兴趣爱好',
            content: '我喜欢阅读、音乐和旅行，对新事物充满好奇心。',
            keywords: ['阅读', '音乐', '旅行', '好奇心'],
            category: 'interests',
            importance: 7
          }
        ]
      },
      {
        id: 'conversation_starters',
        name: '对话启动器',
        description: '各种场景下的对话开场白和话题引导',
        category: 'conversation_starters',
        items: [
          {
            title: '日常问候',
            content: '今天过得怎么样？有什么有趣的事情想分享吗？',
            keywords: ['问候', '日常', '分享'],
            category: 'conversation_starters',
            importance: 6
          },
          {
            title: '情感支持',
            content: '我注意到你似乎有些不开心，愿意和我聊聊吗？',
            keywords: ['情感', '支持', '倾听'],
            category: 'conversation_starters',
            importance: 9
          }
        ]
      },
      {
        id: 'emotional_responses',
        name: '情感回应模板',
        description: '针对不同情感状态的回应方式',
        category: 'emotions',
        items: [
          {
            title: '开心时的回应',
            content: '看到你这么开心我也很高兴！能告诉我是什么让你这么快乐吗？',
            keywords: ['开心', '快乐', '分享'],
            category: 'emotions',
            importance: 8
          },
          {
            title: '难过时的安慰',
            content: '我理解你现在的感受，虽然很难过，但请记住我会一直陪在你身边。',
            keywords: ['难过', '安慰', '陪伴'],
            category: 'emotions',
            importance: 9
          }
        ]
      }
    ];

    res.json({
      success: true,
      data: {
        templates
      }
    });
  } catch (error) {
    console.error('Get knowledge base templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get knowledge base templates'
    });
  }
};

// @desc    Import knowledge from conversation
// @route   POST /api/knowledge/:knowledgeBaseId/import/conversation
// @access  Private
const importFromConversation = async (req, res) => {
  try {
    const { knowledgeBaseId } = req.params;
    const userId = req.user._id;
    const { conversationId, messageIds } = req.body;

    const knowledgeBase = await KnowledgeBase.findOne({
      _id: knowledgeBaseId,
      userId
    });

    if (!knowledgeBase) {
      return res.status(404).json({
        success: false,
        message: 'Knowledge base not found or not accessible'
      });
    }

    // Import logic would go here
    // This is a placeholder for the actual implementation
    
    res.json({
      success: true,
      message: 'Knowledge imported from conversation successfully',
      data: {
        importedItems: 0 // Placeholder
      }
    });
  } catch (error) {
    console.error('Import from conversation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to import from conversation'
    });
  }
};

// Helper function to get max knowledge bases for user membership
function getMaxKnowledgeBasesForUser(membershipType) {
  const limits = {
    'free': 2,
    'premium': 10,
    'vip': 25,
    'lifetime': 100
  };
  
  return limits[membershipType] || limits['free'];
}

module.exports = {
  createKnowledgeBase,
  getUserKnowledgeBases,
  getKnowledgeBaseById,
  updateKnowledgeBase,
  deleteKnowledgeBase,
  addKnowledgeItem,
  updateKnowledgeItem,
  deleteKnowledgeItem,
  searchKnowledgeItems,
  cloneKnowledgeBase,
  getPublicKnowledgeBases,
  getKnowledgeBaseTemplates,
  importFromConversation
};