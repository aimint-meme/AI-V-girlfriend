import 'package:flutter/material.dart';
import '../models/knowledge_payment_model.dart';
import '../services/knowledge_unlock_service.dart';
import '../services/knowledge_base_service.dart';

/// 知识库付费解锁对话框
class KnowledgePaymentDialog extends StatefulWidget {
  final KnowledgeEntry knowledgeEntry;
  final int userCoins;
  final VoidCallback? onUnlockSuccess;
  
  const KnowledgePaymentDialog({
    Key? key,
    required this.knowledgeEntry,
    required this.userCoins,
    this.onUnlockSuccess,
  }) : super(key: key);
  
  @override
  State<KnowledgePaymentDialog> createState() => _KnowledgePaymentDialogState();
}

class _KnowledgePaymentDialogState extends State<KnowledgePaymentDialog> {
  final KnowledgeUnlockService _unlockService = KnowledgeUnlockService();
  bool _isProcessing = false;
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '解锁知识库',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
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
            
            // 知识库信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.knowledgeEntry.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.knowledgeEntry.previewContent,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPaymentTierColor(widget.knowledgeEntry.paymentTier),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.knowledgeEntry.paymentTierDisplayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.knowledgeEntry.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 解锁选项
            _buildUnlockOptions(),
            
            const SizedBox(height: 20),
            
            // 用户金币信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '当前金币: ${widget.userCoins}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUnlockOptions() {
    final unlockPrice = widget.knowledgeEntry.unlockPrice;
    final isMembershipValid = _unlockService.isMembershipValid;
    final membershipType = _unlockService.currentMembershipType;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '解锁方式',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // 单次购买选项
        if (widget.knowledgeEntry.paymentTier != KnowledgePaymentTier.advanced)
          _buildUnlockOption(
            title: '单次购买',
            subtitle: '永久解锁此知识库',
            price: unlockPrice,
            icon: Icons.shopping_cart_outlined,
            color: Colors.blue,
            onTap: () => _handleSinglePurchase(),
            enabled: widget.userCoins >= unlockPrice,
          ),
        
        // 会员解锁选项
        if (widget.knowledgeEntry.requiresMembership || 
            widget.knowledgeEntry.paymentTier == KnowledgePaymentTier.advanced)
          _buildUnlockOption(
            title: isMembershipValid ? '会员解锁' : '购买会员',
            subtitle: isMembershipValid 
                ? '使用${KnowledgePaymentConfig.getMembershipTypeName(membershipType)}权限解锁'
                : '购买会员后可解锁更多内容',
            price: isMembershipValid ? 0 : KnowledgePaymentConfig.advancedMembershipCost,
            icon: isMembershipValid ? Icons.card_membership : Icons.upgrade,
            color: Colors.purple,
            onTap: () => isMembershipValid 
                ? _handleMembershipUnlock() 
                : _showMembershipPurchase(),
            enabled: isMembershipValid || 
                    widget.userCoins >= KnowledgePaymentConfig.advancedMembershipCost,
          ),
        
        // 全部解锁选项（仅付费层级显示）
        if (widget.knowledgeEntry.paymentTier == KnowledgePaymentTier.premium)
          _buildUnlockOption(
            title: '全部解锁',
            subtitle: '解锁所有付费知识库内容',
            price: KnowledgePaymentConfig.allDocumentsUnlockCost,
            icon: Icons.all_inclusive,
            color: Colors.green,
            onTap: () => _handleAllUnlock(),
            enabled: widget.userCoins >= KnowledgePaymentConfig.allDocumentsUnlockCost,
          ),
      ],
    );
  }
  
  Widget _buildUnlockOption({
    required String title,
    required String subtitle,
    required int price,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled ? color.withValues(alpha: 0.3) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: enabled ? color.withValues(alpha: 0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? color : Colors.grey.shade500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: enabled ? Colors.grey.shade800 : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (price > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: enabled ? color : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$price 金币',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '免费',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getPaymentTierColor(KnowledgePaymentTier tier) {
    switch (tier) {
      case KnowledgePaymentTier.free:
        return Colors.green;
      case KnowledgePaymentTier.premium:
        return Colors.blue;
      case KnowledgePaymentTier.advanced:
        return Colors.purple;
    }
  }
  
  Future<void> _handleSinglePurchase() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final success = await _unlockService.unlockKnowledge(
        knowledgeId: widget.knowledgeEntry.id,
        cost: widget.knowledgeEntry.unlockPrice,
        userCoins: widget.userCoins,
      );
      
      if (success) {
        _showSuccessMessage('知识库解锁成功！');
        widget.onUnlockSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
  
  Future<void> _handleMembershipUnlock() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final success = await _unlockService.unlockKnowledgeByMembership(
        widget.knowledgeEntry.id,
      );
      
      if (success) {
        _showSuccessMessage('通过会员权限解锁成功！');
        widget.onUnlockSuccess?.call();
        Navigator.of(context).pop();
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
    showDialog(
      context: context,
      builder: (context) => MembershipPurchaseDialog(
        userCoins: widget.userCoins,
        onPurchaseSuccess: () {
          // 刷新当前对话框状态
          setState(() {});
        },
      ),
    );
  }
  
  Future<void> _handleAllUnlock() async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认全部解锁'),
        content: Text(
          '确定要花费 ${KnowledgePaymentConfig.allDocumentsUnlockCost} 金币解锁所有付费知识库吗？\n\n'
          '这将永久解锁所有付费层级的知识库内容。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('确认解锁'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // TODO: 实现全部解锁逻辑
      _showSuccessMessage('全部解锁功能开发中...');
    }
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
}

/// 会员购买对话框
class MembershipPurchaseDialog extends StatefulWidget {
  final int userCoins;
  final VoidCallback? onPurchaseSuccess;
  
  const MembershipPurchaseDialog({
    Key? key,
    required this.userCoins,
    this.onPurchaseSuccess,
  }) : super(key: key);
  
  @override
  State<MembershipPurchaseDialog> createState() => _MembershipPurchaseDialogState();
}

class _MembershipPurchaseDialogState extends State<MembershipPurchaseDialog> {
  final KnowledgeUnlockService _unlockService = KnowledgeUnlockService();
  bool _isProcessing = false;
  
  final List<Map<String, dynamic>> _membershipOptions = [
    {
      'type': MembershipType.premium,
      'name': '高级会员',
      'duration': '1年',
      'cost': KnowledgePaymentConfig.advancedMembershipCost,
      'benefits': [
        '解锁所有付费知识库',
        '高阶内容可选择8个标签',
        '会员专属内容',
        '优先客服支持',
      ],
      'color': Colors.purple,
    },
    {
      'type': MembershipType.lifetime,
      'name': '终身会员',
      'duration': '永久',
      'cost': 99999,
      'benefits': [
        '终身享受所有会员权益',
        '解锁所有高阶内容标签',
        '永久免费更新',
        '专属会员标识',
      ],
      'color': Colors.amber,
    },
    {
      'type': MembershipType.supreme,
      'name': '至尊版',
      'duration': '永久',
      'cost': 199999,
      'benefits': [
        '包含终身会员所有权益',
        '独家至尊内容',
        '一对一专属服务',
        '定制化功能开发',
      ],
      'color': Colors.red,
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.purple.shade600,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '购买会员',
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
            
            // 会员选项
            Expanded(
              child: ListView.builder(
                itemCount: _membershipOptions.length,
                itemBuilder: (context, index) {
                  final option = _membershipOptions[index];
                  return _buildMembershipOption(option);
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 用户金币信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '当前金币: ${widget.userCoins}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMembershipOption(Map<String, dynamic> option) {
    final membershipType = option['type'] as MembershipType;
    final name = option['name'] as String;
    final duration = option['duration'] as String;
    final cost = option['cost'] as int;
    final benefits = option['benefits'] as List<String>;
    final color = option['color'] as Color;
    final enabled = widget.userCoins >= cost;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        elevation: enabled ? 2 : 0,
        child: InkWell(
          onTap: enabled ? () => _handlePurchase(membershipType, cost) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled ? color.withValues(alpha: 0.3) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: enabled ? color.withValues(alpha: 0.1) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.workspace_premium,
                        color: enabled ? color : Colors.grey.shade500,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: enabled ? color : Colors.grey.shade500,
                            ),
                          ),
                          Text(
                            duration,
                            style: TextStyle(
                              fontSize: 12,
                              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: enabled ? color : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$cost 金币',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: enabled ? color : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 13,
                            color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handlePurchase(MembershipType membershipType, int cost) async {
    if (_isProcessing) return;
    
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认购买'),
        content: Text(
          '确定要购买${KnowledgePaymentConfig.getMembershipTypeName(membershipType)}吗？\n\n'
          '费用: $cost 金币\n'
          '当前金币: ${widget.userCoins}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认购买'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final success = await _unlockService.purchaseMembership(
        membershipType: membershipType,
        cost: cost,
        userCoins: widget.userCoins,
      );
      
      if (success) {
        _showSuccessMessage('会员购买成功！');
        widget.onPurchaseSuccess?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
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
}