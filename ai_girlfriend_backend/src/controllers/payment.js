const { Order, MembershipPlan, UserMembership, Coupon } = require('../models/Payment');
const User = require('../models/User');
const mongoose = require('mongoose');

// @desc    Get membership plans
// @route   GET /api/payment/plans
// @access  Public
const getMembershipPlans = async (req, res) => {
  try {
    const plans = await MembershipPlan.getActivePlans();
    
    res.json({
      success: true,
      data: {
        plans
      }
    });
  } catch (error) {
    console.error('Get membership plans error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get membership plans'
    });
  }
};

// @desc    Create order
// @route   POST /api/payment/orders
// @access  Private
const createOrder = async (req, res) => {
  try {
    const userId = req.user._id;
    const { type, productId, quantity = 1, paymentMethod, couponCode } = req.body;

    let product, amount;

    // Get product details based on type
    switch (type) {
      case 'membership':
        const plan = await MembershipPlan.findOne({ planId: productId, isActive: true });
        if (!plan) {
          return res.status(404).json({
            success: false,
            message: 'Membership plan not found'
          });
        }
        product = {
          id: plan.planId,
          name: plan.name,
          description: plan.description,
          category: 'membership'
        };
        amount = {
          original: plan.pricing.current * quantity,
          discount: 0,
          final: plan.pricing.current * quantity,
          currency: plan.pricing.currency
        };
        break;
        
      case 'coins':
        const coinPackages = {
          'coins_100': { name: '100金币', price: 10, coins: 100 },
          'coins_500': { name: '500金币', price: 45, coins: 500 },
          'coins_1000': { name: '1000金币', price: 80, coins: 1000 },
          'coins_5000': { name: '5000金币', price: 350, coins: 5000 }
        };
        
        const coinPackage = coinPackages[productId];
        if (!coinPackage) {
          return res.status(404).json({
            success: false,
            message: 'Coin package not found'
          });
        }
        
        product = {
          id: productId,
          name: coinPackage.name,
          description: `购买${coinPackage.coins}个金币`,
          category: 'coins'
        };
        amount = {
          original: coinPackage.price * quantity,
          discount: 0,
          final: coinPackage.price * quantity,
          currency: 'CNY'
        };
        break;
        
      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid product type'
        });
    }

    // Apply coupon if provided
    let coupon = null;
    if (couponCode) {
      coupon = await Coupon.findValidCoupon(couponCode);
      if (!coupon) {
        return res.status(400).json({
          success: false,
          message: 'Invalid or expired coupon code'
        });
      }
      
      if (!coupon.canBeUsedBy(userId)) {
        return res.status(400).json({
          success: false,
          message: 'Coupon has already been used by this user'
        });
      }
      
      // Check if coupon is applicable to this product
      if (!coupon.applicableProducts.includes('all') && 
          !coupon.applicableProducts.includes(type)) {
        return res.status(400).json({
          success: false,
          message: 'Coupon is not applicable to this product'
        });
      }
      
      // Apply discount
      if (coupon.type === 'percentage') {
        amount.discount = Math.min(
          amount.original * (coupon.value / 100),
          coupon.maxDiscount || amount.original
        );
      } else if (coupon.type === 'fixed') {
        amount.discount = Math.min(coupon.value, amount.original);
      }
      
      amount.final = Math.max(0, amount.original - amount.discount);
    }

    // Create order
    const order = await Order.create({
      userId,
      type,
      product,
      amount,
      quantity,
      paymentMethod,
      coupon: coupon ? {
        code: coupon.code,
        discountType: coupon.type,
        discountValue: coupon.value,
        appliedAt: new Date()
      } : undefined,
      metadata: {
        userAgent: req.get('User-Agent'),
        ipAddress: req.ip,
        source: 'web'
      }
    });

    // Use coupon
    if (coupon) {
      await coupon.use(userId, order._id);
    }

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        order
      }
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create order'
    });
  }
};

// @desc    Get user orders
// @route   GET /api/payment/orders
// @access  Private
const getUserOrders = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20, status, type } = req.query;

    const orders = await Order.findByUser(userId, {
      status,
      type,
      limit: parseInt(limit),
      page: parseInt(page)
    });

    const total = await Order.countDocuments({
      userId,
      ...(status && { status }),
      ...(type && { type })
    });

    res.json({
      success: true,
      data: {
        orders,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get orders'
    });
  }
};

// @desc    Get order by ID
// @route   GET /api/payment/orders/:orderId
// @access  Private
const getOrderById = async (req, res) => {
  try {
    const { orderId } = req.params;
    const userId = req.user._id;

    const order = await Order.findOne({
      _id: orderId,
      userId
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found'
      });
    }

    res.json({
      success: true,
      data: {
        order
      }
    });
  } catch (error) {
    console.error('Get order by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get order'
    });
  }
};

// @desc    Process payment (mock implementation)
// @route   POST /api/payment/orders/:orderId/pay
// @access  Private
const processPayment = async (req, res) => {
  try {
    const { orderId } = req.params;
    const userId = req.user._id;
    const { paymentDetails } = req.body;

    const order = await Order.findOne({
      _id: orderId,
      userId,
      status: 'pending'
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or already processed'
      });
    }

    if (order.isExpired) {
      order.status = 'cancelled';
      await order.save();
      
      return res.status(400).json({
        success: false,
        message: 'Order has expired'
      });
    }

    // Mock payment processing
    const mockPaymentResult = await mockPaymentGateway(order, paymentDetails);
    
    if (mockPaymentResult.success) {
      // Mark order as paid
      await order.markAsPaid({
        transactionId: mockPaymentResult.transactionId,
        gatewayOrderId: mockPaymentResult.gatewayOrderId,
        gatewayResponse: mockPaymentResult
      });

      // Process order fulfillment
      await fulfillOrder(order);

      res.json({
        success: true,
        message: 'Payment processed successfully',
        data: {
          order,
          transactionId: mockPaymentResult.transactionId
        }
      });
    } else {
      await order.markAsFailed(mockPaymentResult.error);
      
      res.status(400).json({
        success: false,
        message: 'Payment failed',
        error: mockPaymentResult.error
      });
    }
  } catch (error) {
    console.error('Process payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process payment'
    });
  }
};

// @desc    Get user membership
// @route   GET /api/payment/membership
// @access  Private
const getUserMembership = async (req, res) => {
  try {
    const userId = req.user._id;

    const membership = await UserMembership.findActiveByUser(userId);
    
    if (!membership) {
      return res.json({
        success: true,
        data: {
          membership: null,
          plan: {
            type: 'free',
            name: '免费版',
            features: {
              maxCharacters: 1,
              maxKnowledgeBases: 2,
              maxConversationsPerDay: 50
            }
          }
        }
      });
    }

    const plan = await MembershipPlan.findOne({ planId: membership.planId });

    res.json({
      success: true,
      data: {
        membership,
        plan
      }
    });
  } catch (error) {
    console.error('Get user membership error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get membership'
    });
  }
};

// @desc    Validate coupon
// @route   POST /api/payment/coupons/validate
// @access  Private
const validateCoupon = async (req, res) => {
  try {
    const { code, productType, productId } = req.body;
    const userId = req.user._id;

    const coupon = await Coupon.findValidCoupon(code);
    
    if (!coupon) {
      return res.status(404).json({
        success: false,
        message: 'Invalid or expired coupon code'
      });
    }

    if (!coupon.canBeUsedBy(userId)) {
      return res.status(400).json({
        success: false,
        message: 'Coupon has already been used by this user'
      });
    }

    // Check product applicability
    if (!coupon.applicableProducts.includes('all') && 
        !coupon.applicableProducts.includes(productType)) {
      return res.status(400).json({
        success: false,
        message: 'Coupon is not applicable to this product'
      });
    }

    res.json({
      success: true,
      data: {
        coupon: {
          code: coupon.code,
          name: coupon.name,
          description: coupon.description,
          type: coupon.type,
          value: coupon.value,
          maxDiscount: coupon.maxDiscount
        }
      }
    });
  } catch (error) {
    console.error('Validate coupon error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to validate coupon'
    });
  }
};

// @desc    Cancel order
// @route   PUT /api/payment/orders/:orderId/cancel
// @access  Private
const cancelOrder = async (req, res) => {
  try {
    const { orderId } = req.params;
    const userId = req.user._id;

    const order = await Order.findOne({
      _id: orderId,
      userId,
      status: { $in: ['pending', 'processing'] }
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found or cannot be cancelled'
      });
    }

    order.status = 'cancelled';
    await order.save();

    res.json({
      success: true,
      message: 'Order cancelled successfully'
    });
  } catch (error) {
    console.error('Cancel order error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel order'
    });
  }
};

// Helper function: Mock payment gateway
async function mockPaymentGateway(order, paymentDetails) {
  // Simulate payment processing delay
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Mock success/failure (90% success rate)
  const success = Math.random() > 0.1;
  
  if (success) {
    return {
      success: true,
      transactionId: `TXN${Date.now()}${Math.random().toString(36).substring(2, 8).toUpperCase()}`,
      gatewayOrderId: `GW${order.orderNumber}`,
      amount: order.amount.final,
      currency: order.amount.currency,
      paymentMethod: order.paymentMethod,
      processedAt: new Date()
    };
  } else {
    return {
      success: false,
      error: 'Payment declined by bank',
      errorCode: 'PAYMENT_DECLINED'
    };
  }
}

// Helper function: Fulfill order
async function fulfillOrder(order) {
  const session = await mongoose.startSession();
  session.startTransaction();
  
  try {
    switch (order.type) {
      case 'membership':
        await fulfillMembershipOrder(order, session);
        break;
      case 'coins':
        await fulfillCoinsOrder(order, session);
        break;
      default:
        throw new Error(`Unknown order type: ${order.type}`);
    }
    
    await session.commitTransaction();
  } catch (error) {
    await session.abortTransaction();
    throw error;
  } finally {
    session.endSession();
  }
}

// Helper function: Fulfill membership order
async function fulfillMembershipOrder(order, session) {
  const plan = await MembershipPlan.findOne({ planId: order.product.id });
  if (!plan) {
    throw new Error('Membership plan not found');
  }
  
  // Calculate end date
  let endDate = new Date();
  switch (plan.duration.unit) {
    case 'days':
      endDate.setDate(endDate.getDate() + plan.duration.value);
      break;
    case 'months':
      endDate.setMonth(endDate.getMonth() + plan.duration.value);
      break;
    case 'years':
      endDate.setFullYear(endDate.getFullYear() + plan.duration.value);
      break;
    case 'lifetime':
      endDate = new Date('2099-12-31');
      break;
  }
  
  // Create or extend membership
  const existingMembership = await UserMembership.findActiveByUser(order.userId);
  
  if (existingMembership) {
    // Extend existing membership
    if (existingMembership.endDate > new Date()) {
      endDate = new Date(existingMembership.endDate.getTime() + (endDate.getTime() - new Date().getTime()));
    }
    existingMembership.endDate = endDate;
    await existingMembership.save({ session });
  } else {
    // Create new membership
    await UserMembership.create([{
      userId: order.userId,
      planId: plan.planId,
      orderId: order._id,
      endDate
    }], { session });
  }
  
  // Update user membership type
  await User.findByIdAndUpdate(
    order.userId,
    { membershipType: plan.type },
    { session }
  );
}

// Helper function: Fulfill coins order
async function fulfillCoinsOrder(order, session) {
  const coinPackages = {
    'coins_100': 100,
    'coins_500': 500,
    'coins_1000': 1000,
    'coins_5000': 5000
  };
  
  const coinsToAdd = coinPackages[order.product.id] * order.quantity;
  if (!coinsToAdd) {
    throw new Error('Invalid coin package');
  }
  
  await User.findByIdAndUpdate(
    order.userId,
    { $inc: { coins: coinsToAdd } },
    { session }
  );
}

module.exports = {
  getMembershipPlans,
  createOrder,
  getUserOrders,
  getOrderById,
  processPayment,
  getUserMembership,
  validateCoupon,
  cancelOrder
};