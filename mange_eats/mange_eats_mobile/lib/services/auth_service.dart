import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('${ApiConstants.baseUrl}/users/login/', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        // Salvar token localmente
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return response.data;
      } else {
        throw Exception('Falha no login');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String username, String email, String password, String password2, String phone) async {
    try {
      await _dio.post('${ApiConstants.baseUrl}/users/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2, // Seu backend exige esse campo
        'phone': phone,
      });
    } catch (e) {
      rethrow;
    }
  }
}