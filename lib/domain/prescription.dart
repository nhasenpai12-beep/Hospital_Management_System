import 'patient.dart';
import 'staff.dart';

class Prescription {
  String prescriptionId;
  Patient patient;
  Doctor prescribingDoctor;
  List<Medication> medications;
  DateTime issueDate;
  DateTime expiryDate;
  String instructions;
  bool isFilled;

  Prescription({
    required this.prescriptionId,
    required this.patient,
    required this.prescribingDoctor,
    required this.medications,
    required this.issueDate,
    required this.expiryDate,
    required this.instructions,
    this.isFilled = false,
  });

  bool get isValid => DateTime.now().isBefore(expiryDate);

  bool get isExpired => !isValid;

  double get totalCost {
    return medications.fold(0.0, (sum, medication) => sum + medication.cost);
  }

  void markAsFilled() {
    isFilled = true;
  }

  List<Medication> checkContraindications() {
    return medications
        .where((med) => patient.allergies.any((allergy) => med.contraindications
            .toLowerCase()
            .contains(allergy.toLowerCase())))
        .toList();
  }
}

class Medication {
  String name;
  String dosage;
  String frequency;
  Duration duration;
  String administrationRoute; // oral, injection, topical
  String contraindications;
  double cost;
  int quantity;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.administrationRoute,
    this.contraindications = '',
    required this.cost,
    required this.quantity,
  });

  int get totalDays {
    return duration.inDays;
  }

  double get totalCost {
    return cost * quantity;
  }
}
