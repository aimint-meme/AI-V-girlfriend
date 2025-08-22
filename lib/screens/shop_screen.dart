import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ShopItem> _vipItems = [
    ShopItem(
      id: '1',
      title: 'VIP会员 - 月卡',
      description: '享受专属特权，无限制聊天',
      price: 29.9,
      originalPrice: 39.9,
      icon: Icons.diamond,
      type: ShopItemType.vip,
    ),
    ShopItem(
      id: '2',
      title: 'VIP会员 - 季卡',
      description: '3个月会员，更多优惠',
      price: 79.9,
      originalPrice: 119.7,
      icon: Icons.diamond,
      type: ShopItemType.vip,
    ),
    ShopItem(
      id: '3',
      title: 'VIP会员 - 年卡',
      description: '12个月会员，超值优惠',
      price: 299.9,
      originalPrice: 478.8,
      icon: Icons.diamond,
      type: ShopItemType.vip,
    ),
  ];

  final List<ShopItem> _coinItems = [
    ShopItem(
      id: '4',
      title: '100金币',
      description: '用于解锁特殊功能',
      price: 9.9,
      icon: Icons.monetization_on,
      type: ShopItemType.coin,
      coinAmount: 100,
    ),
    ShopItem(
      id: '5',
      title: '500金币',
      description: '更多金币，更多乐趣',
      price: 39.9,
      originalPrice: 49.5,
      icon: Icons.monetization_on,
      type: ShopItemType.coin,
      coinAmount: 500,
    ),
    ShopItem(
      id: '6',
      title: '1000金币',
      description: '超值金币包',
      price: 69.9,
      originalPrice: 99.0,
      icon: Icons.monetization_on,
      type: ShopItemType.coin,
      coinAmount: 1000,
    ),
  ];

  final List<ShopItem> _giftItems = [
    ShopItem(
      id: '7',
      title: '玫瑰花',
      description: '表达你的爱意',
      price: 1.9,
      icon: Icons.local_florist,
      type: ShopItemType.gift,
    ),
    ShopItem(
      id: '8',
      title: '巧克力',
      description: '甜蜜的礼物',
      price: 3.9,
      icon: Icons.cake,
      type: ShopItemType.gift,
    ),
    ShopItem(
      id: '9',
      title: '钻石戒指',
      description: '珍贵的承诺',
      price: 99.9,
      icon: Icons.diamond_outlined,
      type: ShopItemType.gift,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商城'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade700,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.pink.shade600,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pink.shade400,
          tabs: const [
            Tab(text: 'VIP会员'),
            Tab(text: '金币'),
            Tab(text: '礼物'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.pink.shade50,
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildItemGrid(_vipItems),
            _buildItemGrid(_coinItems),
            _buildItemGrid(_giftItems),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(List<ShopItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.pink.shade600,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Column(
                  children: [
                    if (item.originalPrice != null)
                      Text(
                        '¥${item.originalPrice!.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '¥${item.price.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _purchaseItem(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('购买'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _purchaseItem(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('购买${item.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品: ${item.title}'),
            Text('价格: ¥${item.price.toStringAsFixed(1)}'),
            if (item.coinAmount != null)
              Text('金币数量: ${item.coinAmount}'),
            const SizedBox(height: 16),
            const Text('确认购买此商品？'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPurchase(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认购买'),
          ),
        ],
      ),
    );
  }

  void _processPurchase(ShopItem item) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 模拟购买过程
    switch (item.type) {
      case ShopItemType.vip:
        // 处理VIP购买
        break;
      case ShopItemType.coin:
        // 处理金币购买
        if (item.coinAmount != null) {
          authProvider.addCoins(item.coinAmount!);
        }
        break;
      case ShopItemType.gift:
        // 处理礼物购买
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('购买${item.title}成功！'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

enum ShopItemType { vip, coin, gift }

class ShopItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final IconData icon;
  final ShopItemType type;
  final int? coinAmount;

  ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.icon,
    required this.type,
    this.coinAmount,
  });
}