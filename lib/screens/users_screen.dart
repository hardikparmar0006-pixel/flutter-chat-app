import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getUsers(),
        builder: (context, snapshot) {

          /// 🔄 loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          /// ❌ no data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];

              final uid = doc['uid'];
              final email = doc['email'];

              /// ❗ khud ko hide karo
              if (uid == auth.uid) return SizedBox();

              return ListTile(
                leading: CircleAvatar(child: Text(email[0].toUpperCase())),
                title: Text(email),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(receiverId: uid),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}