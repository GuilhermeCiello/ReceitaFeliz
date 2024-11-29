import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/pages/employee.dart';


class Home extends StatefulWidget {
  final String userId;

  const Home({super.key, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Employee(userId: widget.userId)),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          "Receitas",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        centerTitle: true,
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Recipes").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Erro ao carregar receitas.",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma receita cadastrada.",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            );
          }

          final recipes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final data = recipe.data() as Map<String, dynamic>?;

              final title = data?["title"] ?? "Título não informado";
              final description = data?["description"] ?? "Sem descrição";

              return Card(
                margin: const EdgeInsets.all(10.0),
                elevation: 5.0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10.0),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                  subtitle: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _editRecipe(context, recipe.id, data);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteRecipe(recipe.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }


  void _editRecipe(BuildContext context, String recipeId, Map<String, dynamic>? data) {
    if (data == null) return;
  
    final titleController = TextEditingController(text: data["title"] ?? "");
    final descriptionController = TextEditingController(text: data["description"] ?? "");
    final ingredientsController = TextEditingController(text: data["ingredients"] ?? "");
    final stepsController = TextEditingController(text: data["steps"] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Receita"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputField("Título", titleController),
              _buildInputField("Descrição", descriptionController),
              _buildInputField("Ingredientes", ingredientsController),
              _buildInputField("Etapas", stepsController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Atualiza a receita no Firestore.
                await FirebaseFirestore.instance.collection("Recipes").doc(recipeId).update({
                  "title": titleController.text,
                  "description": descriptionController.text,
                  "ingredients": ingredientsController.text,
                  "steps": stepsController.text,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Receita atualizada com sucesso!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro ao atualizar receita: $e")),
                );
              }
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  // Função para deletar uma receita com base no ID.
  void _deleteRecipe(String recipeId) async {
    try {
      await FirebaseFirestore.instance.collection("Recipes").doc(recipeId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Receita deletada com sucesso!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao deletar receita: $e")),
      );
    }
  }

  // Cria um campo de entrada de texto com um rótulo.
  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        TextField(controller: controller),
        const SizedBox(height: 10.0),
      ],
    );
  }
}
