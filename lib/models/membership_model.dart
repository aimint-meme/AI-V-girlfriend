import 'package:flutter/material.dart';

enum MembershipType {
  none,
  monthly,
  quarterly,
  yearly,
  lifetime
}

class MembershipModel {
  final String id;
  final MembershipType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final double price;
  final List<String> benefits;
  final String name;
  final String description;
  final Color color;
  final IconData icon;
  final int durationDays;

  const MembershipModel({
    required this.id,
    required this.type,
    this.startDate,
    this.endDate,
    required this.price,
    required this.benefits,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.durationDays,
  });

  bool get isActive {
    if (type == MembershipType.none) return false;
    if (type == MembershipType.lifetime) return true;
    if (endDate == null) return false;
    return DateTime.now().isBefore(endDate!);
  }

  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'] ?? '',
      type: MembershipType.values[json['type'] ?? 0],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      price: json['price'] ?? 0.0,
      benefits: List<String>.from(json['benefits'] ?? []),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: Color(json['color'] ?? 0xFFFF4081),
      icon: IconData(json['icon'] ?? Icons.star.codePoint, fontFamily: 'MaterialIcons'),
      durationDays: json['durationDays'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'price': price,
      'benefits': benefits,
      'name': name,
      'description': description,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }

  MembershipModel copyWith({
    MembershipType? type,
    DateTime? startDate,
    DateTime? endDate,
    double? price,
    List<String>? benefits,
    String? name,
    String? description,
    Color? color,
    IconData? icon,
  }) {
    return MembershipModel(
      id: this.id,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      price: price ?? this.price,
      benefits: benefits ?? this.benefits,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      durationDays: this.durationDays,
    );
  }

  // 预定义的会员类型
  static List<MembershipModel> getPredefinedMemberships() {
    return [
      MembershipModel(
        id: 'monthly_001',
        type: MembershipType.monthly,
        price: 28.0,
        benefits: [
          '解锁所有高级女友',
          '无限聊天次数',
          '语音和图片功能',
          '去除广告',
        ],
        name: '月度会员',
        description: '每月自动续费，随时可取消',
        color: Colors.pink.shade300,
        icon: Icons.favorite,
        durationDays: 30,
      ),
      MembershipModel(
        id: 'quarterly_001',
        type: MembershipType.quarterly,
        price: 78.0,
        benefits: [
          '解锁所有高级女友',
          '无限聊天次数',
          '语音和图片功能',
          '去除广告',
          '专属头像框',
        ],
        name: '季度会员',
        description: '比月度会员节省13%',
        color: Colors.purple.shade300,
        icon: Icons.diamond,
        durationDays: 90,
      ),
      MembershipModel(
        id: 'yearly_001',
        type: MembershipType.yearly,
        price: 258.0,
        benefits: [
          '解锁所有高级女友',
          '无限聊天次数',
          '语音和图片功能',
          '去除广告',
          '专属头像框',
          '优先客服支持',
          '生日特别祝福',
        ],
        name: '年度会员',
        description: '比月度会员节省28%',
        color: Colors.blue.shade300,
        icon: Icons.workspace_premium,
        durationDays: 365,
      ),
      MembershipModel(
        id: 'lifetime_001',
        type: MembershipType.lifetime,
        price: 998.0,
        benefits: [
          '解锁所有高级女友',
          '无限聊天次数',
          '语音和图片功能',
          '去除广告',
          '专属头像框',
          '优先客服支持',
          '生日特别祝福',
          '终身免费更新',
          '专属定制女友',
        ],
        name: '终身会员',
        description: '一次付费，终身享用',
        color: Colors.amber.shade700,
        durationDays: 99999,
        icon: Icons.auto_awesome,
      ),
    ];
  }
}