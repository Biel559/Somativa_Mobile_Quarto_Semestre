import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Importante para ler o erro do servidor
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    // 1. Roda todas as validações dos campos (validators)
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await _authService.register(
          _usernameCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
          _pass2Ctrl.text.trim(),
          _phoneCtrl.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta criada com sucesso! Faça login.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volta para o login
        }
      } catch (e) {
        // --- TRATAMENTO DE ERRO INTELIGENTE ---
        String errorMessage = 'Erro ao criar conta. Tente novamente.';
        
        // Se o erro veio do Dio (o conector do backend)
        if (e is DioException && e.response != null) {
          // O Django geralmente manda o erro assim: {"username": ["Usuário já existe"], "password": ["Senha muito curta"]}
          final data = e.response!.data;
          
          if (data is Map<String, dynamic>) {
            // Pega a primeira mensagem de erro que encontrar
            final firstKey = data.keys.first;
            final firstError = data[firstKey];
            
            if (firstError is List) {
              errorMessage = "$firstKey: ${firstError[0]}";
            } else {
              errorMessage = "$firstKey: $firstError";
            }
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Criar Conta', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bem-vindo ao Mange Eats',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE63946)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // CAMPO USUÁRIO
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Usuário',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length < 3) return 'Nome muito curto (mínimo 3)';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CAMPO EMAIL
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CAMPO TELEFONE
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length < 8) return 'Telefone inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CAMPO SENHA
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  helperText: 'Mínimo de 8 caracteres',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
                  if (value == '12345678') return 'Senha muito fraca';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // CAMPO CONFIRMAR SENHA
              TextFormField(
                controller: _pass2Ctrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo obrigatório';
                  if (value != _passCtrl.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // BOTÃO CADASTRAR
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)))
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE63946),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'CADASTRAR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}