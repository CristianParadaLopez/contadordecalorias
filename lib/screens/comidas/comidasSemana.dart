
import 'package:flutter/material.dart';
import 'package:mobile/constants/time.dart';    
import 'package:mobile/screens/comidas/DetalleDelDiaPage.dart';             
import 'package:intl/intl.dart';    

class ComidasSemana extends StatelessWidget {
  final String userId;

  const ComidasSemana({super.key, required this.userId});

  /// Construye una lista con los inicios de día de las últimas 7 ventanas (4 AM).
  List<DateTime> get last7Days {
    final today4 = getStartOfTodayAt4AM();
    return List.generate(7, (i) => today4.subtract(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: last7Days.length,
      itemBuilder: (context, index) {
        final dayStart = last7Days[index];
        final dayEnd   = dayStart.add(const Duration(days: 1));
        final labelDay = DateFormat.EEEE('es_ES').format(dayStart);
        final labelDate= DateFormat('d/MM').format(dayStart);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            title: Text(
              '${labelDay[0].toUpperCase()}${labelDay.substring(1)}, $labelDate',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleDelDiaPage(
                    userId: userId,
                    startOfDay: dayStart,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
