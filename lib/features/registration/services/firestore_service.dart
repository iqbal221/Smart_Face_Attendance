import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_face_attendance/features/registration/model/employee_model.dart';

class FirestoreService {
  final CollectionReference _employeesRef = FirebaseFirestore.instance
      .collection('employees');

  /// Saves employee data. Uses employeeId as the document ID
  /// so re-registering the same ID overwrites (rather than duplicates).
  Future<void> saveEmployee(Employee employee) async {
    try {
      // Check for duplicate employee ID first
      final existing = await _employeesRef.doc(employee.employeeId).get();
      if (existing.exists) {
        throw Exception(
          "Employee ID '${employee.employeeId}' is already registered.",
        );
      }

      await _employeesRef.doc(employee.employeeId).set(employee.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final snapshot = await _employeesRef.get();
    return snapshot.docs
        .map((doc) => Employee.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get employee by Employee ID
  Future<Employee?> getEmployee(String employeeId) async {
    try {
      final doc = await _employeesRef.doc(employeeId).get();

      if (!doc.exists) return null;

      return Employee.fromMap(doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Get employee by Employee ID
  Future<Employee?> getEmployeeId(String employeeId) async {
    try {
      final doc = await _employeesRef.doc(employeeId).get();

      if (!doc.exists) return null;

      return Employee.fromMap(doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }
}
