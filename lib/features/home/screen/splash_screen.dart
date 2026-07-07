import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/core/screens/main_nav_screen.dart';
import 'package:smart_face_attendance/features/registration/screens/register_screen.dart';

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
    // AUTO CHECK LOGIN
    Future.microtask(() => checkAuthStatus());
  }

  Future<void> checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 3));
    // final user = FirebaseAuth.instance.currentUser;
    // print("CURRENT USER: $user");

    // if (user != null) {
    //   Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    // } else {
    Navigator.pushReplacementNamed(context, MainNavBarScreen.name);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 340,
              child: Text('Welcome to Smart Face Attendance App'),
            ),
          ],
        ),
      ),
    );
  }
}
