import 'patient.dart';
import 'staff.dart';

// Appointment status enum
enum AppointmentStatus { scheduled, completed, cancelled, noShow }

// Main appointment class
class Appointment {
  String id;
  Patient patient;
  Doctor doctor;
  DateTime appointmentTime;
  Duration duration;
  String reason;
  AppointmentStatus status;
  String? notes;

  Appointment({
    required this.id,
    required this.patient,
    required this.doctor,
    required this.appointmentTime,
    this.duration = const Duration(minutes: 30),
    required this.reason,
    this.status = AppointmentStatus.scheduled,
    this.notes,
  });

  bool get isPast {
    return DateTime.now().isAfter(appointmentTime.add(duration));
  }

  bool get isUpcoming {
    final now = DateTime.now();
    final fifteenMinutesFromNow = now.add(const Duration(minutes: 15));
    return appointmentTime.isAfter(now) &&
        appointmentTime.isBefore(fifteenMinutesFromNow);
  }

  void markAsCompleted(String completionNotes) {
    status = AppointmentStatus.completed;
    notes = completionNotes;
  }

  void cancel(String cancelReason) {
    status = AppointmentStatus.cancelled;
    notes = cancelReason;
  }

  DateTime get endTime {
    return appointmentTime.add(duration);
  }

  bool hasConflictWith(Appointment other) {
    if (doctor.id != other.doctor.id && patient.id != other.patient.id) {
      return false;
    }

    final thisStart = appointmentTime;
    final thisEnd = endTime;
    final otherStart = other.appointmentTime;
    final otherEnd = other.endTime;

    return thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart);
  }

  @override
  String toString() {
    return 'Appointment $id: ${patient.name} with Dr. ${doctor.name} at ${appointmentTime.toString()}';
  }
}
