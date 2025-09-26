import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/aluno.dart';

class AlunoService {
  static const String _baseUrl = 'http://localhost:8080/api/alunos';

  // GET /api/alunos
  Future<List<Aluno>> listarAlunos() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Aluno.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar alunos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // GET /api/alunos/{id}
  Future<Aluno> buscarAluno(int id) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$id'));
      
      if (response.statusCode == 200) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Aluno não encontrado');
      } else {
        throw Exception('Erro ao buscar aluno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // POST /api/alunos
  Future<Aluno> criarAluno(Aluno aluno) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(aluno.toJson()),
      );
      
      if (response.statusCode == 201) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        String errorMessage = 'Dados inválidos:';
        if (errorBody is Map) {
          errorBody.forEach((key, value) {
            errorMessage += '\n$key: $value';
          });
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Erro ao criar aluno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // PUT /api/alunos/{id}
  Future<Aluno> atualizarAluno(int id, Aluno aluno) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(aluno.toJson()),
      );
      
      if (response.statusCode == 200) {
        return Aluno.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Aluno não encontrado');
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        String errorMessage = 'Dados inválidos:';
        if (errorBody is Map) {
          errorBody.forEach((key, value) {
            errorMessage += '\n$key: $value';
          });
        }
        throw Exception(errorMessage);
      } else {
        throw Exception('Erro ao atualizar aluno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // DELETE /api/alunos/{id}
  Future<void> deletarAluno(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      
      if (response.statusCode == 404) {
        throw Exception('Aluno não encontrado');
      } else if (response.statusCode != 204) {
        throw Exception('Erro ao deletar aluno: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}

