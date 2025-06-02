import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants/constants.dart';
import 'package:mobile/service/gemini_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CalcularPage extends StatefulWidget {
  const CalcularPage({super.key});

  @override
  State<CalcularPage> createState() => _CalcularPageState();
}

class _CalcularPageState extends State<CalcularPage> {
  File? _selectedImage;
  bool isLoading = false;
  Map<String, dynamic> foodInfo = {};

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        foodInfo = {};
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    setState(() => isLoading = true);

    final info = await GeminiService().identifyFood(_selectedImage!);

    if (!context.mounted) return;

    setState(() {
      isLoading = false;
      foodInfo = info;
    });

    if (info.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudieron obtener los datos nutricionales.")),
      );
    }
  }

  Widget _buildNutritionInfo(Map<String, dynamic> data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          data['comida'] ?? 'Comida',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          "Porción: ${data['porcion'] ?? 'No especificada'}",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _buildCircular("Calorías", data['calorias'], 800, Colors.orange, Icons.local_fire_department),
            _buildCircular("Proteínas", data['proteinas'], 100, Colors.green, Icons.fitness_center),
            _buildCircular("Carbohidratos", data['carbohidratos'], 300, Colors.blue, Icons.cake),
            _buildCircular("Grasas", data['grasas'], 100, Colors.purple, Icons.opacity),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCircular(String label, dynamic value, double max, Color color, IconData icon) {
    final double val = double.tryParse(value.toString()) ?? 0;
    final double percent = (val / max).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 10.0,
          percent: percent,
          center: Icon(icon, size: 30, color: color),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("FIT ULS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    label: const Text("Abrir cámara", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.image, color: Colors.black),
                    label: const Text("Abrir galería", style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectedImage != null ? _processImage : null,
              icon: const Icon(Icons.analytics, color: Colors.white),
              label: const Text("Procesar", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C08B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
            const SizedBox(height: 20),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!, height: 200),
              ),
            const SizedBox(height: 30),
            if (isLoading)
              Column(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF00C08B)),
                          strokeWidth: 8,
                        ),
                        const Text("Analizando...", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            if (foodInfo.isNotEmpty) _buildNutritionInfo(foodInfo),
          ],
        ),
      ),
    );
  }
}
