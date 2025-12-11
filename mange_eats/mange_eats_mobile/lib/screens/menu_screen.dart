import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- Importante para apagar o token
import '../models/food.dart';
import '../providers/bag_provider.dart';
import '../services/menu_service.dart';
import '../utils/constants.dart';
import 'cart_screen.dart';
import 'login_screen.dart'; // <--- Importante para voltar pro login

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuService _menuService = MenuService();
  late Future<List<Food>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _foodsFuture = _menuService.getFoods();
  }

  // --- LÓGICA DE LOGOUT ---
  void _logout() async {
    // 1. Apaga o token salvo no celular
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (mounted) {
      // 2. Limpa o carrinho (para o próximo usuário não pegar itens do anterior)
      Provider.of<BagProvider>(context, listen: false).clearBag();

      // 3. Navega para o Login removendo todas as telas anteriores (pra não dar para voltar com o botão do Android)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // --- ALERTA DE CONFIRMAÇÃO ---
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja desconectar?'),
        actions: [
          // Botão NÃO (Fecha o alerta e fica na tela)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          // Botão SIM (Chama a função de logout)
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o alerta
              _logout(); // Faz o logout real
            },
            child: const Text('SAIR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- GERADOR DE IMAGENS VIA IA (Mantive sua funcionalidade top) ---
  String _getAiImageUrl(Food food) {
    if (food.image != null && food.image!.isNotEmpty) {
      return '${ApiConstants.mediaUrl}${food.image}';
    }
    String prompt = "delicious food ${food.name}, professional food photography, 4k, hyperrealistic, appetizing";
    String encodedPrompt = Uri.encodeComponent(prompt);
    return 'https://image.pollinations.ai/prompt/$encodedPrompt?width=800&height=600&seed=${food.id}&nologo=true&model=flux';
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = context.watch<BagProvider>().items.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // --- BOTÃO DE SAIR (LADO ESQUERDO) ---
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          tooltip: 'Sair',
          onPressed: _confirmLogout, // <--- Chama o alerta aqui
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mange Eats', style: TextStyle(color: Colors.red.shade700, fontSize: 14, fontWeight: FontWeight.bold)),
            const Text('Cardápio 🍔', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: Colors.black87, size: 28),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: FutureBuilder<List<Food>>(
        future: _foodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE63946)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum item disponível'));
          }

          final foods = snapshot.data!;
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: foods.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final food = foods[index];
              return _buildFoodCard(context, food);
            },
          );
        },
      ),
    );
  }

  Widget _buildFoodCard(BuildContext context, Food food) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              _getAiImageUrl(food),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 220,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFE63946)),
                        SizedBox(height: 10),
                        Text("IA cozinhando a imagem...", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (ctx, err, stack) => Container(
                height: 220,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D3557)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'R\$ ${food.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFE63946)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                    onPressed: () {
                      Provider.of<BagProvider>(context, listen: false).addItem(food);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Adicionado ao carrinho!'), duration: Duration(milliseconds: 800)),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}