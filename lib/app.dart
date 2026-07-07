import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_face_attendance/features/attendance/provider/RecognitionProvider.dart';
import 'package:smart_face_attendance/features/attendance/provider/attendance_report_provider.dart';
import 'package:smart_face_attendance/features/attendance/provider/employee_attendance_details_provider.dart';
import 'package:smart_face_attendance/features/core/routes.dart';
import 'package:smart_face_attendance/features/home/screen/splash_screen.dart';
import 'package:smart_face_attendance/features/registration/provider/registration_provider.dart';

class SmartFaceAttendance extends StatefulWidget {
  const SmartFaceAttendance({super.key});

  @override
  State<SmartFaceAttendance> createState() => _SmartFaceAttendanceState();
}

class _SmartFaceAttendanceState extends State<SmartFaceAttendance> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RegisterProvider>(
          create: (_) => RegisterProvider(),
        ),
        ChangeNotifierProvider<RecognitionProvider>(
          create: (_) => RecognitionProvider(),
        ),
        ChangeNotifierProvider<AttendanceReportProvider>(
          create: (_) => AttendanceReportProvider(),
        ),
        ChangeNotifierProvider<EmployeeAttendanceDetailProvider>(
          create: (_) => EmployeeAttendanceDetailProvider(),
        ),
      ],
      child: MaterialApp(
        initialRoute: SplashScreen.name,
        onGenerateRoute: AppRoutes.routes,
      ),
    );
  }
}
