import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/girlfriend_provider.dart';
import '../providers/auth_provider.dart';
import '../models/girlfriend_model.dart';
import '../widgets/girlfriend_card.dart';
import '../widgets/filter_panel.dart';
import '../utils/responsive_utils.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToChat;
  
  const HomeScreen({Key? key, this.onNavigateToChat}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = '全部';
  bool _showFilterPanel = false;
  FilterOptions _filterOptions = FilterOptions();
  
  // 筛选标签列表
  final List<String> _filterTags = [
    '全部',
    '新人',
    '热门',
    'VIP',
    '清纯',
    '性感',
    '可爱',
    '御姐',
    '萝莉',
    '成熟',
    '活泼',
    '温柔',
    '冷酷',
    '知性',
    '甜美',
    '高颜值',
    '受欢迎程度',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadGirlfriends();
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }
  
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }
  
  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }
  
  void _showFilterOptions() {
    setState(() {
      _showFilterPanel = true;
    });
  }
  
  void _hideFilterPanel() {
    setState(() {
      _showFilterPanel = false;
    });
  }
  
  void _applyFilters(FilterOptions options) {
    setState(() {
      _filterOptions = options;
      _showFilterPanel = false;
    });
  }
  
  void _resetFilters() {
    setState(() {
      _filterOptions = FilterOptions();
    });
  }
  
  List<GirlfriendModel> _mixVirtualAndRealGirlfriends(List<GirlfriendModel> girlfriends) {
    // 分离虚拟女友和真实女友
    List<GirlfriendModel> virtualGirlfriends = girlfriends.where((g) => g.isVirtual).toList();
    List<GirlfriendModel> realGirlfriends = girlfriends.where((g) => !g.isVirtual).toList();
    
    List<GirlfriendModel> mixedList = [];
    int virtualIndex = 0;
    int realIndex = 0;
    
    // 交叉显示：虚拟-真实-虚拟-真实的模式
    while (virtualIndex < virtualGirlfriends.length || realIndex < realGirlfriends.length) {
      // 添加虚拟女友
      if (virtualIndex < virtualGirlfriends.length) {
        mixedList.add(virtualGirlfriends[virtualIndex]);
        virtualIndex++;
      }
      
      // 添加真实女友
      if (realIndex < realGirlfriends.length) {
        mixedList.add(realGirlfriends[realIndex]);
        realIndex++;
      }
    }
    
    return mixedList;
  }
  
  List<GirlfriendModel> _sortGirlfriendsByFilter(List<GirlfriendModel> girlfriends) {
    switch (_selectedFilter) {
      case '热门':
        // 按亲密度排序（热门度）
        girlfriends.sort((a, b) => b.intimacy.compareTo(a.intimacy));
        break;
      case '使用人次':
        // 按最后消息时间排序（使用频率）
        girlfriends.sort((a, b) {
          if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
          if (a.lastMessageTime == null) return 1;
          if (b.lastMessageTime == null) return -1;
          return b.lastMessageTime!.compareTo(a.lastMessageTime!);
        });
        break;
      case '受欢迎程度':
        // 按亲密度和是否在线综合排序
        girlfriends.sort((a, b) {
          int scoreA = a.intimacy + (a.isOnline ? 50 : 0);
          int scoreB = b.intimacy + (b.isOnline ? 50 : 0);
          return scoreB.compareTo(scoreA);
        });
        break;
      case '上新':
        // 按创建时间排序（最新的在前）
        girlfriends.sort((a, b) {
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!);
        });
        break;
      case '高互动':
        // 按在线状态和亲密度排序
        girlfriends.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return b.intimacy.compareTo(a.intimacy);
        });
        break;
      case '全部':
      default:
        // 默认排序：在线优先，然后按亲密度
        girlfriends.sort((a, b) {
          if (a.isOnline && !b.isOnline) return -1;
          if (!a.isOnline && b.isOnline) return 1;
          return b.intimacy.compareTo(a.intimacy);
        });
        break;
    }
    return girlfriends;
  }
  
  List<GirlfriendModel> _getFilteredGirlfriends(List<GirlfriendModel> girlfriends) {
    // 首先按标签筛选排序
    List<GirlfriendModel> sortedGirlfriends = List.from(girlfriends);
    sortedGirlfriends = _sortGirlfriendsByFilter(sortedGirlfriends);
    
    // 实现虚拟女友和真实女友交叉显示
    sortedGirlfriends = _mixVirtualAndRealGirlfriends(sortedGirlfriends);
    
    // 应用筛选条件
    List<GirlfriendModel> filteredGirlfriends = sortedGirlfriends.where((girlfriend) {
      // 地区筛选
      if (_filterOptions.region != null) {
        final region = girlfriend.traits['region'] as String?;
        if (region != _filterOptions.region) {
          return false;
        }
      }
      
      // 年龄筛选
      if (_filterOptions.ageRange != null) {
        final age = girlfriend.traits['age'] as int? ?? 25;
        if (age < _filterOptions.ageRange!.start || age > _filterOptions.ageRange!.end) {
          return false;
        }
      }
      
      // 身高筛选
      if (_filterOptions.heightRange != null) {
        final height = girlfriend.traits['height'] as int? ?? 165;
        if (height < _filterOptions.heightRange!.start || height > _filterOptions.heightRange!.end) {
          return false;
        }
      }
      
      // 费用筛选
      if (_filterOptions.priceRange != null) {
        final price = girlfriend.traits['price'] as int? ?? 500;
        if (price < _filterOptions.priceRange!.start || price > _filterOptions.priceRange!.end) {
          return false;
        }
      }
      
      // 胸围筛选
      if (_filterOptions.bustSize != null) {
        final bustSize = girlfriend.cupSize ?? girlfriend.traits['bustSize'] as String? ?? 'C';
        if (bustSize != _filterOptions.bustSize) {
          return false;
        }
      }
      
      // 费用区间筛选
      if (_filterOptions.feeRange != null) {
        final fee = girlfriend.traits['fee'] as int? ?? 1000;
        if (fee < _filterOptions.feeRange!.start || fee > _filterOptions.feeRange!.end) {
          return false;
        }
      }
      
      // 服务范围筛选
      if (_filterOptions.serviceScope.isNotEmpty) {
        final services = girlfriend.traits['services'] as List<String>? ?? [];
        bool hasMatchingService = false;
        for (String service in _filterOptions.serviceScope) {
          if (services.contains(service)) {
            hasMatchingService = true;
            break;
          }
        }
        if (!hasMatchingService) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // 如果没有搜索查询，直接返回筛选后的结果
    if (_searchQuery.isEmpty) {
      return filteredGirlfriends;
    }
    
    // 应用搜索过滤
    return filteredGirlfriends.where((girlfriend) {
      // 按名字搜索
      final nameMatch = girlfriend.name.toLowerCase().contains(_searchQuery);
      
      // 按描述搜索
      final descriptionMatch = girlfriend.description.toLowerCase().contains(_searchQuery);
      
      // 按性格搜索
      final personalityMatch = girlfriend.personality.toLowerCase().contains(_searchQuery);
      
      // 按背景搜索
      final backgroundMatch = girlfriend.background?.toLowerCase().contains(_searchQuery) ?? false;
      
      // 按介绍搜索
      final introductionMatch = girlfriend.introduction?.toLowerCase().contains(_searchQuery) ?? false;
      
      // 按小说角色搜索
      final novelCharacterMatch = girlfriend.novelCharacter?.toLowerCase().contains(_searchQuery) ?? false;
      
      // 按声音类型搜索
      final voiceTypeMatch = girlfriend.voiceType?.toLowerCase().contains(_searchQuery) ?? false;
      
      // 按聊天模式搜索
      final chatModeMatch = girlfriend.chatMode?.toLowerCase().contains(_searchQuery) ?? false;
      
      // 按种族搜索
      final raceMatch = girlfriend.race?.toLowerCase().contains(_searchQuery) ?? false;
      
      return nameMatch || descriptionMatch || personalityMatch || backgroundMatch || 
             introductionMatch || novelCharacterMatch || voiceTypeMatch || 
             chatModeMatch || raceMatch;
    }).toList();
  }

  Future<void> _loadGirlfriends() async {
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    
    try {
      await girlfriendProvider.loadGirlfriends();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: ${error.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectGirlfriend(GirlfriendModel girlfriend) async {
    print('选择女友: ${girlfriend.name}');
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context, listen: false);
    girlfriendProvider.setCurrentGirlfriend(girlfriend);
    print('当前女友已设置: ${girlfriendProvider.currentGirlfriend?.name}');
    
    // 确保该角色出现在聊天记录中，如果还没有lastMessageTime则设置一个
    if (girlfriend.lastMessageTime == null) {
      await girlfriendProvider.updateLastMessage(
        girlfriend.id,
        '开始对话', // 设置一个默认的最后消息
      );
    }
    
    // 直接导航到聊天界面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      ),
    );
  }
  
  void _navigateToMembership() {
    // 导航到会员页面
    Navigator.of(context).pushNamed('/membership');
  }

  @override
  Widget build(BuildContext context) {
    final girlfriendProvider = Provider.of<GirlfriendProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final allGirlfriends = girlfriendProvider.girlfriends;
    final girlfriends = _getFilteredGirlfriends(allGirlfriends);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF6B9D).withValues(alpha: 0.8),
                      const Color(0xFFC44569).withValues(alpha: 0.6),
                      const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '欢迎回来',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'AI虚拟女友',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '选择你的专属AI伴侣',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 搜索框
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: '搜索角色名字或标签...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        size: 20,
                                      ),
                                      onPressed: _clearSearch,
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                       ],
                     ),
                   ),
                 ),
               ),
             ),
           ),
           // 标签筛选区域
           SliverToBoxAdapter(
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   const Text(
                     '筛选',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color: Colors.black87,
                     ),
                   ),
                   const SizedBox(height: 12),
                   SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     physics: const BouncingScrollPhysics(),
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     child: Row(
                       children: [
                         ..._filterTags.map((tag) {
                           final isSelected = _selectedFilter == tag;
                           return Padding(
                             padding: const EdgeInsets.only(right: 12),
                             child: FilterChip(
                               label: Text(
                                 tag,
                                 style: TextStyle(
                                   color: isSelected ? Colors.white : const Color(0xFFFF6B9D),
                                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                 ),
                               ),
                               selected: isSelected,
                               onSelected: (selected) {
                                 if (selected) {
                                   _selectFilter(tag);
                                 }
                               },
                               backgroundColor: Colors.white,
                               selectedColor: const Color(0xFFFF6B9D),
                               checkmarkColor: Colors.white,
                               side: BorderSide(
                                 color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey.shade300,
                                 width: 1.5,
                               ),
                               elevation: isSelected ? 4 : 1,
                               shadowColor: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                             ),
                           );
                         }).toList(),
                         // 筛选按钮 - 在受欢迎程度后添加
                         Padding(
                           padding: const EdgeInsets.only(right: 12),
                           child: InkWell(
                             onTap: _showFilterOptions,
                             borderRadius: BorderRadius.circular(20),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               decoration: BoxDecoration(
                                 color: Colors.white,
                                 borderRadius: BorderRadius.circular(20),
                                 border: Border.all(
                                   color: Colors.grey.shade300,
                                   width: 1.5,
                                 ),
                                 boxShadow: [
                                   BoxShadow(
                                     color: Colors.grey.withValues(alpha: 0.2),
                                     blurRadius: 4,
                                     offset: const Offset(0, 2),
                                   ),
                                 ],
                               ),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Icon(
                                     Icons.tune,
                                     size: 16,
                                     color: const Color(0xFFFF6B9D),
                                   ),
                                   const SizedBox(width: 4),
                                   Text(
                                     '筛选',
                                     style: TextStyle(
                                       color: const Color(0xFFFF6B9D),
                                       fontWeight: FontWeight.w500,
                                       fontSize: 14,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         )
                       ],
                     ),
                   ),
                 ],
               ),
             ),
           ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: _isLoading
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '正在加载...',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : girlfriends.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B9D).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.favorite_rounded,
                                    size: 60,
                                    color: const Color(0xFFFF6B9D),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _searchQuery.isNotEmpty ? '没有找到匹配的角色' : '还没有AI女友',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _searchQuery.isNotEmpty 
                                      ? '尝试使用其他关键词搜索，或者创建一个新的AI角色'
                                      : '创建你的第一个AI伴侣，开始美妙的对话吧',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_searchQuery.isNotEmpty) ...[
                                      ElevatedButton.icon(
                                        onPressed: _clearSearch,
                                        icon: const Icon(Icons.clear_rounded),
                                        label: const Text('清除搜索'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed('/create_girlfriend');
                                      },
                                      icon: const Icon(Icons.add_rounded),
                                      label: const Text('创建AI女友'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                    ),
                                    if (_searchQuery.isEmpty) ...[
                                      const SizedBox(width: 16),
                                      OutlinedButton.icon(
                                        onPressed: _loadGirlfriends,
                                        icon: const Icon(Icons.refresh_rounded),
                                        label: const Text('刷新'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          side: const BorderSide(color: Color(0xFFFF6B9D)),
                                          foregroundColor: const Color(0xFFFF6B9D),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.getResponsivePadding(context),
                          vertical: 16,
                        ),
                        sliver: SliverGrid(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ResponsiveUtils.getGridColumns(context),
                            childAspectRatio: ResponsiveUtils.getCardAspectRatio(context),
                            crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 20,
                            mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 20,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, index) {
                              return GirlfriendCard(
                                girlfriend: girlfriends[index],
                                onTap: () => _selectGirlfriend(girlfriends[index]),
                                onUnlockTap: () => _navigateToMembership(),
                              );
                            },
                            childCount: girlfriends.length,
                          ),
                        ),
                      ),
          ),
        ],
      ),
          
          // 遮罩层
          if (_showFilterPanel)
            GestureDetector(
              onTap: _hideFilterPanel,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          
          // 筛选面板
          if (_showFilterPanel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FilterPanel(
                initialOptions: _filterOptions,
                onApply: _applyFilters,
                onCancel: _hideFilterPanel,
                onReset: _resetFilters,
              ),
            ),
        ],
      ),
    );
  }
}