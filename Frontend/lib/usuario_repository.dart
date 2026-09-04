import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioRepository {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>> fazerLogin(String email, String senha, String perfil) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'senha': senha, 'perfil': perfil}),
    );

    if (resposta.statusCode == 200) {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } else {
      throw Exception('E-mail, senha ou perfil incorretos.');
    }
  }

  Future<void> criarUsuario(Map<String, dynamic> usuario) async {
    final resposta = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(usuario),
    );

    if (resposta.statusCode != 200) {
      throw Exception('Este e-mail já está em uso.');
    }
  }
}