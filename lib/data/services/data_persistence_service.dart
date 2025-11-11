import 'dart:io';
import 'dart:convert';
import '../../domain/patient.dart';
import '../../domain/medical_record.dart';
import 'intelligent_assignment_service.dart';

/// Enhanced persistence service to store all patient data and assignments
class DataPersistenceService {
  final String _dataDirectory = 'hospital_data';

  /// Initialize the data directory
  Future<void> initialize() async {
    final dir = Directory(_dataDirectory);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// Save patient assignment to file (to combined file)
  Future<void> savePatientAssignment(PatientAssignment assignment) async {
    await initialize();

    final data = {
      'patient_id': assignment.patient.id,
      'patient_name': assignment.patient.name,
      'patient_email': assignment.patient.email,
      'patient_phone': assignment.patient.phoneNumber,
      'date_of_birth': assignment.patient.dateOfBirth.toIso8601String(),
      'blood_type': assignment.patient.bloodType,
      'allergies': assignment.patient.allergies,
      'emergency_contact': assignment.patient.emergencyContact,
      'assigned_doctor_id': assignment.assignedDoctor?.id,
      'assigned_doctor_name': assignment.assignedDoctor?.name,
      'doctor_specialization': assignment.assignedDoctor?.specialization,
      'assigned_room': assignment.assignedRoom?.roomNumber,
      'room_type': assignment.assignedRoom?.type.toString(),
      'triage_level': assignment.triageLevel.toString(),
      'symptoms': assignment.symptoms,
      'diagnosis': assignment.diagnosis,
      'assignment_time': assignment.assignmentTime.toIso8601String(),
    };

    // Append to combined assignments file
    final combinedFile = File('$_dataDirectory/all_assignments.json');
    List<dynamic> assignments = [];

    if (await combinedFile.exists()) {
      try {
        final content = await combinedFile.readAsString();
        assignments = jsonDecode(content);
      } catch (e) {
        print('Warning: Could not read existing assignments: $e');
      }
    }

    assignments.add(data);
    const encoder = JsonEncoder.withIndent('    ');
    await combinedFile.writeAsString(encoder.convert(assignments));
  }

  /// Save complete patient data (to combined file)
  Future<void> savePatient(Patient patient) async {
    await initialize();

    final data = {
      'id': patient.id,
      'name': patient.name,
      'email': patient.email,
      'phoneNumber': patient.phoneNumber,
      'dateOfBirth': patient.dateOfBirth.toIso8601String(),
      'bloodType': patient.bloodType,
      'allergies': patient.allergies,
      'emergencyContact': patient.emergencyContact,
      'age': patient.age,
      'savedAt': DateTime.now().toIso8601String(),
    };

    // Load existing patients from combined file
    final combinedFile = File('$_dataDirectory/all_patients.json');
    List<dynamic> patients = [];

    if (await combinedFile.exists()) {
      try {
        final content = await combinedFile.readAsString();
        patients = jsonDecode(content);
      } catch (e) {
        print('Warning: Could not read existing patients: $e');
      }
    }

    // Check if patient already exists and update, otherwise add
    final existingIndex = patients.indexWhere((p) => p['id'] == patient.id);
    if (existingIndex != -1) {
      patients[existingIndex] = data;
    } else {
      patients.add(data);
    }

    // Save back to combined file
    const encoder = JsonEncoder.withIndent('    ');
    await combinedFile.writeAsString(encoder.convert(patients));
  }

  /// Save medical record entry (to combined file)
  Future<void> saveMedicalRecord(MedicalRecord record) async {
    await initialize();

    final entriesData = record.entries
        .map((entry) => {
              'date': entry.date.toIso8601String(),
              'diagnosis': entry.diagnosis,
              'symptoms': entry.symptoms,
              'treatment': entry.treatment,
              'doctor_id': entry.attendingDoctor.id,
              'doctor_name': entry.attendingDoctor.name,
              'notes': entry.notes,
              'temperature': entry.temperature,
              'bloodPressureSystolic': entry.bloodPressureSystolic,
              'bloodPressureDiastolic': entry.bloodPressureDiastolic,
            })
        .toList();

    final data = {
      'recordId': record.recordId,
      'patientId': record.patient.id,
      'patientName': record.patient.name,
      'entries': entriesData,
      'savedAt': DateTime.now().toIso8601String(),
    };

    // Load existing records from combined file
    final combinedFile = File('$_dataDirectory/all_medical_records.json');
    List<dynamic> records = [];

    if (await combinedFile.exists()) {
      try {
        final content = await combinedFile.readAsString();
        records = jsonDecode(content);
      } catch (e) {
        print('Warning: Could not read existing medical records: $e');
      }
    }

    // Check if record already exists and update, otherwise add
    final existingIndex =
        records.indexWhere((r) => r['patientId'] == record.patient.id);
    if (existingIndex != -1) {
      records[existingIndex] = data;
    } else {
      records.add(data);
    }

    // Save back to combined file
    const encoder = JsonEncoder.withIndent('    ');
    await combinedFile.writeAsString(encoder.convert(records));
  }

  /// Save summary report
  Future<void> saveSummaryReport(Map<String, dynamic> summary) async {
    await initialize();

    final timestamp = DateTime.now();
    final filename =
        '${_dataDirectory}/summary_${timestamp.millisecondsSinceEpoch}.json';
    final file = File(filename);

    summary['generated_at'] = timestamp.toIso8601String();
    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(summary));
  }

  /// Load all patient assignments
  Future<List<Map<String, dynamic>>> loadAllAssignments() async {
    await initialize();

    final dir = Directory(_dataDirectory);
    final files = await dir
        .list()
        .where((file) =>
            file.path.contains('assignment_') && file.path.endsWith('.json'))
        .toList();

    final assignments = <Map<String, dynamic>>[];
    for (final file in files) {
      if (file is File) {
        final content = await file.readAsString();
        assignments.add(jsonDecode(content));
      }
    }

    return assignments;
  }

  /// Load patient data by ID
  Future<Map<String, dynamic>?> loadPatient(String patientId) async {
    await initialize();

    final filename = '${_dataDirectory}/patient_$patientId.json';
    final file = File(filename);

    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content);
    }

    return null;
  }

  /// Load all patients from storage (from combined file)
  Future<List<Patient>> loadAllPatients() async {
    await initialize();

    // Try to load from combined file first
    final combinedFile = File('$_dataDirectory/all_patients.json');
    if (await combinedFile.exists()) {
      try {
        final content = await combinedFile.readAsString();
        final List<dynamic> data = jsonDecode(content);

        final patients = <Patient>[];
        for (final item in data) {
          final patient = Patient(
            id: item['id'] as String,
            name: item['name'] as String,
            email: item['email'] as String,
            phoneNumber: item['phoneNumber'] as String,
            dateOfBirth: DateTime.parse(item['dateOfBirth'] as String),
            bloodType: item['bloodType'] as String,
            allergies: (item['allergies'] as List<dynamic>).cast<String>(),
            emergencyContact: item['emergencyContact'] as String,
          );
          patients.add(patient);
        }
        return patients;
      } catch (e) {
        print('Warning: Could not load from all_patients.json: $e');
      }
    }

    // Fallback: load from individual files if combined file doesn't exist
    final dir = Directory(_dataDirectory);
    if (!await dir.exists()) {
      return [];
    }

    final files = await dir
        .list()
        .where((file) =>
            file.path.contains('patient_') &&
            file.path.endsWith('.json') &&
            !file.path.contains('assignment_') &&
            !file.path.contains('all_patients'))
        .toList();

    final patients = <Patient>[];
    for (final file in files) {
      if (file is File) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;

          final patient = Patient(
            id: data['id'] as String,
            name: data['name'] as String,
            email: data['email'] as String,
            phoneNumber: data['phoneNumber'] as String,
            dateOfBirth: DateTime.parse(data['dateOfBirth'] as String),
            bloodType: data['bloodType'] as String,
            allergies: (data['allergies'] as List<dynamic>).cast<String>(),
            emergencyContact: data['emergencyContact'] as String,
          );

          patients.add(patient);
        } catch (e) {
          print('Warning: Could not load patient from ${file.path}: $e');
        }
      }
    }

    return patients;
  }

  /// Load all medical records from storage
  Future<List<MedicalRecord>> loadAllMedicalRecords(
      List<Patient> patients) async {
    await initialize();

    final dir = Directory(_dataDirectory);
    if (!await dir.exists()) {
      return [];
    }

    final files = await dir
        .list()
        .where((file) =>
            file.path.contains('medical_record_') &&
            file.path.endsWith('.json'))
        .toList();

    final records = <MedicalRecord>[];
    for (final file in files) {
      if (file is File) {
        try {
          final content = await file.readAsString();
          final data = jsonDecode(content) as Map<String, dynamic>;

          final patientId = data['patientId'] as String;
          final patient = patients.firstWhere((p) => p.id == patientId);

          final record = MedicalRecord(
            recordId: data['recordId'] as String,
            patient: patient,
          );

          // Note: Entries require Doctor objects which we can't fully reconstruct
          // from JSON without doctor data. We'll load basic structure only.
          // Full entry reconstruction would need doctor lookup.

          records.add(record);
        } catch (e) {
          print('Warning: Could not load medical record from ${file.path}: $e');
        }
      }
    }

    return records;
  }

  /// Generate and save analytics report
  Future<void> generateAnalyticsReport(
    List<PatientAssignment> assignments,
    List<Patient> allPatients,
  ) async {
    final report = {
      'total_patients': allPatients.length,
      'total_assignments': assignments.length,
      'triage_breakdown': _calculateTriageBreakdown(assignments),
      'specialization_distribution':
          _calculateSpecializationDistribution(assignments),
      'room_occupancy': _calculateRoomOccupancy(assignments),
      'blood_type_distribution': _calculateBloodTypeDistribution(allPatients),
    };

    await saveSummaryReport(report);
  }

  Map<String, int> _calculateTriageBreakdown(
      List<PatientAssignment> assignments) {
    final breakdown = <String, int>{};
    for (final assignment in assignments) {
      final level = assignment.triageLevel.toString();
      breakdown[level] = (breakdown[level] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<String, int> _calculateSpecializationDistribution(
      List<PatientAssignment> assignments) {
    final distribution = <String, int>{};
    for (final assignment in assignments) {
      if (assignment.assignedDoctor != null) {
        final spec = assignment.assignedDoctor!.specialization;
        distribution[spec] = (distribution[spec] ?? 0) + 1;
      }
    }
    return distribution;
  }

  Map<String, int> _calculateRoomOccupancy(
      List<PatientAssignment> assignments) {
    final occupancy = <String, int>{};
    for (final assignment in assignments) {
      if (assignment.assignedRoom != null) {
        final roomType = assignment.assignedRoom!.type.toString();
        occupancy[roomType] = (occupancy[roomType] ?? 0) + 1;
      }
    }
    return occupancy;
  }

  Map<String, int> _calculateBloodTypeDistribution(List<Patient> patients) {
    final distribution = <String, int>{};
    for (final patient in patients) {
      distribution[patient.bloodType] =
          (distribution[patient.bloodType] ?? 0) + 1;
    }
    return distribution;
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final dir = Directory(_dataDirectory);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}
