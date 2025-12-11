import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bag_provider.dart';
import '../services/viacep_service.dart';
import 'order_confirm_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cepController = TextEditingController();
  final ViaCepService _viaCepService = ViaCepService();
  bool _isLoadingCep = false;

  void _searchCep() async {
    setState(() => _isLoadingCep = true);
    try {
      final addressData = await _viaCepService.getAddress(_cepController.text);
      final addressString = "${addressData['logradouro']}, ${addressData['bairro']}, ${addressData['localidade']}";
      
      // Atualiza o provider com o endereço e calcula frete
      Provider.of<BagProvider>(context, listen: false).setAddressAndCalculateShipping(addressString, addressData['uf']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP inválido')));
    } finally {
      setState(() => _isLoadingCep = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: Consumer<BagProvider>(
        builder: (context, bag, child) {
          return Column(
            children: [
              // Lista de Itens
              Expanded(
                child: bag.items.isEmpty
                    ? const Center(child: Text('Carrinho vazio'))
                    : ListView.builder(
                        itemCount: bag.items.length,
                        itemBuilder: (context, index) {
                          final item = bag.items[index];
                          return ListTile(
                            title: Text(item.name),
                            subtitle: Text('R\$ ${item.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => bag.removeItem(item),
                            ),
                          );
                        },
                      ),
              ),
              
              // Área de CEP e Totais
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cepController,
                            decoration: const InputDecoration(labelText: 'Digite seu CEP', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isLoadingCep ? null : _searchCep,
                          child: const Text('Calcular'),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (bag.deliveryAddress.isNotEmpty) 
                      Text("Entrega em: ${bag.deliveryAddress}", style: const TextStyle(fontSize: 12)),
                    const Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Subtotal:"),
                      Text("R\$ ${bag.subtotal.toStringAsFixed(2)}"),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("Frete:"),
                      Text(bag.shippingFee == 0 ? "GRÁTIS" : "R\$ ${bag.shippingFee.toStringAsFixed(2)}", 
                           style: TextStyle(color: bag.shippingFee == 0 ? Colors.green : Colors.black)),
                    ]),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("R\$ ${bag.total.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: bag.items.isEmpty || bag.deliveryAddress.isEmpty 
                          ? null 
                          : () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderConfirmScreen()));
                            },
                        child: const Text("CONFIRMAR PEDIDO"),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}