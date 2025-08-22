import 'package:intl/intl.dart';

enum CoinTransactionType {
  purchase,  // 购买金币
  consumption,  // 消费金币
  reward,  // 奖励金币
  gift,  // 赠送金币
  refund  // 退款
}

class CoinTransaction {
  final String id;
  final CoinTransactionType type;
  final int amount;
  final DateTime timestamp;
  final String description;
  final double? pricePaid;  // 仅适用于购买类型

  CoinTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.timestamp,
    required this.description,
    this.pricePaid,
  });

  factory CoinTransaction.fromJson(Map<String, dynamic> json) {
    return CoinTransaction(
      id: json['id'] ?? '',
      type: CoinTransactionType.values[json['type'] ?? 0],
      amount: json['amount'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      description: json['description'] ?? '',
      pricePaid: json['pricePaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'pricePaid': pricePaid,
    };
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }

  String get typeText {
    switch (type) {
      case CoinTransactionType.purchase:
        return '购买';
      case CoinTransactionType.consumption:
        return '消费';
      case CoinTransactionType.reward:
        return '奖励';
      case CoinTransactionType.gift:
        return '赠送';
      case CoinTransactionType.refund:
        return '退款';
    }
  }

  String get amountText {
    if (type == CoinTransactionType.consumption) {
      return '-$amount';
    } else {
      return '+$amount';
    }
  }
}

class CoinPackage {
  final String id;
  final String name;
  final int amount;
  final double price;
  final int? bonusAmount;
  final bool isPopular;
  final bool isLimited;
  final DateTime? endDate;

  CoinPackage({
    required this.id,
    required this.name,
    required this.amount,
    required this.price,
    this.bonusAmount,
    this.isPopular = false,
    this.isLimited = false,
    this.endDate,
  });

  factory CoinPackage.fromJson(Map<String, dynamic> json) {
    return CoinPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      price: json['price'] ?? 0.0,
      bonusAmount: json['bonusAmount'],
      isPopular: json['isPopular'] ?? false,
      isLimited: json['isLimited'] ?? false,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'price': price,
      'bonusAmount': bonusAmount,
      'isPopular': isPopular,
      'isLimited': isLimited,
      'endDate': endDate?.toIso8601String(),
    };
  }

  int get totalAmount => amount + (bonusAmount ?? 0);

  String get pricePerCoin {
    if (totalAmount == 0) return '0';
    return (price / totalAmount).toStringAsFixed(2);
  }

  bool get isActive {
    if (!isLimited) return true;
    if (endDate == null) return false;
    return DateTime.now().isBefore(endDate!);
  }

  // 预定义的金币套餐
  static List<CoinPackage> getPredefinedPackages() {
    return [
      CoinPackage(
        id: '1',
        name: '小额充值',
        amount: 100,
        price: 10.0,
        isPopular: false,
      ),
      CoinPackage(
        id: '2',
        name: '标准充值',
        amount: 500,
        price: 45.0,
        bonusAmount: 50,
        isPopular: true,
      ),
      CoinPackage(
        id: '3',
        name: '大额充值',
        amount: 1000,
        price: 88.0,
        bonusAmount: 120,
        isPopular: false,
      ),
      CoinPackage(
        id: '4',
        name: '超值充值',
        amount: 2000,
        price: 168.0,
        bonusAmount: 300,
        isPopular: false,
      ),
      CoinPackage(
        id: '5',
        name: '限时特惠',
        amount: 1000,
        price: 68.0,
        bonusAmount: 200,
        isLimited: true,
        endDate: DateTime.now().add(const Duration(days: 7)),
        isPopular: false,
      ),
    ];
  }
}