import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile/screens/inicio.dart';
import 'package:mobile/auth/registro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Por favor, completa todos los campos.";
        _isLoading = false;
      });
      return;
    }
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const InicioPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _traducirMensajeFirebase(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error inesperado: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _traducirMensajeFirebase(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'user-disabled':
        return 'La cuenta ha sido deshabilitada.';
      case 'user-not-found':
        return 'No se encontró ninguna cuenta con ese correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      default:
        return 'Ocurrió un error. Inténtalo de nuevo.';
    }
  }

  void _continuarComoInvitado() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InicioPage(esInvitado: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Image.asset(
                    'assets/imag/logo.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Iniciar sesión",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFb348e5),
                    fontFamily: 'SF Pro', // asegúrate de tenerla agregada si usas esto
                  ),
                ),
                const SizedBox(height: 32),

                // —— Email Field —— 
                _buildGradientInputField(
                  controller: _emailController,
                  label: "Correo electrónico",
                  obscureText: false,
                ),
                const SizedBox(height: 16),

                // —— Password Field ——
                _buildGradientInputField(
                  controller: _passwordController,
                  label: "Contraseña",
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 16),

                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          // —— Ingresar Button ——
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFb348e5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                "Ingresar",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              );
                            },
                            child: const Text("¿No tienes cuenta? Regístrate"),
                          ),
                          TextButton(
                            onPressed: _continuarComoInvitado,
                            child: const Text("Continuar sin iniciar sesión"),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF00E6), Color(0xFF2158FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: label,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}
