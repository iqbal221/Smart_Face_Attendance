import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';
import 'package:smart_face_attendance/features/registration/services/firestore_service.dart';
import '../model/attendance_record.dart';
import '../services/attendance_service.dart';

class DateStatus {
  final DateTime date;
  final bool isPresent;
  DateStatus({required this.date, required this.isPresent});
}

class EmployeeAttendanceDetailProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  String? errorMessage;
  Employee? employee;
  List<DateStatus> dateStatuses = [];

  int get presentCount => dateStatuses.where((d) => d.isPresent).length;
  int get absentCount => dateStatuses.where((d) => !d.isPresent).length;

  String _dateKey(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  Future<void> load(String employeeId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      employee = await _firestoreService.getEmployeeId(employeeId);
      final logs = await _attendanceService.getAttendanceLogsForEmployee(
        employeeId,
      );

      // Collect the set of dates the employee was actually scanned present.
      final presentDates = logs.map((log) => _dateKey(log.timestamp)).toSet();

      // Determine the range: from registration date to today.
      final startDate =
          employee?.createdAt ??
          (logs.isNotEmpty ? logs.last.timestamp : DateTime.now());
      final today = DateTime.now();

      DateTime cursor = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endDate = DateTime(today.year, today.month, today.day);

      final List<DateStatus> statuses = [];
      while (!cursor.isAfter(endDate)) {
        statuses.add(
          DateStatus(
            date: cursor,
            isPresent: presentDates.contains(_dateKey(cursor)),
          ),
        );
        cursor = cursor.add(const Duration(days: 1));
      }

      // Newest date first for display.
      dateStatuses = statuses.reversed.toList();
    } catch (e) {
      errorMessage = "Failed to load employee attendance.";
      debugPrint("❌ EmployeeAttendanceDetail load error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
