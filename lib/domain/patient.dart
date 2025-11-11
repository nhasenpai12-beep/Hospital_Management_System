import 'person.dart';

// Patient class
class Patient extends Person {
  DateTime dateOfBirth;
  String bloodType;
  List<String> allergies;
  String emergencyContact;

  Patient({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required this.dateOfBirth,
    required this.bloodType,
    List<String>? allergies,
    required this.emergencyContact,
  }) : allergies = allergies ?? [];

  @override
  String getRole() {
    return 'Patient';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  void addAllergy(String allergy) {
    if (!allergies.contains(allergy)) {
      allergies.add(allergy);
    }
  }

  bool hasAllergy(String allergy) {
    return allergies.any((a) => a.toLowerCase() == allergy.toLowerCase());
  }
}
