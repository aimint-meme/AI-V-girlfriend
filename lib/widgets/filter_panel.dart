import 'package:flutter/material.dart';

class FilterOptions {
  String? region;
  RangeValues? ageRange;
  RangeValues? heightRange;
  RangeValues? priceRange;
  String? bustSize;
  RangeValues? feeRange;
  List<String> serviceScope;

  FilterOptions({
    this.region,
    this.ageRange,
    this.heightRange,
    this.priceRange,
    this.bustSize,
    this.feeRange,
    this.serviceScope = const [],
  });

  FilterOptions copyWith({
    String? region,
    RangeValues? ageRange,
    RangeValues? heightRange,
    RangeValues? priceRange,
    String? bustSize,
    RangeValues? feeRange,
    List<String>? serviceScope,
  }) {
    return FilterOptions(
      region: region ?? this.region,
      ageRange: ageRange ?? this.ageRange,
      heightRange: heightRange ?? this.heightRange,
      priceRange: priceRange ?? this.priceRange,
      bustSize: bustSize ?? this.bustSize,
      feeRange: feeRange ?? this.feeRange,
      serviceScope: serviceScope ?? this.serviceScope,
    );
  }

  void reset() {
    region = null;
    ageRange = null;
    heightRange = null;
    priceRange = null;
    bustSize = null;
    feeRange = null;
    serviceScope = [];
  }
}

class FilterPanel extends StatefulWidget {
  final FilterOptions initialOptions;
  final Function(FilterOptions) onApply;
  final VoidCallback onCancel;
  final VoidCallback onReset;

  const FilterPanel({
    Key? key,
    required this.initialOptions,
    required this.onApply,
    required this.onCancel,
    required this.onReset,
  }) : super(key: key);

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late FilterOptions _currentOptions;

  // 筛选选项数据
  final List<String> _regions = [
    '全部地区', '北京', '上海', '广州', '深圳', '杭州', '南京', '成都', '重庆', '武汉', '西安', '其他'
  ];
  
  final List<String> _bustSizes = [
    '全部', 'A', 'B', 'C', 'D', 'E', 'F', 'G+'
  ];
  
  final List<String> _serviceScopeOptions = [
    '全部', '可飞', '可口', '三通'
  ];

  @override
  void initState() {
    super.initState();
    _currentOptions = FilterOptions(
      region: widget.initialOptions.region,
      ageRange: widget.initialOptions.ageRange,
      heightRange: widget.initialOptions.heightRange,
      priceRange: widget.initialOptions.priceRange,
      bustSize: widget.initialOptions.bustSize,
      feeRange: widget.initialOptions.feeRange,
      serviceScope: List.from(widget.initialOptions.serviceScope),
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closePanel() async {
    await _animationController.reverse();
    widget.onCancel();
  }

  void _applyFilters() async {
    await _animationController.reverse();
    widget.onApply(_currentOptions);
  }

  void _resetFilters() {
    setState(() {
      _currentOptions.reset();
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * MediaQuery.of(context).size.height * 0.6),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // 头部
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B9D),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _closePanel,
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      const Expanded(
                        child: Text(
                          '筛选条件',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text(
                          '重置',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 筛选内容
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRegionFilter(),
                        const SizedBox(height: 24),
                        _buildAgeFilter(),
                        const SizedBox(height: 24),
                        _buildHeightFilter(),
                        const SizedBox(height: 24),
                        _buildPriceFilter(),
                        const SizedBox(height: 24),
                        _buildBustSizeFilter(),
                        const SizedBox(height: 24),
                        _buildFeeRangeFilter(),
                        const SizedBox(height: 24),
                        _buildServiceScopeFilter(),
                      ],
                    ),
                  ),
                ),
                
                // 底部按钮
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _closePanel,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF6B9D)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            '取消',
                            style: TextStyle(
                              color: Color(0xFFFF6B9D),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B9D),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            '确定',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRegionFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('地区筛选'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _regions.map((region) {
            final isSelected = _currentOptions.region == region || 
                              (region == '全部地区' && _currentOptions.region == null);
            return FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentOptions.region = selected ? (region == '全部地区' ? null : region) : null;
                });
              },
              selectedColor: const Color(0xFFFF6B9D).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFF6B9D),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('年龄筛选'),
        const SizedBox(height: 12),
        RangeSlider(
          values: _currentOptions.ageRange ?? const RangeValues(18, 35),
          min: 18,
          max: 50,
          divisions: 32,
          labels: RangeLabels(
            '${(_currentOptions.ageRange?.start ?? 18).round()}岁',
            '${(_currentOptions.ageRange?.end ?? 35).round()}岁',
          ),
          onChanged: (values) {
            setState(() {
              _currentOptions.ageRange = values;
            });
          },
          activeColor: const Color(0xFFFF6B9D),
        ),
        Text(
          '${(_currentOptions.ageRange?.start ?? 18).round()}岁 - ${(_currentOptions.ageRange?.end ?? 35).round()}岁',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildHeightFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('身高筛选'),
        const SizedBox(height: 12),
        RangeSlider(
          values: _currentOptions.heightRange ?? const RangeValues(150, 175),
          min: 140,
          max: 185,
          divisions: 45,
          labels: RangeLabels(
            '${(_currentOptions.heightRange?.start ?? 150).round()}cm',
            '${(_currentOptions.heightRange?.end ?? 175).round()}cm',
          ),
          onChanged: (values) {
            setState(() {
              _currentOptions.heightRange = values;
            });
          },
          activeColor: const Color(0xFFFF6B9D),
        ),
        Text(
          '${(_currentOptions.heightRange?.start ?? 150).round()}cm - ${(_currentOptions.heightRange?.end ?? 175).round()}cm',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('费用筛选'),
        const SizedBox(height: 12),
        RangeSlider(
          values: _currentOptions.priceRange ?? const RangeValues(100, 1000),
          min: 0,
          max: 2000,
          divisions: 40,
          labels: RangeLabels(
            '¥${(_currentOptions.priceRange?.start ?? 100).round()}',
            '¥${(_currentOptions.priceRange?.end ?? 1000).round()}',
          ),
          onChanged: (values) {
            setState(() {
              _currentOptions.priceRange = values;
            });
          },
          activeColor: const Color(0xFFFF6B9D),
        ),
        Text(
          '¥${(_currentOptions.priceRange?.start ?? 100).round()} - ¥${(_currentOptions.priceRange?.end ?? 1000).round()}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBustSizeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('胸围筛选'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _bustSizes.map((size) {
            final isSelected = _currentOptions.bustSize == size || 
                              (size == '全部' && _currentOptions.bustSize == null);
            return FilterChip(
              label: Text(size),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentOptions.bustSize = selected ? (size == '全部' ? null : size) : null;
                });
              },
              selectedColor: const Color(0xFFFF6B9D).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFF6B9D),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeeRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('费用区间筛选'),
        const SizedBox(height: 12),
        RangeSlider(
          values: _currentOptions.feeRange ?? const RangeValues(500, 2000),
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(
            '¥${(_currentOptions.feeRange?.start ?? 500).round()}',
            '¥${(_currentOptions.feeRange?.end ?? 2000).round()}',
          ),
          onChanged: (values) {
            setState(() {
              _currentOptions.feeRange = values;
            });
          },
          activeColor: const Color(0xFFFF6B9D),
        ),
        Text(
          '¥${(_currentOptions.feeRange?.start ?? 500).round()} - ¥${(_currentOptions.feeRange?.end ?? 2000).round()}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildServiceScopeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('服务范围'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _serviceScopeOptions.map((service) {
            final isSelected = service == '全部' 
                ? _currentOptions.serviceScope.isEmpty
                : _currentOptions.serviceScope.contains(service);
            return FilterChip(
              label: Text(service),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (service == '全部') {
                    if (selected) {
                      _currentOptions.serviceScope.clear();
                    }
                  } else {
                    if (selected) {
                      _currentOptions.serviceScope.add(service);
                    } else {
                      _currentOptions.serviceScope.remove(service);
                    }
                  }
                });
              },
              selectedColor: const Color(0xFFFF6B9D).withOpacity(0.2),
              checkmarkColor: const Color(0xFFFF6B9D),
            );
          }).toList(),
        ),
      ],
    );
  }
}