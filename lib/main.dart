import 'check_in_system.dart';

void main() async {
  final system = CheckInSystem();
  await system.initialize();
  await system.run();
}
