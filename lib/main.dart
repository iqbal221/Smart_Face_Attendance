import 'package:flutter/material.dart';
import 'package:smart_face_attendance/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SmartFaceAttendance());
}
