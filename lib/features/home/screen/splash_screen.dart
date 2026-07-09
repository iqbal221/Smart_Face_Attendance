import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/home/screen/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String name = '/splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() => _moveToNextScreen());
  }

  Future<void> _moveToNextScreen() async {
    await Future.delayed(Duration(seconds: 3));

    Navigator.pushReplacementNamed(context, RoleSelectionScreen.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/splash_logo.png', width: 500),
      ),
    );
  }
}
