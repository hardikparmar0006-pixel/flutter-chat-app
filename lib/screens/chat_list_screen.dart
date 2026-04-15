import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class ChatListScreen extends StatelessWidget {
  final auth = AuthService();
  final firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: firestore.getChats(auth.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return Center(child: Text("No Chats Yet"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final doc = chats[index];
              final data = doc.data() as Map<String, dynamic>;

              final users = List<String>.from(data['participants']);
              final otherUser = users.firstWhere((u) => u != auth.uid);

              final lastMessage = data['lastMessage'] ?? "";

              return ListTile(
                leading: CircleAvatar(
                  child: Text(otherUser[0].toUpperCase()),
                ),
                title: Text("User"),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(receiverId: otherUser),
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
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../services/auth_service.dart';
// import '../services/firestore_service.dart';
// import 'chat_screen.dart';
//
// class ChatListScreen extends StatelessWidget {
//   final auth = AuthService();
//   final firestore = FirestoreService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chats")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: firestore.getChats(auth.uid),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No Chats Yet"));
//           }
//
//           final chats = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: chats.length,
//             itemBuilder: (context, index) {
//               final doc = chats[index];
//
//               ///  SAFE DATA READ
//               final data = doc.data() as Map<String, dynamic>;
//
//               final users = List<String>.from(data['participants'] ?? []);
//               final otherUser =
//               users.firstWhere((u) => u != auth.uid, orElse: () => "Unknown");
//
//               final lastMessage = data['lastMessage'] ?? "";
//
//               final timestamp = data['lastTime'];
//
//               String time = "";
//               if (timestamp != null && timestamp is Timestamp) {
//                 final dt = timestamp.toDate();
//                 time = "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
//               }
//
//               return ListTile(
//                 contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//
//                 /// USER AVATAR
//                 leading: CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   child: Text(
//                     otherUser.substring(0, 1).toUpperCase(),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//
//                 ///  NAME + MESSAGE
//                 title: Text(
//                   "User",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//
//                 subtitle: Text(
//                   lastMessage,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//
//                 ///  TIME + UNREAD
//                 trailing: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       time,
//                       style: TextStyle(fontSize: 12),
//                     ),
//                     SizedBox(height: 5),
//
//                     ///  UNREAD DOT (basic)
//                     Container(
//                       width: 10,
//                       height: 10,
//                       decoration: BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 /// OPEN CHAT
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => ChatScreen(receiverId: otherUser),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }