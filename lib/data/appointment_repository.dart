import '../domain/appointment.dart';

// Simple in-memory repository for appointments
// In a real app, this would connect to a database
class AppointmentRepository {
  final List<Appointment> _appointments = [];

  void addAppointment(Appointment appointment) {
    // Check for scheduling conflicts before adding
    if (_hasSchedulingConflict(appointment)) {
      throw Exception(
        'Scheduling conflict detected for appointment ${appointment.id}',
      );
    }
    _appointments.add(appointment);
  }

  List<Appointment> getAllAppointments() {
    return List.from(_appointments);
  }

  List<Appointment> getAppointmentsByPatient(String patientId) {
    return _appointments.where((appt) => appt.patient.id == patientId).toList();
  }

  List<Appointment> getAppointmentsByDoctor(String doctorId) {
    return _appointments.where((appt) => appt.doctor.id == doctorId).toList();
  }

  List<Appointment> getAppointmentsByDate(DateTime date) {
    return _appointments.where((appt) {
      return appt.appointmentTime.year == date.year &&
          appt.appointmentTime.month == date.month &&
          appt.appointmentTime.day == date.day;
    }).toList();
  }

  Appointment? findAppointmentById(String id) {
    try {
      return _appointments.firstWhere((appt) => appt.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateAppointment(Appointment updatedAppointment) {
    final index = _appointments.indexWhere(
      (appt) => appt.id == updatedAppointment.id,
    );
    if (index != -1) {
      _appointments[index] = updatedAppointment;
    }
  }

  void cancelAppointment(String appointmentId, String reason) {
    final appointment = findAppointmentById(appointmentId);
    if (appointment != null) {
      appointment.cancel(reason);
    }
  }

  bool _hasSchedulingConflict(Appointment newAppointment) {
    return _appointments.any((existingAppt) {
      return newAppointment.hasConflictWith(existingAppt);
    });
  }

  List<Appointment> getUpcomingAppointments() {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));

    return _appointments.where((appt) {
      return appt.appointmentTime.isAfter(now) &&
          appt.appointmentTime.isBefore(nextWeek) &&
          appt.status == AppointmentStatus.scheduled;
    }).toList();
  }
}
