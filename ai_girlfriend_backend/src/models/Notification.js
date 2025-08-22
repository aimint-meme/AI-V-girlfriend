const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  type: {
    type: String,
    enum: [
      'system', 'chat', 'character', 'membership', 'payment', 
      'achievement', 'reminder', 'update', 'promotion', 'warning'
    ],
    required: true
  },
  category: {
    type: String,
    enum: ['info', 'success', 'warning', 'error', 'promotion'],
    default: 'info'
  },
  title: {
    type: String,
    required: true,
    maxlength: [100, 'Title cannot exceed 100 characters']
  },
  message: {
    type: String,
    required: true,
    maxlength: [500, 'Message cannot exceed 500 characters']
  },
  data: {
    // Additional data specific to notification type
    characterId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Character'
    },
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Conversation'
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Order'
    },
    url: String, // Deep link or action URL
    imageUrl: String,
    actionButton: {
      text: String,
      action: String, // 'navigate', 'api_call', 'dismiss'
      url: String
    },
    metadata: mongoose.Schema.Types.Mixed
  },
  status: {
    type: String,
    enum: ['unread', 'read', 'dismissed', 'archived'],
    default: 'unread'
  },
  priority: {
    type: String,
    enum: ['low', 'normal', 'high', 'urgent'],
    default: 'normal'
  },
  channels: [{
    type: String,
    enum: ['in_app', 'push', 'email', 'sms']
  }],
  delivery: {
    inApp: {
      delivered: {
        type: Boolean,
        default: false
      },
      deliveredAt: Date,
      readAt: Date
    },
    push: {
      delivered: {
        type: Boolean,
        default: false
      },
      deliveredAt: Date,
      clicked: {
        type: Boolean,
        default: false
      },
      clickedAt: Date,
      pushId: String // External push service ID
    },
    email: {
      delivered: {
        type: Boolean,
        default: false
      },
      deliveredAt: Date,
      opened: {
        type: Boolean,
        default: false
      },
      openedAt: Date,
      emailId: String // External email service ID
    },
    sms: {
      delivered: {
        type: Boolean,
        default: false
      },
      deliveredAt: Date,
      smsId: String // External SMS service ID
    }
  },
  scheduledFor: {
    type: Date,
    default: null // null means send immediately
  },
  expiresAt: {
    type: Date,
    default: null // null means never expires
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 通知模板模式
const notificationTemplateSchema = new mongoose.Schema({
  templateId: {
    type: String,
    required: true,
    unique: true
  },
  name: {
    type: String,
    required: true
  },
  description: String,
  type: {
    type: String,
    enum: [
      'system', 'chat', 'character', 'membership', 'payment', 
      'achievement', 'reminder', 'update', 'promotion', 'warning'
    ],
    required: true
  },
  category: {
    type: String,
    enum: ['info', 'success', 'warning', 'error', 'promotion'],
    default: 'info'
  },
  template: {
    title: {
      type: String,
      required: true
    },
    message: {
      type: String,
      required: true
    },
    variables: [{
      name: String,
      type: {
        type: String,
        enum: ['string', 'number', 'date', 'boolean']
      },
      required: {
        type: Boolean,
        default: false
      },
      defaultValue: String
    }]
  },
  defaultChannels: [{
    type: String,
    enum: ['in_app', 'push', 'email', 'sms']
  }],
  priority: {
    type: String,
    enum: ['low', 'normal', 'high', 'urgent'],
    default: 'normal'
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// 用户通知设置模式
const userNotificationSettingsSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  preferences: {
    inApp: {
      enabled: {
        type: Boolean,
        default: true
      },
      types: {
        system: { type: Boolean, default: true },
        chat: { type: Boolean, default: true },
        character: { type: Boolean, default: true },
        membership: { type: Boolean, default: true },
        payment: { type: Boolean, default: true },
        achievement: { type: Boolean, default: true },
        reminder: { type: Boolean, default: true },
        update: { type: Boolean, default: true },
        promotion: { type: Boolean, default: false },
        warning: { type: Boolean, default: true }
      }
    },
    push: {
      enabled: {
        type: Boolean,
        default: true
      },
      deviceTokens: [{
        token: String,
        platform: {
          type: String,
          enum: ['ios', 'android', 'web']
        },
        addedAt: {
          type: Date,
          default: Date.now
        },
        isActive: {
          type: Boolean,
          default: true
        }
      }],
      types: {
        system: { type: Boolean, default: false },
        chat: { type: Boolean, default: true },
        character: { type: Boolean, default: true },
        membership: { type: Boolean, default: true },
        payment: { type: Boolean, default: true },
        achievement: { type: Boolean, default: true },
        reminder: { type: Boolean, default: true },
        update: { type: Boolean, default: false },
        promotion: { type: Boolean, default: false },
        warning: { type: Boolean, default: true }
      },
      quietHours: {
        enabled: {
          type: Boolean,
          default: false
        },
        startTime: {
          type: String, // HH:MM format
          default: '22:00'
        },
        endTime: {
          type: String, // HH:MM format
          default: '08:00'
        },
        timezone: {
          type: String,
          default: 'Asia/Shanghai'
        }
      }
    },
    email: {
      enabled: {
        type: Boolean,
        default: true
      },
      types: {
        system: { type: Boolean, default: true },
        chat: { type: Boolean, default: false },
        character: { type: Boolean, default: false },
        membership: { type: Boolean, default: true },
        payment: { type: Boolean, default: true },
        achievement: { type: Boolean, default: false },
        reminder: { type: Boolean, default: true },
        update: { type: Boolean, default: true },
        promotion: { type: Boolean, default: false },
        warning: { type: Boolean, default: true }
      },
      frequency: {
        type: String,
        enum: ['immediate', 'daily', 'weekly', 'never'],
        default: 'immediate'
      }
    },
    sms: {
      enabled: {
        type: Boolean,
        default: false
      },
      types: {
        system: { type: Boolean, default: false },
        chat: { type: Boolean, default: false },
        character: { type: Boolean, default: false },
        membership: { type: Boolean, default: true },
        payment: { type: Boolean, default: true },
        achievement: { type: Boolean, default: false },
        reminder: { type: Boolean, default: false },
        update: { type: Boolean, default: false },
        promotion: { type: Boolean, default: false },
        warning: { type: Boolean, default: true }
      }
    }
  }
}, {
  timestamps: true
});

// 索引
notificationSchema.index({ userId: 1, createdAt: -1 });
notificationSchema.index({ status: 1 });
notificationSchema.index({ type: 1 });
notificationSchema.index({ priority: 1 });
notificationSchema.index({ scheduledFor: 1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

notificationTemplateSchema.index({ templateId: 1 });
notificationTemplateSchema.index({ type: 1 });
notificationTemplateSchema.index({ isActive: 1 });

// 虚拟字段
notificationSchema.virtual('isExpired').get(function() {
  return this.expiresAt && this.expiresAt < new Date();
});

notificationSchema.virtual('isScheduled').get(function() {
  return this.scheduledFor && this.scheduledFor > new Date();
});

notificationSchema.virtual('isDelivered').get(function() {
  return this.channels.some(channel => {
    return this.delivery[channel] && this.delivery[channel].delivered;
  });
});

// 实例方法
notificationSchema.methods.markAsRead = function() {
  this.status = 'read';
  if (this.delivery.inApp) {
    this.delivery.inApp.readAt = new Date();
  }
  return this.save();
};

notificationSchema.methods.markAsDelivered = function(channel, externalId) {
  if (this.delivery[channel]) {
    this.delivery[channel].delivered = true;
    this.delivery[channel].deliveredAt = new Date();
    
    if (externalId) {
      switch (channel) {
        case 'push':
          this.delivery[channel].pushId = externalId;
          break;
        case 'email':
          this.delivery[channel].emailId = externalId;
          break;
        case 'sms':
          this.delivery[channel].smsId = externalId;
          break;
      }
    }
  }
  return this.save();
};

notificationSchema.methods.markAsClicked = function(channel) {
  if (channel === 'push' && this.delivery.push) {
    this.delivery.push.clicked = true;
    this.delivery.push.clickedAt = new Date();
  }
  return this.save();
};

notificationSchema.methods.dismiss = function() {
  this.status = 'dismissed';
  return this.save();
};

// 静态方法
notificationSchema.statics.findUnreadByUser = function(userId, options = {}) {
  const { limit = 20, type, priority } = options;
  
  const query = {
    userId,
    status: 'unread',
    isActive: true,
    $or: [
      { expiresAt: null },
      { expiresAt: { $gt: new Date() } }
    ]
  };
  
  if (type) query.type = type;
  if (priority) query.priority = priority;
  
  return this.find(query)
    .sort({ priority: -1, createdAt: -1 })
    .limit(limit)
    .populate('data.characterId', 'name avatar')
    .populate('data.conversationId', 'title');
};

notificationSchema.statics.markAllAsReadByUser = function(userId, type) {
  const query = { userId, status: 'unread' };
  if (type) query.type = type;
  
  return this.updateMany(query, {
    status: 'read',
    'delivery.inApp.readAt': new Date()
  });
};

notificationSchema.statics.getUnreadCountByUser = function(userId, type) {
  const query = {
    userId,
    status: 'unread',
    isActive: true,
    $or: [
      { expiresAt: null },
      { expiresAt: { $gt: new Date() } }
    ]
  };
  
  if (type) query.type = type;
  
  return this.countDocuments(query);
};

notificationTemplateSchema.statics.findByTemplateId = function(templateId) {
  return this.findOne({ templateId, isActive: true });
};

notificationTemplateSchema.methods.render = function(variables = {}) {
  let title = this.template.title;
  let message = this.template.message;
  
  // Replace variables in template
  this.template.variables.forEach(variable => {
    const value = variables[variable.name] || variable.defaultValue || '';
    const placeholder = new RegExp(`{{${variable.name}}}`, 'g');
    
    title = title.replace(placeholder, value);
    message = message.replace(placeholder, value);
  });
  
  return {
    title,
    message,
    type: this.type,
    category: this.category,
    priority: this.priority,
    channels: this.defaultChannels
  };
};

userNotificationSettingsSchema.statics.findByUserId = function(userId) {
  return this.findOne({ userId });
};

userNotificationSettingsSchema.statics.createDefault = function(userId) {
  return this.create({ userId });
};

userNotificationSettingsSchema.methods.isChannelEnabledForType = function(channel, type) {
  const channelPrefs = this.preferences[channel];
  return channelPrefs && channelPrefs.enabled && channelPrefs.types[type];
};

userNotificationSettingsSchema.methods.addDeviceToken = function(token, platform) {
  // Remove existing token if it exists
  this.preferences.push.deviceTokens = this.preferences.push.deviceTokens.filter(
    device => device.token !== token
  );
  
  // Add new token
  this.preferences.push.deviceTokens.push({
    token,
    platform,
    addedAt: new Date(),
    isActive: true
  });
  
  return this.save();
};

userNotificationSettingsSchema.methods.removeDeviceToken = function(token) {
  this.preferences.push.deviceTokens = this.preferences.push.deviceTokens.filter(
    device => device.token !== token
  );
  
  return this.save();
};

const Notification = mongoose.model('Notification', notificationSchema);
const NotificationTemplate = mongoose.model('NotificationTemplate', notificationTemplateSchema);
const UserNotificationSettings = mongoose.model('UserNotificationSettings', userNotificationSettingsSchema);

module.exports = {
  Notification,
  NotificationTemplate,
  UserNotificationSettings
};