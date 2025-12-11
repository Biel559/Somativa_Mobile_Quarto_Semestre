import 'package:dio/dio.dart';

class ViaCepService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getAddress(String cep) async {
    try {
      // Remove traços e pontos
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
      final response = await _dio.get('https://viacep.com.br/ws/$cleanCep/json/');
      
      if (response.data['erro'] == true) {
        throw Exception('CEP não encontrado');
      }
      return response.data;
    } catch (e) {
      throw Exception('Erro ao buscar CEP');
    }
  }
}