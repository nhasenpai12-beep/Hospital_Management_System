import 'enums.dart';

class InventoryItem {
  String itemId;
  String name;
  String category; // medication, equipment, supplies
  int quantity;
  int minStockLevel;
  double unitPrice;
  DateTime? expiryDate;
  String supplier;

  InventoryItem({
    required this.itemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minStockLevel,
    required this.unitPrice,
    this.expiryDate,
    required this.supplier,
  });

  bool get needsRestocking => quantity <= minStockLevel;

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  double get totalValue => quantity * unitPrice;

  void restock(int amount) {
    quantity += amount;
  }

  void useItem(int amount) {
    if (amount <= quantity) {
      quantity -= amount;
    }
  }
}

class Equipment {
  String equipmentId;
  String name;
  String location;
  EquipmentStatus status;
  DateTime lastMaintenance;
  DateTime nextMaintenance;
  String maintenanceNotes;

  Equipment({
    required this.equipmentId,
    required this.name,
    required this.location,
    required this.status,
    required this.lastMaintenance,
    required this.nextMaintenance,
    this.maintenanceNotes = '',
  });

  bool get needsMaintenance {
    return DateTime.now().isAfter(nextMaintenance) ||
        status == EquipmentStatus.maintenance;
  }

  void performMaintenance(String notes) {
    lastMaintenance = DateTime.now();
    nextMaintenance =
        lastMaintenance.add(const Duration(days: 180)); // 6 months
    status = EquipmentStatus.operational;
    maintenanceNotes = notes;
  }

  void markAsBroken() {
    status = EquipmentStatus.broken;
  }
}
