import '../../domain/patient.dart';
import '../../domain/staff.dart';
import '../../domain/room.dart';
import '../../domain/enums.dart';
import '../../domain/emergency.dart';

/// Intelligent service that automatically assigns patients to doctors
/// and allocates beds based on symptoms, diagnosis, and severity
class IntelligentAssignmentService {
  final Map<String, List<String>> _symptomsToSpecialization = {
    'heart': ['Cardiologist', 'Cardiology'],
    'chest pain': ['Cardiologist', 'Cardiology'],
    'cardiac': ['Cardiologist', 'Cardiology'],
    'breathing': ['Pulmonologist', 'Cardiology', 'Internal Medicine'],
    'lungs': ['Pulmonologist', 'Internal Medicine'],
    'cough': ['Pulmonologist', 'Internal Medicine', 'General Practice'],
    'fever': ['Internal Medicine', 'General Practice', 'Infectious Disease'],
    'child': ['Pediatrician', 'Pediatrics'],
    'baby': ['Pediatrician', 'Pediatrics'],
    'infant': ['Pediatrician', 'Pediatrics'],
    'pregnancy': ['Obstetrician', 'Gynecology'],
    'pregnant': ['Obstetrician', 'Gynecology'],
    'bone': ['Orthopedic Surgeon', 'Orthopedics'],
    'fracture': ['Orthopedic Surgeon', 'Orthopedics'],
    'joint': ['Orthopedic Surgeon', 'Rheumatology'],
    'skin': ['Dermatologist', 'Dermatology'],
    'rash': ['Dermatologist', 'Internal Medicine'],
    'brain': ['Neurologist', 'Neurology'],
    'headache': ['Neurologist', 'Internal Medicine', 'General Practice'],
    'seizure': ['Neurologist', 'Neurology'],
    'mental': ['Psychiatrist', 'Psychiatry'],
    'depression': ['Psychiatrist', 'Psychiatry'],
    'anxiety': ['Psychiatrist', 'Psychiatry'],
    'eye': ['Ophthalmologist', 'Ophthalmology'],
    'vision': ['Ophthalmologist', 'Ophthalmology'],
    'ear': ['ENT Specialist', 'Otolaryngology'],
    'throat': ['ENT Specialist', 'Otolaryngology'],
    'stomach': ['Gastroenterologist', 'Gastroenterology'],
    'digestive': ['Gastroenterologist', 'Gastroenterology'],
    'diabetes': ['Endocrinologist', 'Internal Medicine'],
    'thyroid': ['Endocrinologist', 'Endocrinology'],
    'kidney': ['Nephrologist', 'Nephrology'],
    'cancer': ['Oncologist', 'Oncology'],
    'tumor': ['Oncologist', 'Surgery'],
    'injury': ['Emergency Medicine', 'Orthopedics', 'Surgery'],
    'accident': ['Emergency Medicine', 'Trauma Surgery'],
    'bleeding': ['Emergency Medicine', 'Surgery'],
  };

  final Map<String, TriageLevel> _conditionSeverity = {
    'cardiac arrest': TriageLevel.red,
    'heart attack': TriageLevel.red,
    'stroke': TriageLevel.red,
    'severe bleeding': TriageLevel.red,
    'unconscious': TriageLevel.red,
    'chest pain': TriageLevel.yellow,
    'breathing difficulty': TriageLevel.yellow,
    'fracture': TriageLevel.yellow,
    'high fever': TriageLevel.yellow,
    'headache': TriageLevel.green,
    'cough': TriageLevel.green,
    'cold': TriageLevel.green,
    'checkup': TriageLevel.green,
  };

  /// Automatically assign the best doctor based on patient symptoms
  Doctor? assignDoctorToPatient(
    Patient patient,
    String symptoms,
    String diagnosis,
    List<Doctor> availableDoctors,
  ) {
    final keywords = _extractKeywords(symptoms, diagnosis);
    final matchedSpecializations = <String>[];

    // Find matching specializations
    for (final keyword in keywords) {
      for (final entry in _symptomsToSpecialization.entries) {
        if (keyword.contains(entry.key) || entry.key.contains(keyword)) {
          matchedSpecializations.addAll(entry.value);
        }
      }
    }

    // Find doctors with matching specialization who are available
    final matchingDoctors = availableDoctors.where((doctor) {
      return doctor.isAvailable &&
          matchedSpecializations.any((spec) =>
              doctor.specialization
                  .toLowerCase()
                  .contains(spec.toLowerCase()) ||
              doctor.department.toLowerCase().contains(spec.toLowerCase()));
    }).toList();

    if (matchingDoctors.isNotEmpty) {
      // Return doctor with least patients (load balancing)
      matchingDoctors.sort(
          (a, b) => a.currentPatientCount.compareTo(b.currentPatientCount));
      return matchingDoctors.first;
    }

    // Try to find any available doctor even if specialization doesn't match
    final anyAvailableDoctor =
        availableDoctors.where((d) => d.isAvailable).toList();

    if (anyAvailableDoctor.isNotEmpty) {
      // Sort by patient count and return least busy
      anyAvailableDoctor.sort(
          (a, b) => a.currentPatientCount.compareTo(b.currentPatientCount));
      return anyAvailableDoctor.first;
    }

    // Last resort: assign to general practice or internal medicine (even if busy)
    final generalDoctor = availableDoctors.firstWhere(
      (d) =>
          d.specialization.toLowerCase().contains('general') ||
          d.specialization.toLowerCase().contains('internal'),
      orElse: () {
        // Return doctor with least patients
        availableDoctors.sort(
            (a, b) => a.currentPatientCount.compareTo(b.currentPatientCount));
        return availableDoctors.first;
      },
    );

    return generalDoctor;
  }

  /// Assess patient severity and determine triage level
  TriageLevel assessSeverity(String symptoms, String diagnosis) {
    final keywords = _extractKeywords(symptoms, diagnosis);

    // Check for critical conditions
    for (final keyword in keywords) {
      for (final entry in _conditionSeverity.entries) {
        if (keyword.contains(entry.key) || entry.key.contains(keyword)) {
          if (entry.value == TriageLevel.red) {
            return TriageLevel.red;
          }
        }
      }
    }

    // Check for moderate conditions
    for (final keyword in keywords) {
      for (final entry in _conditionSeverity.entries) {
        if (keyword.contains(entry.key) || entry.key.contains(keyword)) {
          if (entry.value == TriageLevel.yellow) {
            return TriageLevel.yellow;
          }
        }
      }
    }

    return TriageLevel.green;
  }

  /// Automatically assign appropriate room/bed based on severity
  Room? assignRoom(
    Patient patient,
    TriageLevel severity,
    List<Room> availableRooms,
    List<Ward> availableWards,
  ) {
    // Filter only truly available (not occupied) rooms
    final unoccupiedRooms = availableRooms.where((r) => r.isAvailable).toList();

    if (unoccupiedRooms.isEmpty) {
      print('[WARNING] No available rooms found! All rooms occupied.');
      return null;
    }

    List<Room> preferredRooms = [];

    switch (severity) {
      case TriageLevel.red:
        // Critical - prefer emergency or operating rooms
        preferredRooms = unoccupiedRooms
            .where(
              (r) =>
                  r.type == RoomType.emergency || r.type == RoomType.operating,
            )
            .toList();
        break;

      case TriageLevel.yellow:
        // Moderate - prefer patient rooms or examination rooms
        preferredRooms = unoccupiedRooms
            .where(
              (r) =>
                  r.type == RoomType.patientRoom ||
                  r.type == RoomType.examination,
            )
            .toList();
        break;

      case TriageLevel.green:
        // Minor - prefer consultation or examination rooms
        preferredRooms = unoccupiedRooms
            .where(
              (r) =>
                  r.type == RoomType.consultation ||
                  r.type == RoomType.examination,
            )
            .toList();
        break;
    }

    // Return preferred room if available, otherwise any unoccupied room
    return preferredRooms.isNotEmpty
        ? preferredRooms.first
        : unoccupiedRooms.first;
  }

  /// Extract keywords from symptoms and diagnosis
  List<String> _extractKeywords(String symptoms, String diagnosis) {
    final combined = '${symptoms.toLowerCase()} ${diagnosis.toLowerCase()}';
    final words = combined.split(RegExp(r'[,\s]+'));
    return words.where((w) => w.length > 3).toList();
  }

  /// Create complete patient assignment
  PatientAssignment createPatientAssignment({
    required Patient patient,
    required String symptoms,
    required String diagnosis,
    required List<Doctor> availableDoctors,
    required List<Room> availableRooms,
    required List<Ward> availableWards,
  }) {
    final severity = assessSeverity(symptoms, diagnosis);
    final assignedDoctor =
        assignDoctorToPatient(patient, symptoms, diagnosis, availableDoctors);
    final assignedRoom =
        assignRoom(patient, severity, availableRooms, availableWards);

    return PatientAssignment(
      patient: patient,
      assignedDoctor: assignedDoctor,
      assignedRoom: assignedRoom,
      triageLevel: severity,
      symptoms: symptoms,
      diagnosis: diagnosis,
      assignmentTime: DateTime.now(),
    );
  }
}

/// Data class to hold patient assignment information
class PatientAssignment {
  final Patient patient;
  final Doctor? assignedDoctor;
  final Room? assignedRoom;
  final TriageLevel triageLevel;
  final String symptoms;
  final String diagnosis;
  final DateTime assignmentTime;

  PatientAssignment({
    required this.patient,
    required this.assignedDoctor,
    required this.assignedRoom,
    required this.triageLevel,
    required this.symptoms,
    required this.diagnosis,
    required this.assignmentTime,
  });

  @override
  String toString() {
    return '''
Patient Assignment:
  Patient: ${patient.name} (${patient.id})
  Doctor: ${assignedDoctor?.name ?? 'Not assigned'} - ${assignedDoctor?.specialization ?? 'N/A'}
  Room: ${assignedRoom?.roomNumber ?? 'Not assigned'} (${assignedRoom?.type ?? 'N/A'})
  Severity: $triageLevel
  Symptoms: $symptoms
  Diagnosis: $diagnosis
  Time: $assignmentTime
''';
  }
}
