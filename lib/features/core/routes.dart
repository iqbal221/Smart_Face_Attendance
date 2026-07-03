import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/attendance/screens/attendance_screen.dart';
import 'package:smart_face_attendance/features/auth/screens/login_screen.dart';
import 'package:smart_face_attendance/features/core/screens/main_nav_screen.dart';
import 'package:smart_face_attendance/features/home/screen/splash_screen.dart';
import 'package:smart_face_attendance/features/registration/screens/register_screen.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings settings) {
    Widget widget = SizedBox();

    if (settings.name == SplashScreen.name) {
      widget = SplashScreen();
    } else if (settings.name == RegistrationScreen.name) {
      widget = RegistrationScreen();
    } else if (settings.name == LoginScreen.name) {
      widget = LoginScreen();
    } else if (settings.name == AttendanceScreen.name) {
      widget = AttendanceScreen();
    } else if (settings.name == MainNavBarScreen.name) {
      widget = MainNavBarScreen(initialIndex: 1);
    }
    return MaterialPageRoute(builder: (ctx) => widget);
  }
}
