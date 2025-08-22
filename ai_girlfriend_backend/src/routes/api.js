const express = require('express');
const router = express.Router();

// Import controllers
const authController = require('../controllers/auth');
const userController = require('../controllers/user');
const chatController = require('../controllers/chat');

// Import middleware
const { authenticateToken, requireMembership, userRateLimit } = require('../middleware/auth');
const {
  validateUserRegistration,
  validateUserLogin,
  validateChatMessage,
  validateProfileUpdate,
  validatePasswordChange,
  validateObjectId,
  validatePagination
} = require('../middleware/validation');

// Auth routes
router.post('/auth/register', validateUserRegistration, authController.register);
router.post('/auth/login', validateUserLogin, authController.login);
router.post('/auth/refresh', authController.refreshToken);
router.post('/auth/logout', authenticateToken, authController.logout);
router.get('/auth/me', authenticateToken, authController.getMe);
router.put('/auth/password', authenticateToken, validatePasswordChange, authController.updatePassword);
router.post('/auth/forgot-password', authController.forgotPassword);
router.post('/auth/reset-password', authController.resetPassword);

// User routes
router.get('/user/profile', authenticateToken, userController.getProfile);
router.put('/user/profile', authenticateToken, validateProfileUpdate, userController.updateProfile);
router.get('/user/statistics', authenticateToken, userController.getStatistics);
router.get('/user/characters', authenticateToken, validatePagination, userController.getCharacters);
router.get('/user/conversations', authenticateToken, validatePagination, userController.getConversations);
router.put('/user/preferences', authenticateToken, userController.updatePreferences);
router.post('/user/avatar', authenticateToken, userController.uploadAvatar);
router.delete('/user/account', authenticateToken, userController.deleteAccount);

// Chat routes
router.post('/chat/send', 
  authenticateToken, 
  userRateLimit(50, 15 * 60 * 1000), // 50 messages per 15 minutes
  validateChatMessage, 
  chatController.sendMessage
);

router.get('/chat/history/:conversationId', 
  authenticateToken, 
  validateObjectId('conversationId'), 
  validatePagination, 
  chatController.getChatHistory
);

router.get('/chat/conversations', 
  authenticateToken, 
  validatePagination, 
  chatController.getConversations
);

router.delete('/chat/message/:messageId', 
  authenticateToken, 
  validateObjectId('messageId'), 
  chatController.deleteMessage
);

router.put('/chat/conversation/:conversationId/archive', 
  authenticateToken, 
  validateObjectId('conversationId'), 
  chatController.archiveConversation
);

router.post('/chat/message/:messageId/reaction', 
  authenticateToken, 
  validateObjectId('messageId'), 
  chatController.addReaction
);

router.get('/chat/conversation/:conversationId/summary', 
  authenticateToken, 
  validateObjectId('conversationId'), 
  requireMembership('premium'), // Premium feature
  chatController.getConversationSummary
);

// Character routes
router.use('/characters', require('./characters'));

// Knowledge base routes
router.use('/knowledge', require('./knowledge'));

// Payment routes
router.use('/payment', require('./payment'));

// Notification routes
router.use('/notifications', require('./notifications'));

// Analytics routes
router.use('/analytics', require('./analytics'));

// Content moderation routes
router.use('/moderation', require('./moderation'));

// Security monitoring routes
router.use('/security', require('./security'));

// File upload routes (to be implemented)
// router.use('/upload', require('./upload'));

module.exports = router;