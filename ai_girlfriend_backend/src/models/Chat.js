const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
  conversationId: {
    type: String,
    required: true,
    index: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  characterId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Character',
    required: true
  },
  message: {
    content: {
      type: String,
      required: true,
      maxlength: [2000, 'Message content cannot exceed 2000 characters']
    },
    type: {
      type: String,
      enum: ['text', 'image', 'audio', 'video', 'file', 'system'],
      default: 'text'
    },
    metadata: {
      fileUrl: String,
      fileName: String,
      fileSize: Number,
      mimeType: String,
      duration: Number, // for audio/video
      dimensions: {
        width: Number,
        height: Number
      }
    }
  },
  sender: {
    type: String,
    enum: ['user', 'character', 'system'],
    required: true
  },
  aiResponse: {
    model: String,
    tokens: {
      prompt: Number,
      completion: Number,
      total: Number
    },
    processingTime: Number, // milliseconds
    confidence: Number, // 0-1
    ragUsed: {
      type: Boolean,
      default: false
    },
    knowledgeSources: [{
      source: String,
      relevance: Number
    }]
  },
  emotions: {
    detected: [{
      emotion: String,
      confidence: Number
    }],
    response: {
      emotion: String,
      intensity: Number
    }
  },
  status: {
    type: String,
    enum: ['sent', 'delivered', 'read', 'failed'],
    default: 'sent'
  },
  readAt: Date,
  editedAt: Date,
  deletedAt: Date,
  isDeleted: {
    type: Boolean,
    default: false
  },
  reactions: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    type: {
      type: String,
      enum: ['like', 'love', 'laugh', 'surprise', 'sad', 'angry']
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  flags: {
    isImportant: {
      type: Boolean,
      default: false
    },
    isFlagged: {
      type: Boolean,
      default: false
    },
    flagReason: String,
    isNSFW: {
      type: Boolean,
      default: false
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Conversation schema for grouping messages
const conversationSchema = new mongoose.Schema({
  participants: {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    character: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Character',
      required: true
    }
  },
  title: {
    type: String,
    maxlength: [100, 'Conversation title cannot exceed 100 characters']
  },
  summary: {
    type: String,
    maxlength: [500, 'Conversation summary cannot exceed 500 characters']
  },
  statistics: {
    messageCount: {
      type: Number,
      default: 0
    },
    duration: {
      type: Number,
      default: 0 // in minutes
    },
    lastMessageAt: {
      type: Date,
      default: Date.now
    },
    intimacyGained: {
      type: Number,
      default: 0
    }
  },
  settings: {
    isActive: {
      type: Boolean,
      default: true
    },
    isArchived: {
      type: Boolean,
      default: false
    },
    isPinned: {
      type: Boolean,
      default: false
    },
    notifications: {
      type: Boolean,
      default: true
    }
  },
  metadata: {
    startedAt: {
      type: Date,
      default: Date.now
    },
    endedAt: Date,
    tags: [String],
    mood: {
      type: String,
      enum: ['happy', 'sad', 'excited', 'calm', 'romantic', 'playful', 'serious']
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes for ChatMessage
chatMessageSchema.index({ conversationId: 1, createdAt: -1 });
chatMessageSchema.index({ userId: 1, createdAt: -1 });
chatMessageSchema.index({ characterId: 1, createdAt: -1 });
chatMessageSchema.index({ sender: 1 });
chatMessageSchema.index({ 'message.type': 1 });
chatMessageSchema.index({ status: 1 });
chatMessageSchema.index({ isDeleted: 1 });

// Indexes for Conversation
conversationSchema.index({ 'participants.user': 1, 'participants.character': 1 });
conversationSchema.index({ 'statistics.lastMessageAt': -1 });
conversationSchema.index({ 'settings.isActive': 1 });
conversationSchema.index({ 'settings.isArchived': 1 });
conversationSchema.index({ 'settings.isPinned': 1 });

// Virtual for message age
chatMessageSchema.virtual('age').get(function() {
  return Date.now() - this.createdAt.getTime();
});

// Virtual for conversation duration
conversationSchema.virtual('totalDuration').get(function() {
  if (this.metadata.endedAt) {
    return Math.floor((this.metadata.endedAt - this.metadata.startedAt) / (1000 * 60));
  }
  return Math.floor((Date.now() - this.metadata.startedAt) / (1000 * 60));
});

// Method to mark message as read
chatMessageSchema.methods.markAsRead = function() {
  this.status = 'read';
  this.readAt = new Date();
  return this.save();
};

// Method to add reaction
chatMessageSchema.methods.addReaction = function(userId, reactionType) {
  // Remove existing reaction from this user
  this.reactions = this.reactions.filter(r => !r.userId.equals(userId));
  
  // Add new reaction
  this.reactions.push({
    userId,
    type: reactionType,
    createdAt: new Date()
  });
  
  return this.save();
};

// Method to update conversation statistics
conversationSchema.methods.updateStats = function(messageCount = 1, intimacyGain = 0) {
  this.statistics.messageCount += messageCount;
  this.statistics.lastMessageAt = new Date();
  this.statistics.intimacyGained += intimacyGain;
  
  // Update duration
  this.statistics.duration = this.totalDuration;
  
  return this.save();
};

// Method to end conversation
conversationSchema.methods.endConversation = function() {
  this.metadata.endedAt = new Date();
  this.settings.isActive = false;
  this.statistics.duration = this.totalDuration;
  
  return this.save();
};

// Static method to find conversation between user and character
conversationSchema.statics.findByParticipants = function(userId, characterId) {
  return this.findOne({
    'participants.user': userId,
    'participants.character': characterId,
    'settings.isActive': true
  });
};

// Static method to get user's conversations
conversationSchema.statics.findByUser = function(userId, options = {}) {
  const query = {
    'participants.user': userId,
    'settings.isArchived': options.includeArchived || false
  };
  
  return this.find(query)
    .populate('participants.character', 'name avatar')
    .sort({ 'statistics.lastMessageAt': -1 })
    .limit(options.limit || 50);
};

// Static method to get recent messages
chatMessageSchema.statics.getRecentMessages = function(conversationId, limit = 50) {
  return this.find({ 
    conversationId, 
    isDeleted: false 
  })
  .sort({ createdAt: -1 })
  .limit(limit)
  .populate('userId', 'username avatar')
  .populate('characterId', 'name avatar');
};

const ChatMessage = mongoose.model('ChatMessage', chatMessageSchema);
const Conversation = mongoose.model('Conversation', conversationSchema);

module.exports = {
  ChatMessage,
  Conversation
};