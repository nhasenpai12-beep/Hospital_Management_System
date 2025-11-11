import 'package:test/test.dart';
import '../lib/domain/patient.dart';
import '../lib/domain/staff.dart';
import '../lib/domain/appointment.dart';

void main() {
  group('Appointment Tests', () {
    late Patient testPatient;
    late Doctor testDoctor;
    late Appointment testAppointment;

    setUp(() {
      testPatient = Patient(
        id: 'P001',
        name: 'Sok Sreymom',
        email: 'sok.sreymom@email.com',
        phoneNumber: '012-345-001',
        dateOfBirth: DateTime(1990, 3, 20),
        bloodType: 'A+',
        emergencyContact: 'Sok Sopheak - 012-345-002',
      );

      testDoctor = Doctor(
        id: 'D001',
        name: 'Dr. Chea Bopha',
        email: 'chea.bopha@hospital.com',
        phoneNumber: '023-456-7801',
        department: 'Cardiology',
        hireDate: DateTime(2015, 8, 1),
        salary: 150000,
        specialization: 'Cardiologist',
      );

      testAppointment = Appointment(
        id: 'A001',
        patient: testPatient,
        doctor: testDoctor,
        appointmentTime: DateTime.now().add(const Duration(hours: 2)),
        reason: 'Heart checkup',
      );
    });

    test('Appointment creation and basic properties', () {
      expect(testAppointment.patient.name, equals('Sok Sreymom'));
      expect(testAppointment.doctor.name, equals('Dr. Chea Bopha'));
      expect(testAppointment.status, equals(AppointmentStatus.scheduled));
      expect(testAppointment.isPast, isFalse);
    });

    test('Appointment status changes', () {
      expect(testAppointment.status, equals(AppointmentStatus.scheduled));

      testAppointment.markAsCompleted('Patient responded well to treatment');
      expect(testAppointment.status, equals(AppointmentStatus.completed));
      expect(testAppointment.notes, contains('responded well'));
    });

    test('Appointment time calculations', () {
      final endTime = testAppointment.endTime;
      final difference = endTime.difference(testAppointment.appointmentTime);
      expect(difference.inMinutes, equals(30)); // Default duration
    });

    test('Conflict detection between appointments', () {
      final sameTimeAppointment = Appointment(
        id: 'A002',
        patient: testPatient,
        doctor: testDoctor,
        appointmentTime: testAppointment.appointmentTime.add(
          const Duration(minutes: 15),
        ),
        reason: 'Follow-up',
      );

      expect(testAppointment.hasConflictWith(sameTimeAppointment), isTrue);
    });
  });
}
