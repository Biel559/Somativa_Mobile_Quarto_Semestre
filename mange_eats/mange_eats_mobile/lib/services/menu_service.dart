import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para ler o token
import '../utils/constants.dart';
import '../models/food.dart';

class MenuService {
  final Dio _dio = Dio();

  Future<List<Food>> getFoods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final options = Options(
        headers: token != null ? {'Authorization': 'Token $token'} : {},
      );

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/menu/',
        options: options, 
      );
      
      List<dynamic> data = response.data;
      return data.map((json) => Food.fromJson(json)).toList();
    } catch (e) {
      print("Erro ao buscar cardápio: $e");
      throw Exception('Erro ao carregar cardápio. Verifique se você está logado.');
    }
  }
}