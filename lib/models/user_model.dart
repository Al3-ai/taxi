import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { passenger, driver }
enum VehicleType { motorcycle, trimoto }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserType userType;
  final VehicleType? vehicleType;
  final String? vehiclePlate;
  final String? fcmToken;
  final bool isActive;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.vehicleType,
    this.vehiclePlate,
    this.fcmToken,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'userType': userType.toString().split('.').last,
      'vehicleType': vehicleType?.toString().split('.').last,
      'vehiclePlate': vehiclePlate,
      'fcmToken': fcmToken,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      userType: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['userType'],
      ),
      vehicleType: map['vehicleType'] != null
          ? VehicleType.values.firstWhere(
              (e) => e.toString().split('.').last == map['vehicleType'],
            )
          : null,
      vehiclePlate: map['vehiclePlate'],
      fcmToken: map['fcmToken'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'],
    );
  }
}