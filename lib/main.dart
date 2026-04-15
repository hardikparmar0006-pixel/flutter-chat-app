import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskproject/screens/splash_screen.dart';
import 'package:taskproject/services/notification_service.dart';
import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}