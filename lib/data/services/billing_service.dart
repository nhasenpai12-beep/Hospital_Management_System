import 'dart:io';
import 'dart:convert';
import '../../domain/billing.dart';
import '../../domain/patient.dart';
import '../../domain/staff.dart';
import '../../domain/enums.dart';

/// Service to manage billing operations
class BillingService {
  final List<Bill> _bills = [];
  final String _dataDirectory = 'hospital_data';

  /// Get all bills
  List<Bill> get allBills => List.unmodifiable(_bills);

  /// Get bills for a specific patient
  List<Bill> getBillsForPatient(String patientId) {
    return _bills.where((bill) => bill.patient.id == patientId).toList();
  }

  /// Get unpaid bills
  List<Bill> getUnpaidBills() {
    return _bills.where((bill) => bill.status != BillStatus.paid).toList();
  }

  /// Get overdue bills
  List<Bill> getOverdueBills() {
    return _bills.where((bill) => bill.isOverdue).toList();
  }

  /// Create a new bill for consultation
  Bill createConsultationBill(Patient patient, Doctor doctor) {
    final billId = 'BILL${DateTime.now().millisecondsSinceEpoch}';

    final consultationItem = BillableItem(
      description: 'Medical Consultation - ${doctor.specialization}',
      cost: 50.0,
      serviceDate: DateTime.now(),
      serviceType: 'consultation',
    );

    final bill = Bill(
      billId: billId,
      patient: patient,
      items: [consultationItem],
      insurance: null,
      status: BillStatus.issued,
      issueDate: DateTime.now(),
    );

    _bills.add(bill);
    return bill;
  }

  /// Add item to existing bill
  void addItemToBill(String billId, BillableItem item) {
    final bill = _bills.firstWhere((b) => b.billId == billId);
    bill.addBillableItem(item);
  }

  /// Add emergency charges
  BillableItem createEmergencyCharge() {
    return BillableItem(
      description: 'Emergency Room Service',
      cost: 150.0,
      serviceDate: DateTime.now(),
      serviceType: 'emergency',
    );
  }

  /// Add room charges
  BillableItem createRoomCharge(String roomType, int days) {
    double costPerDay = 100.0;
    if (roomType.toLowerCase().contains('emergency')) {
      costPerDay = 200.0;
    } else if (roomType.toLowerCase().contains('ward')) {
      costPerDay = 150.0;
    }

    return BillableItem(
      description: 'Room Charges - $roomType ($days day${days > 1 ? 's' : ''})',
      cost: costPerDay * days,
      serviceDate: DateTime.now(),
      serviceType: 'room',
    );
  }

  /// Add lab test charges
  BillableItem createLabTestCharge(String testName) {
    double cost = 30.0;
    if (testName.toLowerCase().contains('xray') ||
        testName.toLowerCase().contains('x-ray')) {
      cost = 80.0;
    } else if (testName.toLowerCase().contains('mri')) {
      cost = 500.0;
    } else if (testName.toLowerCase().contains('ct')) {
      cost = 400.0;
    }

    return BillableItem(
      description: 'Lab Test - $testName',
      cost: cost,
      serviceDate: DateTime.now(),
      serviceType: 'laboratory',
    );
  }

  /// Add medication charges
  BillableItem createMedicationCharge(String medicationName, int quantity) {
    return BillableItem(
      description: 'Medication - $medicationName (x$quantity)',
      cost: 15.0 * quantity,
      serviceDate: DateTime.now(),
      serviceType: 'medication',
    );
  }

  /// Process payment for a bill
  bool processPayment(String billId, double amount, String paymentMethod) {
    try {
      final bill = _bills.firstWhere((b) => b.billId == billId);

      if (amount >= bill.patientResponsibility) {
        bill.markAsPaid();
        return true;
      } else {
        // Partial payment - could track this
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Apply insurance to bill
  void applyInsurance(String billId, Insurance insurance) {
    final bill = _bills.firstWhere((b) => b.billId == billId);
    bill.applyInsurance(insurance);
  }

  /// Get bill by ID
  Bill? getBillById(String billId) {
    try {
      return _bills.firstWhere((b) => b.billId == billId);
    } catch (e) {
      return null;
    }
  }

  /// Add bill (for loading from storage)
  void addBill(Bill bill) {
    _bills.add(bill);
  }

  /// Generate summary report
  Map<String, dynamic> generateBillingReport() {
    final totalRevenue = _bills
        .where((b) => b.status == BillStatus.paid)
        .fold(0.0, (sum, bill) => sum + bill.totalAmount);

    final pendingAmount = _bills
        .where((b) => b.status == BillStatus.issued)
        .fold(0.0, (sum, bill) => sum + bill.patientResponsibility);

    final overdueAmount = _bills
        .where((b) => b.isOverdue)
        .fold(0.0, (sum, bill) => sum + bill.patientResponsibility);

    return {
      'total_bills': _bills.length,
      'paid_bills': _bills.where((b) => b.status == BillStatus.paid).length,
      'pending_bills':
          _bills.where((b) => b.status == BillStatus.issued).length,
      'overdue_bills': _bills.where((b) => b.isOverdue).length,
      'total_revenue': totalRevenue,
      'pending_amount': pendingAmount,
      'overdue_amount': overdueAmount,
    };
  }

  /// Save bill to JSON
  Future<void> saveBill(Bill bill) async {
    final file = File('$_dataDirectory/bills.json');
    List<dynamic> bills = [];

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        bills = jsonDecode(content);
      } catch (e) {
        print('Warning: Could not read existing bills: $e');
      }
    }

    final billData = {
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
      'insurance': bill.insurance != null
          ? {
              'provider': bill.insurance!.provider,
              'policyNumber': bill.insurance!.policyNumber,
              'coveragePercentage': bill.insurance!.coveragePercentage,
            }
          : null,
    };

    // Check if bill exists and update, otherwise add
    final existingIndex = bills.indexWhere((b) => b['billId'] == bill.billId);
    if (existingIndex != -1) {
      bills[existingIndex] = billData;
    } else {
      bills.add(billData);
    }

    const encoder = JsonEncoder.withIndent('    ');
    await file.writeAsString(encoder.convert(bills));
  }

  /// Load all bills from JSON
  Future<void> loadBills(List<Patient> patients) async {
    final file = File('$_dataDirectory/bills.json');

    if (!await file.exists()) {
      return;
    }

    try {
      final content = await file.readAsString();
      final List<dynamic> billsData = jsonDecode(content);

      for (final data in billsData) {
        // Find patient
        final patient = patients.firstWhere(
          (p) => p.id == data['patientId'],
          orElse: () => patients.first, // Fallback
        );

        // Reconstruct items
        final items = (data['items'] as List).map((item) {
          return BillableItem(
            description: item['description'],
            cost: (item['cost'] as num).toDouble(),
            serviceDate: DateTime.parse(item['serviceDate']),
            serviceType: item['serviceType'],
          );
        }).toList();

        // Reconstruct insurance if exists
        Insurance? insurance;
        if (data['insurance'] != null) {
          insurance = Insurance(
            provider: data['insurance']['provider'],
            policyNumber: data['insurance']['policyNumber'],
            coveragePercentage:
                (data['insurance']['coveragePercentage'] as num).toDouble(),
            coveredServices: [],
            expiryDate: DateTime.now().add(const Duration(days: 365)),
          );
        }

        // Create bill
        final bill = Bill(
          billId: data['billId'],
          patient: patient,
          items: items,
          insurance: insurance,
          status: _parseStatus(data['status']),
          issueDate: DateTime.parse(data['issueDate']),
        );

        _bills.add(bill);
      }
    } catch (e) {
      print('Warning: Could not load bills: $e');
    }
  }

  BillStatus _parseStatus(String status) {
    if (status.contains('paid')) return BillStatus.paid;
    if (status.contains('issued')) return BillStatus.issued;
    if (status.contains('overdue')) return BillStatus.overdue;
    if (status.contains('cancelled')) return BillStatus.cancelled;
    return BillStatus.draft;
  }
}
