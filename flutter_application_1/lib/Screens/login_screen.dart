import 'package:flutter/material.dart';
import 'professor_dashboard.dart';
import 'aluno_dashboard.dart';
import '../usuario_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final UsuarioRepository _usuarioRepo = UsuarioRepository();
bool _isLoading = false;
  
  String _tipoPerfil = 'Aluno';

  // Animação de transição de tela (Fade)
  Route _criarRotaSuave(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  void _fazerLogin() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    try {
      // Vai no banco de dados verificar (Note o .trim() no e-mail)
      await _usuarioRepo.fazerLogin(
        _emailController.text.trim(), 
        _senhaController.text,
        _tipoPerfil,
      );

      if (!mounted) return;
      if (_tipoPerfil == 'Professor') {
        Navigator.pushReplacement(context, _criarRotaSuave(const ProfessorDashboard()));
      } else {
        Navigator.pushReplacement(context, _criarRotaSuave(const AlunoDashboard()));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.cyan,
                          child: Icon(Icons.school_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Agenda Escolar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Selecione seu perfil para continuar',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        height: 52,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _tipoPerfil = 'Aluno'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _tipoPerfil == 'Aluno' ? Colors.cyan : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    'Aluno',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _tipoPerfil == 'Aluno' ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => setState(() => _tipoPerfil = 'Professor'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: _tipoPerfil == 'Professor' ? Colors.cyan : Colors.transparent,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Text(
                                    'Professor',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: _tipoPerfil == 'Professor' ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail institucional',
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.cyan),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Informe seu e-mail' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.cyan),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Informe sua senha' : null,
                      ),
                      const SizedBox(height: 32),
                     ElevatedButton(
                        // Se estiver carregando, desativa o botão (null) para não clicarem duas vezes
                        onPressed: _isLoading ? null : _fazerLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        // Aqui está o uso da variável! Se for true, mostra a bolinha. Se false, mostra o texto.
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'ENTRAR COMO ${_tipoPerfil.toUpperCase()}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}