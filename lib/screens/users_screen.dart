import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';

class UsersScreen extends StatelessWidget {
  final auth = AuthService();
  final firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users")),
      body: StreamBuilder(
        stream: firestore.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text("No users"));

          final users = snapshot.data!.docs;

          return ListView(
            children: users.map((doc) {
              final uid = doc['uid'];

              if (uid == auth.uid) return SizedBox(); // skip self

              return ListTile(
                title: Text(doc['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(receiverId: uid),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}