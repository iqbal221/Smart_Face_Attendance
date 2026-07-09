import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/attendance/screens/attendance_screen.dart';
import 'package:smart_face_attendance/features/auth/screens/admin_auth_screen.dart';
import 'package:smart_face_attendance/features/core/screens/admin_home_screen.dart';
import 'package:smart_face_attendance/features/core/screens/main_nav_screen.dart';
import 'package:smart_face_attendance/features/home/screen/role_selection_screen.dart';
import 'package:smart_face_attendance/features/home/screen/splash_screen.dart';
import 'package:smart_face_attendance/features/registration/screens/employee_register_screen.dart';

class AppRoutes {
  static Route<dynamic> routes(RouteSettings settings) {
    Widget widget = SizedBox();

    if (settings.name == SplashScreen.name) {
      widget = SplashScreen();
    } else if (settings.name == EmployeeRegisterScreen.name) {
      widget = EmployeeRegisterScreen();
    } else if (settings.name == RoleSelectionScreen.name) {
      widget = RoleSelectionScreen();
    } else if (settings.name == AttendanceCheckInScreen.name) {
      widget = AttendanceCheckInScreen();
    } else if (settings.name == MainNavBarScreen.name) {
      widget = MainNavBarScreen(initialIndex: 1);
    } else if (settings.name == AdminAuthScreen.name) {
      widget = AdminAuthScreen();
    } else if (settings.name == AdminHomeScreen.name) {
      widget = AdminHomeScreen();
    }
    return MaterialPageRoute(builder: (ctx) => widget);
  }
}
