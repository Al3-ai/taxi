import 'package:cloud_firestore/cloud_firestore.dart';

enum RideStatus { pending, accepted, inProgress, completed, cancelled }

class RideRequest {
  final String id;
  final String passengerId;
  final String? driverId;
  final GeoPoint pickupLocation;
  final GeoPoint destinationLocation;
  final String pickupAddress;
  final String destinationAddress;
  final RideStatus status;
  final double distance;
  final Timestamp createdAt;
  final Timestamp? acceptedAt;
  final Timestamp? completedAt;

  RideRequest({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.status,
    required this.distance,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'status': status.toString().split('.').last,
      'distance': distance,
      'createdAt': createdAt,
      'acceptedAt': acceptedAt,
      'completedAt': completedAt,
    };
  }

  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      id: map['id'],
      passengerId: map['passengerId'],
      driverId: map['driverId'],
      pickupLocation: map['pickupLocation'],
      destinationLocation: map['destinationLocation'],
      pickupAddress: map['pickupAddress'],
      destinationAddress: map['destinationAddress'],
      status: RideStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      distance: map['distance'],
      createdAt: map['createdAt'],
      acceptedAt: map['acceptedAt'],
      completedAt: map['completedAt'],
    );
  }
}