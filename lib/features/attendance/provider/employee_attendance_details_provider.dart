import 'package:flutter/material.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';
import 'package:smart_face_attendance/features/registration/services/firestore_service.dart';
import '../services/attendance_service.dart';

class DateStatus {
  final DateTime date;
  final bool isPresent;
  DateStatus({required this.date, required this.isPresent});
}

class MonthKey {
  final int year;
  final int month;
  MonthKey(this.year, this.month);

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.year == year && other.month == month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  String get label {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${months[month - 1]} $year";
  }
}

class EmployeeAttendanceDetailProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = false;
  String? errorMessage;
  Employee? employee;
  List<DateStatus> dateStatuses = [];

  // NEW: currently selected month filter (null = show all months' list, but counts still need a month)
  MonthKey? selectedMonth;

  String _dateKey(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  // NEW: list of months that have data, newest first — used to populate the dropdown
  List<MonthKey> get availableMonths {
    final set = <MonthKey>{};
    for (final s in dateStatuses) {
      set.add(MonthKey(s.date.year, s.date.month));
    }
    final list = set.toList()
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });
    return list;
  }

  // NEW: statuses filtered to the selected month only
  List<DateStatus> get filteredStatuses {
    if (selectedMonth == null) return dateStatuses;
    return dateStatuses
        .where(
          (s) =>
              s.date.year == selectedMonth!.year &&
              s.date.month == selectedMonth!.month,
        )
        .toList();
  }

  // UPDATED: counts now reflect the selected month, not lifetime total
  int get presentCount => filteredStatuses.where((d) => d.isPresent).length;
  int get absentCount => filteredStatuses.where((d) => !d.isPresent).length;

  // NEW: call this when user picks a month from the dropdown
  void selectMonth(MonthKey month) {
    selectedMonth = month;
    notifyListeners();
  }

  Future<void> load(String employeeId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      employee = await _firestoreService.getEmployeeId(employeeId);
      final logs = await _attendanceService.getAttendanceLogsForEmployee(
        employeeId,
      );

      final presentDates = logs.map((log) => _dateKey(log.timestamp)).toSet();

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

      dateStatuses = statuses.reversed.toList();

      // NEW: default the dropdown to the most recent month with data
      if (dateStatuses.isNotEmpty) {
        selectedMonth = MonthKey(
          dateStatuses.first.date.year,
          dateStatuses.first.date.month,
        );
      }
    } catch (e) {
      errorMessage = "Failed to load employee attendance.";
      debugPrint("❌ EmployeeAttendanceDetail load error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
