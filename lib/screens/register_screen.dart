import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _plateController = TextEditingController();
  final _firebaseService = FirebaseService();
  
  UserType _selectedType = UserType.passenger;
  VehicleType _selectedVehicle = VehicleType.motorcycle;
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      var user = await _firebaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedType,
        vehicleType: _selectedType == UserType.driver ? _selectedVehicle : null,
        vehiclePlate: _selectedType == UserType.driver 
            ? _plateController.text.trim() 
            : null,
      );

      if (user != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrarse')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre completo'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            Text('Tipo de usuario:', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<UserType>(
                    title: Text('Pasajero'),
                    value: UserType.passenger,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<UserType>(
                    title: Text('Conductor'),
                    value: UserType.driver,
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                ),
              ],
            ),
            if (_selectedType == UserType.driver) ...[
              SizedBox(height: 16),
              Text('Tipo de vehículo:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<VehicleType>(
                      title: Text('Moto'),
                      value: VehicleType.motorcycle,
                      groupValue: _selectedVehicle,
                      onChanged: (value) {
                        setState(() => _selectedVehicle = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<VehicleType>(
                      title: Text('Trimoto'),
                      value: VehicleType.trimoto,
                      groupValue: _selectedVehicle,
                      onChanged: (value) {
                        setState(() => _selectedVehicle = value!);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _plateController,
                decoration: InputDecoration(labelText: 'Placa del vehículo'),
              ),
            ],
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: Text('Registrarse'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}