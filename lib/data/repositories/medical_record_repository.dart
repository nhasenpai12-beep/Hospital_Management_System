import '../../domain/medical_record.dart';

class MedicalRecordRepository {
  final List<MedicalRecord> _records = [];

  void addRecord(MedicalRecord record) {
    _records.add(record);
  }

  MedicalRecord? findRecordByPatientId(String patientId) {
    try {
      return _records.firstWhere((record) => record.patient.id == patientId);
    } catch (e) {
      return null;
    }
  }

  void addMedicalEntry(String patientId, MedicalEntry entry) {
    final record = findRecordByPatientId(patientId);
    if (record != null) {
      record.addEntry(entry);
    } else {
      // Create new record if none exists
      // This would need a Patient object, so you'd need to fetch it first
    }
  }

  List<MedicalEntry> getPatientHistory(String patientId,
      {DateTime? startDate, DateTime? endDate}) {
    final record = findRecordByPatientId(patientId);
    if (record == null) return [];

    if (startDate != null && endDate != null) {
      return record.getEntriesByDateRange(startDate, endDate);
    }

    return record.entries;
  }
}
