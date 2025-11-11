import 'dart:io';

import 'menus/patient_menu.dart';
// import 'menus/medical_menu.dart';
// import 'menus/billing_menu.dart';
import '../data/repositories/patient_repository.dart';
import '../data/services/auth_service.dart';
import '../data/appointment_repository.dart';
import '../domain/patient.dart';
import '../domain/staff.dart';
import '../domain/appointment.dart';

class HospitalMenu {
  final AppointmentRepository appointmentRepository = AppointmentRepository();
  final PatientRepository patientRepository = PatientRepository();
  final AuthenticationService authService = AuthenticationService();
  final List<Patient> patients = [];
  final List<Doctor> doctors = [];

  late PatientMenu patientMenu;

  HospitalMenu() {
    patientMenu = PatientMenu(patientRepository);
    _initializeSampleData();
  }

  void _initializeSampleData() {
    patients.addAll([
      Patient(
        id: 'P001',
        name: 'Maria Garcia',
        email: 'maria.garcia@email.com',
        phoneNumber: '555-0101',
        dateOfBirth: DateTime(1978, 11, 3),
        bloodType: 'B+',
        emergencyContact: 'Carlos Garcia - 555-0102',
      ),
      Patient(
        id: 'P002',
        name: 'James Wilson',
        email: 'j.wilson@email.com',
        phoneNumber: '555-0201',
        dateOfBirth: DateTime(1992, 7, 14),
        bloodType: 'AB-',
        emergencyContact: 'Sarah Wilson - 555-0202',
      ),
    ]);

    doctors.addAll([
      Doctor(
        id: 'D001',
        name: 'Dr. Sarah Johnson',
        email: 's.johnson@hospital.com',
        phoneNumber: '555-1001',
        department: 'Pediatrics',
        hireDate: DateTime(2018, 3, 15),
        salary: 140000,
        specialization: 'Pediatrician',
      ),
      Doctor(
        id: 'D002',
        name: 'Dr. Michael Brown',
        email: 'm.brown@hospital.com',
        phoneNumber: '555-1002',
        department: 'Orthopedics',
        hireDate: DateTime(2012, 9, 22),
        salary: 180000,
        specialization: 'Orthopedic Surgeon',
      ),
    ]);

    appointmentRepository.addAppointment(
      Appointment(
        id: 'A001',
        patient: patients[0],
        doctor: doctors[0],
        appointmentTime: DateTime.now().add(const Duration(days: 1, hours: 10)),
        reason: 'Annual checkup',
      ),
    );
  }

  void showMainMenu() {
    print('\n=== HOSPITAL MANAGEMENT SYSTEM ===');
    print('1. Patient Management');
    print('2. Medical Records');
    print('3. Appointments');
    print('4. Billing & Insurance');
    print('5. Inventory Management');
    print('6. Emergency Cases');
    print('7. Reports & Analytics');
    print('8. Exit');
    print('==================================');
  }

  void run() {
    if (!_login()) {
      print('Login failed. Exiting system.');
      return;
    }

    print('Welcome to Hospital Management System!');

    bool running = true;
    while (running) {
      showMainMenu();
      stdout.write('Choose an option (1-8): ');
      var input = stdin.readLineSync();

      switch (input) {
        case '1':
          _showPatientManagement();
          break;
        case '2':
          _showMedicalRecords();
          break;
        case '3':
          // Existing appointment functionality
          break;
        case '4':
          _showBilling();
          break;
        case '5':
          _showInventory();
          break;
        case '6':
          _showEmergency();
          break;
        case '7':
          _showReports();
          break;
        case '8':
          running = false;
          print('Thank you for using Hospital Management System!');
          break;
        default:
          print('Invalid option. Please try again.');
      }
    }
  }

  bool _login() {
    print('\n=== LOGIN ===');
    stdout.write('Username: ');
    final username = stdin.readLineSync() ?? '';
    stdout.write('Password: ');
    final password = stdin.readLineSync() ?? '';

    final user = authService.login(username, password);
    if (user != null) {
      print('✅ Welcome, ${user.username} (${user.role})!');
      return true;
    } else {
      print('❌ Invalid username or password.');
      return false;
    }
  }

  void _showPatientManagement() {
    bool inPatientMenu = true;
    while (inPatientMenu) {
      patientMenu.showMenu();
      stdout.write('Choose an option: ');
      final input = stdin.readLineSync() ?? '';

      if (input == '5') {
        inPatientMenu = false;
      } else {
        patientMenu.handleInput(input);
      }
    }
  }

  void _showMedicalRecords() {
    print('\nMedical Records Management - Coming Soon!');
  }

  void _showBilling() {
    print('\nBilling & Insurance - Coming Soon!');
  }

  void _showInventory() {
    print('\nInventory Management - Coming Soon!');
  }

  void _showEmergency() {
    print('\nEmergency Cases - Coming Soon!');
  }

  void _showReports() {
    print('\nReports & Analytics - Coming Soon!');
  }
}
