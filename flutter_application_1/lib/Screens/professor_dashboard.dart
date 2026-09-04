import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'nova_atividade_screen.dart';
import '../atividade_repository.dart'; // Importa o repositório
import 'novo_usuario_screen.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  final AtividadeRepository _repository = AtividadeRepository();
  List<dynamic> _atividades = [];
  bool _isLoading = true;
  String _filtroAtual = 'Todas';

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _repository.listarAtividades();
      setState(() {
        // Inverte a lista para mostrar a mais nova no topo
        _atividades = dados.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar dados da API'), backgroundColor: Colors.red),
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
    final atividadesFiltradas = _filtroAtual == 'Todas'
        ? _atividades
        : _atividades.where((a) => a['tipo'] == _filtroAtual).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Painel do Professor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    icon: const Icon(Icons.person_add, color: Colors.white),
    tooltip: 'Criar Usuário',
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NovoUsuarioScreen()),
      );
    },
  ),
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
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: atividadesFiltradas.isEmpty
                        ? Center(
                            key: const ValueKey('vazio'),
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
                            key: ValueKey(_filtroAtual),
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
                                    atividade['titulo'] ?? '',
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
                                    onPressed: () async {
                                      // Caixa de diálogo para confirmar exclusão
                                      final confirmar = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Excluir Atividade?'),
                                          content: const Text('Essa ação apagará a atividade do banco de dados definitivamente.'),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, true), 
                                              child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        )
                                      );

                                      if (confirmar == true) {
                                        setState(() => _isLoading = true);
                                        try {
                                          await _repository.deletarAtividade(atividade['id']);
                                          await _carregarDados(); // Recarrega a lista
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Atividade excluída com sucesso!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                                            );
                                          }
                                        } catch (e) {
                                          setState(() => _isLoading = false);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Erro ao excluir do banco de dados.'), backgroundColor: Colors.red),
                                            );
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final novaAtividade = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const NovaAtividadeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                return SlideTransition(position: animation.drive(tween), child: child);
              },
            ),
          );

          if (novaAtividade != null) {
            // MOSTRA A BOLINHA DE CARREGANDO enquanto salva no Python
            setState(() => _isLoading = true); 
            
            try {
              // 1. Envia para o Python (Banco de dados)
              await _repository.criarAtividade(Map<String, dynamic>.from(novaAtividade));
              
              // 2. Busca a lista atualizada
              await _carregarDados(); 
              
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Atividade salva com sucesso no banco de dados!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (e) {
              setState(() => _isLoading = false);
              if(mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erro ao salvar no banco de dados.'), backgroundColor: Colors.red),
                );
              }
            }
          }
        },
        backgroundColor: Colors.cyan,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Atividade', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFiltroChip(String titulo, IconData icone) {
    final selecionado = _filtroAtual == titulo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ChoiceChip(
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
      ),
    );
  }
}