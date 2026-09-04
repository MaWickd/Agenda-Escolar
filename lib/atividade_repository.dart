class AtividadeRepository {
  // Lista global compartilhada entre Professor e Aluno
  static final List<Map<String, dynamic>> atividades = [
    {
      'titulo': 'Exercícios de Matemática - Pág 15',
      'tipo': 'Tarefa',
      'data': '05/09',
      'concluida': false,
    },
    {
      'titulo': 'Reunião de Pais e Mestres',
      'tipo': 'Evento',
      'data': '10/09',
      'concluida': false,
    },
    {
      'titulo': 'Trabalho de História',
      'tipo': 'Tarefa',
      'data': '12/09',
      'concluida': false,
    },
  ];

  static void adicionarAtividade(Map<String, dynamic> nova) {
    atividades.insert(0, {
      'titulo': nova['titulo'],
      'tipo': nova['tipo'],
      'data': nova['data'],
      'concluida': false, // Todo item novo começa como pendente
    });
  }

  static void removerAtividade(int index) {
    if (index >= 0 && index < atividades.length) {
      atividades.removeAt(index);
    }
  }
}