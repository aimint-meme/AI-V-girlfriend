import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and register

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success;

      if (_isLogin) {
        // Login
        success = await authProvider.login(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        // Register
        success = await authProvider.register(
          _emailController.text.trim(),
          _passwordController.text,
          '新用户', // 默认显示名称
          inviteCode: _inviteCodeController.text.trim().isEmpty 
              ? null 
              : _inviteCodeController.text.trim(),
        );
      }

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (error) {
      _showErrorDialog(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_isLogin ? '登录失败' : '注册失败'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // For demo purposes, allow skipping login
  void _skipLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.pink.shade100,
              Colors.purple.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // App logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 60,
                    color: Colors.pink.shade400,
                  ),
                ),
                const SizedBox(height: 24),
                // App name
                const Text(
                  'AI Virtual Girlfriend',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                Text(
                  '你的专属AI伴侣',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 40),
                // Login/Register form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isLogin ? '登录' : '注册',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Email field
                        CustomTextField(
                          controller: _emailController,
                          hintText: '邮箱',
                          prefixIcon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入邮箱';
                            }
                            if (!value.contains('@')) {
                              return '请输入有效的邮箱地址';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password field
                        CustomTextField(
                          controller: _passwordController,
                          hintText: '密码',
                          prefixIcon: Icons.lock,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 6) {
                              return '密码长度至少为6位';
                            }
                            return null;
                          },
                        ),
                        // Invite code field (only for register)
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _inviteCodeController,
                            hintText: '邀请码（可选）',
                            prefixIcon: Icons.card_giftcard,
                            validator: (value) {
                              // 邀请码是可选的，但如果填写了需要验证格式
                              if (value != null && value.isNotEmpty) {
                                if (value.length != 8) {
                                  return '邀请码应为8位字符';
                                }
                                // 可以在这里添加更多验证逻辑
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        // Login/Register button
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : CustomButton(
                                text: _isLogin ? '登录' : '注册',
                                onPressed: _submitForm,
                              ),
                        const SizedBox(height: 16),
                        // Toggle between login and register
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin ? '没有账号？点击注册' : '已有账号？点击登录',
                            style: TextStyle(
                              color: Colors.pink.shade400,
                            ),
                          ),
                        ),
                        // Demo mode - Skip login
                        TextButton(
                          onPressed: _skipLogin,
                          child: const Text(
                            '体验模式（跳过登录）',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}