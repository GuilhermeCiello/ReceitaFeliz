import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Employee extends StatefulWidget {
  final String userId;

  const Employee({super.key, required this.userId});

  @override
  State<Employee> createState() => _EmployeeState();
}

class _EmployeeState extends State<Employee> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  @override
  void dispose() {
    // Liberar os controladores ao finalizar o widget
    _titleController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _addRecipe() async {
  
    if ([_titleController, _descriptionController, _ingredientsController, _stepsController]
        .any((controller) => controller.text.trim().isEmpty)) {
      _showMessage("Preencha todos os campos!", isError: true);
      return;
    }

    // Cria o objeto da receita para enviar ao Firestore
    final recipeInfo = {
      "title": _titleController.text.trim(),
      "description": _descriptionController.text.trim(),
      "ingredients": _ingredientsController.text.trim(),
      "steps": _stepsController.text.trim(),
      "userId": widget.userId,
      "timestamp": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection("Recipes").add(recipeInfo);

      _showMessage("Receita adicionada com sucesso!");
      _clearFields();
    } catch (e) {
      _showMessage("Erro ao adicionar: $e", isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _ingredientsController.clear();
    _stepsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Adicionar Receita",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField("Título", _titleController),
              _buildInputField("Descrição", _descriptionController),
              _buildInputField("Ingredientes", _ingredientsController),
              _buildInputField("Etapas", _stepsController),
              const SizedBox(height: 30.0),
              Center(
                child: ElevatedButton(
                  onPressed: _addRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 15.0,
                    ),
                  ),
                  child: const Text(
                    "Adicionar Receita",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Digite $label",
            contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.orange[50],
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );
  }
}
