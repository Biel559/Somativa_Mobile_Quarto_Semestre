import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'menu_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      // O trim() evita erros de espaço
      await _authService.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Usuário ou senha incorretos!'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Logo ou Ícone Estilizado
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fastfood_rounded, size: 60, color: Color(0xFFE63946)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Mange Eats',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D3557),
                ),
              ),
              const Text(
                'Sua fome resolvemos aqui.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              // Inputs Modernos
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              
              // Botão Grande
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('ENTRAR'),
                    ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                },
                child: const Text('Não tem conta? Crie agora', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}