import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:samrt_complaint/src/services/auth_service.dart';
import '../utils/constants.dart';
import '../widgets/input_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      final userRole = await authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        switch (userRole) {
          case AppConstants.roleAdmin:
            context.go('/admin_dashboard');
            break;
          case AppConstants.roleBatchAdvisor:
            context.go('/advisor_dashboard');
            break;
          case AppConstants.roleHOD:
            context.go('/hod_dashboard');
            break;
          case AppConstants.roleStudent:
            context.go('/student_dashboard');
            break;
          default:
            setState(() {
              _errorMessage = 'Invalid user role';
            });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.png', height: 100), // Logo
            const SizedBox(height: 20),
            InputField(
              controller: _emailController,
              label: 'Email or ID',
              keyboardType: TextInputType.emailAddress,
            ),
            InputField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Login',
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}