import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';    

class DetalleDelDiaPage extends StatelessWidget {
  final String userId;
  final DateTime startOfDay; // ya corresponde a 4 AM
  const DetalleDelDiaPage({
    super.key,
    required this.userId,
    required this.startOfDay,
  });

  @override
  Widget build(BuildContext context) {
    final endOfDay = startOfDay.add(const Duration(days:1));
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMMEEEEd('es_ES').format(startOfDay))),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('comidas')
            .where('userId', isEqualTo: userId)
            .where('fecha', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
            .where('fecha', isLessThan: endOfDay.toIso8601String())
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (snap.data!.docs.isEmpty) return const Center(child: Text('No hay comidas'));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final fecha = DateTime.parse(data['fecha']);
              final hora = '${fecha.hour.toString().padLeft(2,'0')}:${fecha.minute.toString().padLeft(2,'0')}';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.fastfood, color: Color(0xFFb348e5)),
                  title: Text(data['comida'] ?? ''),
                  subtitle: Text('Porción: ${data['porcion']} • ${data['calorias']} kcal'),
                  trailing: Text(hora),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
