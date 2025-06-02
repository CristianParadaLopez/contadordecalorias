import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfoComidasPage extends StatelessWidget {
  final String userId;
  final String categoriaId;
  final String categoriaNombre;

  const InfoComidasPage({
    super.key,
    required this.userId,
    required this.categoriaId,
    required this.categoriaNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Comidas en $categoriaNombre")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('categorias')
            .doc(categoriaId)
            .collection('comidas')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hay comidas en esta categoría"));
          }
          final comidas = snapshot.data!.docs;
          return ListView.builder(
            itemCount: comidas.length,
            itemBuilder: (context, index) {
              final data = comidas[index].data()! as Map<String, dynamic>;
              final fecha = DateTime.parse(data['fecha']);
              final hora = "${fecha.hour.toString().padLeft(2,'0')}:"
                         "${fecha.minute.toString().padLeft(2,'0')}";
              return ListTile(
                leading: const Icon(Icons.fastfood),
                title: Text(data['comida'] ?? 'Comida'),
                subtitle: Text(
                  "Porción: ${data['porcion'] ?? '-'} · "
                  "Calorías: ${data['calorias'] ?? 0} kcal",
                ),
                trailing: Text(hora),
              );
            },
          );
        },
      ),
    );
  }
}
