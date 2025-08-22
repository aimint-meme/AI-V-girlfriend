import 'package:flutter/material.dart';

/// 响应式工具类
class ResponsiveUtils {
  /// 获取屏幕断点
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.mobile;
    } else if (width < 1024) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }
  
  /// 判断是否为移动端
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  /// 判断是否为平板
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }
  
  /// 判断是否为桌面端
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  /// 获取响应式网格列数
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 2; // 移动端2列
    } else if (width < 900) {
      return 3; // 平板3列
    } else if (width < 1200) {
      return 4; // 小桌面4列
    } else {
      return 5; // 大桌面5列
    }
  }
  
  /// 获取响应式间距
  static double getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 16.0; // 移动端
    } else if (width < 1024) {
      return 24.0; // 平板
    } else {
      return 32.0; // 桌面端
    }
  }
  
  /// 获取响应式字体大小
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return baseFontSize * 0.9; // 移动端稍小
    } else if (width < 1024) {
      return baseFontSize; // 平板正常
    } else {
      return baseFontSize * 1.1; // 桌面端稍大
    }
  }
  
  /// 获取响应式卡片宽高比
  static double getCardAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 0.75; // 移动端
    } else if (width < 1024) {
      return 0.8; // 平板
    } else {
      return 0.85; // 桌面端
    }
  }
  
  /// 获取最大内容宽度
  static double getMaxContentWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) {
      return 1200; // 限制最大宽度
    }
    return screenWidth;
  }
}

/// 屏幕尺寸枚举
enum ScreenSize {
  mobile,
  tablet,
  desktop,
}

/// 响应式布局组件
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    
    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

/// 响应式容器组件
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.maxWidth,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.getResponsivePadding(context),
      vertical: 16,
    );
    
    final maxContentWidth = maxWidth ?? ResponsiveUtils.getMaxContentWidth(context);
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }
}