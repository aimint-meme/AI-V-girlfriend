const mongoose = require('mongoose');

// 订单模式
const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['membership', 'coins', 'premium_features', 'character_slots', 'knowledge_bases'],
    required: true
  },
  product: {
    id: String,
    name: String,
    description: String,
    category: String
  },
  amount: {
    original: {
      type: Number,
      required: true
    },
    discount: {
      type: Number,
      default: 0
    },
    final: {
      type: Number,
      required: true
    },
    currency: {
      type: String,
      default: 'CNY'
    }
  },
  quantity: {
    type: Number,
    default: 1,
    min: 1
  },
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded'],
    default: 'pending'
  },
  paymentMethod: {
    type: String,
    enum: ['alipay', 'wechat', 'credit_card', 'paypal', 'apple_pay', 'google_pay'],
    required: true
  },
  paymentDetails: {
    transactionId: String,
    gatewayOrderId: String,
    gatewayResponse: mongoose.Schema.Types.Mixed,
    paidAt: Date,
    refundedAt: Date,
    refundAmount: Number,
    refundReason: String
  },
  coupon: {
    code: String,
    discountType: {
      type: String,
      enum: ['percentage', 'fixed']
    },
    discountValue: Number,
    appliedAt: Date
  },
  metadata: {
    userAgent: String,
    ipAddress: String,
    deviceInfo: String,
    source: String // 'web', 'mobile', 'api'
  },
  expiresAt: {
    type: Date,
    default: () => new Date(Date.now() + 30 * 60 * 1000) // 30 minutes
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 会员套餐模式
const membershipPlanSchema = new mongoose.Schema({
  planId: {
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
    enum: ['free', 'premium', 'vip', 'lifetime'],
    required: true
  },
  duration: {
    value: Number, // 持续时间数值
    unit: {
      type: String,
      enum: ['days', 'months', 'years', 'lifetime']
    }
  },
  pricing: {
    original: Number,
    current: Number,
    currency: {
      type: String,
      default: 'CNY'
    }
  },
  features: {
    maxCharacters: {
      type: Number,
      default: 1
    },
    maxKnowledgeBases: {
      type: Number,
      default: 2
    },
    maxConversationsPerDay: {
      type: Number,
      default: 50
    },
    maxMessagesPerConversation: {
      type: Number,
      default: 100
    },
    aiModelAccess: [{
      type: String,
      enum: ['gpt-3.5-turbo', 'gpt-4', 'claude', 'custom']
    }],
    premiumFeatures: [{
      type: String,
      enum: [
        'voice_chat', 'video_chat', 'image_generation', 'advanced_analytics',
        'conversation_export', 'character_sharing', 'priority_support',
        'custom_themes', 'advanced_personality', 'memory_enhancement'
      ]
    }],
    storageLimit: {
      type: Number, // MB
      default: 100
    },
    apiCallsPerDay: {
      type: Number,
      default: 1000
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  isPopular: {
    type: Boolean,
    default: false
  },
  sortOrder: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

// 用户会员记录模式
const userMembershipSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  planId: {
    type: String,
    required: true
  },
  orderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order'
  },
  status: {
    type: String,
    enum: ['active', 'expired', 'cancelled', 'suspended'],
    default: 'active'
  },
  startDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  endDate: {
    type: Date,
    required: true
  },
  autoRenew: {
    type: Boolean,
    default: false
  },
  renewalReminders: {
    sent7Days: {
      type: Boolean,
      default: false
    },
    sent3Days: {
      type: Boolean,
      default: false
    },
    sent1Day: {
      type: Boolean,
      default: false
    }
  },
  usage: {
    charactersCreated: {
      type: Number,
      default: 0
    },
    knowledgeBasesCreated: {
      type: Number,
      default: 0
    },
    conversationsToday: {
      type: Number,
      default: 0
    },
    messagesThisMonth: {
      type: Number,
      default: 0
    },
    apiCallsToday: {
      type: Number,
      default: 0
    },
    storageUsed: {
      type: Number, // MB
      default: 0
    },
    lastResetDate: {
      type: Date,
      default: Date.now
    }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// 优惠券模式
const couponSchema = new mongoose.Schema({
  code: {
    type: String,
    required: true,
    unique: true,
    uppercase: true,
    trim: true
  },
  name: String,
  description: String,
  type: {
    type: String,
    enum: ['percentage', 'fixed', 'free_trial'],
    required: true
  },
  value: {
    type: Number,
    required: true
  },
  minAmount: {
    type: Number,
    default: 0
  },
  maxDiscount: Number, // 最大折扣金额（百分比折扣时使用）
  applicableProducts: [{
    type: String,
    enum: ['membership', 'coins', 'premium_features', 'all']
  }],
  applicablePlans: [String], // 适用的会员套餐ID
  usage: {
    maxUses: {
      type: Number,
      default: 1
    },
    maxUsesPerUser: {
      type: Number,
      default: 1
    },
    currentUses: {
      type: Number,
      default: 0
    },
    usedBy: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      usedAt: {
        type: Date,
        default: Date.now
      },
      orderId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Order'
      }
    }]
  },
  validity: {
    startDate: {
      type: Date,
      required: true
    },
    endDate: {
      type: Date,
      required: true
    }
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User' // 管理员用户
  }
}, {
  timestamps: true
});

// 索引
orderSchema.index({ userId: 1, createdAt: -1 });
orderSchema.index({ status: 1 });
orderSchema.index({ 'paymentDetails.transactionId': 1 });
orderSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

userMembershipSchema.index({ userId: 1 });
userMembershipSchema.index({ status: 1 });
userMembershipSchema.index({ endDate: 1 });

couponSchema.index({ code: 1 });
couponSchema.index({ 'validity.startDate': 1, 'validity.endDate': 1 });
couponSchema.index({ isActive: 1 });

// 虚拟字段
orderSchema.virtual('isExpired').get(function() {
  return this.expiresAt < new Date();
});

orderSchema.virtual('discountAmount').get(function() {
  return this.amount.original - this.amount.final;
});

userMembershipSchema.virtual('isExpired').get(function() {
  return this.endDate < new Date();
});

userMembershipSchema.virtual('daysRemaining').get(function() {
  const now = new Date();
  const diffTime = this.endDate - now;
  return Math.max(0, Math.ceil(diffTime / (1000 * 60 * 60 * 24)));
});

couponSchema.virtual('isValid').get(function() {
  const now = new Date();
  return this.isActive && 
         this.validity.startDate <= now && 
         this.validity.endDate >= now &&
         this.usage.currentUses < this.usage.maxUses;
});

// 方法
orderSchema.methods.generateOrderNumber = function() {
  const timestamp = Date.now().toString();
  const random = Math.random().toString(36).substring(2, 8).toUpperCase();
  this.orderNumber = `ORD${timestamp}${random}`;
};

orderSchema.methods.markAsPaid = function(paymentDetails) {
  this.status = 'completed';
  this.paymentDetails = {
    ...this.paymentDetails,
    ...paymentDetails,
    paidAt: new Date()
  };
  return this.save();
};

orderSchema.methods.markAsFailed = function(reason) {
  this.status = 'failed';
  this.paymentDetails.failureReason = reason;
  return this.save();
};

userMembershipSchema.methods.extend = function(days) {
  this.endDate = new Date(this.endDate.getTime() + days * 24 * 60 * 60 * 1000);
  return this.save();
};

userMembershipSchema.methods.cancel = function() {
  this.status = 'cancelled';
  this.autoRenew = false;
  return this.save();
};

userMembershipSchema.methods.resetDailyUsage = function() {
  const today = new Date();
  const lastReset = this.usage.lastResetDate;
  
  if (!lastReset || lastReset.toDateString() !== today.toDateString()) {
    this.usage.conversationsToday = 0;
    this.usage.apiCallsToday = 0;
    this.usage.lastResetDate = today;
    return this.save();
  }
};

couponSchema.methods.canBeUsedBy = function(userId) {
  if (!this.isValid) return false;
  
  const userUsage = this.usage.usedBy.filter(usage => 
    usage.userId.toString() === userId.toString()
  ).length;
  
  return userUsage < this.usage.maxUsesPerUser;
};

couponSchema.methods.use = function(userId, orderId) {
  if (!this.canBeUsedBy(userId)) {
    throw new Error('Coupon cannot be used by this user');
  }
  
  this.usage.currentUses += 1;
  this.usage.usedBy.push({
    userId,
    orderId,
    usedAt: new Date()
  });
  
  return this.save();
};

// 静态方法
orderSchema.statics.findByUser = function(userId, options = {}) {
  const { status, type, limit = 20, page = 1 } = options;
  
  const query = { userId };
  if (status) query.status = status;
  if (type) query.type = type;
  
  return this.find(query)
    .sort({ createdAt: -1 })
    .limit(limit)
    .skip((page - 1) * limit);
};

membershipPlanSchema.statics.getActivePlans = function() {
  return this.find({ isActive: true }).sort({ sortOrder: 1, pricing.current: 1 });
};

userMembershipSchema.statics.findActiveByUser = function(userId) {
  return this.findOne({
    userId,
    status: 'active',
    endDate: { $gt: new Date() }
  });
};

couponSchema.statics.findValidCoupon = function(code) {
  const now = new Date();
  return this.findOne({
    code: code.toUpperCase(),
    isActive: true,
    'validity.startDate': { $lte: now },
    'validity.endDate': { $gte: now },
    $expr: { $lt: ['$usage.currentUses', '$usage.maxUses'] }
  });
};

// Pre-save 中间件
orderSchema.pre('save', function(next) {
  if (this.isNew && !this.orderNumber) {
    this.generateOrderNumber();
  }
  next();
});

const Order = mongoose.model('Order', orderSchema);
const MembershipPlan = mongoose.model('MembershipPlan', membershipPlanSchema);
const UserMembership = mongoose.model('UserMembership', userMembershipSchema);
const Coupon = mongoose.model('Coupon', couponSchema);

module.exports = {
  Order,
  MembershipPlan,
  UserMembership,
  Coupon
};