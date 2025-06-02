import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mobile/constants/constants.dart';

class GeminiService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: apiKey,
  );

  Future<Map<String, dynamic>> identifyFood(File imageFile) async {
    try {
      final image = await imageFile.readAsBytes();

      const prompt = """
Analiza esta imagen de comida y responde con los datos nutricionales en formato JSON. No agregues explicaciones, solo responde con el siguiente formato:

{
  "comida": "Nombre de la comida",
  "porcion": "Cantidad estimada de porción (ej. 200g)",
  "calorias": número,
  "proteinas": número,
  "carbohidratos": número,
  "grasas": número
}

Responde solo con el JSON, en español.
""";

      final response = await model.generateContent(
        [Content.text(prompt), Content.data('image/jpeg', image)],
      );

      print("Respuesta de Gemini:\n${response.text}");

      if (response.text == null || response.text!.trim().isEmpty) return {};

      // Asegura que la respuesta solo contenga JSON válido
      final text = response.text!.trim();

      // Buscar inicio y fin del JSON por seguridad
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1) return {};

      final jsonString = text.substring(start, end + 1);

      final Map<String, dynamic> result = json.decode(jsonString);
      return result;
    } catch (e) {
      print("Error al procesar imagen: $e");
      return {};
    }
  }
  Future<Map<String, dynamic>> identifyFoodWithCorrection(File imageFile, String correction) async {
  try {
    final image = await imageFile.readAsBytes();

final prompt = """
El usuario ha corregido la descripción del contenido de la imagen con este texto: "$correction". Usa esta descripción como guía principal para analizar la imagen y genera un nuevo análisis nutricional.

Responde únicamente en el siguiente formato JSON (en español), sin explicaciones:

{
  "comida": "Nombre de la comida",
  "porcion": "Cantidad estimada de porción (ej. 200g)",
  "calorias": número,
  "proteinas": número,
  "carbohidratos": número,
  "grasas": número
}
""";

    final response = await model.generateContent(
      [Content.text(prompt), Content.data('image/jpeg', image)],
    );

    if (response.text == null || response.text!.trim().isEmpty) return {};

    final text = response.text!.trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start == -1 || end == -1) return {};

    final jsonString = text.substring(start, end + 1);
    final Map<String, dynamic> result = json.decode(jsonString);
    return result;
  } catch (e) {
    print("Error al procesar con corrección: $e");
    return {};
  }
}

}
