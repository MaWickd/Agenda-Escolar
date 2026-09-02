import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'nova_atividade_screen.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  // Lista local de atividades para teste imediato na UI
  final List<Map<String, String>> _atividades = [
    {'titulo': 'Exercícios de Matemática - Pág 15', 'tipo': 'Tarefa', 'data': '05/09'},
    {'titulo': 'Reunião de Pais e Mestres', 'tipo': 'Evento', 'data': '10/09'},
    {'titulo': 'Trabalho de História', 'tipo': 'Tarefa', 'data': '12/09'},
  ];

  // Filtro ativo ('Todas', 'Tarefa', 'Evento')
  String _filtroAtual = 'Todas';

  void _fazerLogoff() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtra a lista com base na categoria selecionada
    final atividadesFiltradas = _filtroAtual == 'Todas'
        ? _atividades
        : _atividades.where((a) => a['tipo'] == _filtroAtual).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Professor', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.cyan, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _fazerLogoff,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Filtros Visual (Chips)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFiltroChip('Todas', Icons.list_alt_rounded),
                const SizedBox(width: 8),
                _buildFiltroChip('Tarefa', Icons.menu_book_rounded),
                const SizedBox(width: 8),
                _buildFiltroChip('Evento', Icons.event_rounded),
              ],
            ),
          ),
          
          // Lista de Atividades Filtradas
          Expanded(
            child: atividadesFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: Colors.cyan[200]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma atividade do tipo "$_filtroAtual" encontrada.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: atividadesFiltradas.length,
                    itemBuilder: (context, index) {
                      final atividade = atividadesFiltradas[index];
                      final isTarefa = atividade['tipo'] == 'Tarefa';

                      return Card(
                        elevation: 4,
                        shadowColor: Colors.cyan.withValues(alpha: 0.2),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isTarefa ? Colors.cyan.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTarefa ? Icons.menu_book : Icons.event,
                              color: isTarefa ? Colors.cyan[700] : Colors.orange[700],
                              size: 28,
                            ),
                          ),
                          title: Text(
                            atividade['titulo']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${atividade['tipo']} • Para: ${atividade['data']}',
                              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                // Remove da lista principal original
                                _atividades.remove(atividade);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final novaAtividade = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NovaAtividadeScreen()),
          );

          if (novaAtividade != null) {
            setState(() {
              _atividades.insert(0, novaAtividade as Map<String, String>);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Atividade cadastrada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        backgroundColor: Colors.cyan,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Atividade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget auxiliar para criar os botões de filtro com estilo moderno
  Widget _buildFiltroChip(String titulo, IconData icone) {
    final selecionado = _filtroAtual == titulo;
    return ChoiceChip(
      selected: selecionado,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: selecionado ? Colors.white : Colors.cyan[700]),
          const SizedBox(width: 6),
          Text(titulo),
        ],
      ),
      selectedColor: Colors.cyan,
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: selecionado ? Colors.white : Colors.grey[800],
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selecionado ? Colors.cyan : Colors.grey.shade300,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          _filtroAtual = titulo;
        });
      },
    );
  }
}