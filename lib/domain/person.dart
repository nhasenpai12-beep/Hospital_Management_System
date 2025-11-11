
abstract class Person {
  String id;
  String name;
  String email;
  String phoneNumber;

  Person({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  String getRole();

  @override
  String toString() {
    return 'ID: $id, Name: $name, Role: ${getRole()}';
  }
}
