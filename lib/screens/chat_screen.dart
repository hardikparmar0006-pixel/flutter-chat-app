import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/encryption_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  ChatScreen({required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final auth = AuthService();
  final firestore = FirestoreService();
  final encryption = EncryptionService();
  final storage = StorageService();
  final picker = ImagePicker();

  late String chatId;

  @override
  void initState() {
    super.initState();
    chatId = firestore.getChatId(auth.uid, widget.receiverId);
  }

  void sendText() async {
    if (controller.text.trim().isEmpty) return;

    final encrypted = encryption.encrypt(controller.text);

    await firestore.sendMessage(chatId, {
      "sender": auth.uid,
      "receiver": widget.receiverId,
      "message": encrypted,
      "type": "text",
      "time": DateTime.now(),
    });

    controller.clear();
  }

  void sendImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final url = await storage.uploadImage(File(picked.path));

    await firestore.sendMessage(chatId, {
      "sender": auth.uid,
      "receiver": widget.receiverId,
      "message": url,
      "type": "image",
      "time": DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestore.getMessages(chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: Text("No messages"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final isMe = doc['sender'] == auth.uid;

                    if (doc['type'] == "image") {
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Image.network(
                          doc['message'],
                          width: 150,
                        ),
                      );
                    }

                    String message = "";
                    try {
                      message = encryption.decrypt(doc['message']);
                    } catch (e) {
                      message = "Error";
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: Icon(Icons.image),
                onPressed: sendImage,
              ),
              Expanded(child: TextField(controller: controller)),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendText,
              ),
            ],
          )
        ],
      ),
    );
  }
}
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../services/auth_service.dart';
// import '../services/encryption_service.dart';
// import '../services/firestore_service.dart';
// import '../services/storage_service.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String receiverId;
//
//   ChatScreen({required this.receiverId});
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final controller = TextEditingController();
//   final auth = AuthService();
//   final firestore = FirestoreService();
//   final encryption = EncryptionService();
//   final picker = ImagePicker();
//   final storage = StorageService();
//
//   late String chatId;
//
//   @override
//   void initState() {
//     super.initState();
//     chatId = firestore.getChatId(auth.uid, widget.receiverId);
//   }
//
//   void sendText() async {
//     if (controller.text.isEmpty) return;
//
//     final encrypted = encryption.encrypt(controller.text);
//
//     await firestore.sendMessage(chatId, {
//       "sender": auth.uid,
//       "receiver": widget.receiverId,
//       "message": encrypted,
//       "type": "text",
//       "time": DateTime.now(),
//     });
//
//     controller.clear();
//   }
//
//   void sendImage() async {
//     final picked = await picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     final url = await storage.uploadImage(File(picked.path));
//
//     await firestore.sendMessage(chatId, {
//       "sender": auth.uid,
//       "receiver": widget.receiverId,
//       "message": url,
//       "type": "image",
//       "time": DateTime.now(),
//     });
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: firestore.getMessages(chatId),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//
//                 final docs = snapshot.data!.docs;
//
//                 if (docs.isEmpty) {
//                   return Center(child: Text("No messages yet"));
//                 }
//
//                 return ListView.builder(
//                   padding: EdgeInsets.all(10),
//                   itemCount: docs.length,
//                   itemBuilder: (context, index) {
//                     final doc = docs[index];
//                     final isMe = doc['sender'] == auth.uid;
//
//                     String message = "";
//                     try {
//                       message = encryption.decrypt(doc['message']);
//                     } catch (e) {
//                       message = "️ Error decrypting";
//                     }
//
//                     return Align(
//                       alignment:
//                       isMe ? Alignment.centerRight : Alignment.centerLeft,
//                       child: Container(
//                         margin: EdgeInsets.symmetric(vertical: 5),
//                         padding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: isMe ? Colors.blue : Colors.grey[300],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           message,
//                           style: TextStyle(
//                             color: isMe ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//
//           ///  INPUT BOX
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             color: Colors.grey[200],
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     decoration: InputDecoration(
//                       hintText: "Type a message...",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(20),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.white,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 5),
//                 CircleAvatar(
//                   backgroundColor: Colors.blue,
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: sendText,
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.image),
//                   onPressed: sendImage,
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }