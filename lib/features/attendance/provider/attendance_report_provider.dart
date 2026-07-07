import 'package:flutter/material.dart';
import '../model/attendance_record.dart';
import '../services/attendance_service.dart';

class AttendanceReportProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  bool isLoading = false;
  String? errorMessage;
  List<AttendanceRecord> records = [];

  Future<void> loadRecords() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      records = await _attendanceService.getAttendanceLogs();
    } catch (e) {
      errorMessage = "Failed to load attendance records.";
      debugPrint("❌ getAttendanceLogs error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Groups records by date (yyyy-MM-dd) for sectioned display.
  Map<String, List<AttendanceRecord>> get groupedByDate {
    final Map<String, List<AttendanceRecord>> grouped = {};
    for (final record in records) {
      final dateKey =
          "${record.timestamp.year}-${record.timestamp.month.toString().padLeft(2, '0')}-${record.timestamp.day.toString().padLeft(2, '0')}";
      grouped.putIfAbsent(dateKey, () => []).add(record);
    }
    return grouped;
  }
}
