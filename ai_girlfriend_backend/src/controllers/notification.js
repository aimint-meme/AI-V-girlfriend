const { Notification, NotificationTemplate, UserNotificationSettings } = require('../models/Notification');
const User = require('../models/User');
const mongoose = require('mongoose');

// @desc    Get user notifications
// @route   GET /api/notifications
// @access  Private
const getUserNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page = 1, limit = 20, type, status = 'unread', priority } = req.query;

    const query = {
      userId,
      isActive: true,
      $or: [
        { expiresAt: null },
        { expiresAt: { $gt: new Date() } }
      ]
    };

    if (status !== 'all') {
      query.status = status;
    }
    if (type) query.type = type;
    if (priority) query.priority = priority;

    const notifications = await Notification.find(query)
      .sort({ priority: -1, createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .populate('data.characterId', 'name avatar')
      .populate('data.conversationId', 'title');

    const total = await Notification.countDocuments(query);

    res.json({
      success: true,
      data: {
        notifications,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          pages: Math.ceil(total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Get user notifications error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notifications'
    });
  }
};

// @desc    Get unread notification count
// @route   GET /api/notifications/unread-count
// @access  Private
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user._id;
    const { type } = req.query;

    const count = await Notification.getUnreadCountByUser(userId, type);

    res.json({
      success: true,
      data: {
        count
      }
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get unread count'
    });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:notificationId/read
// @access  Private
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: notificationId,
      userId
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    await notification.markAsRead();

    res.json({
      success: true,
      message: 'Notification marked as read'
    });
  } catch (error) {
    console.error('Mark as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark notification as read'
    });
  }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/read-all
// @access  Private
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user._id;
    const { type } = req.body;

    await Notification.markAllAsReadByUser(userId, type);

    res.json({
      success: true,
      message: 'All notifications marked as read'
    });
  } catch (error) {
    console.error('Mark all as read error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to mark all notifications as read'
    });
  }
};

// @desc    Dismiss notification
// @route   PUT /api/notifications/:notificationId/dismiss
// @access  Private
const dismissNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user._id;

    const notification = await Notification.findOne({
      _id: notificationId,
      userId
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found'
      });
    }

    await notification.dismiss();

    res.json({
      success: true,
      message: 'Notification dismissed'
    });
  } catch (error) {
    console.error('Dismiss notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to dismiss notification'
    });
  }
};

// @desc    Get user notification settings
// @route   GET /api/notifications/settings
// @access  Private
const getNotificationSettings = async (req, res) => {
  try {
    const userId = req.user._id;

    let settings = await UserNotificationSettings.findByUserId(userId);
    
    if (!settings) {
      settings = await UserNotificationSettings.createDefault(userId);
    }

    res.json({
      success: true,
      data: {
        settings
      }
    });
  } catch (error) {
    console.error('Get notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notification settings'
    });
  }
};

// @desc    Update user notification settings
// @route   PUT /api/notifications/settings
// @access  Private
const updateNotificationSettings = async (req, res) => {
  try {
    const userId = req.user._id;
    const { preferences } = req.body;

    let settings = await UserNotificationSettings.findByUserId(userId);
    
    if (!settings) {
      settings = await UserNotificationSettings.createDefault(userId);
    }

    // Update preferences
    settings.preferences = {
      ...settings.preferences,
      ...preferences
    };

    await settings.save();

    res.json({
      success: true,
      message: 'Notification settings updated successfully',
      data: {
        settings
      }
    });
  } catch (error) {
    console.error('Update notification settings error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update notification settings'
    });
  }
};

// @desc    Register device token for push notifications
// @route   POST /api/notifications/device-token
// @access  Private
const registerDeviceToken = async (req, res) => {
  try {
    const userId = req.user._id;
    const { token, platform } = req.body;

    let settings = await UserNotificationSettings.findByUserId(userId);
    
    if (!settings) {
      settings = await UserNotificationSettings.createDefault(userId);
    }

    await settings.addDeviceToken(token, platform);

    res.json({
      success: true,
      message: 'Device token registered successfully'
    });
  } catch (error) {
    console.error('Register device token error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to register device token'
    });
  }
};

// @desc    Remove device token
// @route   DELETE /api/notifications/device-token
// @access  Private
const removeDeviceToken = async (req, res) => {
  try {
    const userId = req.user._id;
    const { token } = req.body;

    const settings = await UserNotificationSettings.findByUserId(userId);
    
    if (settings) {
      await settings.removeDeviceToken(token);
    }

    res.json({
      success: true,
      message: 'Device token removed successfully'
    });
  } catch (error) {
    console.error('Remove device token error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to remove device token'
    });
  }
};

// @desc    Send notification (internal use)
// @route   POST /api/notifications/send
// @access  Private/Admin
const sendNotification = async (req, res) => {
  try {
    const {
      userId,
      type,
      title,
      message,
      data = {},
      channels = ['in_app'],
      priority = 'normal',
      scheduledFor = null
    } = req.body;

    // Verify user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user notification settings
    const settings = await UserNotificationSettings.findByUserId(userId);
    
    // Filter channels based on user preferences
    const enabledChannels = channels.filter(channel => {
      if (!settings) return channel === 'in_app'; // Default to in-app only
      return settings.isChannelEnabledForType(channel, type);
    });

    if (enabledChannels.length === 0) {
      return res.json({
        success: true,
        message: 'Notification not sent - user has disabled all channels for this type'
      });
    }

    // Create notification
    const notification = await Notification.create({
      userId,
      type,
      title,
      message,
      data,
      channels: enabledChannels,
      priority,
      scheduledFor
    });

    // Send notification through enabled channels
    await processNotificationDelivery(notification, settings);

    res.status(201).json({
      success: true,
      message: 'Notification sent successfully',
      data: {
        notification
      }
    });
  } catch (error) {
    console.error('Send notification error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send notification'
    });
  }
};

// @desc    Send notification from template
// @route   POST /api/notifications/send-template
// @access  Private/Admin
const sendNotificationFromTemplate = async (req, res) => {
  try {
    const {
      userId,
      templateId,
      variables = {},
      data = {},
      scheduledFor = null
    } = req.body;

    // Get template
    const template = await NotificationTemplate.findByTemplateId(templateId);
    if (!template) {
      return res.status(404).json({
        success: false,
        message: 'Notification template not found'
      });
    }

    // Render template
    const rendered = template.render(variables);

    // Send notification
    const notification = await Notification.create({
      userId,
      type: rendered.type,
      category: rendered.category,
      title: rendered.title,
      message: rendered.message,
      data,
      channels: rendered.channels,
      priority: rendered.priority,
      scheduledFor
    });

    // Get user settings and process delivery
    const settings = await UserNotificationSettings.findByUserId(userId);
    await processNotificationDelivery(notification, settings);

    res.status(201).json({
      success: true,
      message: 'Notification sent from template successfully',
      data: {
        notification
      }
    });
  } catch (error) {
    console.error('Send notification from template error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send notification from template'
    });
  }
};

// @desc    Get notification templates
// @route   GET /api/notifications/templates
// @access  Private/Admin
const getNotificationTemplates = async (req, res) => {
  try {
    const { type, isActive = true } = req.query;

    const query = {};
    if (type) query.type = type;
    if (isActive !== 'all') query.isActive = isActive === 'true';

    const templates = await NotificationTemplate.find(query)
      .sort({ type: 1, name: 1 });

    res.json({
      success: true,
      data: {
        templates
      }
    });
  } catch (error) {
    console.error('Get notification templates error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get notification templates'
    });
  }
};

// Helper function to process notification delivery
async function processNotificationDelivery(notification, userSettings) {
  const deliveryPromises = [];

  for (const channel of notification.channels) {
    switch (channel) {
      case 'in_app':
        // In-app notifications are stored in database, mark as delivered
        deliveryPromises.push(
          notification.markAsDelivered('inApp')
        );
        break;
        
      case 'push':
        if (userSettings && userSettings.preferences.push.enabled) {
          deliveryPromises.push(
            sendPushNotification(notification, userSettings)
          );
        }
        break;
        
      case 'email':
        if (userSettings && userSettings.preferences.email.enabled) {
          deliveryPromises.push(
            sendEmailNotification(notification, userSettings)
          );
        }
        break;
        
      case 'sms':
        if (userSettings && userSettings.preferences.sms.enabled) {
          deliveryPromises.push(
            sendSMSNotification(notification, userSettings)
          );
        }
        break;
    }
  }

  await Promise.allSettled(deliveryPromises);
}

// Helper function to send push notification
async function sendPushNotification(notification, userSettings) {
  try {
    // Check quiet hours
    if (userSettings.preferences.push.quietHours.enabled) {
      const now = new Date();
      const currentTime = now.toTimeString().substring(0, 5); // HH:MM format
      const startTime = userSettings.preferences.push.quietHours.startTime;
      const endTime = userSettings.preferences.push.quietHours.endTime;
      
      if (isInQuietHours(currentTime, startTime, endTime)) {
        console.log('Skipping push notification due to quiet hours');
        return;
      }
    }

    // Get active device tokens
    const activeTokens = userSettings.preferences.push.deviceTokens
      .filter(device => device.isActive)
      .map(device => device.token);

    if (activeTokens.length === 0) {
      console.log('No active device tokens found');
      return;
    }

    // Mock push notification sending
    // In production, integrate with FCM, APNs, or other push services
    const pushResult = await mockPushNotificationService({
      tokens: activeTokens,
      title: notification.title,
      body: notification.message,
      data: notification.data
    });

    await notification.markAsDelivered('push', pushResult.messageId);
    
    console.log('Push notification sent successfully');
  } catch (error) {
    console.error('Push notification error:', error);
  }
}

// Helper function to send email notification
async function sendEmailNotification(notification, userSettings) {
  try {
    // Mock email sending
    // In production, integrate with SendGrid, AWS SES, or other email services
    const emailResult = await mockEmailService({
      to: notification.userId, // Would need user email
      subject: notification.title,
      body: notification.message,
      data: notification.data
    });

    await notification.markAsDelivered('email', emailResult.messageId);
    
    console.log('Email notification sent successfully');
  } catch (error) {
    console.error('Email notification error:', error);
  }
}

// Helper function to send SMS notification
async function sendSMSNotification(notification, userSettings) {
  try {
    // Mock SMS sending
    // In production, integrate with Twilio, AWS SNS, or other SMS services
    const smsResult = await mockSMSService({
      to: notification.userId, // Would need user phone number
      message: `${notification.title}: ${notification.message}`
    });

    await notification.markAsDelivered('sms', smsResult.messageId);
    
    console.log('SMS notification sent successfully');
  } catch (error) {
    console.error('SMS notification error:', error);
  }
}

// Helper function to check if current time is in quiet hours
function isInQuietHours(currentTime, startTime, endTime) {
  const current = timeToMinutes(currentTime);
  const start = timeToMinutes(startTime);
  const end = timeToMinutes(endTime);
  
  if (start <= end) {
    // Same day range (e.g., 09:00 - 17:00)
    return current >= start && current <= end;
  } else {
    // Overnight range (e.g., 22:00 - 08:00)
    return current >= start || current <= end;
  }
}

// Helper function to convert time string to minutes
function timeToMinutes(timeString) {
  const [hours, minutes] = timeString.split(':').map(Number);
  return hours * 60 + minutes;
}

// Mock services (replace with real implementations)
async function mockPushNotificationService(payload) {
  await new Promise(resolve => setTimeout(resolve, 100));
  return {
    success: true,
    messageId: `push_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`
  };
}

async function mockEmailService(payload) {
  await new Promise(resolve => setTimeout(resolve, 200));
  return {
    success: true,
    messageId: `email_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`
  };
}

async function mockSMSService(payload) {
  await new Promise(resolve => setTimeout(resolve, 150));
  return {
    success: true,
    messageId: `sms_${Date.now()}_${Math.random().toString(36).substring(2, 8)}`
  };
}

module.exports = {
  getUserNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
  dismissNotification,
  getNotificationSettings,
  updateNotificationSettings,
  registerDeviceToken,
  removeDeviceToken,
  sendNotification,
  sendNotificationFromTemplate,
  getNotificationTemplates
};