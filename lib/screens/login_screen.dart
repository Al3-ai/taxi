import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import 'passenger_home.dart';
import 'driver_home.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      var user = await _firebaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
        var userModel = await _firebaseService.getCurrentUser();
        
        if (userModel != null) {
          if (userModel.userType == UserType.passenger) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PassengerHome()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => DriverHome()),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión')),
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
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    child: Text('Iniciar Sesión'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                );
              },
              child: Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}