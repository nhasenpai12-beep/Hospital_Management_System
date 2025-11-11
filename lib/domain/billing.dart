import 'patient.dart';
import 'enums.dart';

class Bill {
  String billId;
  Patient patient;
  List<BillableItem> items;
  late double totalAmount;
  late double insuranceCoverage;
  late double patientResponsibility;
  BillStatus status;
  DateTime issueDate;
  DateTime dueDate;
  Insurance? insurance;

  Bill({
    required this.billId,
    required this.patient,
    required this.items,
    required this.insurance,
    this.status = BillStatus.draft,
    required this.issueDate,
  }) : dueDate = issueDate.add(const Duration(days: 30)) {
    calculateTotal();
  }

  void calculateTotal() {
    totalAmount = items.fold(0.0, (sum, item) => sum + item.cost);

    if (insurance != null) {
      insuranceCoverage = totalAmount * (insurance!.coveragePercentage / 100);
      patientResponsibility = totalAmount - insuranceCoverage;
    } else {
      insuranceCoverage = 0.0;
      patientResponsibility = totalAmount;
    }
  }

  void applyInsurance(Insurance insurance) {
    this.insurance = insurance;
    calculateTotal();
  }

  void addBillableItem(BillableItem item) {
    items.add(item);
    calculateTotal();
  }

  void markAsPaid() {
    status = BillStatus.paid;
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != BillStatus.paid;
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
}

class BillableItem {
  String description;
  double cost;
  DateTime serviceDate;
  String serviceType; // consultation, procedure, medication, etc.

  BillableItem({
    required this.description,
    required this.cost,
    required this.serviceDate,
    required this.serviceType,
  });
}

class Insurance {
  String provider;
  String policyNumber;
  double coveragePercentage;
  List<String> coveredServices;
  DateTime expiryDate;

  Insurance({
    required this.provider,
    required this.policyNumber,
    required this.coveragePercentage,
    required this.coveredServices,
    required this.expiryDate,
  });

  bool get isValid => DateTime.now().isBefore(expiryDate);

  bool coversService(String serviceType) {
    return coveredServices.contains(serviceType);
  }
}
