import 'package:flutter/material.dart';
import '../models/aluno.dart';
import '../services/aluno_service.dart';
import 'aluno_form_screen.dart';

class AlunoListScreen extends StatefulWidget {
  const AlunoListScreen({super.key});

  @override
  State<AlunoListScreen> createState() => _AlunoListScreenState();
}

class _AlunoListScreenState extends State<AlunoListScreen> {
  final AlunoService _alunoService = AlunoService();
  List<Aluno> _alunos = [];
  List<Aluno> _alunosFiltrados = [];
  bool _carregando = false;
  String _filtro = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
    _searchController.addListener(_filtrarAlunos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _carregarAlunos() async {
    setState(() {
      _carregando = true;
    });

    try {
      final alunos = await _alunoService.listarAlunos();
      setState(() {
        _alunos = alunos;
        _alunosFiltrados = alunos;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _carregando = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar alunos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filtrarAlunos() {
    final filtro = _searchController.text.toLowerCase();
    setState(() {
      _filtro = filtro;
      if (filtro.isEmpty) {
        _alunosFiltrados = _alunos;
      } else {
        _alunosFiltrados = _alunos.where((aluno) {
          return aluno.nome.toLowerCase().contains(filtro) ||
                 aluno.curso.toLowerCase().contains(filtro);
        }).toList();
      }
    });
  }

  Future<void> _confirmarExclusao(Aluno aluno) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text('Tem certeza que deseja excluir o aluno ${aluno.nome}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && aluno.id != null) {
      await _excluirAluno(aluno.id!);
    }
  }

  Future<void> _excluirAluno(int id) async {
    try {
      await _alunoService.deletarAluno(id);
      await _carregarAlunos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aluno excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir aluno: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navegarParaFormulario([Aluno? aluno]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlunoFormScreen(aluno: aluno),
      ),
    );

    if (resultado == true) {
      await _carregarAlunos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Alunos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _carregarAlunos,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar aluno...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _alunosFiltrados.isEmpty
                    ? _buildEmptyState()
                    : _buildAlunosList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navegarParaFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _filtro.isEmpty ? 'Nenhum aluno encontrado' : 'Nenhum resultado para "$_filtro"',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (_filtro.isEmpty)
            ElevatedButton.icon(
              onPressed: () => _navegarParaFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Primeiro Aluno'),
            ),
        ],
      ),
    );
  }

  Widget _buildAlunosList() {
    return ListView.builder(
      itemCount: _alunosFiltrados.length,
      itemBuilder: (context, index) {
        final aluno = _alunosFiltrados[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                aluno.nome.isNotEmpty ? aluno.nome[0].toUpperCase() : 'A',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              aluno.nome,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Curso: ${aluno.curso}'),
                if (aluno.telefone != null && aluno.telefone!.isNotEmpty)
                  Text('Telefone: ${aluno.telefone}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _navegarParaFormulario(aluno),
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () => _confirmarExclusao(aluno),
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

