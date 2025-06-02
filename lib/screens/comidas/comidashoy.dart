import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/constants/time.dart';

class HoyTab extends StatelessWidget {
  final String userId;
  final Map<String, String> iconosCategorias;

  const HoyTab({
    super.key,
    required this.userId,
    required this.iconosCategorias,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCategoriasUsuario(context),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => mostrarDialogoAgregarCategoria(context),
              icon: const Icon(Icons.add),
              label: const Text("Agregar nueva categoría"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFb348e5),
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "🍽️ Comidas recientes",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 10),
          buildMealList(),
        ],
      ),
    );
  }

  Widget buildCategoriasUsuario(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(userId)
          .collection('categorias')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final categorias = snapshot.data!.docs;

        return Column(
          children: categorias.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final categoriaId = doc.id;
            final nombreCategoria = data['nombre'];

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(userId)
                  .collection('comidas')
                  .where('categoria', isEqualTo: nombreCategoria)
                  .get(),
              builder: (context, snapshotComidas) {
                double totalCalorias = 0;

                if (snapshotComidas.hasData) {
                  for (var comida in snapshotComidas.data!.docs) {
                    totalCalorias += (comida['calorias'] ?? 0).toDouble();
                  }
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/infocomidas',
                      arguments: {
                        'userId': userId,
                        'categoriaId': categoriaId,
                        'categoriaNombre': nombreCategoria,
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF00E6), Color(0xFF2158FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              iconosCategorias[nombreCategoria] ?? 'assets/imag/calories.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCategoria,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${totalCalorias.toStringAsFixed(1)} kcal",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  void mostrarDialogoAgregarCategoria(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Nueva categoría"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Nombre de la categoría",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nombre = _controller.text.trim();
              if (nombre.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(userId)
                    .collection('categorias')
                    .add({'nombre': nombre});
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFb348e5),
              foregroundColor: Colors.white,
            ),
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

 Widget buildMealList() {
    final start = getStartOfTodayAt4AM();
    final end   = start.add(const Duration(days: 1));

  return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
        .collectionGroup('comidas')
        .where('userId', isEqualTo: userId)
        .where('fecha', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('fecha', isLessThan: end.toIso8601String())
        .orderBy('fecha', descending: true)
        .limit(5)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final docs = snapshot.data!.docs;

      if (docs.isEmpty) {
        return const Text("No hay comidas recientes hoy.");
      }

      return Column(
        children: docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final fecha = DateTime.tryParse(data['fecha'] ?? '') ?? DateTime.now();
          final hora = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.fastfood, color: Color(0xFFb348e5), size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['comida'] ?? 'Comida',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Porción: ${data['porcion'] ?? '-'} • ${data['calorias'] ?? 0} kcal",
                          style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hora,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}

}
