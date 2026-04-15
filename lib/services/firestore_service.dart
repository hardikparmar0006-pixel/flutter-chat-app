import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // 🔥 Generate chatId
  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) > 0
        ? uid1 + "_" + uid2
        : uid2 + "_" + uid1;
  }

  // 🔥 Send Message + Create Chat if not exists
  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    final chatRef = _db.collection('chats').doc(chatId);

    final doc = await chatRef.get();

    if (!doc.exists) {
      await chatRef.set({
        "participants": [message['sender'], message['receiver']],
        "lastMessage": message['message'],
        "timestamp": FieldValue.serverTimestamp(),
      });
    } else {
      await chatRef.update({
        "lastMessage": message['message'],
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    await chatRef.collection('messages').add(message);
  }

  // 🔥 Get messages
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  // 🔥 Get chat list
  Stream<QuerySnapshot> getChats(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots();
  }

  // 🔥 Get all users
  Stream<QuerySnapshot> getUsers() {
    return _db.collection('users').snapshots();
  }
}