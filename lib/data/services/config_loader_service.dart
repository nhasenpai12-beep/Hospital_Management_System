import 'dart:io';
import 'dart:convert';
import '../../domain/staff.dart';
import '../../domain/room.dart';

/// Service to load configuration data from JSON files
class ConfigLoaderService {
  final String _configDirectory = 'hospital_data';

  /// Load doctors from JSON file
  Future<List<Doctor>> loadDoctors() async {
    final filename = '$_configDirectory/doctors.json';
    final file = File(filename);

    if (!await file.exists()) {
      print('Warning: $filename not found. No doctors loaded.');
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final doctors = <Doctor>[];
      for (final item in data) {
        final doctor = Doctor(
          id: item['id'] as String,
          name: item['name'] as String,
          email: item['email'] as String,
          phoneNumber: item['phoneNumber'] as String,
          department: item['department'] as String,
          hireDate: DateTime.parse(item['hireDate'] as String),
          salary: (item['salary'] as num).toDouble(),
          specialization: item['specialization'] as String,
        );

        // Add certifications if any
        if (item['certifications'] != null) {
          final certs =
              (item['certifications'] as List<dynamic>).cast<String>();
          for (final cert in certs) {
            doctor.addCertification(cert);
          }
        }

        doctors.add(doctor);
      }

      return doctors;
    } catch (e) {
      print('Error loading $filename: $e');
      return [];
    }
  }

  /// Load nurses from JSON file
  Future<List<Nurse>> loadNurses() async {
    final filename = '$_configDirectory/nurses.json';
    final file = File(filename);

    if (!await file.exists()) {
      print('Warning: $filename not found. No nurses loaded.');
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final nurses = <Nurse>[];
      for (final item in data) {
        final nurse = Nurse(
          id: item['id'] as String,
          name: item['name'] as String,
          email: item['email'] as String,
          phoneNumber: item['phoneNumber'] as String,
          department: item['department'] as String,
          hireDate: DateTime.parse(item['hireDate'] as String),
          salary: (item['salary'] as num).toDouble(),
          shift: item['shift'] as String,
        );

        // Set patient load if stored
        if (item['patientLoad'] != null) {
          nurse.patientLoad = item['patientLoad'] as int;
        }

        nurses.add(nurse);
      }

      return nurses;
    } catch (e) {
      print('Error loading $filename: $e');
      return [];
    }
  }

  /// Load rooms from JSON file
  Future<List<Room>> loadRooms() async {
    final filename = '$_configDirectory/rooms.json';
    final file = File(filename);

    if (!await file.exists()) {
      print('Warning: $filename not found. No rooms loaded.');
      return [];
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> data = jsonDecode(content);

      final rooms = <Room>[];
      for (final item in data) {
        final roomTypeStr = item['type'] as String;
        RoomType roomType;

        switch (roomTypeStr.toLowerCase()) {
          case 'emergency':
            roomType = RoomType.emergency;
            break;
          case 'examination':
            roomType = RoomType.examination;
            break;
          case 'patientroom':
            roomType = RoomType.patientRoom;
            break;
          default:
            roomType = RoomType.examination;
        }

        final room = Room(
          roomNumber: item['roomNumber'] as String,
          type: roomType,
          capacity: item['capacity'] as int,
        );

        rooms.add(room);
      }

      return rooms;
    } catch (e) {
      print('Error loading $filename: $e');
      return [];
    }
  }
}
