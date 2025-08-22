const { ChatMessage, Conversation } = require('../models/Chat');
const Character = require('../models/Character');
const User = require('../models/User');
const { v4: uuidv4 } = require('uuid');
const RAGService = require('../services/ragService');
const AIService = require('../services/aiService');

// @desc    Send message
// @route   POST /api/chat/send
// @access  Private
const sendMessage = async (req, res) => {
  try {
    const { message, characterId, conversationId } = req.body;
    const userId = req.user._id;

    // Verify character belongs to user
    const character = await Character.findOne({
      _id: characterId,
      userId,
      'settings.isActive': true
    });

    if (!character) {
      return res.status(404).json({
        success: false,
        message: 'Character not found or not accessible'
      });
    }

    // Find or create conversation
    let conversation;
    if (conversationId) {
      conversation = await Conversation.findById(conversationId);
    } else {
      conversation = await Conversation.findByParticipants(userId, characterId);
    }

    if (!conversation) {
      conversation = await Conversation.create({
        participants: {
          user: userId,
          character: characterId
        },
        title: `Chat with ${character.name}`,
        metadata: {
          startedAt: new Date()
        }
      });
    }

    // Create user message
    const userMessage = await ChatMessage.create({
      conversationId: conversation._id,
      userId,
      characterId,
      message: {
        content: message,
        type: 'text'
      },
      sender: 'user'
    });

    // Generate AI response
    const aiResponse = await AIService.generateResponse({
      message,
      character,
      conversation,
      user: req.user
    });

    // Create AI message
    const aiMessage = await ChatMessage.create({
      conversationId: conversation._id,
      userId,
      characterId,
      message: {
        content: aiResponse.content,
        type: 'text'
      },
      sender: 'character',
      aiResponse: {
        model: aiResponse.model,
        tokens: aiResponse.tokens,
        processingTime: aiResponse.processingTime,
        confidence: aiResponse.confidence,
        ragUsed: aiResponse.ragUsed,
        knowledgeSources: aiResponse.knowledgeSources
      },
      emotions: aiResponse.emotions
    });

    // Update conversation statistics
    await conversation.updateStats(2, aiResponse.intimacyGain || 0);

    // Update character statistics and intimacy
    await character.updateInteractionStats(2);
    if (aiResponse.intimacyGain) {
      await character.increaseIntimacy(aiResponse.intimacyGain);
    }

    // Add memory if important
    if (aiResponse.importance && aiResponse.importance > 7) {
      await character.addMemory(message, aiResponse.importance);
    }

    // Update user statistics
    await User.findByIdAndUpdate(userId, {
      $inc: {
        'statistics.totalMessages': 2,
        'statistics.totalChats': 1
      },
      'statistics.lastActiveAt': new Date()
    });

    res.json({
      success: true,
      data: {
        conversation: {
          id: conversation._id,
          title: conversation.title
        },
        messages: [userMessage, aiMessage],
        character: {
          intimacyLevel: character.relationship.intimacyLevel,
          relationshipStatus: character.relationship.relationshipStatus
        }
      }
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send message'
    });
  }
};

// @desc    Get chat history
// @route   GET /api/chat/history/:conversationId
// @access  Private
const getChatHistory = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    const userId = req.user._id;

    // Verify conversation belongs to user
    const conversation = await Conversation.findOne({
      _id: conversationId,
      'participants.user': userId
    }).populate('participants.character', 'name avatar');

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    // Get messages
    const messages = await ChatMessage.find({
      conversationId,
      isDeleted: false
    })
    .sort({ createdAt: -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit)
    .populate('userId', 'username avatar')
    .populate('characterId', 'name avatar');

    const total = await ChatMessage.countDocuments({
      conversationId,
      isDeleted: false
    });

    // Mark messages as read
    await ChatMessage.updateMany(
      {
        conversationId,
        sender: 'character',
        status: { $ne: 'read' }
      },
      {
        status: 'read',
        readAt: new Date()
      }
    );

    res.json({
      success: true,
      data: {
        conversation,
        messages: messages.reverse(), // Return in chronological order
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get chat history error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get chat history'
    });
  }
};

// @desc    Get conversations list
// @route   GET /api/chat/conversations
// @access  Private
const getConversations = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20, archived = false } = req.query;

    const conversations = await Conversation.find({
      'participants.user': userId,
      'settings.isArchived': archived === 'true'
    })
    .populate('participants.character', 'name avatar')
    .sort({ 'statistics.lastMessageAt': -1 })
    .limit(limit * 1)
    .skip((page - 1) * limit);

    const total = await Conversation.countDocuments({
      'participants.user': userId,
      'settings.isArchived': archived === 'true'
    });

    // Get unread message counts for each conversation
    const conversationsWithUnread = await Promise.all(
      conversations.map(async (conv) => {
        const unreadCount = await ChatMessage.countDocuments({
          conversationId: conv._id,
          sender: 'character',
          status: { $ne: 'read' }
        });

        return {
          ...conv.toObject(),
          unreadCount
        };
      })
    );

    res.json({
      success: true,
      data: {
        conversations: conversationsWithUnread,
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

// @desc    Delete message
// @route   DELETE /api/chat/message/:messageId
// @access  Private
const deleteMessage = async (req, res) => {
  try {
    const { messageId } = req.params;
    const userId = req.user._id;

    const message = await ChatMessage.findOne({
      _id: messageId,
      userId,
      sender: 'user' // Only allow users to delete their own messages
    });

    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found or not authorized'
      });
    }

    message.isDeleted = true;
    message.deletedAt = new Date();
    await message.save();

    res.json({
      success: true,
      message: 'Message deleted successfully'
    });
  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete message'
    });
  }
};

// @desc    Archive conversation
// @route   PUT /api/chat/conversation/:conversationId/archive
// @access  Private
const archiveConversation = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user._id;

    const conversation = await Conversation.findOne({
      _id: conversationId,
      'participants.user': userId
    });

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    conversation.settings.isArchived = !conversation.settings.isArchived;
    await conversation.save();

    res.json({
      success: true,
      message: `Conversation ${conversation.settings.isArchived ? 'archived' : 'unarchived'} successfully`,
      data: {
        conversation
      }
    });
  } catch (error) {
    console.error('Archive conversation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to archive conversation'
    });
  }
};

// @desc    Add reaction to message
// @route   POST /api/chat/message/:messageId/reaction
// @access  Private
const addReaction = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { type } = req.body;
    const userId = req.user._id;

    const message = await ChatMessage.findById(messageId);
    if (!message) {
      return res.status(404).json({
        success: false,
        message: 'Message not found'
      });
    }

    await message.addReaction(userId, type);

    res.json({
      success: true,
      message: 'Reaction added successfully',
      data: {
        reactions: message.reactions
      }
    });
  } catch (error) {
    console.error('Add reaction error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to add reaction'
    });
  }
};

// @desc    Get conversation summary
// @route   GET /api/chat/conversation/:conversationId/summary
// @access  Private
const getConversationSummary = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user._id;

    const conversation = await Conversation.findOne({
      _id: conversationId,
      'participants.user': userId
    }).populate('participants.character', 'name avatar');

    if (!conversation) {
      return res.status(404).json({
        success: false,
        message: 'Conversation not found'
      });
    }

    // Get recent messages for context
    const recentMessages = await ChatMessage.find({
      conversationId,
      isDeleted: false
    })
    .sort({ createdAt: -1 })
    .limit(10)
    .select('message.content sender createdAt');

    // Generate summary using AI (implement based on your AI service)
    const summary = await AIService.generateSummary(recentMessages);

    // Update conversation summary
    conversation.summary = summary;
    await conversation.save();

    res.json({
      success: true,
      data: {
        summary,
        statistics: conversation.statistics
      }
    });
  } catch (error) {
    console.error('Get conversation summary error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get conversation summary'
    });
  }
};

module.exports = {
  sendMessage,
  getChatHistory,
  getConversations,
  deleteMessage,
  archiveConversation,
  addReaction,
  getConversationSummary
};