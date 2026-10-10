import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';

class PassengerHome extends StatefulWidget {
  @override
  _PassengerHomeState createState() => _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  final _firebaseService = FirebaseService();
  final _locationService = LocationService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    var user = await _firebaseService.getCurrentUser();
    setState(() => _currentUser = user);
  }

  Future<void> _requestRide() async {
    var position = await _locationService.getCurrentLocation();
    
    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener tu ubicación')),
      );
      return;
    }

    try {
      var rideId = await _firebaseService.createRideRequest(
        passengerId: _currentUser!.uid,
        pickupLocation: GeoPoint(position.latitude, position.longitude),
        destinationLocation: GeoPoint(position.latitude, position.longitude), // Cambiar por destino real
        pickupAddress: 'Mi ubicación actual',
        destinationAddress: 'Destino', // Cambiar por dirección real
        distance: 0.0, // Calcular distancia real
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud enviada. ID: $rideId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al solicitar viaje: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pasajero - ${_currentUser?.name ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _firebaseService.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Solicitar Viaje',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _requestRide,
              icon: Icon(Icons.directions_bike),
              label: Text('Solicitar Moto/Trimoto'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}