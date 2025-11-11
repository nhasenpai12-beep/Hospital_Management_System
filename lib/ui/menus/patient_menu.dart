import 'dart:io';
import '../../domain/patient.dart';
import '../../data/repositories/patient_repository.dart';

class PatientMenu {
  final PatientRepository patientRepository;

  PatientMenu(this.patientRepository);

  void showMenu() {
    print('\n=== PATIENT MANAGEMENT ===');
    print('1. Register New Patient');
    print('2. Search Patients');
    print('3. View All Patients');
    print('4. Update Patient Information');
    print('5. Back to Main Menu');
  }

  void handleInput(String input) {
    switch (input) {
      case '1':
        registerNewPatient();
        break;
      case '2':
        searchPatients();
        break;
      case '3':
        viewAllPatients();
        break;
      case '4':
        updatePatient();
        break;
      case '5':
        return;
      default:
        print('Invalid option');
    }
  }

  void registerNewPatient() {
    print('\n--- Register New Patient ---');

    stdout.write('Patient ID: ');
    final id = stdin.readLineSync() ?? '';

    stdout.write('Full Name: ');
    final name = stdin.readLineSync() ?? '';

    stdout.write('Email: ');
    final email = stdin.readLineSync() ?? '';

    stdout.write('Phone Number: ');
    final phone = stdin.readLineSync() ?? '';

    stdout.write('Blood Type: ');
    final bloodType = stdin.readLineSync() ?? '';

    stdout.write('Emergency Contact: ');
    final emergencyContact = stdin.readLineSync() ?? '';

    final patient = Patient(
      id: id,
      name: name,
      email: email,
      phoneNumber: phone,
      dateOfBirth: DateTime(1980, 1, 1), // Would need proper date input
      bloodType: bloodType,
      emergencyContact: emergencyContact,
    );

    patientRepository.addPatient(patient);
    print('✅ Patient registered successfully!');
  }

  void searchPatients() {
    stdout.write('Enter search query: ');
    final query = stdin.readLineSync() ?? '';
    final results = patientRepository.searchPatients(query);

    print('\n--- Search Results ---');
    if (results.isEmpty) {
      print('No patients found.');
    } else {
      for (final patient in results) {
        print('${patient.name} (ID: ${patient.id}) - ${patient.bloodType}');
      }
    }
  }

  void viewAllPatients() {
    final patients = patientRepository.getAllPatients();

    print('\n--- All Patients ---');
    if (patients.isEmpty) {
      print('No patients registered.');
    } else {
      for (final patient in patients) {
        print('${patient.name} (ID: ${patient.id}) - Age: ${patient.age}');
      }
    }
  }

  void updatePatient() {
    print('Update patient functionality to be implemented...');
  }
}
