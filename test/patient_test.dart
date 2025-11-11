import 'package:test/test.dart';
import '../lib/domain/patient.dart';

void main() {
  group('Patient Tests', () {
    late Patient testPatient;

    setUp(() {
      testPatient = Patient(
        id: 'P001',
        name: 'Heng Veasna',
        email: 'heng.veasna@email.com',
        phoneNumber: '012-789-123',
        dateOfBirth: DateTime(1985, 6, 15),
        bloodType: 'O+',
        emergencyContact: 'Heng Dara - 012-789-124',
      );
    });

    test('Patient creation with basic info', () {
      expect(testPatient.name, equals('Heng Veasna'));
      expect(testPatient.bloodType, equals('O+'));
      expect(testPatient.getRole(), equals('Patient'));
    });

    test('Patient age calculation', () {
      // This test might need adjustment based on current date
      expect(testPatient.age, greaterThan(30));
    });

    test('Allergy management', () {
      expect(testPatient.allergies.isEmpty, isTrue);

      testPatient.addAllergy('Penicillin');
      expect(testPatient.hasAllergy('penicillin'), isTrue);
      expect(testPatient.hasAllergy('aspirin'), isFalse);

      // Test duplicate allergy prevention
      testPatient.addAllergy('Penicillin');
      expect(testPatient.allergies.length, equals(1));
    });
  });
}
