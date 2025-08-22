import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/membership_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final memberships = MembershipModel.getPredefinedMemberships();
    final currentMembershipId = authProvider.user?.membershipId;
    final isMembershipActive = authProvider.isMembershipActive;

    return Scaffold(
      appBar: AppBar(
        title: const Text('会员中心'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 会员状态卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isMembershipActive
                    ? [Colors.purple.shade300, Colors.pink.shade300]
                    : [Colors.grey.shade300, Colors.grey.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isMembershipActive ? Icons.workspace_premium : Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isMembershipActive ? '高级会员' : '普通用户',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isMembershipActive
                      ? '到期时间: ${authProvider.user?.membershipEndDate?.toString().split(' ')[0]}'
                      : '升级会员解锁更多功能',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (isMembershipActive) ...[  
                  const SizedBox(height: 16),
                  CustomButton(
                    text: '取消会员',
                    color: Colors.white,
                    isOutlined: true,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('确认取消'),
                          content: const Text('确定要取消会员吗？取消后将立即失去会员权益。'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('再想想'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('确认取消'),
                            ),
                          ],
                        ),
                      ) ?? false;
                      
                      if (confirmed) {
                        await authProvider.cancelMembership();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('会员已取消')),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
          
          // 会员权益说明
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '会员特权',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBenefitItem(Icons.favorite, '解锁所有高级女友'),
                _buildBenefitItem(Icons.chat, '无限聊天次数'),
                _buildBenefitItem(Icons.mic, '语音和图片功能'),
                _buildBenefitItem(Icons.block, '去除广告'),
                _buildBenefitItem(Icons.support_agent, '优先客服支持'),
              ],
            ),
          ),
          
          const Divider(),
          
          // 会员套餐列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: memberships.length,
              itemBuilder: (context, index) {
                final membership = memberships[index];
                final isCurrentMembership = membership.type.toString() == currentMembershipId;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isCurrentMembership
                        ? BorderSide(color: Colors.pink.shade400, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(membership.icon, color: membership.color),
                            const SizedBox(width: 8),
                            Text(
                              membership.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: membership.color.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '¥${membership.price}',
                                style: TextStyle(
                                  color: membership.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          membership.description,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
                        ...membership.benefits.map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: Colors.green.shade400),
                              const SizedBox(width: 8),
                              Text(benefit),
                            ],
                          ),
                        )),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: isCurrentMembership ? '当前会员' : '立即购买',
                            color: membership.color,
                            onPressed: isCurrentMembership
                                ? null
                                : () => _purchaseMembership(context, authProvider, membership),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.pink.shade400),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _purchaseMembership(BuildContext context, AuthProvider authProvider, MembershipModel membership) async {
    // 在实际应用中，这里会调用支付API
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认购买'),
        content: Text('确定要购买${membership.name}吗？价格：¥${membership.price}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认购买'),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed) {
      final now = DateTime.now();
      DateTime endDate;
      
      switch (membership.type) {
        case MembershipType.monthly:
          endDate = DateTime(now.year, now.month + 1, now.day);
          break;
        case MembershipType.quarterly:
          endDate = DateTime(now.year, now.month + 3, now.day);
          break;
        case MembershipType.yearly:
          endDate = DateTime(now.year + 1, now.month, now.day);
          break;
        case MembershipType.lifetime:
          endDate = DateTime(now.year + 100, now.month, now.day); // 设置一个很远的日期
          break;
        default:
          endDate = now;
          break;
      }
      
      final success = await authProvider.purchaseMembership(
        membership,
        'default',
        membership.price,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${membership.name}购买成功！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('购买失败，请稍后再试')),
        );
      }
    }
  }
}