import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  List<PaymentRecord> _payments = [];
  List<PaymentRecord> _filteredPayments = [];
  List<ReconciliationRecord> _reconciliationRecords = [];
  PaymentStats? _stats;
  bool _isLoading = false;
  String? _error;
  String _selectedStatsPeriod = '本月';

  // Getters
  List<PaymentRecord> get payments => _payments;
  List<PaymentRecord> get filteredPayments => _filteredPayments;
  List<ReconciliationRecord> get reconciliationRecords => _reconciliationRecords;
  PaymentStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatsPeriod => _selectedStatsPeriod;

  // 统计数据快捷访问
  double get todayAmount => _stats?.todayAmount ?? 0.0;
  int get todayCount => _stats?.todayCount ?? 0;
  double get todayTrend => _stats?.todayTrend ?? 0.0;
  double get monthlyRevenue => _stats?.monthlyRevenue ?? 0.0;
  double get monthlyGrowth => _stats?.monthlyGrowth ?? 0.0;
  double get successRate => _stats?.successRate ?? 0.0;
  double get successRateTrend => _stats?.successRateTrend ?? 0.0;
  int get failedCount => _stats?.failedCount ?? 0;
  double get pendingAmount => _stats?.pendingAmount ?? 0.0;
  int get pendingCount => _stats?.pendingCount ?? 0;
  double get pendingTrend => _stats?.pendingTrend ?? 0.0;
  int get reconciledCount => _stats?.reconciledCount ?? 0;
  double get reconciledAmount => _stats?.reconciledAmount ?? 0.0;
  int get exceptionCount => _stats?.exceptionCount ?? 0;
  double get exceptionAmount => _stats?.exceptionAmount ?? 0.0;
  double get reconciliationRate => _stats?.reconciliationRate ?? 0.0;
  Map<String, PaymentMethodStats> get paymentMethodStats => _stats?.paymentMethodStats ?? {};
  List<TopProduct> get topProducts => _stats?.topProducts ?? [];
  List<PaymentRecord> get recentTransactions => _stats?.recentTransactions ?? [];

  // 加载支付数据
  Future<void> loadPaymentData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      _payments = _generateMockPayments();
      _filteredPayments = List.from(_payments);
      _reconciliationRecords = _generateMockReconciliationRecords();
      _stats = _generateMockStats();
      
    } catch (e) {
      _error = '加载支付数据失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 应用筛选条件
  void applyFilters({
    String? searchQuery,
    String? status,
    String? paymentMethod,
    String? timeRange,
    DateTimeRange? customDateRange,
  }) {
    _filteredPayments = _payments.where((payment) {
      // 搜索查询
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!payment.orderNo.toLowerCase().contains(query) &&
            !payment.userId.toLowerCase().contains(query) &&
            !payment.userName.toLowerCase().contains(query) &&
            !payment.productName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 状态筛选
      if (status != null && payment.status != status) {
        return false;
      }

      // 支付方式筛选
      if (paymentMethod != null && payment.paymentMethod != paymentMethod) {
        return false;
      }

      // 时间范围筛选
      if (timeRange != null) {
        final now = DateTime.now();
        DateTime startDate;
        
        switch (timeRange) {
          case '最近7天':
            startDate = now.subtract(const Duration(days: 7));
            break;
          case '最近30天':
            startDate = now.subtract(const Duration(days: 30));
            break;
          case '最近3个月':
            startDate = now.subtract(const Duration(days: 90));
            break;
          case '自定义':
            if (customDateRange != null) {
              if (payment.createdAt.isBefore(customDateRange.start) ||
                  payment.createdAt.isAfter(customDateRange.end.add(const Duration(days: 1)))) {
                return false;
              }
            }
            return true;
          default:
            return true;
        }
        
        if (payment.createdAt.isBefore(startDate)) {
          return false;
        }
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // 更改统计周期
  void changeStatsPeriod(String period) {
    _selectedStatsPeriod = period;
    // 这里可以重新加载对应周期的统计数据
    notifyListeners();
  }

  // 处理退款
  Future<bool> processRefund(String paymentId, double refundAmount, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex != -1) {
        final payment = _payments[paymentIndex];
        _payments[paymentIndex] = payment.copyWith(
          status: '已退款',
          refundAmount: refundAmount,
          refundReason: reason,
          refundedAt: DateTime.now(),
        );
        
        applyFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '处理退款失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 取消订单
  Future<bool> cancelPayment(String paymentId, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex != -1) {
        final payment = _payments[paymentIndex];
        _payments[paymentIndex] = payment.copyWith(
          status: '失败',
          metadata: {...payment.metadata, 'cancelReason': reason},
        );
        
        applyFilters(); // 重新应用筛选
      }
      
      return true;
    } catch (e) {
      _error = '取消订单失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 重发支付通知
  Future<bool> resendPaymentNotification(String paymentId) async {
    try {
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // 这里实现重发通知的逻辑
      
      return true;
    } catch (e) {
      _error = '重发通知失败: $e';
      debugPrint(_error);
      return false;
    }
  }

  // 开始自动对账
  Future<bool> startAutoReconciliation(DateTime startDate, DateTime endDate) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 3));
      
      // 生成新的对账记录
      final batchNo = 'AUTO_${DateTime.now().millisecondsSinceEpoch}';
      final newRecord = ReconciliationRecord(
        id: 'recon_${DateTime.now().millisecondsSinceEpoch}',
        batchNo: batchNo,
        type: 'auto',
        status: '已完成',
        createdAt: DateTime.now(),
        completedAt: DateTime.now().add(const Duration(minutes: 2)),
        totalCount: 150,
        totalAmount: 45600.0,
        successCount: 147,
        successAmount: 44800.0,
        exceptionCount: 3,
        exceptionAmount: 800.0,
        operator: 'system',
        description: '自动对账批次',
      );
      
      _reconciliationRecords.insert(0, newRecord);
      
      return true;
    } catch (e) {
      _error = '自动对账失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 手动对账
  Future<bool> startManualReconciliation(List<String> orderNos, String operator) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      // 生成新的对账记录
      final batchNo = 'MANUAL_${DateTime.now().millisecondsSinceEpoch}';
      final totalAmount = orderNos.length * 150.0; // 模拟金额
      
      final newRecord = ReconciliationRecord(
        id: 'recon_${DateTime.now().millisecondsSinceEpoch}',
        batchNo: batchNo,
        type: 'manual',
        status: '已完成',
        createdAt: DateTime.now(),
        completedAt: DateTime.now().add(const Duration(minutes: 1)),
        totalCount: orderNos.length,
        totalAmount: totalAmount,
        successCount: orderNos.length,
        successAmount: totalAmount,
        exceptionCount: 0,
        exceptionAmount: 0.0,
        operator: operator,
        description: '手动对账批次',
      );
      
      _reconciliationRecords.insert(0, newRecord);
      
      return true;
    } catch (e) {
      _error = '手动对账失败: $e';
      debugPrint(_error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 获取支付详情
  PaymentRecord? getPaymentById(String paymentId) {
    try {
      return _payments.firstWhere((payment) => payment.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  // 获取对账记录详情
  ReconciliationRecord? getReconciliationById(String recordId) {
    try {
      return _reconciliationRecords.firstWhere((record) => record.id == recordId);
    } catch (e) {
      return null;
    }
  }

  // 导出支付记录
  Future<List<Map<String, dynamic>>> exportPaymentRecords({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      var recordsToExport = _payments;
      
      // 应用筛选条件
      if (startDate != null) {
        recordsToExport = recordsToExport.where((p) => p.createdAt.isAfter(startDate)).toList();
      }
      if (endDate != null) {
        recordsToExport = recordsToExport.where((p) => p.createdAt.isBefore(endDate)).toList();
      }
      if (status != null) {
        recordsToExport = recordsToExport.where((p) => p.status == status).toList();
      }
      
      return recordsToExport.map((payment) => payment.toJson()).toList();
    } catch (e) {
      _error = '导出支付记录失败: $e';
      debugPrint(_error);
      return [];
    }
  }

  // 导出财务报表
  Future<Map<String, dynamic>> exportFinancialReport(String period) async {
    try {
      // 模拟生成财务报表
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'period': period,
        'totalRevenue': monthlyRevenue,
        'totalTransactions': todayCount * 30, // 模拟月度数据
        'averageOrderValue': monthlyRevenue / (todayCount * 30),
        'successRate': successRate,
        'paymentMethods': paymentMethodStats,
        'topProducts': topProducts.map((p) => p.toJson()).toList(),
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _error = '导出财务报表失败: $e';
      debugPrint(_error);
      return {};
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 生成模拟支付记录
  List<PaymentRecord> _generateMockPayments() {
    final payments = <PaymentRecord>[];
    final productNames = ['VIP会员', '金币充值', '高级功能', '专属皮肤', '语音包', '表情包'];
    final productTypes = ['membership', 'coins', 'premium_features', 'skin', 'voice', 'emoji'];
    final paymentMethods = ['微信支付', '支付宝', '银行卡', '苹果支付'];
    final statuses = ['成功', '失败', '处理中', '已退款'];
    final random = Random();
    
    for (int i = 0; i < 50; i++) {
      final createdAt = DateTime.now().subtract(Duration(hours: i * 2));
      final status = statuses[i % 4 == 0 ? 1 : 0]; // 大部分成功
      final amount = (random.nextInt(500) + 10).toDouble();
      
      payments.add(PaymentRecord(
        id: 'pay_${(i + 1).toString().padLeft(3, '0')}',
        orderNo: 'ORD${DateTime.now().millisecondsSinceEpoch + i}',
        userId: 'user_${(i % 20 + 1).toString().padLeft(3, '0')}',
        userName: '用户${i % 20 + 1}',
        productName: productNames[i % productNames.length],
        productType: productTypes[i % productTypes.length],
        amount: amount,
        paymentMethod: paymentMethods[i % paymentMethods.length],
        status: status,
        transactionId: status == '成功' ? 'TXN${DateTime.now().millisecondsSinceEpoch + i}' : '',
        gatewayOrderId: 'GW${DateTime.now().millisecondsSinceEpoch + i}',
        createdAt: createdAt,
        completedAt: status == '成功' ? createdAt.add(Duration(seconds: 30 + random.nextInt(300))) : null,
        refundAmount: status == '已退款' ? amount : 0.0,
        refundReason: status == '已退款' ? '用户申请退款' : '',
        clientIp: '192.168.1.${random.nextInt(255)}',
        userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)',
        isReconciled: random.nextBool(),
        reconciledAt: random.nextBool() ? createdAt.add(const Duration(hours: 24)) : null,
      ));
    }
    
    return payments;
  }

  // 生成模拟对账记录
  List<ReconciliationRecord> _generateMockReconciliationRecords() {
    final records = <ReconciliationRecord>[];
    final random = Random();
    
    for (int i = 0; i < 10; i++) {
      final createdAt = DateTime.now().subtract(Duration(days: i));
      final totalCount = 100 + random.nextInt(200);
      final exceptionCount = random.nextInt(5);
      final successCount = totalCount - exceptionCount;
      final totalAmount = totalCount * (50.0 + random.nextDouble() * 200);
      final exceptionAmount = exceptionCount * (50.0 + random.nextDouble() * 200);
      final successAmount = totalAmount - exceptionAmount;
      
      records.add(ReconciliationRecord(
        id: 'recon_${(i + 1).toString().padLeft(3, '0')}',
        batchNo: 'BATCH_${DateTime.now().millisecondsSinceEpoch - (i * 86400000)}',
        type: i % 3 == 0 ? 'manual' : 'auto',
        status: exceptionCount > 0 ? '异常' : '已完成',
        createdAt: createdAt,
        completedAt: createdAt.add(Duration(minutes: 5 + random.nextInt(55))),
        totalCount: totalCount,
        totalAmount: totalAmount,
        successCount: successCount,
        successAmount: successAmount,
        exceptionCount: exceptionCount,
        exceptionAmount: exceptionAmount,
        operator: i % 3 == 0 ? 'admin' : 'system',
        description: i % 3 == 0 ? '手动对账批次' : '自动对账批次',
      ));
    }
    
    return records;
  }

  // 生成模拟统计数据
  PaymentStats _generateMockStats() {
    final random = Random();
    
    // 支付方式统计
    final paymentMethodStats = {
      '微信支付': PaymentMethodStats(
        method: '微信支付',
        count: 1250,
        amount: 45600.0,
        percentage: 45.2,
      ),
      '支付宝': PaymentMethodStats(
        method: '支付宝',
        count: 980,
        amount: 38900.0,
        percentage: 38.5,
      ),
      '银行卡': PaymentMethodStats(
        method: '银行卡',
        count: 320,
        amount: 12800.0,
        percentage: 12.7,
      ),
      '苹果支付': PaymentMethodStats(
        method: '苹果支付',
        count: 95,
        amount: 3700.0,
        percentage: 3.6,
      ),
    };
    
    // 热门商品
    final topProducts = [
      TopProduct(
        id: 'prod_001',
        name: 'VIP会员月卡',
        type: 'membership',
        salesCount: 850,
        revenue: 25500.0,
        avgPrice: 30.0,
      ),
      TopProduct(
        id: 'prod_002',
        name: '金币充值包',
        type: 'coins',
        salesCount: 1200,
        revenue: 18000.0,
        avgPrice: 15.0,
      ),
      TopProduct(
        id: 'prod_003',
        name: '高级功能解锁',
        type: 'premium_features',
        salesCount: 450,
        revenue: 22500.0,
        avgPrice: 50.0,
      ),
      TopProduct(
        id: 'prod_004',
        name: '专属皮肤包',
        type: 'skin',
        salesCount: 320,
        revenue: 9600.0,
        avgPrice: 30.0,
      ),
      TopProduct(
        id: 'prod_005',
        name: '语音包套装',
        type: 'voice',
        salesCount: 280,
        revenue: 8400.0,
        avgPrice: 30.0,
      ),
    ];
    
    // 最近交易
    final recentTransactions = _payments.take(10).toList();
    
    // 收入趋势
    final revenueTrend = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return RevenueTrendPoint(
        date: date,
        amount: 8000.0 + random.nextDouble() * 4000,
        count: 150 + random.nextInt(100),
      );
    });
    
    return PaymentStats(
      todayAmount: 12580.50,
      todayCount: 89,
      todayTrend: 15.8,
      monthlyRevenue: 356780.0,
      monthlyGrowth: 23.5,
      successRate: 96.8,
      successRateTrend: 2.1,
      failedCount: 12,
      pendingAmount: 2340.0,
      pendingCount: 8,
      pendingTrend: 5.2,
      reconciledCount: 2450,
      reconciledAmount: 345600.0,
      exceptionCount: 15,
      exceptionAmount: 4500.0,
      reconciliationRate: 98.5,
      paymentMethodStats: paymentMethodStats,
      topProducts: topProducts,
      recentTransactions: recentTransactions,
      revenueTrend: revenueTrend,
    );
  }
}