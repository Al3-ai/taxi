import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/ride_request.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Autenticación
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error en signIn: $e');
      return null;
    }
  }

  Future<User?> signUp(
    String email,
    String password,
    String name,
    String phone,
    UserType userType, {
    VehicleType? vehicleType,
    String? vehiclePlate,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        userType: userType,
        vehicleType: vehicleType,
        vehiclePlate: vehiclePlate,
        createdAt: Timestamp.now(),
      );

      await _firestore.collection('users').doc(result.user!.uid).set(user.toMap());
      return result.user;
    } catch (e) {
      print('Error en signUp: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Solicitudes de viaje
  Future<String> createRideRequest({
    required String passengerId,
    required GeoPoint pickupLocation,
    required GeoPoint destinationLocation,
    required String pickupAddress,
    required String destinationAddress,
    required double distance,
  }) async {
    DocumentReference docRef = _firestore.collection('ride_requests').doc();
    
    RideRequest request = RideRequest(
      id: docRef.id,
      passengerId: passengerId,
      pickupLocation: pickupLocation,
      destinationLocation: destinationLocation,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      status: RideStatus.pending,
      distance: distance,
      createdAt: Timestamp.now(),
    );

    await docRef.set(request.toMap());
    return docRef.id;
  }

  // Obtener solicitudes pendientes cerca del conductor
  Stream<List<RideRequest>> getNearbyRideRequests(GeoPoint driverLocation) {
    return _firestore
        .collection('ride_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        RideRequest request = RideRequest.fromMap(doc.data());
        
        // Calcular distancia
        double distance = _calculateDistance(
          driverLocation.latitude,
          driverLocation.longitude,
          request.pickupLocation.latitude,
          request.pickupLocation.longitude,
        );

        // Filtrar solicitudes a menos de 200 metros
        if (distance <= 0.2) {
          return request;
        }
        return null;
      }).where((request) => request != null).cast<RideRequest>().toList();
    });
  }

  // Aceptar solicitud de viaje
  Future<void> acceptRideRequest(String requestId, String driverId) async {
    await _firestore.collection('ride_requests').doc(requestId).update({
      'driverId': driverId,
      'status': 'accepted',
      'acceptedAt': Timestamp.now(),
    });
  }

  // Actualizar token FCM
  Future<void> updateFCMToken(String uid, String token) async {
    await _firestore.collection('users').doc(uid).update({
      'fcmToken': token,
    });
  }

  // Calcular distancia entre dos puntos (en kilómetros)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Radio de la Tierra en km
    
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    
    double a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degToRad(lat1).cos() * _degToRad(lat2).cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * (3.141592653589793 / 180.0);
}

// Extensiones para cálculos matemáticos
extension _MathExtension on double {
  double sin() => _sin(this);
  double cos() => _cos(this);
  double sqrt() => _sqrt(this);
  double asin() => _asin(this);
  
  static double _sin(double x) {
    double result = 0;
    double term = x;
    for (int i = 1; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i) * (2 * i + 1));
    }
    return result;
  }
  
  static double _cos(double x) {
    double result = 0;
    double term = 1;
    for (int i = 0; i < 20; i++) {
      result += term;
      term *= -x * x / ((2 * i + 1) * (2 * i + 2));
    }
    return result;
  }
  
  static double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
  
  static double _asin(double x) {
    if (x < -1 || x > 1) return double.nan;
    if (x == 0) return 0;
    if (x == 1) return 1.5707963267948966;
    if (x == -1) return -1.5707963267948966;
    
    // Aproximación usando serie de Taylor
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= x * x * (2 * i - 1) * (2 * i - 1) / (2 * i * (2 * i + 1));
      result += term;
    }
    return result;
  }
}