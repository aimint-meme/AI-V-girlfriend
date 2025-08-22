import 'package:flutter/material.dart';
import '../models/knowledge_payment_model.dart';
import '../services/knowledge_unlock_service.dart';

/// 高阶内容标签选择对话框
class AdvancedTagsSelectionDialog extends StatefulWidget {
  final VoidCallback? onSelectionChanged;
  
  const AdvancedTagsSelectionDialog({
    Key? key,
    this.onSelectionChanged,
  }) : super(key: key);
  
  @override
  State<AdvancedTagsSelectionDialog> createState() => _AdvancedTagsSelectionDialogState();
}

class _AdvancedTagsSelectionDialogState extends State<AdvancedTagsSelectionDialog> {
  final KnowledgeUnlockService _unlockService = KnowledgeUnlockService();
  late AdvancedContentUnlock _currentUnlock;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _currentUnlock = _unlockService.advancedContentUnlock;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.label_outline,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '高阶内容标签',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 会员状态信息
            _buildMembershipStatus(),
            const SizedBox(height: 20),
            
            // 标签选择说明
            _buildSelectionInfo(),
            const SizedBox(height: 16),
            
            // 标签列表
            Expanded(
              child: _buildTagsList(),
            ),
            
            const SizedBox(height: 16),
            
            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipStatus() {
    final membershipType = _currentUnlock.membershipType;
    final isMembershipValid = _currentUnlock.isMembershipValid;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (!isMembershipValid) {
      statusColor = Colors.red;
      statusText = '需要购买会员才能解锁高阶内容标签';
      statusIcon = Icons.error_outline;
    } else if (membershipType == MembershipType.lifetime || 
               membershipType == MembershipType.supreme) {
      statusColor = Colors.green;
      statusText = '${KnowledgePaymentConfig.getMembershipTypeName(membershipType)} - 可解锁所有标签';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.orange;
      statusText = '${KnowledgePaymentConfig.getMembershipTypeName(membershipType)} - 可选择8个标签';
      statusIcon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: statusColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSelectionInfo() {
    final unlockedCount = _currentUnlock.unlockedTags.length;
    final maxCount = _getMaxSelectableCount();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.blue.shade600,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              maxCount == -1 
                  ? '已解锁 $unlockedCount 个标签，可解锁所有标签'
                  : '已解锁 $unlockedCount/$maxCount 个标签',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagsList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: AdvancedContentTag.values.length,
      itemBuilder: (context, index) {
        final tag = AdvancedContentTag.values[index];
        return _buildTagItem(tag);
      },
    );
  }
  
  Widget _buildTagItem(AdvancedContentTag tag) {
    final isUnlocked = _currentUnlock.unlockedTags.contains(tag);
    final canUnlock = _currentUnlock.canUnlockTag(tag);
    final tagName = KnowledgePaymentConfig.getAdvancedTagName(tag);
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    
    if (isUnlocked) {
      backgroundColor = Colors.green.shade50;
      borderColor = Colors.green;
      textColor = Colors.green.shade700;
      icon = Icons.check_circle;
    } else if (canUnlock) {
      backgroundColor = Colors.blue.shade50;
      borderColor = Colors.blue.shade300;
      textColor = Colors.blue.shade700;
      icon = Icons.add_circle_outline;
    } else {
      backgroundColor = Colors.grey.shade100;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade500;
      icon = Icons.lock_outline;
    }
    
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: canUnlock && !isUnlocked ? () => _handleTagToggle(tag) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 18,
                  color: textColor,
                ),
              if (icon != null) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tagName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Row(
      children: [
        if (!_currentUnlock.isMembershipValid)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showMembershipPurchase(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('购买会员'),
            ),
          )
        else
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ),
      ],
    );
  }
  
  int _getMaxSelectableCount() {
    final membershipType = _currentUnlock.membershipType;
    if (membershipType == MembershipType.lifetime || 
        membershipType == MembershipType.supreme) {
      return -1; // 无限制
    } else if (membershipType == MembershipType.premium) {
      return 8;
    }
    return 0;
  }
  
  Future<void> _handleTagToggle(AdvancedContentTag tag) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final success = await _unlockService.unlockAdvancedTag(tag);
      
      if (success) {
        setState(() {
          _currentUnlock = _unlockService.advancedContentUnlock;
        });
        
        _showSuccessMessage('标签解锁成功！');
        widget.onSelectionChanged?.call();
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  void _showMembershipPurchase() {
    Navigator.of(context).pop();
    // TODO: 显示会员购买对话框
    _showInfoMessage('请前往会员页面购买会员');
  }
  
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// 高阶内容标签展示组件
class AdvancedTagsDisplay extends StatelessWidget {
  final Set<AdvancedContentTag> unlockedTags;
  final bool showAll;
  final VoidCallback? onTap;
  
  const AdvancedTagsDisplay({
    Key? key,
    required this.unlockedTags,
    this.showAll = false,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final displayTags = showAll 
        ? unlockedTags.toList()
        : unlockedTags.take(3).toList();
    
    if (displayTags.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '选择标签',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          ...displayTags.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Text(
              KnowledgePaymentConfig.getAdvancedTagName(tag),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.purple.shade700,
              ),
            ),
          )).toList(),
          
          if (!showAll && unlockedTags.length > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                '+${unlockedTags.length - 3}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}