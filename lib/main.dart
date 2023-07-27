import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Services/auth_services.dart';
import 'meu_aplicativo.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Solicitar a permissão de localização
  await Permission.location.request();

  // // Verifica a permissão de localização atual
  // LocationPermission permission = await Geolocator.checkPermission();
  //
  // // Se a permissão ainda não foi concedida, solicita ao usuário
  // if (permission == LocationPermission.denied) {
  //   permission = await Geolocator.requestPermission();
  // }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MeuAplicativo(),
    ),
  );
}
