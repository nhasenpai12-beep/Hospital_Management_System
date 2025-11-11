import 'patient.dart';
import 'staff.dart';
import 'enums.dart';
import 'room.dart';

class EmergencyCase {
  String caseId;
  Patient patient;
  TriageLevel triageLevel;
  String chiefComplaint;
  DateTime arrivalTime;
  List<Staff> assignedStaff;
  EmergencyStatus status;
  Room? assignedRoom;
  String? initialAssessment;

  EmergencyCase({
    required this.caseId,
    required this.patient,
    required this.triageLevel,
    required this.chiefComplaint,
    required this.arrivalTime,
    this.assignedStaff = const [],
    this.status = EmergencyStatus.active,
    this.assignedRoom,
    this.initialAssessment,
  });

  Duration get timeInEmergency {
    return DateTime.now().difference(arrivalTime);
  }

  bool get isUrgent {
    return triageLevel == TriageLevel.red;
  }

  void assignStaff(Staff staff) {
    if (!assignedStaff.contains(staff)) {
      assignedStaff.add(staff);
    }
  }

  void assignRoom(Room room) {
    assignedRoom = room;
    room.occupy();
  }

  void updateStatus(EmergencyStatus newStatus) {
    status = newStatus;
    if (newStatus == EmergencyStatus.discharged && assignedRoom != null) {
      assignedRoom!.vacate();
    }
  }
}

class Ward {
  String wardId;
  WardType type;
  List<Room> rooms;
  Nurse? headNurse;
  int currentOccupancy;
  int maxCapacity;

  Ward({
    required this.wardId,
    required this.type,
    required this.rooms,
    this.headNurse,
    this.currentOccupancy = 0,
    required this.maxCapacity,
  });

  double get occupancyRate {
    return (currentOccupancy / maxCapacity) * 100;
  }

  bool get hasAvailableBeds {
    return currentOccupancy < maxCapacity;
  }

  List<Room> getAvailableRooms() {
    return rooms.where((room) => room.isAvailable).toList();
  }

  void admitPatient() {
    if (hasAvailableBeds) {
      currentOccupancy++;
    }
  }

  void dischargePatient() {
    if (currentOccupancy > 0) {
      currentOccupancy--;
    }
  }
}
