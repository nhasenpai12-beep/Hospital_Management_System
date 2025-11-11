import 'package:test/test.dart';
import '../lib/domain/medical_record.dart';
import '../lib/domain/patient.dart';
import '../lib/domain/staff.dart';

void main() {
  group('Medical Record Tests', () {
    late Patient testPatient;
    late Doctor testDoctor;
    late MedicalRecord medicalRecord;

    setUp(() {
      testPatient = Patient(
        id: 'P001',
        name: 'Prak Daravuth',
        email: 'prak.daravuth@email.com',
        phoneNumber: '012-888-001',
        dateOfBirth: DateTime(1980, 1, 1),
        bloodType: 'O+',
        emergencyContact: 'Prak Sophea - 012-888-002',
      );

      testDoctor = Doctor(
        id: 'D001',
        name: 'Dr. Meas Channary',
        email: 'meas.channary@hospital.com',
        phoneNumber: '023-999-001',
        department: 'Internal Medicine',
        hireDate: DateTime.now(),
        salary: 100000,
        specialization: 'Internal Medicine Specialist',
      );

      medicalRecord = MedicalRecord(
        recordId: 'MR001',
        patient: testPatient,
      );
    });

    test('Medical record should store patient entries', () {
      final entry = MedicalEntry(
        date: DateTime.now(),
        diagnosis: 'Common Cold',
        symptoms: 'Cough, fever',
        treatment: 'Rest and hydration',
        attendingDoctor: testDoctor,
      );

      medicalRecord.addEntry(entry);
      expect(medicalRecord.entries.length, equals(1));
      expect(medicalRecord.entries.first.diagnosis, equals('Common Cold'));
    });

    test('Should filter entries by date range', () {
      final oldEntry = MedicalEntry(
        date: DateTime(2023, 1, 1),
        diagnosis: 'Old Issue',
        symptoms: 'Old symptoms',
        treatment: 'Old treatment',
        attendingDoctor: testDoctor,
      );

      final newEntry = MedicalEntry(
        date: DateTime.now(),
        diagnosis: 'Current Issue',
        symptoms: 'Current symptoms',
        treatment: 'Current treatment',
        attendingDoctor: testDoctor,
      );

      medicalRecord.addEntry(oldEntry);
      medicalRecord.addEntry(newEntry);

      final recentEntries = medicalRecord.getEntriesByDateRange(
          DateTime(2024, 1, 1), DateTime.now().add(const Duration(days: 1)));

      expect(recentEntries.length, equals(1));
      expect(recentEntries.first.diagnosis, equals('Current Issue'));
    });
  });
}
