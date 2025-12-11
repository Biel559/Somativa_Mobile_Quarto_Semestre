import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bag_provider.dart';
import 'menu_screen.dart';

class OrderConfirmScreen extends StatelessWidget {
  const OrderConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bag = Provider.of<BagProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Pedido Confirmado')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                'Pedido realizado com sucesso!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Endereço de entrega:\n${bag.deliveryAddress}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Valor Total: R\$ ${bag.total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  bag.clearBag(); // Limpa o carrinho
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MenuScreen()),
                    (route) => false, // Remove todas as rotas anteriores
                  );
                },
                child: const Text('VOLTAR AO MENU'),
              )
            ],
          ),
        ),
      ),
    );
  }
}