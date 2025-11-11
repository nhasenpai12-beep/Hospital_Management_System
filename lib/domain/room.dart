// Room types in the hospital
enum RoomType { consultation, examination, emergency, operating, patientRoom }

// Room class for managing hospital rooms
class Room {
  String roomNumber;
  RoomType type;
  int capacity;
  bool isOccupied;
  List<String> equipment;

  Room({
    required this.roomNumber,
    required this.type,
    required this.capacity,
    this.isOccupied = false,
    this.equipment = const [],
  });

  bool get isAvailable {
    return !isOccupied;
  }

  void occupy() {
    if (!isOccupied) {
      isOccupied = true;
    }
  }

  void vacate() {
    isOccupied = false;
  }

  void addEquipment(String item) {
    equipment.add(item);
  }

  bool hasEquipment(String item) {
    return equipment.contains(item);
  }

  @override
  String toString() {
    return 'Room $roomNumber ($type) - ${isAvailable ? 'Available' : 'Occupied'}';
  }
}
