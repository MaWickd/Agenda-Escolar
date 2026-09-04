import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../atividade_repository.dart'; // Importa o repositório

class AlunoDashboard extends StatefulWidget {
  const AlunoDashboard({super.key});

  @override
  State<AlunoDashboard> createState() => _AlunoDashboardState();
}

class _AlunoDashboardState extends State<AlunoDashboard> {
  final AtividadeRepository _repository = AtividadeRepository();
  List<dynamic> _atividades = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // Função que busca os dados no Python
  Future<void> _carregarDados() async {
    try {
      final dados = await _repository.listarAtividades();
      setState(() {
        _atividades = dados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar atividades da API'), backgroundColor: Colors.red),
      );
    }
  }

  Route _criarRotaSuave(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _fazerLogoff() {
    Navigator.pushReplacement(context, _criarRotaSuave(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final tarefas = _atividades.where((a) => a['tipo'] == 'Tarefa').toList();
    final concluidas = tarefas.where((a) => a['concluida'] == true).length;
    final progresso = tarefas.isNotEmpty ? concluidas / tarefas.length : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Agenda do Aluno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
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
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyan)) // Bolinha de carregamento
        : Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Suas Tarefas Pendentes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '$concluidas de ${tarefas.length} concluídas',
                        key: ValueKey<int>(concluidas),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progresso),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _atividades.length,
              itemBuilder: (context, index) {
                final item = _atividades[index];
                final isTarefa = item['tipo'] == 'Tarefa';
                final isConcluida = item['concluida'] as bool;

                return Card(
                  elevation: 4,
                  shadowColor: Colors.cyan.withValues(alpha: 0.15),
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    title: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: isConcluida ? TextDecoration.lineThrough : TextDecoration.none,
                        color: isConcluida ? Colors.grey : Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      child: Text(item['titulo'] ?? ''),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${item['tipo']} • Para: ${item['data']}',
                        style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                      ),
                    ),
                    trailing: isTarefa
                        ? Checkbox(
                              value: isConcluida,
                              activeColor: Colors.cyan,
                              onChanged: (val) async {
                                // Salva o status anterior caso dê erro na internet
                                final statusAnterior = item['concluida'];
                                setState(() {
                                  item['concluida'] = val!;
                                });

                                try {
                                  // Atualiza no Banco de Dados
                                  await _repository.atualizarAtividade(item['id'], Map<String, dynamic>.from(item));
                                } catch (e) {
                                  // Se der erro, desfaz a animação visual e avisa o aluno
                                  setState(() {
                                    item['concluida'] = statusAnterior;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Erro ao salvar no servidor.'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                            )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}