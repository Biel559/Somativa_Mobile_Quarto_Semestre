import 'package:flutter/material.dart';
import '../models/food.dart';

class BagProvider with ChangeNotifier {
  final List<Food> _items = [];
  String _deliveryAddress = '';
  double _shippingFee = 0.0;

  List<Food> get items => _items;
  String get deliveryAddress => _deliveryAddress;
  double get shippingFee => _shippingFee;

  // Adicionar item
  void addItem(Food food) {
    _items.add(food);
    notifyListeners();
  }

  // Remover item
  void removeItem(Food food) {
    _items.remove(food);
    notifyListeners();
  }

  // Calcular subtotal
  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.price);
  }

  // Calcular total final
  double get total {
    return subtotal + _shippingFee;
  }

  // Limpar carrinho
  void clearBag() {
    _items.clear();
    _deliveryAddress = '';
    _shippingFee = 0.0;
    notifyListeners();
  }

  // Lógica de Frete (Regra: Acima de R$100 é grátis)
  void setAddressAndCalculateShipping(String address, String uf) {
    _deliveryAddress = address;
    
    // Regra da atividade: Acima de 100 reais não tem taxa
    if (subtotal > 100.00) {
      _shippingFee = 0.0;
    } else {
      // Simulação de frete baseada na UF ou valor fixo (já que a API não calcula)
      // Vamos colocar um valor fixo de R$ 15,00 para teste
      _shippingFee = 15.00;
    }
    notifyListeners();
  }
}