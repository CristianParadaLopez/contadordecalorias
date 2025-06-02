import 'package:flutter/material.dart';
import 'package:mobile/screens/comidasPage.dart';
import 'package:mobile/screens/home.dart';
import 'package:mobile/screens/perfil.dart';
import 'package:mobile/auth/login.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InicioPage extends StatefulWidget {
  final bool esInvitado;

  const InicioPage({super.key, this.esInvitado = false});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final PageController _pageController = PageController(initialPage: 1);
  int _currentIndex = 1;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if (widget.esInvitado && index != 1) {
      _showLoginRequiredDialog();
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Iniciar sesión requerido'),
        content:
            const Text('Debes iniciar sesión para acceder a esta sección.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ).then((_) => setState(() {}));
            },
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;


    final pages = <Widget>[
      widget.esInvitado
    ? const SizedBox.shrink()
    : ComidasPages(userId: userId!),
      const HomePage(),
      widget.esInvitado
          ? const SizedBox.shrink()
          : const PerfilPage(),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}
