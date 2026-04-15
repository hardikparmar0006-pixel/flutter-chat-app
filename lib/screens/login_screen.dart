import 'package:flutter/material.dart';
import 'package:taskproject/screens/register_screen.dart';
import '../services/auth_service.dart';
import 'chat_list_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool isHidden = true;
  bool loading = false;

  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => loading = true);

    try {
      await auth.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ChatListScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Failed")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: passwordController,
              obscureText: isHidden,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                      isHidden ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      isHidden = !isHidden;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 20),

            loading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: Text("Login"),
            ),

            SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text("Don't have an account? Register"),
            )
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:taskproject/screens/register_screen.dart';
// import 'package:taskproject/screens/users_screen.dart';
// import '../services/auth_service.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final auth = AuthService();
//
//   bool isLoading = false;
//
//   void login() async {
//     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enter email & password")),
//       );
//       return;
//     }
//
//     try {
//       setState(() => isLoading = true);
//
//       await auth.login(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//       );
//
//       setState(() => isLoading = false);
//
//       // 🔥 IMPORTANT CHANGE
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => UsersScreen()),
//       );
//     } catch (e) {
//       setState(() => isLoading = false);
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Login Failed")),
//       );
//
//       print("Login error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: emailController,
//               decoration: InputDecoration(labelText: "Email"),
//             ),
//             TextField(
//               controller: passwordController,
//               decoration: InputDecoration(labelText: "Password"),
//               obscureText: true,
//             ),
//             SizedBox(height: 20),
//
//             isLoading
//                 ? CircularProgressIndicator()
//                 : ElevatedButton(
//               onPressed: login,
//               child: Text("Login"),
//             ),
//
//             SizedBox(height: 20),
//
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => RegisterScreen()),
//                 );
//               },
//               child: Text("Don't have an account? Register"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }