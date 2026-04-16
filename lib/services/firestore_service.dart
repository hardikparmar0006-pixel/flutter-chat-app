import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final db = FirebaseFirestore.instance;

  /// 🔥 CHAT ID FIX
  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) > 0
        ? "${uid1}_$uid2"
        : "${uid2}_$uid1";
  }

  /// 🔥 SEND MESSAGE
  Future<void> sendMessage(String chatId, Map<String, dynamic> data) async {
    await db.collection("chats")
        .doc(chatId)
        .collection("messages")
        .add(data);

    /// chat list ke liye
    await db.collection("chats").doc(chatId).set({
      "participants": [data['sender'], data['receiver']],
      "lastMessage": data['type'] == "image" ? "📷 Image" : data['message'],
      "time": DateTime.now(),
    });
  }

  /// 🔥 GET MESSAGES
  Stream<QuerySnapshot> getMessages(String chatId) {
    return db.collection("chats")
        .doc(chatId)
        .collection("messages")
        .orderBy("time", descending: true)
        .snapshots();
  }

  /// 🔥 CHAT LIST
  Stream<QuerySnapshot> getChats(String uid) {
    return db.collection("chats")
        .where("participants", arrayContains: uid)
        .orderBy("time", descending: true)
        .snapshots();
  }


  Stream<QuerySnapshot> getUsers() {
    return FirebaseFirestore.instance
        .collection("users")
        .snapshots();
  }
}