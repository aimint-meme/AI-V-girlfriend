import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;

  const ChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题区域
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                if (actions != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 图表内容
            child,
          ],
        ),
      ),
    );
  }
}

// 带筛选器的图表卡片
class FilterableChartCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<String> filterOptions;
  final String initialFilter;
  final ValueChanged<String>? onFilterChanged;
  final EdgeInsetsGeometry? padding;

  const FilterableChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.filterOptions,
    required this.initialFilter,
    this.onFilterChanged,
    this.padding,
  });

  @override
  State<FilterableChartCard> createState() => _FilterableChartCardState();
}

class _FilterableChartCardState extends State<FilterableChartCard> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和筛选器
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
                // 筛选器下拉菜单
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isDense: true,
                      style: Theme.of(context).textTheme.bodySmall,
                      items: widget.filterOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFilter = value;
                          });
                          widget.onFilterChanged?.call(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // 图表内容
            widget.child,
          ],
        ),
      ),
    );
  }
}

// 简单的图表容器
class SimpleChartContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const SimpleChartContainer({
    super.key,
    required this.child,
    this.height,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

// 图表图例组件
class ChartLegend extends StatelessWidget {
  final List<LegendItem> items;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ChartLegend({
    super.key,
    required this.items,
    this.direction = Axis.horizontal,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildLegendItems(context),
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _buildLegendItems(context),
      );
    }
  }

  List<Widget> _buildLegendItems(BuildContext context) {
    final widgets = <Widget>[];
    
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
      
      // 添加间距（除了最后一个）
      if (i < items.length - 1) {
        if (direction == Axis.horizontal) {
          widgets.add(const SizedBox(width: 24));
        } else {
          widgets.add(const SizedBox(height: 12));
        }
      }
    }
    
    return widgets;
  }
}

class LegendItem {
  final String label;
  final Color color;
  final String? value;

  const LegendItem({
    required this.label,
    required this.color,
    this.value,
  });
}

// 空状态图表组件
class EmptyChart extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final double height;

  const EmptyChart({
    super.key,
    this.message = '暂无数据',
    this.icon,
    this.onRetry,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.bar_chart,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 加载中的图表组件
class LoadingChart extends StatelessWidget {
  final double height;
  final String? message;

  const LoadingChart({
    super.key,
    this.height = 200,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}