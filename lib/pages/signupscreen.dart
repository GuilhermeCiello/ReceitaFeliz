import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controladores de texto para os campos do formulário
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> _registerUser() async {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos!")),
        );
        return;
      }

      try {
        // Gerar o ID para o usuario
        final String userId = FirebaseFirestore.instance.collection("Users").doc().id;

        final userInfo = {
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text, 
          "timestamp": FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection("Users").doc(userId).set(userInfo);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conta criada com sucesso!")),
        );

        // Retornar para a tela anterior
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao criar conta: $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Criar Conta"),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo Nome
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),

            ElevatedButton(
              onPressed: _registerUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                "Criar Conta",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
