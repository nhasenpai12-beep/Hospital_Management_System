import 'person.dart';

// Staff member class - base for doctors, nurses, etc.
class Staff extends Person {
  String department;
  DateTime hireDate;
  double salary;

  Staff({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required this.department,
    required this.hireDate,
    required this.salary,
  });

  @override
  String getRole() {
    return 'Staff';
  }

  int getYearsOfService() {
    final now = DateTime.now();
    return now.year - hireDate.year;
  }
}

// Doctor specialization
class Doctor extends Staff {
  String specialization;
  List<String> certifications;
  int currentPatientCount = 0;
  int maxPatients = 5; // Maximum patients a doctor can handle at once

  Doctor({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.department,
    required super.hireDate,
    required super.salary,
    required this.specialization,
    this.certifications = const [],
  });

  @override
  String getRole() {
    return 'Doctor - $specialization';
  }

  /// Check if doctor is available to take more patients
  bool get isAvailable => currentPatientCount < maxPatients;

  /// Get availability status
  String get availabilityStatus {
    if (currentPatientCount == 0) return 'Available';
    if (currentPatientCount >= maxPatients) return 'Busy (Full)';
    return 'Available ($currentPatientCount/$maxPatients patients)';
  }

  /// Assign a patient to this doctor
  void assignPatient() {
    if (currentPatientCount < maxPatients) {
      currentPatientCount++;
    }
  }

  /// Release a patient from this doctor
  void releasePatient() {
    if (currentPatientCount > 0) {
      currentPatientCount--;
    }
  }

  void addCertification(String certification) {
    certifications.add(certification);
  }
}

// Nurse class
class Nurse extends Staff {
  String shift; // "day", "night", "rotating"
  int patientLoad;

  Nurse({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.department,
    required super.hireDate,
    required super.salary,
    required this.shift,
    this.patientLoad = 0,
  });

  @override
  String getRole() {
    return 'Nurse - $shift shift';
  }

  bool canTakeMorePatients() {
    return patientLoad < 8; // Assuming max 8 patients per nurse
  }
}
