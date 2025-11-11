import 'prescription.dart';
import 'staff.dart';
import 'patient.dart';

class MedicalRecord {
  String recordId;
  Patient patient;
  List<MedicalEntry> entries;

  MedicalRecord({
    required this.recordId,
    required this.patient,
    List<MedicalEntry>? entries,
  }) : entries = entries ?? [];

  void addEntry(MedicalEntry entry) {
    entries.add(entry);
  }

  List<MedicalEntry> getEntriesByDateRange(DateTime start, DateTime end) {
    return entries
        .where((entry) => entry.date.isAfter(start) && entry.date.isBefore(end))
        .toList();
  }

  MedicalEntry? getLatestEntry() {
    if (entries.isEmpty) return null;
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.first;
  }
}

class MedicalEntry {
  DateTime date;
  String diagnosis;
  String symptoms;
  String treatment;
  Doctor attendingDoctor;
  List<Prescription> prescriptions;
  String? notes;
  double? temperature;
  int? bloodPressureSystolic;
  int? bloodPressureDiastolic;

  MedicalEntry({
    required this.date,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    required this.attendingDoctor,
    List<Prescription>? prescriptions,
    this.notes,
    this.temperature,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
  }) : prescriptions = prescriptions ?? [];

  void addPrescription(Prescription prescription) {
    prescriptions.add(prescription);
  }

  bool get hasNormalVitals {
    final hasNormalTemp =
        temperature == null || (temperature! >= 36.1 && temperature! <= 37.2);
    final hasNormalBP = bloodPressureSystolic == null ||
        (bloodPressureSystolic! >= 90 && bloodPressureSystolic! <= 120);
    return hasNormalTemp && hasNormalBP;
  }
}
