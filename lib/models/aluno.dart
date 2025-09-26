class Aluno {
  final int? id;
  final String nome;
  final String curso;
  final String? telefone;

  Aluno({
    this.id,
    required this.nome,
    required this.curso,
    this.telefone,
  });

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      curso: json['curso'],
      telefone: json['telefone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'curso': curso,
      'telefone': telefone,
    };
  }

  Map<String, dynamic> toJsonWithId() {
    return {
      'id': id,
      'nome': nome,
      'curso': curso,
      'telefone': telefone,
    };
  }

  Aluno copyWith({
    int? id,
    String? nome,
    String? curso,
    String? telefone,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      telefone: telefone ?? this.telefone,
    );
  }

  @override
  String toString() {
    return 'Aluno{id: $id, nome: $nome, curso: $curso, telefone: $telefone}';
  }
}

