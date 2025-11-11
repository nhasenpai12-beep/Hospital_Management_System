import '../../domain/patient.dart';

class PatientRepository {
  final List<Patient> _patients = [];

  void addPatient(Patient patient) {
    _patients.add(patient);
  }

  List<Patient> getAllPatients() {
    return List.from(_patients);
  }

  Patient? findPatientById(String id) {
    try {
      return _patients.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Patient> searchPatients(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _patients
        .where((patient) =>
            patient.name.toLowerCase().contains(lowercaseQuery) ||
            patient.id.toLowerCase().contains(lowercaseQuery) ||
            patient.email.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  void updatePatient(Patient updatedPatient) {
    final index = _patients.indexWhere((p) => p.id == updatedPatient.id);
    if (index != -1) {
      _patients[index] = updatedPatient;
    }
  }
}
