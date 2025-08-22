import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/admin_layout.dart';
import '../../widgets/stat_card.dart';
import '../../constants/app_theme.dart';
import '../../providers/system_settings_provider.dart';

class ApiManagementScreen extends StatefulWidget {
  const ApiManagementScreen({super.key});

  @override
  State<ApiManagementScreen> createState() => _ApiManagementScreenState();
}

class _ApiManagementScreenState extends State<ApiManagementScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Azure OpenAI 配置
  final TextEditingController _azureEndpointController = TextEditingController();
  final TextEditingController _azureApiKeyController = TextEditingController();
  final TextEditingController _azureDeploymentController = TextEditingController();
  
  // AWS 配置
  final TextEditingController _awsAccessKeyController = TextEditingController();
  final TextEditingController _awsSecretKeyController = TextEditingController();
  final TextEditingController _awsRegionController = TextEditingController();
  
  // 计费配置
  String _selectedBillingModel = 'usage_based';
  double _monthlyBudget = 1000.0;
  double _alertThreshold = 80.0;
  bool _autoScaling = true;
  bool _costOptimization = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SystemSettingsProvider>().loadApiSettings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _azureEndpointController.dispose();
    _azureApiKeyController.dispose();
    _azureDeploymentController.dispose();
    _awsAccessKeyController.dispose();
    _awsSecretKeyController.dispose();
    _awsRegionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: '/settings/api',
      child: Consumer<SystemSettingsProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 页面标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API接口管理',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '管理第三方服务集成和基于使用情况的计费模型',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _testConnections(),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('测试连接'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _saveApiSettings(),
                          icon: const Icon(Icons.save),
                          label: const Text('保存配置'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 统计卡片
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: '本月费用',
                        value: '\$${provider.monthlySpend.toStringAsFixed(2)}',
                        subtitle: '预算: \$${_monthlyBudget.toStringAsFixed(0)}',
                        trend: provider.spendTrend,
                        icon: Icons.attach_money,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: 'API调用量',
                        value: NumberFormat('#,##0').format(provider.totalApiCalls),
                        subtitle: '今日: ${NumberFormat('#,##0').format(provider.todayApiCalls)}',
                        trend: provider.apiCallTrend,
                        icon: Icons.api,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '平均响应时间',
                        value: '${provider.avgResponseTime}ms',
                        subtitle: '可用性: ${provider.availability.toStringAsFixed(1)}%',
                        trend: provider.responseTrend,
                        icon: Icons.speed,
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        title: '成本效率',
                        value: '\$${provider.costPerCall.toStringAsFixed(4)}',
                        subtitle: '每次调用平均成本',
                        trend: provider.costEfficiencyTrend,
                        icon: Icons.trending_down,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 标签页
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 标签栏
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primary,
                            unselectedLabelColor: Colors.grey.shade600,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.cloud),
                                text: 'Azure OpenAI',
                              ),
                              Tab(
                                icon: Icon(Icons.cloud_queue),
                                text: 'AWS服务',
                              ),
                              Tab(
                                icon: Icon(Icons.account_balance),
                                text: '计费模型',
                              ),
                              Tab(
                                icon: Icon(Icons.analytics),
                                text: '使用分析',
                              ),
                            ],
                          ),
                        ),
                        // 标签页内容
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildAzureOpenAITab(provider),
                              _buildAWSTab(provider),
                              _buildBillingModelTab(provider),
                              _buildUsageAnalyticsTab(provider),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAzureOpenAITab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Azure OpenAI 配置',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // 基础配置
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _azureEndpointController,
                    decoration: const InputDecoration(
                      labelText: 'Azure Endpoint *',
                      hintText: 'https://your-resource.openai.azure.com/',
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Azure Endpoint';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _azureApiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'API Key *',
                      hintText: '输入您的API密钥',
                      prefixIcon: Icon(Icons.key),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入API Key';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _azureDeploymentController,
                    decoration: const InputDecoration(
                      labelText: 'Deployment Name *',
                      hintText: 'gpt-35-turbo',
                      prefixIcon: Icon(Icons.settings),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入Deployment Name';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'API版本',
                      prefixIcon: Icon(Icons.info),
                    ),
                    value: '2023-12-01-preview',
                    items: [
                      '2023-12-01-preview',
                      '2023-10-01-preview',
                      '2023-08-01-preview',
                      '2023-06-01-preview',
                    ].map((version) => DropdownMenuItem(
                      value: version,
                      child: Text(version),
                    )).toList(),
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 模型配置
            Text(
              '模型配置',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Temperature',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Slider(
                              value: 0.7,
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: '0.7',
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Max Tokens',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Slider(
                              value: 1000,
                              min: 100,
                              max: 4000,
                              divisions: 39,
                              label: '1000',
                              onChanged: (value) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 连接状态
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '连接状态：正常',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '最后测试时间：${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _testAzureConnection(),
                    child: const Text('测试连接'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAWSTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AWS 服务配置',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // AWS 凭证配置
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _awsAccessKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Access Key ID *',
                    hintText: 'AKIA...',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _awsSecretKeyController,
                  decoration: const InputDecoration(
                    labelText: 'Secret Access Key *',
                    hintText: '输入您的密钥',
                    prefixIcon: Icon(Icons.security),
                  ),
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'AWS Region',
                    prefixIcon: Icon(Icons.public),
                  ),
                  value: 'us-east-1',
                  items: [
                    'us-east-1',
                    'us-west-2',
                    'eu-west-1',
                    'ap-southeast-1',
                    'ap-northeast-1',
                  ].map((region) => DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  )).toList(),
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // AWS 服务配置
          Text(
            'AWS 服务配置',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildAWSServiceCard(
                  'Amazon Bedrock',
                  'Claude, Llama等模型',
                  Icons.psychology,
                  AppColors.primary,
                  true,
                ),
                _buildAWSServiceCard(
                  'Amazon Polly',
                  '文本转语音服务',
                  Icons.record_voice_over,
                  AppColors.success,
                  false,
                ),
                _buildAWSServiceCard(
                  'Amazon Transcribe',
                  '语音转文本服务',
                  Icons.mic,
                  AppColors.info,
                  true,
                ),
                _buildAWSServiceCard(
                  'Amazon Translate',
                  '机器翻译服务',
                  Icons.translate,
                  AppColors.warning,
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingModelTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '计费模型配置',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // 计费模式选择
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '计费模式',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('按使用量计费'),
                        subtitle: const Text('根据实际API调用次数和Token使用量计费'),
                        value: 'usage_based',
                        groupValue: _selectedBillingModel,
                        onChanged: (value) {
                          setState(() {
                            _selectedBillingModel = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('预付费模式'),
                        subtitle: const Text('预先购买Token包，用完后自动续费'),
                        value: 'prepaid',
                        groupValue: _selectedBillingModel,
                        onChanged: (value) {
                          setState(() {
                            _selectedBillingModel = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 预算和告警设置
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '月度预算设置',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        initialValue: _monthlyBudget.toString(),
                        decoration: const InputDecoration(
                          labelText: '月度预算 (USD)',
                          prefixText: '\$ ',
                          suffixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _monthlyBudget = double.tryParse(value) ?? 1000.0;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        '告警阈值: ${_alertThreshold.toStringAsFixed(0)}%',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Slider(
                        value: _alertThreshold,
                        min: 50,
                        max: 95,
                        divisions: 9,
                        label: '${_alertThreshold.toStringAsFixed(0)}%',
                        onChanged: (value) {
                          setState(() {
                            _alertThreshold = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '成本优化设置',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('自动扩缩容'),
                        subtitle: const Text('根据使用量自动调整资源'),
                        value: _autoScaling,
                        onChanged: (value) {
                          setState(() {
                            _autoScaling = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('成本优化'),
                        subtitle: const Text('启用智能成本优化策略'),
                        value: _costOptimization,
                        onChanged: (value) {
                          setState(() {
                            _costOptimization = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 计费详情
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '计费详情',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: ListView(
                      children: [
                        _buildBillingDetailItem(
                          'Azure OpenAI GPT-4',
                          '\$0.03 / 1K tokens',
                          '156,420 tokens',
                          '\$4.69',
                        ),
                        _buildBillingDetailItem(
                          'Azure OpenAI GPT-3.5',
                          '\$0.002 / 1K tokens',
                          '892,350 tokens',
                          '\$1.78',
                        ),
                        _buildBillingDetailItem(
                          'AWS Bedrock Claude',
                          '\$0.008 / 1K tokens',
                          '234,560 tokens',
                          '\$1.88',
                        ),
                        _buildBillingDetailItem(
                          'AWS Polly TTS',
                          '\$4.00 / 1M chars',
                          '45,230 chars',
                          '\$0.18',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageAnalyticsTab(SystemSettingsProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 使用分析概览
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '使用量趋势',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'API使用量趋势图表\n（此处可集成图表库）',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '成本分析',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              '成本分析图表\n（此处可集成图表库）',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // 详细统计
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '服务使用排行',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildUsageRankItem('Azure OpenAI GPT-4', '45.2%', AppColors.primary),
                              _buildUsageRankItem('Azure OpenAI GPT-3.5', '32.8%', AppColors.success),
                              _buildUsageRankItem('AWS Bedrock Claude', '15.6%', AppColors.warning),
                              _buildUsageRankItem('AWS Polly TTS', '6.4%', AppColors.info),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '成本分布',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildCostDistributionItem('模型推理', '\$6.35', '76.2%'),
                              _buildCostDistributionItem('语音合成', '\$1.24', '14.9%'),
                              _buildCostDistributionItem('数据传输', '\$0.52', '6.2%'),
                              _buildCostDistributionItem('存储费用', '\$0.22', '2.7%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAWSServiceCard(String title, String description, IconData icon, Color color, bool enabled) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enabled ? color.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? color.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: enabled ? color : Colors.grey,
                size: 32,
              ),
              Switch(
                value: enabled,
                onChanged: (value) {},
                activeColor: color,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: enabled ? AppTheme.textSecondaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingDetailItem(String service, String rate, String usage, String cost) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              service,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              rate,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              usage,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              cost,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageRankItem(String service, String percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostDistributionItem(String category, String cost, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cost,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _testConnections() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在测试所有API连接...')),
    );
  }

  void _testAzureConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在测试Azure OpenAI连接...')),
    );
  }

  void _saveApiSettings() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('API配置保存成功！'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}