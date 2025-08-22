class PaymentRecord {
  final String id;
  final String orderNo;
  final String userId;
  final String userName;
  final String productName;
  final String productType; // membership, coins, premium_features
  final double amount;
  final String currency;
  final String paymentMethod; // 微信支付、支付宝、银行卡、苹果支付、其他
  final String status; // 成功、失败、处理中、已退款
  final String transactionId; // 第三方交易流水号
  final String gatewayOrderId; // 支付网关订单号
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? refundedAt;
  final double refundAmount;
  final String refundReason;
  final Map<String, dynamic> metadata;
  final String clientIp;
  final String userAgent;
  final bool isReconciled; // 是否已对账
  final DateTime? reconciledAt;

  PaymentRecord({
    required this.id,
    required this.orderNo,
    required this.userId,
    this.userName = '',
    required this.productName,
    required this.productType,
    required this.amount,
    this.currency = 'CNY',
    required this.paymentMethod,
    required this.status,
    this.transactionId = '',
    this.gatewayOrderId = '',
    required this.createdAt,
    this.completedAt,
    this.refundedAt,
    this.refundAmount = 0.0,
    this.refundReason = '',
    this.metadata = const {},
    this.clientIp = '',
    this.userAgent = '',
    this.isReconciled = false,
    this.reconciledAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? '',
      orderNo: json['orderNo'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      productName: json['productName'] ?? '',
      productType: json['productType'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'CNY',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '处理中',
      transactionId: json['transactionId'] ?? '',
      gatewayOrderId: json['gatewayOrderId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      refundedAt: json['refundedAt'] != null ? DateTime.parse(json['refundedAt']) : null,
      refundAmount: (json['refundAmount'] ?? 0.0).toDouble(),
      refundReason: json['refundReason'] ?? '',
      metadata: json['metadata'] ?? {},
      clientIp: json['clientIp'] ?? '',
      userAgent: json['userAgent'] ?? '',
      isReconciled: json['isReconciled'] ?? false,
      reconciledAt: json['reconciledAt'] != null ? DateTime.parse(json['reconciledAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNo': orderNo,
      'userId': userId,
      'userName': userName,
      'productName': productName,
      'productType': productType,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'gatewayOrderId': gatewayOrderId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'refundedAt': refundedAt?.toIso8601String(),
      'refundAmount': refundAmount,
      'refundReason': refundReason,
      'metadata': metadata,
      'clientIp': clientIp,
      'userAgent': userAgent,
      'isReconciled': isReconciled,
      'reconciledAt': reconciledAt?.toIso8601String(),
    };
  }

  PaymentRecord copyWith({
    String? id,
    String? orderNo,
    String? userId,
    String? userName,
    String? productName,
    String? productType,
    double? amount,
    String? currency,
    String? paymentMethod,
    String? status,
    String? transactionId,
    String? gatewayOrderId,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? refundedAt,
    double? refundAmount,
    String? refundReason,
    Map<String, dynamic>? metadata,
    String? clientIp,
    String? userAgent,
    bool? isReconciled,
    DateTime? reconciledAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      orderNo: orderNo ?? this.orderNo,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      gatewayOrderId: gatewayOrderId ?? this.gatewayOrderId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      refundedAt: refundedAt ?? this.refundedAt,
      refundAmount: refundAmount ?? this.refundAmount,
      refundReason: refundReason ?? this.refundReason,
      metadata: metadata ?? this.metadata,
      clientIp: clientIp ?? this.clientIp,
      userAgent: userAgent ?? this.userAgent,
      isReconciled: isReconciled ?? this.isReconciled,
      reconciledAt: reconciledAt ?? this.reconciledAt,
    );
  }

  // 是否为成功支付
  bool get isSuccessful => status == '成功';

  // 是否为失败支付
  bool get isFailed => status == '失败';

  // 是否为处理中
  bool get isPending => status == '处理中';

  // 是否已退款
  bool get isRefunded => status == '已退款';

  // 获取支付耗时
  Duration? get paymentDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  // 获取净收入（扣除退款）
  double get netAmount => amount - refundAmount;

  // 是否为大额交易
  bool get isLargeTransaction => amount >= 1000.0;

  // 获取支付方式类型
  String get paymentMethodType {
    if (paymentMethod.contains('微信')) return 'wechat';
    if (paymentMethod.contains('支付宝')) return 'alipay';
    if (paymentMethod.contains('银行卡')) return 'bank_card';
    if (paymentMethod.contains('苹果')) return 'apple_pay';
    return 'other';
  }
}

// 对账记录
class ReconciliationRecord {
  final String id;
  final String batchNo;
  final String type; // auto, manual
  final String status; // 已完成、处理中、异常
  final DateTime createdAt;
  final DateTime? completedAt;
  final int totalCount;
  final double totalAmount;
  final int successCount;
  final double successAmount;
  final int exceptionCount;
  final double exceptionAmount;
  final List<String> exceptionOrderNos;
  final String operator;
  final Map<String, dynamic> config;
  final String description;

  ReconciliationRecord({
    required this.id,
    required this.batchNo,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    required this.totalCount,
    required this.totalAmount,
    required this.successCount,
    required this.successAmount,
    required this.exceptionCount,
    required this.exceptionAmount,
    this.exceptionOrderNos = const [],
    this.operator = '',
    this.config = const {},
    this.description = '',
  });

  factory ReconciliationRecord.fromJson(Map<String, dynamic> json) {
    return ReconciliationRecord(
      id: json['id'] ?? '',
      batchNo: json['batchNo'] ?? '',
      type: json['type'] ?? 'auto',
      status: json['status'] ?? '处理中',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      totalCount: json['totalCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      successCount: json['successCount'] ?? 0,
      successAmount: (json['successAmount'] ?? 0.0).toDouble(),
      exceptionCount: json['exceptionCount'] ?? 0,
      exceptionAmount: (json['exceptionAmount'] ?? 0.0).toDouble(),
      exceptionOrderNos: List<String>.from(json['exceptionOrderNos'] ?? []),
      operator: json['operator'] ?? '',
      config: json['config'] ?? {},
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchNo': batchNo,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'totalCount': totalCount,
      'totalAmount': totalAmount,
      'successCount': successCount,
      'successAmount': successAmount,
      'exceptionCount': exceptionCount,
      'exceptionAmount': exceptionAmount,
      'exceptionOrderNos': exceptionOrderNos,
      'operator': operator,
      'config': config,
      'description': description,
    };
  }

  // 对账成功率
  double get successRate {
    if (totalCount == 0) return 0.0;
    return (successCount / totalCount) * 100;
  }

  // 异常率
  double get exceptionRate {
    if (totalCount == 0) return 0.0;
    return (exceptionCount / totalCount) * 100;
  }

  // 对账耗时
  Duration? get reconciliationDuration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  // 是否已完成
  bool get isCompleted => status == '已完成';

  // 是否有异常
  bool get hasExceptions => exceptionCount > 0;
}

// 支付方式统计
class PaymentMethodStats {
  final String method;
  final int count;
  final double amount;
  final double percentage;

  PaymentMethodStats({
    required this.method,
    required this.count,
    required this.amount,
    required this.percentage,
  });

  factory PaymentMethodStats.fromJson(Map<String, dynamic> json) {
    return PaymentMethodStats(
      method: json['method'] ?? '',
      count: json['count'] ?? 0,
      amount: (json['amount'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'count': count,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

// 热门商品
class TopProduct {
  final String id;
  final String name;
  final String type;
  final int salesCount;
  final double revenue;
  final double avgPrice;

  TopProduct({
    required this.id,
    required this.name,
    required this.type,
    required this.salesCount,
    required this.revenue,
    required this.avgPrice,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      salesCount: json['salesCount'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      avgPrice: (json['avgPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'salesCount': salesCount,
      'revenue': revenue,
      'avgPrice': avgPrice,
    };
  }
}

// 收入趋势数据点
class RevenueTrendPoint {
  final DateTime date;
  final double amount;
  final int count;

  RevenueTrendPoint({
    required this.date,
    required this.amount,
    required this.count,
  });

  factory RevenueTrendPoint.fromJson(Map<String, dynamic> json) {
    return RevenueTrendPoint(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0.0).toDouble(),
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'count': count,
    };
  }
}

// 支付统计
class PaymentStats {
  final double todayAmount;
  final int todayCount;
  final double todayTrend;
  final double monthlyRevenue;
  final double monthlyGrowth;
  final double successRate;
  final double successRateTrend;
  final int failedCount;
  final double pendingAmount;
  final int pendingCount;
  final double pendingTrend;
  final int reconciledCount;
  final double reconciledAmount;
  final int exceptionCount;
  final double exceptionAmount;
  final double reconciliationRate;
  final Map<String, PaymentMethodStats> paymentMethodStats;
  final List<TopProduct> topProducts;
  final List<PaymentRecord> recentTransactions;
  final List<RevenueTrendPoint> revenueTrend;

  PaymentStats({
    required this.todayAmount,
    required this.todayCount,
    required this.todayTrend,
    required this.monthlyRevenue,
    required this.monthlyGrowth,
    required this.successRate,
    required this.successRateTrend,
    required this.failedCount,
    required this.pendingAmount,
    required this.pendingCount,
    required this.pendingTrend,
    required this.reconciledCount,
    required this.reconciledAmount,
    required this.exceptionCount,
    required this.exceptionAmount,
    required this.reconciliationRate,
    required this.paymentMethodStats,
    required this.topProducts,
    required this.recentTransactions,
    required this.revenueTrend,
  });

  factory PaymentStats.fromJson(Map<String, dynamic> json) {
    return PaymentStats(
      todayAmount: (json['todayAmount'] ?? 0.0).toDouble(),
      todayCount: json['todayCount'] ?? 0,
      todayTrend: (json['todayTrend'] ?? 0.0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      monthlyGrowth: (json['monthlyGrowth'] ?? 0.0).toDouble(),
      successRate: (json['successRate'] ?? 0.0).toDouble(),
      successRateTrend: (json['successRateTrend'] ?? 0.0).toDouble(),
      failedCount: json['failedCount'] ?? 0,
      pendingAmount: (json['pendingAmount'] ?? 0.0).toDouble(),
      pendingCount: json['pendingCount'] ?? 0,
      pendingTrend: (json['pendingTrend'] ?? 0.0).toDouble(),
      reconciledCount: json['reconciledCount'] ?? 0,
      reconciledAmount: (json['reconciledAmount'] ?? 0.0).toDouble(),
      exceptionCount: json['exceptionCount'] ?? 0,
      exceptionAmount: (json['exceptionAmount'] ?? 0.0).toDouble(),
      reconciliationRate: (json['reconciliationRate'] ?? 0.0).toDouble(),
      paymentMethodStats: (json['paymentMethodStats'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, PaymentMethodStats.fromJson(value))),
      topProducts: (json['topProducts'] as List<dynamic>? ?? [])
          .map((e) => TopProduct.fromJson(e))
          .toList(),
      recentTransactions: (json['recentTransactions'] as List<dynamic>? ?? [])
          .map((e) => PaymentRecord.fromJson(e))
          .toList(),
      revenueTrend: (json['revenueTrend'] as List<dynamic>? ?? [])
          .map((e) => RevenueTrendPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayAmount': todayAmount,
      'todayCount': todayCount,
      'todayTrend': todayTrend,
      'monthlyRevenue': monthlyRevenue,
      'monthlyGrowth': monthlyGrowth,
      'successRate': successRate,
      'successRateTrend': successRateTrend,
      'failedCount': failedCount,
      'pendingAmount': pendingAmount,
      'pendingCount': pendingCount,
      'pendingTrend': pendingTrend,
      'reconciledCount': reconciledCount,
      'reconciledAmount': reconciledAmount,
      'exceptionCount': exceptionCount,
      'exceptionAmount': exceptionAmount,
      'reconciliationRate': reconciliationRate,
      'paymentMethodStats': paymentMethodStats.map((key, value) => MapEntry(key, value.toJson())),
      'topProducts': topProducts.map((e) => e.toJson()).toList(),
      'recentTransactions': recentTransactions.map((e) => e.toJson()).toList(),
      'revenueTrend': revenueTrend.map((e) => e.toJson()).toList(),
    };
  }

  // 获取平均订单金额
  double get averageOrderAmount {
    if (todayCount == 0) return 0.0;
    return todayAmount / todayCount;
  }

  // 获取失败率
  double get failureRate => 100.0 - successRate;

  // 获取待对账率
  double get pendingReconciliationRate {
    if (pendingCount + reconciledCount == 0) return 0.0;
    return (pendingCount / (pendingCount + reconciledCount)) * 100;
  }

  // 获取异常率
  double get exceptionRate {
    if (exceptionCount + reconciledCount == 0) return 0.0;
    return (exceptionCount / (exceptionCount + reconciledCount)) * 100;
  }
}