import 'enums.dart';

class User {
  String userId;
  String username;
  String password; // In real app, this would be hashed
  UserRole role;
  String email;
  DateTime lastLogin;
  bool isActive;

  User({
    required this.userId,
    required this.username,
    required this.password,
    required this.role,
    required this.email,
    required this.lastLogin,
    this.isActive = true,
  });

  bool canViewMedicalRecords() {
    return role == UserRole.admin ||
        role == UserRole.doctor ||
        role == UserRole.nurse;
  }

  bool canEditBilling() {
    return role == UserRole.admin || role == UserRole.receptionist;
  }

  bool canManageInventory() {
    return role == UserRole.admin;
  }

  bool canManageStaff() {
    return role == UserRole.admin;
  }

  void updateLastLogin() {
    lastLogin = DateTime.now();
  }

  bool authenticate(String inputPassword) {
    return password == inputPassword && isActive; // Simple auth for demo
  }
}
