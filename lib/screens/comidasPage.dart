import 'package:flutter/material.dart';
import 'package:mobile/screens/comidas/comidasMes.dart';
import 'package:mobile/screens/comidas/comidasSemana.dart';
import 'package:mobile/screens/comidas/comidashoy.dart';
import 'package:intl/intl.dart';    

class ComidasPages extends StatefulWidget {
  final String userId;

  const ComidasPages({super.key, required this.userId});
  

  @override
  State<ComidasPages> createState() => _ComidasPagesState();
}

class _ComidasPagesState extends State<ComidasPages> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> iconosCategorias = {
  'Desayuno': 'assets/imag/carb.png',
  'Almuerzo': 'assets/imag/proteins.png',
  'Cena': 'assets/imag/calories.png',
  // Puedes agregar más o dejar valores por defecto en HoyTab
};
    final pages = [
  HoyTab(
    userId: widget.userId,
    iconosCategorias: iconosCategorias,
  ),
  const ComidasSemana(userId: 'userId',),
  const ComidasMes(),
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
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Hoy'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_view_week), label: 'Semana'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Mes'),
        ],
      ),
    );
  }
}
