import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/screens/comidas/infocomidas.dart';
import 'firebase_options.dart';
import 'package:mobile/auth/check_auth.dart';


import 'package:intl/date_symbol_data_local.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return MaterialApp(
  onGenerateRoute: (settings) {
    if (settings.name == '/infocomidas') {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => InfoComidasPage(
        userId: args['userId'] as String,
        categoriaId: args['categoriaId'] as String,
        categoriaNombre: args['categoriaNombre'] as String,
      ));
    }
    return null;
      },
      debugShowCheckedModeBanner: false,
      home: const CheckAuthPage(),

    );
  }
}
