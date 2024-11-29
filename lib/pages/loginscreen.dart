import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teste/pages/home.dart';
import 'package:teste/pages/signupscreen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> _loginUser() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Preencha todos os campos!")),
        );
        return;
      }

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection("Users")
            .where("email", isEqualTo: emailController.text)
            .get();

        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuário não encontrado!")),
          );
          return;
        }

        final userDoc = snapshot.docs.first;
        final user = userDoc.data() as Map<String, dynamic>;

        if (user["password"] == passwordController.text) {
          final userId = userDoc.id; 

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login efetuado com sucesso!")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(userId: userId),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Senha incorreta!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao efetuar login: $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              onPressed: _loginUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                "Entrar",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            const SizedBox(height: 16.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Não possui conta?",
                  style: TextStyle(fontSize: 16.0),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Crie uma",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
