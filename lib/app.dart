import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/core/routes.dart';
import 'package:smart_face_attendance/features/home/screen/splash_screen.dart';

class SmartFaceAttendance extends StatefulWidget {
  const SmartFaceAttendance({super.key});

  @override
  State<SmartFaceAttendance> createState() => _SmartFaceAttendanceState();
}

class _SmartFaceAttendanceState extends State<SmartFaceAttendance> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: SplashScreen.name,
      onGenerateRoute: AppRoutes.routes,
      home: const SplashScreen(),
    );
  }
}
