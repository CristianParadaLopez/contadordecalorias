import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/auth/login.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final firestore = FirebaseFirestore.instance;

  final _nombreController      = TextEditingController();
  final _descripcionController = TextEditingController();
  final _instagramController   = TextEditingController();
  final _facebookController    = TextEditingController();

  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final doc = await firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nombreController.text      = data['nombre_usuario'] ?? '';
      _descripcionController.text = data['descripcion']    ?? '';
      _instagramController.text   = data['instagram']      ?? '';
      _facebookController.text    = data['facebook']       ?? '';
    }
    setState(() => _isLoading = false);
  }

  Future<void> _guardarDatos() async {
    await firestore.collection('usuarios').doc(user.uid).set({
      'correo': user.email,
      'nombre_usuario': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'instagram': _instagramController.text.trim(),
      'facebook': _facebookController.text.trim(),
    }, SetOptions(merge: true));

    setState(() {
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado')),
    );
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = 100.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar con logo
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 3),
                      image: const DecorationImage(
                        image: AssetImage('assets/imag/logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // Contenido editable o sólo lectura
                  if (_isEditing) ...[
                    _buildTextField(controller: _nombreController,      label: 'Nombre de usuario'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _descripcionController, label: 'Descripción'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _instagramController,   label: 'Instagram'),
                    const SizedBox(height: 12),
                    _buildTextField(controller: _facebookController,    label: 'Facebook'),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _guardarDatos,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Guardar"),
                        ),
                        OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Cancelar"),
                        ),
                      ],
                    ),
                  ] else ...[
                    _buildReadOnlyRow('Nombre de usuario', _nombreController.text),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow('Descripción',       _descripcionController.text),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow('Instagram',         _instagramController.text),
                    const SizedBox(height: 12),
                    _buildReadOnlyRow('Facebook',          _facebookController.text),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text("Editar perfil"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '-',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
