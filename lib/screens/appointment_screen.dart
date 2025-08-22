import 'package:flutter/material.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final List<AppointmentService> _services = [
    AppointmentService(
      id: '1',
      title: '情感咨询',
      description: '专业的情感问题咨询服务',
      duration: '60分钟',
      price: 199.0,
      icon: Icons.favorite,
    ),
    AppointmentService(
      id: '2',
      title: '心理疏导',
      description: '缓解压力，调节情绪',
      duration: '45分钟',
      price: 149.0,
      icon: Icons.psychology,
    ),
    AppointmentService(
      id: '3',
      title: '陪伴聊天',
      description: '温暖的陪伴和倾听',
      duration: '30分钟',
      price: 99.0,
      icon: Icons.chat_bubble,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预约服务'),
        backgroundColor: Colors.pink.shade50,
        foregroundColor: Colors.pink.shade700,
        elevation: 0,
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final service = _services[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.pink.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            service.icon,
                            color: Colors.pink.shade600,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '时长: ${service.duration}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '¥${service.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink.shade600,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => _bookAppointment(service),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('立即预约'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _bookAppointment(AppointmentService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('预约${service.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('服务: ${service.title}'),
            Text('时长: ${service.duration}'),
            Text('价格: ¥${service.price.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            const Text('请选择预约时间:'),
            const SizedBox(height: 8),
            // 这里可以添加日期时间选择器
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('今天 14:00 - 15:00'),
            ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('预约成功！我们会尽快联系您确认时间。'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认预约'),
          ),
        ],
      ),
    );
  }
}

class AppointmentService {
  final String id;
  final String title;
  final String description;
  final String duration;
  final double price;
  final IconData icon;

  AppointmentService({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.price,
    required this.icon,
  });
}