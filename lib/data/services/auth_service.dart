import '../../domain/user.dart';
import '../../domain/enums.dart';

class AuthenticationService {
  final List<User> _users = [];
  User? _currentUser;

  AuthenticationService() {
    _initializeDefaultUsers();
  }

  void _initializeDefaultUsers() {
    // Add some default users for demo
    _users.addAll([
      User(
        userId: 'U001',
        username: 'admin',
        password: 'admin123',
        role: UserRole.admin,
        email: 'admin@hospital.com',
        lastLogin: DateTime.now(),
      ),
      User(
        userId: 'U002',
        username: 'doctor1',
        password: 'doc123',
        role: UserRole.doctor,
        email: 'doctor@hospital.com',
        lastLogin: DateTime.now(),
      ),
    ]);
  }

  User? login(String username, String password) {
    try {
      final user = _users.firstWhere(
          (user) => user.username == username && user.authenticate(password));
      user.updateLastLogin();
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  void logout() {
    _currentUser = null;
  }

  User? getCurrentUser() {
    return _currentUser;
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }
}
