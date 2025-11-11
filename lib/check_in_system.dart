import 'dart:io';
import 'dart:convert';
import 'domain/patient.dart';
import 'domain/staff.dart';
import 'domain/room.dart';
import 'domain/enums.dart';
import 'domain/emergency.dart';
import 'domain/medical_record.dart';
import 'domain/billing.dart';
import 'domain/inventory.dart';
import 'data/services/intelligent_assignment_service.dart';
import 'data/services/data_persistence_service.dart';
import 'data/services/config_loader_service.dart';
import 'data/repositories/patient_repository.dart';
import 'data/repositories/medical_record_repository.dart';

/// Hospital Patient Check-In System
/// Interactive system for registering and checking in patients
void main() async {
  final system = CheckInSystem();
  await system.initialize();
  await system.run();
}

class CheckInSystem {
  final IntelligentAssignmentService _assignmentService =
      IntelligentAssignmentService();
  final DataPersistenceService _persistenceService = DataPersistenceService();
  final ConfigLoaderService _configLoader = ConfigLoaderService();
  final PatientRepository _patientRepository = PatientRepository();
  final MedicalRecordRepository _recordRepository = MedicalRecordRepository();

  final List<Doctor> _doctors = [];
  final List<Nurse> _nurses = [];
  final List<Room> _rooms = [];
  final List<Ward> _wards = [];
  final List<PatientAssignment> _todayAssignments = [];
  final List<InventoryItem> _inventory = [];
  final List<Bill> _bills = [];

  /// Initialize hospital resources
  Future<void> initialize() async {
    await _persistenceService.initialize();
    await _loadDoctorsFromConfig();
    await _loadNursesFromConfig();
    await _loadRoomsFromConfig();
    _initializeWards();
    await _loadExistingPatients();
    await _restoreRoomOccupancy();
    await _loadInventory();
    await _loadBills();
  }

  /// Restore room occupancy from active assignments
  Future<void> _restoreRoomOccupancy() async {
    try {
      // In a real system, we'd track active vs discharged patients
      // For now, we'll mark all rooms as available on startup
      // Rooms will be occupied as patients are checked in during the session
      for (final room in _rooms) {
        room.vacate();
      }
    } catch (e) {
      print('Warning: Could not restore room occupancy: $e');
    }
  }

  /// Load existing patients from storage
  Future<void> _loadExistingPatients() async {
    try {
      final patients = await _persistenceService.loadAllPatients();

      for (final patient in patients) {
        _patientRepository.addPatient(patient);
      }

      // Load medical records
      final records = await _persistenceService.loadAllMedicalRecords(patients);
      for (final record in records) {
        _recordRepository.addRecord(record);
      }

      if (patients.isNotEmpty) {
        print('✓ Loaded ${patients.length} existing patient(s) from database');
      }
    } catch (e) {
      print('Warning: Could not load existing patients: $e');
    }
  }

  /// Load doctors from configuration file
  Future<void> _loadDoctorsFromConfig() async {
    final doctors = await _configLoader.loadDoctors();
    if (doctors.isNotEmpty) {
      _doctors.addAll(doctors);
      print(
          '✓ Loaded ${doctors.length} doctor(s) from hospital_data/doctors.json');
    } else {
      print('[!] Warning: No doctors loaded. Check hospital_data/doctors.json');
    }
  }

  /// Load nurses from configuration file
  Future<void> _loadNursesFromConfig() async {
    final nurses = await _configLoader.loadNurses();
    if (nurses.isNotEmpty) {
      _nurses.addAll(nurses);
      print(
          '✓ Loaded ${nurses.length} nurse(s) from hospital_data/nurses.json');
    } else {
      print('[!] Warning: No nurses loaded. Check hospital_data/nurses.json');
    }
  }

  /// Load rooms from configuration file
  Future<void> _loadRoomsFromConfig() async {
    final rooms = await _configLoader.loadRooms();
    if (rooms.isNotEmpty) {
      _rooms.addAll(rooms);
      print('✓ Loaded ${rooms.length} room(s) from hospital_data/rooms.json');
    } else {
      print('[!] Warning: No rooms loaded. Check hospital_data/rooms.json');
    }
  }

  /// Initialize wards
  void _initializeWards() {
    _wards.addAll([
      Ward(
        wardId: 'Emergency',
        type: WardType.icu,
        rooms: _rooms.where((r) => r.type == RoomType.emergency).toList(),
        maxCapacity: 5,
      ),
      Ward(
        wardId: 'General Ward',
        type: WardType.general,
        rooms: _rooms.where((r) => r.type == RoomType.patientRoom).toList(),
        maxCapacity: 12,
      ),
    ]);
  }

  /// Load inventory from JSON
  Future<void> _loadInventory() async {
    try {
      final file = File('hospital_data/inventory.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as List<dynamic>;

        for (final item in data) {
          _inventory.add(InventoryItem(
            itemId: item['itemId'],
            name: item['name'],
            category: item['category'],
            quantity: item['quantity'],
            minStockLevel: item['minStockLevel'],
            unitPrice: item['unitPrice'].toDouble(),
            supplier: item['supplier'] ?? 'Unknown',
            expiryDate: item['expiryDate'] != null
                ? DateTime.parse(item['expiryDate'])
                : null,
          ));
        }
        print('✓ Loaded ${_inventory.length} inventory items');
      }
    } catch (e) {
      print('[!] Warning: Could not load inventory: $e');
    }
  }

  /// Load bills from JSON
  Future<void> _loadBills() async {
    try {
      final file = File('hospital_data/bills.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final data = jsonDecode(content) as List<dynamic>;

        for (final billData in data) {
          final patientId = billData['patientId'];
          final patient = _patientRepository.findPatientById(patientId);

          if (patient != null) {
            final items = <BillableItem>[];
            for (final itemData in billData['items']) {
              items.add(BillableItem(
                description: itemData['description'],
                cost: itemData['cost'].toDouble(),
                serviceDate: DateTime.parse(itemData['serviceDate']),
                serviceType: itemData['serviceType'],
              ));
            }

            final bill = Bill(
              billId: billData['billId'],
              patient: patient,
              items: items,
              insurance: null,
              status: _parseBillStatus(billData['status']),
              issueDate: DateTime.parse(billData['issueDate']),
            );

            _bills.add(bill);
          }
        }
        print('✓ Loaded ${_bills.length} bill(s)');
      }
    } catch (e) {
      print('[!] Warning: Could not load bills: $e');
    }
  }

  /// Parse bill status from string
  BillStatus _parseBillStatus(String status) {
    if (status.contains('paid')) return BillStatus.paid;
    if (status.contains('issued')) return BillStatus.issued;
    if (status.contains('overdue')) return BillStatus.overdue;
    return BillStatus.draft;
  }

  /// Main system loop
  Future<void> run() async {
    bool running = true;
    while (running) {
      _printMenu();
      stdout.write('\nSelect option: ');
      final choice = stdin.readLineSync()?.trim() ?? '';

      print(''); // Blank line for spacing

      switch (choice) {
        case '1':
          await _checkInNewPatient();
          break;
        case '2':
          await _searchExistingPatient();
          break;
        case '3':
          _viewTodayAdmissions();
          break;
        case '4':
          _viewHospitalStatus();
          break;
        case '5':
          _viewMedicalStaff();
          break;
        case '6':
          await _dischargePatient();
          break;
        case '7':
          await _addVisitNotes();
          break;
        case '8':
          _viewPatientHistory();
          break;
        case '9':
          _viewOutstandingBills();
          break;
        case '10':
          await _processBillPayment();
          break;
        case '11':
          await _createPrescription();
          break;
        case '12':
          _viewInventoryLevels();
          break;
        case '0':
          running = false;
          print('Thank you for using the Hospital Check-In System.');
          break;
        default:
          print('❌ Invalid option. Please try again.');
      }

      if (running) {
        stdout.write('\nPress Enter to continue...');
        stdin.readLineSync();
        print('\n');
      }
    }
  }

  void _printMenu() {
    print('═══════════════════════════════════════════════════');
    print('       HOSPITAL PATIENT CHECK-IN SYSTEM');
    print('═══════════════════════════════════════════════════');
    print('');
    print('MAIN MENU');
    print('───────────────────────────────────────────────────');
    print('1. Check In New Patient');
    print('2. Search Existing Patient');
    print('3. View Today\'s Admissions');
    print('4. View Hospital Status');
    print('5. View Medical Staff');
    print('6. Discharge Patient');
    print('7. Add Visit Notes');
    print('8. View Patient Medical History');
    print('');
    print('BILLING & INVENTORY');
    print('───────────────────────────────────────────────────');
    print('9. View Outstanding Bills');
    print('10. Process Bill Payment');
    print('11. Create Prescription (with inventory)');
    print('12. View Inventory Levels');
    print('0. Exit');
  }

  /// Check in a new patient
  Future<void> _checkInNewPatient() async {
    print('═══════════════════════════════════════════════════');
    print('         NEW PATIENT CHECK-IN');
    print('═══════════════════════════════════════════════════\n');

    stdout.write('Patient Name: ');
    final name = stdin.readLineSync()?.trim() ?? '';
    if (name.isEmpty) {
      print('❌ Name is required.');
      return;
    }

    stdout.write('Phone Number: ');
    final phone = stdin.readLineSync()?.trim() ?? '';
    final email = '';

    stdout.write('Date of Birth (YYYY-MM-DD): ');
    final dobString = stdin.readLineSync()?.trim() ?? '';
    DateTime? dob;
    try {
      final parts = dobString.split('-');
      dob = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (e) {
      print('❌ Invalid date format. Using default date.');
      dob = DateTime(1980, 1, 1);
    }

    stdout.write('Blood Type (e.g., O+, A-, B+): ');
    final bloodType = stdin.readLineSync()?.trim() ?? 'Unknown';

    stdout.write('Known Allergies (comma-separated, or press Enter if none): ');
    final allergiesInput = stdin.readLineSync()?.trim() ?? '';
    final allergies = allergiesInput.isEmpty
        ? <String>[]
        : allergiesInput.split(',').map((a) => a.trim()).toList();

    stdout.write('Emergency Contact Name and Phone: ');
    final emergencyContact = stdin.readLineSync()?.trim() ?? '';

    print('\n--- Medical Information ---');
    stdout.write('Chief Complaint / Symptoms: ');
    final symptoms = stdin.readLineSync()?.trim() ?? '';
    if (symptoms.isEmpty) {
      print('❌ Symptoms are required for check-in.');
      return;
    }

    stdout.write('Initial Diagnosis / Reason for Visit: ');
    final diagnosis = stdin.readLineSync()?.trim() ?? 'To be determined';

    // Generate patient ID
    final patientId =
        'P${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Create patient
    final patient = Patient(
      id: patientId,
      name: name,
      email: email,
      phoneNumber: phone,
      dateOfBirth: dob,
      bloodType: bloodType,
      allergies: allergies,
      emergencyContact: emergencyContact,
    );

    print('\n--- Processing Check-In ---');
    print('Analyzing symptoms and assigning resources...\n');

    // Auto-assign doctor and room
    final assignment = _assignmentService.createPatientAssignment(
      patient: patient,
      symptoms: symptoms,
      diagnosis: diagnosis,
      availableDoctors: _doctors,
      availableRooms: _rooms,
      availableWards: _wards,
    );

    // Assign doctor and occupy room
    if (assignment.assignedDoctor != null) {
      assignment.assignedDoctor!.assignPatient();
    }
    if (assignment.assignedRoom != null) {
      assignment.assignedRoom!.occupy();
      print(
          '[DEBUG] Room ${assignment.assignedRoom!.roomNumber} marked as occupied');
    }

    // Save everything
    _patientRepository.addPatient(patient);
    await _persistenceService.savePatient(patient);
    await _persistenceService.savePatientAssignment(assignment);
    _todayAssignments.add(assignment);

    // Create medical record
    final medicalRecord = MedicalRecord(
      recordId: 'MR_${patient.id}',
      patient: patient,
    );

    if (assignment.assignedDoctor != null) {
      final entry = MedicalEntry(
        date: DateTime.now(),
        diagnosis: diagnosis,
        symptoms: symptoms,
        treatment: 'Awaiting evaluation',
        attendingDoctor: assignment.assignedDoctor!,
        notes: 'Patient checked in at reception',
      );
      medicalRecord.addEntry(entry);
    }

    _recordRepository.addRecord(medicalRecord);
    await _persistenceService.saveMedicalRecord(medicalRecord);

    // Auto-generate consultation bill with dynamic pricing
    double consultationCost = 50.0; // Base cost

    // Adjust cost based on triage level (urgency)
    if (assignment.triageLevel == TriageLevel.red) {
      consultationCost = 150.0; // Emergency/Urgent
    } else if (assignment.triageLevel == TriageLevel.yellow) {
      consultationCost = 100.0; // Moderate urgency
    } else {
      consultationCost = 75.0; // Routine
    }

    // Additional charge for specialists
    if (assignment.assignedDoctor != null) {
      final specialization =
          assignment.assignedDoctor!.specialization.toLowerCase();
      if (specialization.contains('cardiologist') ||
          specialization.contains('neurologist') ||
          specialization.contains('surgeon')) {
        consultationCost += 50.0; // Specialist surcharge
      } else if (specialization.contains('pediatrician') ||
          specialization.contains('internal medicine')) {
        consultationCost += 25.0; // Standard specialist
      }
    }

    final bill = Bill(
      billId: 'BILL${DateTime.now().millisecondsSinceEpoch}',
      patient: patient,
      items: [
        BillableItem(
          description: assignment.assignedDoctor != null
              ? 'Medical Consultation - ${assignment.assignedDoctor!.specialization} (${assignment.triageLevel == TriageLevel.red ? "Emergency" : assignment.triageLevel == TriageLevel.yellow ? "Urgent" : "Standard"})'
              : 'Medical Consultation - General',
          cost: consultationCost,
          serviceDate: DateTime.now(),
          serviceType: 'consultation',
        ),
      ],
      insurance: null,
      status: BillStatus.issued,
      issueDate: DateTime.now(),
    );
    _bills.add(bill);
    await _saveBills();

    // Print confirmation
    print('CHECK-IN COMPLETE');
    print('═══════════════════════════════════════════════════');
    print('PATIENT INFORMATION:');
    print('  Patient ID: ${patient.id}');
    print('  Name: ${patient.name}');
    print('  Age: ${patient.age} years');
    print('  Blood Type: ${patient.bloodType}');
    print('  Phone: ${patient.phoneNumber}');
    if (allergies.isNotEmpty) {
      print('  [!] Allergies: ${allergies.join(", ")}');
    }
    if (emergencyContact.isNotEmpty) {
      print('  Emergency Contact: $emergencyContact');
    }
    print('');
    print('MEDICAL ASSIGNMENT:');
    final priorityText = assignment.triageLevel == TriageLevel.red
        ? 'URGENT'
        : assignment.triageLevel == TriageLevel.yellow
            ? 'Moderate'
            : 'Routine';

    print('  Priority Level: $priorityText');
    if (assignment.assignedDoctor != null) {
      print('  Assigned Doctor: ${assignment.assignedDoctor!.name}');
      print('  Department: ${assignment.assignedDoctor!.department}');
    }
    if (assignment.assignedRoom != null) {
      print('  Room Number: ${assignment.assignedRoom!.roomNumber}');
      print(
          '  Room Type: ${assignment.assignedRoom!.type.toString().split('.').last}');
    }
    print('  Chief Complaint: $symptoms');
    print('  Initial Assessment: $diagnosis');
    print('');
    print('BILLING:');
    print('  Bill ID: ${bill.billId}');
    print('  Consultation Fee: \$${bill.totalAmount.toStringAsFixed(2)}');
    print(
        '  Status: Issued (Due: ${bill.dueDate.toString().substring(0, 10)})');
    print('');
    print('TIP: Save your Patient ID (${patient.id}) for future reference');
    print('═══════════════════════════════════════════════════');
  }

  /// Search for existing patient
  Future<void> _searchExistingPatient() async {
    print('═══════════════════════════════════════════════════');
    print('         SEARCH PATIENT RECORDS');
    print('═══════════════════════════════════════════════════\n');
    print('TIP: You can search by name or patient ID\n');

    stdout.write('Enter patient name or ID: ');
    final query = stdin.readLineSync()?.trim() ?? '';

    if (query.isEmpty) {
      print('[!] Search query cannot be empty.');
      return;
    }

    final results = _patientRepository.searchPatients(query);

    if (results.isEmpty) {
      print('\n[!] No patients found matching "$query"');
      print('TIP: Try searching with a different name or ID');
      return;
    }

    print(
        '\nSearch Results (${results.length} patient${results.length > 1 ? 's' : ''} found):');
    print('───────────────────────────────────────────────────');

    for (final patient in results) {
      print('');
      print('${patient.name}');
      print('   Patient ID: ${patient.id}');
      print('   Age: ${patient.age} years | Blood Type: ${patient.bloodType}');
      print('   Contact: ${patient.phoneNumber}');
      if (patient.emergencyContact.isNotEmpty) {
        print('   Emergency Contact: ${patient.emergencyContact}');
      }
      if (patient.allergies.isNotEmpty) {
        print('   [!] Allergies: ${patient.allergies.join(", ")}');
      }
      print('───────────────────────────────────────────────────');
    }
  }

  /// View today's admissions
  void _viewTodayAdmissions() {
    print('═══════════════════════════════════════════════════');
    print('         TODAY\'S ADMISSIONS');
    print('═══════════════════════════════════════════════════\n');

    if (_todayAssignments.isEmpty) {
      print('No admissions yet today.');
      print('\nTIP: Use option 1 to check in a new patient');
      return;
    }

    print('Total check-ins today: ${_todayAssignments.length}');

    // Show breakdown by priority
    final urgent =
        _todayAssignments.where((a) => a.triageLevel == TriageLevel.red).length;
    final moderate = _todayAssignments
        .where((a) => a.triageLevel == TriageLevel.yellow)
        .length;
    final routine = _todayAssignments
        .where((a) => a.triageLevel == TriageLevel.green)
        .length;
    print('Urgent: $urgent | Moderate: $moderate | Routine: $routine\n');

    for (var i = 0; i < _todayAssignments.length; i++) {
      final assignment = _todayAssignments[i];
      final priorityLabel = assignment.triageLevel == TriageLevel.red
          ? '[URGENT]'
          : assignment.triageLevel == TriageLevel.yellow
              ? '[MODERATE]'
              : '[ROUTINE]';

      print(
          '${i + 1}. ${assignment.patient.name} (ID: ${assignment.patient.id})');
      print(
          '   $priorityLabel Doctor: ${assignment.assignedDoctor?.name ?? "Pending"}');
      print(
          '   Room: ${assignment.assignedRoom?.roomNumber ?? "Pending"} | Department: ${assignment.assignedDoctor?.department ?? "N/A"}');
      print('   Symptoms: ${assignment.symptoms}');
      print(
          '   Time: ${assignment.assignmentTime.toString().substring(11, 16)}');
      print('');
    }
  }

  /// View hospital status
  void _viewHospitalStatus() {
    print('═══════════════════════════════════════════════════');
    print('         HOSPITAL STATUS');
    print('═══════════════════════════════════════════════════\n');

    // Overall status
    print('Hospital Overview:');
    print('  ├─ Doctors on duty: ${_doctors.length}');
    print('  ├─ Nurses on duty: ${_nurses.length}');
    print(
        '  ├─ Available rooms: ${_rooms.where((r) => r.isAvailable).length}/${_rooms.length}');
    print(
        '  ├─ Total patients in database: ${_patientRepository.getAllPatients().length}');
    print('  └─ Today\'s check-ins: ${_todayAssignments.length}');
    print('');

    // Room availability
    final totalRooms = _rooms.length;
    final occupiedRooms = _rooms.where((r) => r.isOccupied).length;
    final availableRooms = totalRooms - occupiedRooms;
    final occupancyRate = (occupiedRooms / totalRooms * 100).toStringAsFixed(0);

    print('ROOM STATUS:');
    print('  Total rooms: $totalRooms');
    print('  Occupied: $occupiedRooms');
    print('  Available: $availableRooms');
    print('[DEBUG] Occupied room details:');
    for (final room in _rooms.where((r) => r.isOccupied)) {
      print('  - ${room.roomNumber} (${room.type})');
    }
    print('  Occupancy rate: $occupancyRate%');
    print('');

    // By room type
    final erRooms = _rooms.where((r) => r.type == RoomType.emergency);
    final examRooms = _rooms.where((r) => r.type == RoomType.examination);
    final wardRooms = _rooms.where((r) => r.type == RoomType.patientRoom);

    print(
        'Emergency Rooms: ${erRooms.where((r) => r.isAvailable).length}/${erRooms.length} available');
    print(
        'Examination Rooms: ${examRooms.where((r) => r.isAvailable).length}/${examRooms.length} available');
    print(
        'Ward Rooms: ${wardRooms.where((r) => r.isAvailable).length}/${wardRooms.length} available');
    print('');

    // Staff
    print('MEDICAL STAFF:');
    final availableDoctors = _doctors.where((d) => d.isAvailable).length;
    final busyDoctors = _doctors.length - availableDoctors;
    print('  Doctors on duty: ${_doctors.length}');
    print('    ├─ Available: $availableDoctors');
    print('    └─ Busy: $busyDoctors');

    final availableNurses =
        _nurses.where((n) => n.canTakeMorePatients()).length;
    print('  Nurses on duty: ${_nurses.length}');
    print('    └─ Available: $availableNurses');
    print('');

    // Today's stats
    print('TODAY\'S STATISTICS:');
    print('  Total check-ins: ${_todayAssignments.length}');

    if (_todayAssignments.isNotEmpty) {
      final urgent = _todayAssignments
          .where((a) => a.triageLevel == TriageLevel.red)
          .length;
      final moderate = _todayAssignments
          .where((a) => a.triageLevel == TriageLevel.yellow)
          .length;
      final routine = _todayAssignments
          .where((a) => a.triageLevel == TriageLevel.green)
          .length;

      if (urgent > 0) print('  Urgent: $urgent');
      if (moderate > 0) print('  Moderate: $moderate');
      if (routine > 0) print('  Routine: $routine');
    }
  }

  /// View medical staff (doctors and nurses)
  void _viewMedicalStaff() {
    print('═══════════════════════════════════════════════════');
    print('         MEDICAL STAFF ON DUTY');
    print('═══════════════════════════════════════════════════\n');

    print('DOCTORS (${_doctors.length} on duty):');
    print('───────────────────────────────────────────────────');
    for (final doctor in _doctors) {
      final yearsOfService = doctor.getYearsOfService();
      print('${doctor.name}');
      print('  Department: ${doctor.department}');
      print('  Specialization: ${doctor.specialization}');
      print('  Status: ${doctor.availabilityStatus}');
      print(
          '  Current Patients: ${doctor.currentPatientCount}/${doctor.maxPatients}');
      print(
          '  Years of Service: $yearsOfService year${yearsOfService != 1 ? 's' : ''}');
      print('  Contact: ${doctor.phoneNumber}');
      print('');
    }

    print('NURSES (${_nurses.length} on duty):');
    print('───────────────────────────────────────────────────');
    final dayShiftNurses =
        _nurses.where((n) => n.shift.toLowerCase() == 'day').length;
    final nightShiftNurses =
        _nurses.where((n) => n.shift.toLowerCase() == 'night').length;
    print('Day Shift: $dayShiftNurses | Night Shift: $nightShiftNurses\n');

    for (final nurse in _nurses) {
      final yearsOfService = nurse.getYearsOfService();
      final availability =
          nurse.canTakeMorePatients() ? 'Available' : 'At capacity';
      print('${nurse.name}');
      print('  Department: ${nurse.department}');
      print('  Shift: ${nurse.shift} | Status: $availability');
      print('  Patient Load: ${nurse.patientLoad}/8');
      print(
          '  Years of Service: $yearsOfService year${yearsOfService != 1 ? 's' : ''}');
      print('  Contact: ${nurse.phoneNumber}');
      print('');
    }
  }

  /// Discharge a patient
  Future<void> _dischargePatient() async {
    print('═══════════════════════════════════════════════════');
    print('         DISCHARGE PATIENT');
    print('═══════════════════════════════════════════════════\n');

    if (_todayAssignments.isEmpty) {
      print('[!] No patients currently admitted today.');
      print('TIP: Check option 3 to view today\'s admissions');
      return;
    }

    // Show current patients
    print('Currently Admitted Patients (${_todayAssignments.length}):');
    print('───────────────────────────────────────────────────');
    for (var i = 0; i < _todayAssignments.length; i++) {
      final assignment = _todayAssignments[i];
      final priorityLabel = assignment.triageLevel == TriageLevel.red
          ? '[URGENT]'
          : assignment.triageLevel == TriageLevel.yellow
              ? '[MODERATE]'
              : '[ROUTINE]';
      print(
          '${i + 1}. ${assignment.patient.name} (ID: ${assignment.patient.id})');
      print(
          '   $priorityLabel Room: ${assignment.assignedRoom?.roomNumber ?? "N/A"} | Doctor: ${assignment.assignedDoctor?.name ?? "N/A"}');
    }

    print('');
    stdout.write('Select patient number to discharge (or 0 to cancel): ');
    final input = stdin.readLineSync()?.trim() ?? '0';
    final selection = int.tryParse(input) ?? 0;

    if (selection < 1 || selection > _todayAssignments.length) {
      print('[!] Cancelled or invalid selection.');
      return;
    }

    final assignment = _todayAssignments[selection - 1];

    stdout.write('Discharge summary/notes: ');
    final notes = stdin.readLineSync()?.trim() ?? 'Discharged';

    // Release doctor and free up the room
    if (assignment.assignedDoctor != null) {
      assignment.assignedDoctor!.releasePatient();
    }
    if (assignment.assignedRoom != null) {
      assignment.assignedRoom!.vacate();
    }

    // Update medical record
    final record =
        _recordRepository.findRecordByPatientId(assignment.patient.id);
    if (record != null && record.entries.isNotEmpty) {
      record.entries.last.notes =
          '${record.entries.last.notes}\nDischarged: $notes';
      await _persistenceService.saveMedicalRecord(record);
    }

    // Remove from today's list
    _todayAssignments.removeAt(selection - 1);

    print('\nDISCHARGE SUCCESSFUL');
    print('   Patient: ${assignment.patient.name} (${assignment.patient.id})');
    print(
        '   Room ${assignment.assignedRoom?.roomNumber ?? "N/A"} is now available');
    print('   Attended by: ${assignment.assignedDoctor?.name ?? "N/A"}');
    print('   Discharge Summary: $notes');
  }

  /// Add visit notes to a patient
  Future<void> _addVisitNotes() async {
    print('═══════════════════════════════════════════════════');
    print('         ADD VISIT NOTES');
    print('═══════════════════════════════════════════════════\n');

    stdout.write('Enter patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';

    if (patientId.isEmpty) {
      print('[!] Patient ID is required.');
      return;
    }

    final patient = _patientRepository.findPatientById(patientId);
    if (patient == null) {
      print('[!] Patient not found.');
      return;
    }

    print('\nPatient: ${patient.name}');
    print('');

    stdout.write('Visit notes: ');
    final notes = stdin.readLineSync()?.trim() ?? '';

    if (notes.isEmpty) {
      print('[!] Notes cannot be empty.');
      return;
    }

    stdout.write('Treatment provided: ');
    final treatment = stdin.readLineSync()?.trim() ?? 'See notes';

    // Find or create medical record
    var record = _recordRepository.findRecordByPatientId(patientId);

    if (record == null) {
      print('[!] No medical record found for this patient.');
      return;
    }

    // Find assigned doctor
    final assignment = _todayAssignments.firstWhere(
      (a) => a.patient.id == patientId,
      orElse: () => _todayAssignments.first,
    );

    // Add entry
    if (assignment.assignedDoctor != null) {
      final entry = MedicalEntry(
        date: DateTime.now(),
        diagnosis: record.entries.last.diagnosis,
        symptoms: record.entries.last.symptoms,
        treatment: treatment,
        attendingDoctor: assignment.assignedDoctor!,
        notes: notes,
      );
      record.addEntry(entry);
      await _persistenceService.saveMedicalRecord(record);

      print('\nNotes added successfully to ${patient.name}\'s record.');
    }
  }

  /// View patient medical history
  void _viewPatientHistory() {
    print('═══════════════════════════════════════════════════');
    print('         PATIENT MEDICAL HISTORY');
    print('═══════════════════════════════════════════════════\n');

    stdout.write('Enter patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';

    if (patientId.isEmpty) {
      print('[!] Patient ID is required.');
      return;
    }

    final patient = _patientRepository.findPatientById(patientId);
    if (patient == null) {
      print('[!] Patient not found.');
      return;
    }

    final record = _recordRepository.findRecordByPatientId(patientId);
    if (record == null) {
      print('[!] No medical records found for this patient.');
      return;
    }

    print('PATIENT: ${patient.name} (${patient.id})');
    print('Age: ${patient.age} years | Blood Type: ${patient.bloodType}');
    if (patient.allergies.isNotEmpty) {
      print('[!] Allergies: ${patient.allergies.join(", ")}');
    }
    print('');
    print('MEDICAL HISTORY:');
    print('───────────────────────────────────────────────────');

    for (var i = 0; i < record.entries.length; i++) {
      final entry = record.entries[i];
      print('\nVisit ${i + 1} - ${entry.date.toString().substring(0, 16)}');
      print('Doctor: ${entry.attendingDoctor.name}');
      print('Symptoms: ${entry.symptoms}');
      print('Diagnosis: ${entry.diagnosis}');
      print('Treatment: ${entry.treatment}');
      if (entry.notes != null && entry.notes!.isNotEmpty) {
        print('Notes: ${entry.notes}');
      }
      if (entry.temperature != null) {
        print('Temperature: ${entry.temperature}°C');
      }
      if (entry.bloodPressureSystolic != null) {
        print(
            'BP: ${entry.bloodPressureSystolic}/${entry.bloodPressureDiastolic}');
      }
    }
  }

  /// View outstanding bills
  void _viewOutstandingBills() {
    print('═══════════════════════════════════════════════════');
    print('         OUTSTANDING BILLS');
    print('═══════════════════════════════════════════════════\n');

    final unpaidBills =
        _bills.where((b) => b.status != BillStatus.paid).toList();

    if (unpaidBills.isEmpty) {
      print('✓ No outstanding bills. All bills have been paid.');
      return;
    }

    print('Total outstanding bills: ${unpaidBills.length}');
    print('───────────────────────────────────────────────────\n');

    for (final bill in unpaidBills) {
      final statusText = bill.isOverdue
          ? '[OVERDUE ${bill.daysOverdue} days]'
          : bill.status == BillStatus.issued
              ? '[ISSUED]'
              : '[DRAFT]';

      print('$statusText Bill ID: ${bill.billId}');
      print('  Patient: ${bill.patient.name} (${bill.patient.id})');
      print('  Issue Date: ${bill.issueDate.toString().substring(0, 10)}');
      print('  Due Date: ${bill.dueDate.toString().substring(0, 10)}');
      print('  Total Amount: \$${bill.totalAmount.toStringAsFixed(2)}');

      if (bill.insurance != null) {
        print(
            '  Insurance Coverage: \$${bill.insuranceCoverage.toStringAsFixed(2)}');
      }
      print(
          '  Patient Responsibility: \$${bill.patientResponsibility.toStringAsFixed(2)}');

      print('  Items:');
      for (final item in bill.items) {
        print(
            '    - ${item.description}: \$${item.cost.toStringAsFixed(2)} (${item.serviceType})');
      }
      print('');
    }

    final totalOwed = unpaidBills.fold<double>(
        0.0, (sum, bill) => sum + bill.patientResponsibility);
    print('TOTAL OUTSTANDING: \$${totalOwed.toStringAsFixed(2)}');
  }

  /// Process bill payment
  Future<void> _processBillPayment() async {
    print('═══════════════════════════════════════════════════');
    print('         PROCESS BILL PAYMENT');
    print('═══════════════════════════════════════════════════\n');

    final unpaidBills =
        _bills.where((b) => b.status != BillStatus.paid).toList();

    if (unpaidBills.isEmpty) {
      print('[!] No outstanding bills to process.');
      return;
    }

    print('Outstanding Bills (${unpaidBills.length}):');
    print('───────────────────────────────────────────────────');
    for (var i = 0; i < unpaidBills.length; i++) {
      final bill = unpaidBills[i];
      print(
          '${i + 1}. ${bill.patient.name} - \$${bill.patientResponsibility.toStringAsFixed(2)} (${bill.billId})');
    }

    print('');
    stdout.write('Select bill number to pay (or 0 to cancel): ');
    final input = stdin.readLineSync()?.trim() ?? '0';
    final selection = int.tryParse(input) ?? 0;

    if (selection < 1 || selection > unpaidBills.length) {
      print('[!] Cancelled or invalid selection.');
      return;
    }

    final bill = unpaidBills[selection - 1];

    print('\nBill Details:');
    print('  Patient: ${bill.patient.name}');
    print('  Total Amount: \$${bill.patientResponsibility.toStringAsFixed(2)}');
    print('');

    stdout.write('Enter payment amount (or press Enter for full amount): \$');
    final paymentInput = stdin.readLineSync()?.trim() ?? '';
    final paymentAmount = paymentInput.isEmpty
        ? bill.patientResponsibility
        : double.tryParse(paymentInput) ?? 0.0;

    if (paymentAmount <= 0) {
      print('[!] Invalid payment amount.');
      return;
    }

    if (paymentAmount >= bill.patientResponsibility) {
      bill.markAsPaid();
      print('\n✓ PAYMENT SUCCESSFUL');
      print('  Bill ${bill.billId} has been marked as PAID');
      print('  Amount paid: \$${paymentAmount.toStringAsFixed(2)}');
      if (paymentAmount > bill.patientResponsibility) {
        final change = paymentAmount - bill.patientResponsibility;
        print('  Change due: \$${change.toStringAsFixed(2)}');
      }

      await _saveBills();
    } else {
      print(
          '\n[!] Partial payment of \$${paymentAmount.toStringAsFixed(2)} received.');
      print(
          '  Remaining balance: \$${(bill.patientResponsibility - paymentAmount).toStringAsFixed(2)}');
      print('  Note: Bill status unchanged (partial payment not implemented)');
    }
  }

  /// Create prescription with inventory deduction
  Future<void> _createPrescription() async {
    print('═══════════════════════════════════════════════════');
    print('         CREATE PRESCRIPTION');
    print('═══════════════════════════════════════════════════\n');

    stdout.write('Enter patient ID: ');
    final patientId = stdin.readLineSync()?.trim() ?? '';

    if (patientId.isEmpty) {
      print('[!] Patient ID is required.');
      return;
    }

    final patient = _patientRepository.findPatientById(patientId);
    if (patient == null) {
      print('[!] Patient not found.');
      return;
    }

    print('\nPatient: ${patient.name}');
    if (patient.allergies.isNotEmpty) {
      print('[!] ALLERGIES: ${patient.allergies.join(", ")}');
      print('⚠️  Please verify medication compatibility!\n');
    } else {
      print('No known allergies\n');
    }

    final assignment = _todayAssignments.firstWhere(
      (a) => a.patient.id == patientId,
      orElse: () => _todayAssignments.first,
    );

    if (assignment.assignedDoctor == null) {
      print('[!] No doctor assigned to this patient.');
      return;
    }

    print('Prescribing Doctor: ${assignment.assignedDoctor!.name}');
    print('');

    print('Available Medications:');
    print('───────────────────────────────────────────────────');
    final medications =
        _inventory.where((item) => item.category == 'medication').toList();

    if (medications.isEmpty) {
      print('[!] No medications available in inventory.');
      return;
    }

    for (var i = 0; i < medications.length; i++) {
      final med = medications[i];
      final stockStatus = med.needsRestocking ? '[LOW STOCK]' : '';
      print(
          '${i + 1}. ${med.name} - Stock: ${med.quantity} units $stockStatus');
      print('   Price: \$${med.unitPrice.toStringAsFixed(2)}/unit');
    }

    print('');
    stdout.write('Select medication number: ');
    final medInput = stdin.readLineSync()?.trim() ?? '0';
    final medSelection = int.tryParse(medInput) ?? 0;

    if (medSelection < 1 || medSelection > medications.length) {
      print('[!] Invalid selection.');
      return;
    }

    final selectedMed = medications[medSelection - 1];

    if (patient.hasAllergy(selectedMed.name)) {
      print('\n⚠️  WARNING: Patient is allergic to ${selectedMed.name}!');
      stdout.write('Are you sure you want to continue? (yes/no): ');
      final confirm = stdin.readLineSync()?.trim().toLowerCase() ?? 'no';
      if (confirm != 'yes') {
        print('[!] Prescription cancelled for safety.');
        return;
      }
    }

    stdout.write('\nQuantity to prescribe: ');
    final qtyInput = stdin.readLineSync()?.trim() ?? '0';
    final quantity = int.tryParse(qtyInput) ?? 0;

    if (quantity <= 0) {
      print('[!] Invalid quantity.');
      return;
    }

    if (quantity > selectedMed.quantity) {
      print('[!] Insufficient stock. Available: ${selectedMed.quantity} units');
      return;
    }

    stdout.write('Dosage instructions (e.g., "Take 1 tablet twice daily"): ');
    final dosage = stdin.readLineSync()?.trim() ?? '';

    stdout.write('Duration (e.g., "7 days"): ');
    final duration = stdin.readLineSync()?.trim() ?? '';

    selectedMed.useItem(quantity);
    await _saveInventory();

    final cost = selectedMed.unitPrice * quantity;

    final prescriptionId =
        'RX${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    print('\n✓ PRESCRIPTION CREATED');
    print('═══════════════════════════════════════════════════');
    print('Prescription ID: $prescriptionId');
    print('Patient: ${patient.name} (${patient.id})');
    print('Doctor: ${assignment.assignedDoctor!.name}');
    print('Medication: ${selectedMed.name}');
    print('Quantity: $quantity units');
    print('Dosage: $dosage');
    print('Duration: $duration');
    print('Cost: \$${cost.toStringAsFixed(2)}');
    print('\nInventory Updated:');
    print(
        '  ${selectedMed.name}: ${selectedMed.quantity + quantity} → ${selectedMed.quantity} units');

    if (selectedMed.needsRestocking) {
      print('  ⚠️  [LOW STOCK WARNING] - Restock needed!');
    }

    final existingBill = _bills.firstWhere(
      (b) => b.patient.id == patientId && b.status != BillStatus.paid,
      orElse: () {
        final newBill = Bill(
          billId: 'BILL${DateTime.now().millisecondsSinceEpoch}',
          patient: patient,
          items: [],
          insurance: null,
          status: BillStatus.issued,
          issueDate: DateTime.now(),
        );
        _bills.add(newBill);
        return newBill;
      },
    );

    existingBill.addBillableItem(BillableItem(
      description: 'Medication - ${selectedMed.name} (x$quantity)',
      cost: cost,
      serviceDate: DateTime.now(),
      serviceType: 'medication',
    ));

    await _saveBills();

    print('\n✓ Charge added to bill ${existingBill.billId}');
    print('  New bill total: \$${existingBill.totalAmount.toStringAsFixed(2)}');
  }

  /// View inventory levels
  void _viewInventoryLevels() {
    print('═══════════════════════════════════════════════════');
    print('         INVENTORY LEVELS');
    print('═══════════════════════════════════════════════════\n');

    if (_inventory.isEmpty) {
      print('[!] No inventory items found.');
      return;
    }

    print('Total items: ${_inventory.length}');

    final categories = _inventory.map((i) => i.category).toSet().toList();
    categories.sort();

    for (final category in categories) {
      final items = _inventory.where((i) => i.category == category).toList();
      print('\n${category.toUpperCase()} (${items.length} items):');
      print('───────────────────────────────────────────────────');

      for (final item in items) {
        final stockStatus = item.needsRestocking
            ? '[LOW STOCK]'
            : item.quantity > item.minStockLevel * 2
                ? '[GOOD]'
                : '[OK]';
        final expiredStatus = item.isExpired ? '[EXPIRED]' : '';

        print('${item.name} $stockStatus $expiredStatus');
        print('  Stock: ${item.quantity} units (min: ${item.minStockLevel})');
        print('  Unit Price: \$${item.unitPrice.toStringAsFixed(2)}');
        print('  Total Value: \$${item.totalValue.toStringAsFixed(2)}');
        if (item.expiryDate != null) {
          print('  Expiry: ${item.expiryDate!.toString().substring(0, 10)}');
        }
        print('  Supplier: ${item.supplier}');
        print('');
      }
    }

    final lowStock = _inventory.where((i) => i.needsRestocking).toList();
    if (lowStock.isNotEmpty) {
      print('\n⚠️  LOW STOCK ALERTS (${lowStock.length} items):');
      print('───────────────────────────────────────────────────');
      for (final item in lowStock) {
        print(
            '  - ${item.name}: ${item.quantity} units (min: ${item.minStockLevel})');
      }
    }

    final expired = _inventory.where((i) => i.isExpired).toList();
    if (expired.isNotEmpty) {
      print('\n⚠️  EXPIRED ITEMS (${expired.length}):');
      print('───────────────────────────────────────────────────');
      for (final item in expired) {
        print('  - ${item.name} (expired: ${item.expiryDate})');
      }
    }

    final totalValue =
        _inventory.fold<double>(0.0, (sum, item) => sum + item.totalValue);
    print('\nTOTAL INVENTORY VALUE: \$${totalValue.toStringAsFixed(2)}');
  }

  /// Save inventory to JSON
  Future<void> _saveInventory() async {
    try {
      final data = _inventory
          .map((item) => {
                'itemId': item.itemId,
                'name': item.name,
                'category': item.category,
                'quantity': item.quantity,
                'minStockLevel': item.minStockLevel,
                'unitPrice': item.unitPrice,
                'supplier': item.supplier,
                'expiryDate': item.expiryDate?.toIso8601String(),
              })
          .toList();

      const encoder = JsonEncoder.withIndent('    ');
      final file = File('hospital_data/inventory.json');
      await file.writeAsString(encoder.convert(data));
    } catch (e) {
      print('[!] Error saving inventory: $e');
    }
  }

  /// Save bills to JSON
  Future<void> _saveBills() async {
    try {
      final data = _bills
          .map((bill) => {
                'billId': bill.billId,
                'patientId': bill.patient.id,
                'patientName': bill.patient.name,
                'items': bill.items
                    .map((item) => {
                          'description': item.description,
                          'cost': item.cost,
                          'serviceDate': item.serviceDate.toIso8601String(),
                          'serviceType': item.serviceType,
                        })
                    .toList(),
                'totalAmount': bill.totalAmount,
                'insuranceCoverage': bill.insuranceCoverage,
                'patientResponsibility': bill.patientResponsibility,
                'status': bill.status.toString(),
                'issueDate': bill.issueDate.toIso8601String(),
                'dueDate': bill.dueDate.toIso8601String(),
                'insurance': null,
              })
          .toList();

      const encoder = JsonEncoder.withIndent('    ');
      final file = File('hospital_data/bills.json');
      await file.writeAsString(encoder.convert(data));
    } catch (e) {
      print('[!] Error saving bills: $e');
    }
  }
}
