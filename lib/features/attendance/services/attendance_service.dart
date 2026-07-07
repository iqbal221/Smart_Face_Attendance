import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_face_attendance/features/attendance/model/attendance_record.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';

class AttendanceService {
  final CollectionReference _attendanceRef = FirebaseFirestore.instance
      .collection('attendance_logs');

  Future<void> markAttendance({
    required String employeeId,
    required String name,
  }) async {
    await _attendanceRef.add({
      'employeeId': employeeId,
      'name': name,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Fetches all attendance logs, newest first.
  Future<List<AttendanceRecord>> getAttendanceLogs() async {
    final snapshot = await _attendanceRef
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => AttendanceRecord.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  /// Fetches attendance logs for one specific employee, newest first.
  Future<List<AttendanceRecord>> getAttendanceLogsForEmployee(
    String employeeId,
  ) async {
    final snapshot = await _attendanceRef
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => AttendanceRecord.fromMap(
            doc.id,
            doc.data() as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
