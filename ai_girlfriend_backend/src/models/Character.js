const mongoose = require('mongoose');

const characterSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  name: {
    type: String,
    required: [true, 'Character name is required'],
    trim: true,
    maxlength: [50, 'Character name cannot exceed 50 characters']
  },
  avatar: {
    type: String,
    default: null
  },
  personality: {
    traits: [{
      name: String,
      value: {
        type: Number,
        min: 0,
        max: 100
      }
    }],
    description: {
      type: String,
      maxlength: [1000, 'Personality description cannot exceed 1000 characters']
    },
    background: {
      type: String,
      maxlength: [2000, 'Background cannot exceed 2000 characters']
    },
    interests: [String],
    speaking_style: {
      type: String,
      enum: ['formal', 'casual', 'cute', 'mature', 'playful'],
      default: 'casual'
    }
  },
  appearance: {
    age: {
      type: Number,
      min: 18,
      max: 100
    },
    height: String,
    hairColor: String,
    eyeColor: String,
    bodyType: String,
    style: String
  },
  relationship: {
    intimacyLevel: {
      type: Number,
      default: 0,
      min: 0,
      max: 100
    },
    relationshipStatus: {
      type: String,
      enum: ['stranger', 'friend', 'close_friend', 'romantic', 'lover'],
      default: 'stranger'
    },
    memories: [{
      content: String,
      importance: {
        type: Number,
        min: 1,
        max: 10
      },
      createdAt: {
        type: Date,
        default: Date.now
      }
    }]
  },
  capabilities: {
    canChat: {
      type: Boolean,
      default: true
    },
    canVoiceCall: {
      type: Boolean,
      default: false
    },
    canVideoCall: {
      type: Boolean,
      default: false
    },
    canSendImages: {
      type: Boolean,
      default: false
    },
    specialSkills: [String]
  },
  statistics: {
    totalConversations: {
      type: Number,
      default: 0
    },
    totalMessages: {
      type: Number,
      default: 0
    },
    averageSessionDuration: {
      type: Number,
      default: 0
    },
    lastInteractionAt: {
      type: Date,
      default: Date.now
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  },
  settings: {
    isActive: {
      type: Boolean,
      default: true
    },
    isPublic: {
      type: Boolean,
      default: false
    },
    responseDelay: {
      type: Number,
      default: 1000, // milliseconds
      min: 0,
      max: 10000
    },
    maxMessageLength: {
      type: Number,
      default: 500
    }
  },
  aiModel: {
    modelType: {
      type: String,
      enum: ['gpt-3.5-turbo', 'gpt-4', 'claude', 'custom'],
      default: 'gpt-3.5-turbo'
    },
    temperature: {
      type: Number,
      default: 0.7,
      min: 0,
      max: 2
    },
    maxTokens: {
      type: Number,
      default: 150
    },
    systemPrompt: {
      type: String,
      maxlength: [2000, 'System prompt cannot exceed 2000 characters']
    }
  },
  knowledgeBase: {
    customKnowledge: [{
      topic: String,
      content: String,
      source: String,
      createdAt: {
        type: Date,
        default: Date.now
      }
    }],
    linkedKnowledgeBases: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'KnowledgeBase'
    }]
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
characterSchema.index({ userId: 1 });
characterSchema.index({ 'statistics.lastInteractionAt': -1 });
characterSchema.index({ 'settings.isActive': 1 });
characterSchema.index({ 'settings.isPublic': 1 });

// Virtual for relationship progress
characterSchema.virtual('relationshipProgress').get(function() {
  const level = this.relationship.intimacyLevel;
  if (level < 20) return 'stranger';
  if (level < 40) return 'acquaintance';
  if (level < 60) return 'friend';
  if (level < 80) return 'close_friend';
  return 'intimate';
});

// Method to update interaction statistics
characterSchema.methods.updateInteractionStats = function(messageCount = 1, sessionDuration = 0) {
  this.statistics.totalMessages += messageCount;
  this.statistics.totalConversations += 1;
  
  // Update average session duration
  const totalSessions = this.statistics.totalConversations;
  const currentAvg = this.statistics.averageSessionDuration;
  this.statistics.averageSessionDuration = 
    ((currentAvg * (totalSessions - 1)) + sessionDuration) / totalSessions;
  
  this.statistics.lastInteractionAt = new Date();
  
  return this.save();
};

// Method to increase intimacy
characterSchema.methods.increaseIntimacy = function(amount = 1) {
  this.relationship.intimacyLevel = Math.min(
    this.relationship.intimacyLevel + amount,
    100
  );
  
  // Update relationship status based on intimacy level
  const level = this.relationship.intimacyLevel;
  if (level >= 80) {
    this.relationship.relationshipStatus = 'lover';
  } else if (level >= 60) {
    this.relationship.relationshipStatus = 'romantic';
  } else if (level >= 40) {
    this.relationship.relationshipStatus = 'close_friend';
  } else if (level >= 20) {
    this.relationship.relationshipStatus = 'friend';
  }
  
  return this.save();
};

// Method to add memory
characterSchema.methods.addMemory = function(content, importance = 5) {
  this.relationship.memories.push({
    content,
    importance,
    createdAt: new Date()
  });
  
  // Keep only the most important memories (max 50)
  if (this.relationship.memories.length > 50) {
    this.relationship.memories.sort((a, b) => b.importance - a.importance);
    this.relationship.memories = this.relationship.memories.slice(0, 50);
  }
  
  return this.save();
};

// Static method to find user's characters
characterSchema.statics.findByUser = function(userId) {
  return this.find({ userId, 'settings.isActive': true });
};

// Static method to find public characters
characterSchema.statics.findPublicCharacters = function() {
  return this.find({ 
    'settings.isActive': true, 
    'settings.isPublic': true 
  }).populate('userId', 'username');
};

module.exports = mongoose.model('Character', characterSchema);