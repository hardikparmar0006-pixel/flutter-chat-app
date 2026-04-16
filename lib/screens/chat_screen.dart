import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

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

  bool showEmoji = false;
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
      backgroundColor: Color(0xFFECE5DD),
      appBar: AppBar(
        title: Text("Chat"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [

          /// 🔥 CHAT LIST
          Expanded(
            child: StreamBuilder(
              stream: firestore.getMessages(chatId),
              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final isMe = doc['sender'] == auth.uid;

                    /// IMAGE
                    if (doc['type'] == "image") {
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Image.network(
                            doc['message'],
                            width: 150,
                          ),
                        ),
                      );
                    }

                    /// TEXT
                    String message = "";
                    try {
                      message = encryption.decrypt(doc['message']);
                    } catch (e) {
                      message = "⚠️ Error";
                    }

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          message,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// 🔥 INPUT
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.emoji_emotions),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  setState(() => showEmoji = !showEmoji);
                },
              ),
              IconButton(
                icon: Icon(Icons.image),
                onPressed: sendImage,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  onTap: () => setState(() => showEmoji = false),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: sendText,
              ),
            ],
          ),

          /// 🔥 EMOJI
          showEmoji
              ? SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (cat, emoji) {
                controller.text += emoji.emoji;
              },
            ),
          )
              : SizedBox(),
        ],
      ),
    );
  }
}