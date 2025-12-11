import 'dart:io';

class ApiConstants {
  // Endereço base da API
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api'; // Para Web ou iOS Simulator
    }
  }

  // Endereço base para carregar as imagens (Media)
  static String get mediaUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }
}