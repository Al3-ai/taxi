import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Solicitar permisos de notificación
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permiso de notificaciones concedido');
    }

    // Obtener token FCM
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  void listenToMessages() {
    // Mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      
      // Aquí puedes mostrar una notificación local
    });

    // Mensajes cuando la app está en segundo plano
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación abierta: ${message.data}');
      // Aquí puedes navegar a una pantalla específica
    });
  }
}