import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/coin_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({Key? key}) : super(key: key);

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<CoinTransaction> _transactions = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadDemoTransactions();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadDemoTransactions() {
    // 加载模拟的交易记录
    final now = DateTime.now();
    
    _transactions.addAll([
      CoinTransaction(
        id: const Uuid().v4(),
        type: CoinTransactionType.purchase,
        amount: 500,
        timestamp: now.subtract(const Duration(days: 7)),
        description: '购买金币套餐',
        pricePaid: 45.0,
      ),
      CoinTransaction(
        id: const Uuid().v4(),
        type: CoinTransactionType.consumption,
        amount: 50,
        timestamp: now.subtract(const Duration(days: 5)),
        description: '解锁高级女友聊天',
      ),
      CoinTransaction(
        id: const Uuid().v4(),
        type: CoinTransactionType.reward,
        amount: 20,
        timestamp: now.subtract(const Duration(days: 3)),
        description: '每日签到奖励',
      ),
      CoinTransaction(
        id: const Uuid().v4(),
        type: CoinTransactionType.consumption,
        amount: 30,
        timestamp: now.subtract(const Duration(days: 2)),
        description: '发送语音消息',
      ),
      CoinTransaction(
        id: const Uuid().v4(),
        type: CoinTransactionType.gift,
        amount: 100,
        timestamp: now.subtract(const Duration(days: 1)),
        description: '新用户奖励',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final coinPackages = CoinPackage.getPredefinedPackages();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('金币中心'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '充值金币'),
            Tab(text: '交易记录'),
          ],
          indicatorColor: Colors.pink.shade400,
          labelColor: Colors.pink.shade400,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 充值金币页面
          _buildCoinPurchaseTab(context, authProvider, coinPackages),
          
          // 交易记录页面
          _buildTransactionHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildCoinPurchaseTab(BuildContext context, AuthProvider authProvider, List<CoinPackage> packages) {
    return Column(
      children: [
        // 当前金币余额
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade300, Colors.amber.shade700],
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
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 48,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '当前金币余额',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${authProvider.coinBalance}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 金币用途说明
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '金币用途',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildUsageItem(Icons.lock_open, '解锁高级女友聊天 (50金币/次)'),
              _buildUsageItem(Icons.mic, '发送语音消息 (10金币/次)'),
              _buildUsageItem(Icons.image, '发送图片消息 (20金币/次)'),
              _buildUsageItem(Icons.auto_awesome, '定制女友形象 (200金币/次)'),
            ],
          ),
        ),
        
        const Divider(),
        
        // 金币套餐列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: package.isPopular
                        ? Border.all(color: Colors.amber.shade700, width: 2)
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(
                              package.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (package.isPopular)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '热门',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            if (package.isLimited)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '限时',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '${package.amount}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('金币'),
                            if (package.bonusAmount != null && package.bonusAmount! > 0) ...[  
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  '+${package.bonusAmount}',
                                  style: TextStyle(color: Colors.red.shade500, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '单价: ${package.pricePerCoin}元/金币',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        if (package.isLimited && package.endDate != null) ...[  
                          const SizedBox(height: 4),
                          Text(
                            '限时至: ${DateFormat('yyyy-MM-dd').format(package.endDate!)}',
                            style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: '¥${package.price} 立即购买',
                            color: Colors.amber.shade700,
                            onPressed: () => _purchaseCoins(context, authProvider, package),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistoryTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text('暂无交易记录'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final isConsumption = transaction.type == CoinTransactionType.consumption;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isConsumption ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isConsumption ? Icons.remove_circle : Icons.add_circle,
                    color: isConsumption ? Colors.red.shade400 : Colors.green.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.amountText,
                  style: TextStyle(
                    color: isConsumption ? Colors.red.shade400 : Colors.green.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsageItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Future<void> _purchaseCoins(BuildContext context, AuthProvider authProvider, CoinPackage package) async {
    // 在实际应用中，这里会调用支付API
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认购买'),
        content: Text('确定要购买${package.amount}${package.bonusAmount != null && package.bonusAmount! > 0 ? "+${package.bonusAmount}" : ""}金币吗？价格：¥${package.price}'),
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
      final success = await authProvider.purchaseCoins(
        package.id,
        package.totalAmount,
        package.price,
      );
      
      if (success) {
        // 添加交易记录
        setState(() {
          _transactions.insert(0, CoinTransaction(
            id: const Uuid().v4(),
            type: CoinTransactionType.purchase,
            amount: package.totalAmount,
            timestamp: DateTime.now(),
            description: '购买${package.name}',
            pricePaid: package.price,
          ));
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功购买${package.totalAmount}金币！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('购买失败，请稍后再试')),
        );
      }
    }
  }
}