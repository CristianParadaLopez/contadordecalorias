import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:mobile/service/gemini_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/auth/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  double _progress = 0.0;
  Map<String, dynamic>? _nutritionalInfo;
  bool _isLoading = false;
  String _userCorrection = "";

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile == null) return;

    setState(() {
  _image = File(pickedFile.path);
  _nutritionalInfo = null;
  _isLoading = true;
  _progress = 0.0;
});
final response = await GeminiService().identifyFood(_image!);
final calorias = double.tryParse(response['calorias'].toString()) ?? 0.0;

setState(() {
  _nutritionalInfo = response;
  _progress = (calorias / 2000).clamp(0.0, 1.0);
  _isLoading = false;
});
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Iniciar sesión requerido'),
        content: const Text('Debes iniciar sesión para guardar comidas.'),
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

  void _showSaveDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si no hay usuario, pedimos login
      return _showLoginRequiredDialog();
    }
    final userId = user.uid;

    // Cargamos las categorías del usuario
    final categoriasRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('categorias');
    final categoriasSnapshot = await categoriasRef.get();
    final categorias = categoriasSnapshot.docs.map((doc) => {
          'id': doc.id,
          'nombre': doc['nombre'],
        }).toList();

    String? categoriaSeleccionada;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar comida"),
          content: DropdownButtonFormField<String>(
            items: categorias
                .map((categoria) => DropdownMenuItem<String>(
                      value: categoria['id'],
                      child: Text(categoria['nombre']!),
                    ))
                .toList(),
            onChanged: (value) {
              categoriaSeleccionada = value;
            },
            decoration: const InputDecoration(labelText: "Selecciona una categoría"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (categoriaSeleccionada == null || _nutritionalInfo == null) return;
                final now = DateTime.now();
                final nombreCat = categorias
                    .firstWhere((c) => c['id'] == categoriaSeleccionada)['nombre'];
                await FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(userId)
                    .collection('categorias')
                    .doc(categoriaSeleccionada)
                    .collection('comidas')
                    .add({
                  ..._nutritionalInfo!,
                  'fecha': now.toIso8601String(),
                  'categoriaId': categoriaSeleccionada,
                  'categoriaNombre': nombreCat,
                  'userId': userId,      
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("Comida guardada")));
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _showCorrectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar comida"),
          content: TextField(
            decoration: const InputDecoration(hintText: "Describe correctamente la comida"),
            onChanged: (value) => _userCorrection = value,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                  _nutritionalInfo = null;
                });
                final response =
                    await GeminiService().identifyFoodWithCorrection(_image!, _userCorrection);
                setState(() {
                  _isLoading = false;
                  _nutritionalInfo = response;
                  double consumed = double.tryParse(response['calorias'].toString()) ?? 0.0;
                  _progress = (consumed / 2000).clamp(0.0, 1.0);
                });
              },
              child: const Text("Corregir"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCircular(String label, dynamic value, double max, Color color, String asset) {
    final val = double.tryParse(value.toString()) ?? 0;
    final percent = (val / max).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 50,
          lineWidth: 10,
          percent: percent,
          center: Image.asset(asset, width: 30, height: 30),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
        ),
        const SizedBox(height: 8),
        Text("$label: ${val.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildNutritionInfo() {
    if (_nutritionalInfo == null) return const SizedBox.shrink();
    final data = _nutritionalInfo!;
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(data['comida'] ?? 'Comida',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: _showCorrectionDialog,
          icon: const Icon(Icons.edit, color: Color(0xFFb736ff)),
          label: const Text("Corregir", style: TextStyle(color: Color(0xFFb736ff))),
        ),
        Text("Porción: ${data['porcion'] ?? 'No especificada'}",
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildCircular("Calorías", data['calorias'], 800, Colors.orange, 'assets/imag/calories.png'),
            _buildCircular("Proteínas", data['proteinas'], 100, Colors.green, 'assets/imag/proteins.png'),
            _buildCircular("Carbohidratos", data['carbohidratos'], 300, Colors.blue, 'assets/imag/carb.png'),
            _buildCircular("Grasas", data['grasas'], 100, const Color(0xFFb736ff), 'assets/imag/fat.png'),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _showSaveDialog,
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text("Guardar comida"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFb736ff),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              "Resumen Nutricional",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            CircularPercentIndicator(
              radius: 90,
              lineWidth: 12,
              animation: true,
              percent: _progress,
              center: Text(
                "${(_progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: const Color(0xFFb736ff),
              backgroundColor: Colors.grey[300]!,
              footer: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  "Meta diaria 2000 kcal",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _customActionButton(
                  icon: Icons.camera_alt,
                  label: "Cámara",
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 15),
                _customActionButton(
                  icon: Icons.photo_library,
                  label: "Galería",
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 25),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _image!,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Color(0xFFb736ff)),
                        strokeWidth: 8,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "Analizando...",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFb736ff),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            if (_nutritionalInfo != null) _buildNutritionInfo(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

Widget _customActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: const Color(0xFFb736ff)),
    label: Text(label, style: const TextStyle(color: Color(0xFFb736ff))),
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFFb736ff),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Color(0xFFb736ff)),
      ),
    ),
  );
}

}
