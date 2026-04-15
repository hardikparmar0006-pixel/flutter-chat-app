import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final key = Key.fromUtf8('1234567890123456');
  final iv = IV.fromUtf8('1234567890123456');

  late final encrypter = Encrypter(AES(key));

  String encrypt(String text) {
    return encrypter.encrypt(text, iv: iv).base64;
  }

  String decrypt(String text) {
    try {
      return encrypter.decrypt64(text, iv: iv);
    } catch (e) {
      print("Decrypt error: $e");
      return " Error decrypting";
    }
  }
}