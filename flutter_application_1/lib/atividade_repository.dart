import 'dart:convert';
import 'package:http/http.dart' as http;

class AtividadeRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/atividades/';

  // Busca as atividades no Python (GET)
  Future<List<dynamic>> listarAtividades() async {
    final resposta = await http.get(Uri.parse(baseUrl));
    if (resposta.statusCode == 200) {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } else {
      throw Exception('Falha ao carregar as atividades da API');
    }
  }

  // Envia uma nova atividade para o Python (POST)
  Future<void> criarAtividade(Map<String, dynamic> atividade) async {
    final resposta = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(atividade),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Falha ao salvar a atividade na API');
    }
  }

  // Atualiza uma atividade existente no Python (PUT)
  Future<void> atualizarAtividade(int id, Map<String, dynamic> atividade) async {
    final resposta = await http.put(
      Uri.parse('$baseUrl$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(atividade),
    );
    if (resposta.statusCode != 200) {
      throw Exception('Falha ao atualizar a atividade na API');
    }
  }

  // Deleta uma atividade no Python (DELETE)
  Future<void> deletarAtividade(int id) async {
    final resposta = await http.delete(Uri.parse('$baseUrl$id'));
    if (resposta.statusCode != 200) {
      throw Exception('Falha ao deletar a atividade na API');
    }
  }
}