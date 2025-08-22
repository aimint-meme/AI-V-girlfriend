const mongoose = require('mongoose');

const knowledgeItemSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Knowledge item title is required'],
    trim: true,
    maxlength: [200, 'Title cannot exceed 200 characters']
  },
  content: {
    type: String,
    required: [true, 'Knowledge item content is required'],
    maxlength: [5000, 'Content cannot exceed 5000 characters']
  },
  keywords: [{
    type: String,
    trim: true,
    maxlength: [50, 'Keyword cannot exceed 50 characters']
  }],
  category: {
    type: String,
    required: true,
    enum: [
      'personality', 'background', 'interests', 'skills', 'memories',
      'relationships', 'preferences', 'facts', 'stories', 'emotions',
      'conversation_starters', 'responses', 'custom'
    ]
  },
  importance: {
    type: Number,
    default: 5,
    min: 1,
    max: 10
  },
  source: {
    type: String,
    enum: ['user_input', 'conversation', 'template', 'import', 'system'],
    default: 'user_input'
  },
  metadata: {
    tags: [String],
    language: {
      type: String,
      default: 'zh-CN'
    },
    confidence: {
      type: Number,
      default: 1.0,
      min: 0,
      max: 1
    },
    lastUsed: Date,
    useCount: {
      type: Number,
      default: 0
    }
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

const knowledgeBaseSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Knowledge base name is required'],
    trim: true,
    maxlength: [100, 'Name cannot exceed 100 characters']
  },
  description: {
    type: String,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  characterId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Character',
    default: null // null means it's a general knowledge base
  },
  type: {
    type: String,
    enum: ['personal', 'character_specific', 'shared', 'template', 'system'],
    default: 'personal'
  },
  items: [knowledgeItemSchema],
  settings: {
    isPublic: {
      type: Boolean,
      default: false
    },
    allowCloning: {
      type: Boolean,
      default: false
    },
    autoUpdate: {
      type: Boolean,
      default: true
    },
    maxItems: {
      type: Number,
      default: 1000
    }
  },
  statistics: {
    totalItems: {
      type: Number,
      default: 0
    },
    totalUses: {
      type: Number,
      default: 0
    },
    lastUpdated: {
      type: Date,
      default: Date.now
    },
    averageImportance: {
      type: Number,
      default: 5
    }
  },
  vectorIndex: {
    // For future vector database integration
    indexId: String,
    lastIndexed: Date,
    indexVersion: {
      type: String,
      default: '1.0'
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Indexes
knowledgeBaseSchema.index({ userId: 1 });
knowledgeBaseSchema.index({ characterId: 1 });
knowledgeBaseSchema.index({ type: 1 });
knowledgeBaseSchema.index({ 'settings.isPublic': 1 });
knowledgeBaseSchema.index({ 'items.keywords': 1 });
knowledgeBaseSchema.index({ 'items.category': 1 });
knowledgeBaseSchema.index({ 'items.importance': -1 });

// Text search index
knowledgeBaseSchema.index({
  name: 'text',
  description: 'text',
  'items.title': 'text',
  'items.content': 'text',
  'items.keywords': 'text'
});

// Virtual for active items count
knowledgeBaseSchema.virtual('activeItemsCount').get(function() {
  return this.items.filter(item => item.isActive).length;
});

// Pre-save middleware to update statistics
knowledgeBaseSchema.pre('save', function(next) {
  if (this.isModified('items')) {
    const activeItems = this.items.filter(item => item.isActive);
    this.statistics.totalItems = activeItems.length;
    
    if (activeItems.length > 0) {
      const totalImportance = activeItems.reduce((sum, item) => sum + item.importance, 0);
      this.statistics.averageImportance = totalImportance / activeItems.length;
    }
    
    this.statistics.lastUpdated = new Date();
  }
  next();
});

// Method to add knowledge item
knowledgeBaseSchema.methods.addItem = function(itemData) {
  if (this.items.length >= this.settings.maxItems) {
    throw new Error(`Maximum ${this.settings.maxItems} items allowed`);
  }
  
  this.items.push(itemData);
  return this.save();
};

// Method to update knowledge item
knowledgeBaseSchema.methods.updateItem = function(itemId, updateData) {
  const item = this.items.id(itemId);
  if (!item) {
    throw new Error('Knowledge item not found');
  }
  
  Object.assign(item, updateData);
  return this.save();
};

// Method to remove knowledge item
knowledgeBaseSchema.methods.removeItem = function(itemId) {
  const item = this.items.id(itemId);
  if (!item) {
    throw new Error('Knowledge item not found');
  }
  
  item.isActive = false;
  return this.save();
};

// Method to search knowledge items
knowledgeBaseSchema.methods.searchItems = function(query, options = {}) {
  const {
    category,
    minImportance = 1,
    limit = 10,
    sortBy = 'importance'
  } = options;
  
  let items = this.items.filter(item => {
    if (!item.isActive) return false;
    if (category && item.category !== category) return false;
    if (item.importance < minImportance) return false;
    
    if (query) {
      const searchText = `${item.title} ${item.content} ${item.keywords.join(' ')}`.toLowerCase();
      return searchText.includes(query.toLowerCase());
    }
    
    return true;
  });
  
  // Sort items
  items.sort((a, b) => {
    switch (sortBy) {
      case 'importance':
        return b.importance - a.importance;
      case 'recent':
        return new Date(b.createdAt) - new Date(a.createdAt);
      case 'usage':
        return b.metadata.useCount - a.metadata.useCount;
      default:
        return b.importance - a.importance;
    }
  });
  
  return items.slice(0, limit);
};

// Method to increment item usage
knowledgeBaseSchema.methods.incrementItemUsage = function(itemId) {
  const item = this.items.id(itemId);
  if (item) {
    item.metadata.useCount += 1;
    item.metadata.lastUsed = new Date();
    this.statistics.totalUses += 1;
    return this.save();
  }
};

// Method to get category statistics
knowledgeBaseSchema.methods.getCategoryStats = function() {
  const stats = {};
  
  this.items.filter(item => item.isActive).forEach(item => {
    if (!stats[item.category]) {
      stats[item.category] = {
        count: 0,
        totalImportance: 0,
        averageImportance: 0
      };
    }
    
    stats[item.category].count += 1;
    stats[item.category].totalImportance += item.importance;
  });
  
  // Calculate averages
  Object.keys(stats).forEach(category => {
    stats[category].averageImportance = 
      stats[category].totalImportance / stats[category].count;
  });
  
  return stats;
};

// Static method to find public knowledge bases
knowledgeBaseSchema.statics.findPublic = function(options = {}) {
  const { limit = 20, category, search } = options;
  
  const query = {
    'settings.isPublic': true,
    'statistics.totalItems': { $gt: 0 }
  };
  
  if (search) {
    query.$text = { $search: search };
  }
  
  return this.find(query)
    .populate('userId', 'username')
    .populate('characterId', 'name avatar')
    .sort({ 'statistics.totalUses': -1 })
    .limit(limit);
};

// Static method to find by user
knowledgeBaseSchema.statics.findByUser = function(userId, options = {}) {
  const { includeShared = true, type } = options;
  
  const query = {
    $or: [
      { userId },
      ...(includeShared ? [{ type: 'shared' }] : [])
    ]
  };
  
  if (type) {
    query.type = type;
  }
  
  return this.find(query)
    .populate('characterId', 'name avatar')
    .sort({ updatedAt: -1 });
};

// Static method to clone knowledge base
knowledgeBaseSchema.statics.cloneKnowledgeBase = async function(originalId, userId, newName) {
  const original = await this.findById(originalId);
  
  if (!original) {
    throw new Error('Original knowledge base not found');
  }
  
  if (!original.settings.allowCloning && !original.settings.isPublic) {
    throw new Error('Knowledge base cloning not allowed');
  }
  
  const clonedData = original.toObject();
  delete clonedData._id;
  delete clonedData.createdAt;
  delete clonedData.updatedAt;
  delete clonedData.statistics.totalUses;
  delete clonedData.vectorIndex;
  
  // Reset item usage statistics
  clonedData.items.forEach(item => {
    item.metadata.useCount = 0;
    item.metadata.lastUsed = undefined;
    delete item._id;
  });
  
  const cloned = await this.create({
    ...clonedData,
    name: newName || `${original.name} (Copy)`,
    userId,
    characterId: null, // Cloned knowledge bases are not character-specific
    type: 'personal',
    settings: {
      ...clonedData.settings,
      isPublic: false,
      allowCloning: false
    }
  });
  
  return cloned;
};

module.exports = mongoose.model('KnowledgeBase', knowledgeBaseSchema);