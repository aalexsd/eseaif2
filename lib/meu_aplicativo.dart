import 'package:flutter/material.dart';
import 'package:projeto_agricultura_familiar/Pages/edit_profile_screen.dart';
import 'package:projeto_agricultura_familiar/Pages/inicial_page.dart';
import 'package:projeto_agricultura_familiar/Pages/lgpd_page.dart';
import 'package:projeto_agricultura_familiar/Pages/splash_screen.dart';
import 'package:projeto_agricultura_familiar/Pages/verify_email_screen.dart';
import 'package:projeto_agricultura_familiar/Wigets/auth_check.dart';
import 'Pages/forgot_password_page.dart';
import 'Pages/home_page.dart';
import 'Pages/login_page.dart';
import 'Pages/survey_page.dart';

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          color: Colors.indigo,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      title: 'Flutter Demo',
      initialRoute: '/splash',
      routes: {
        '/': (context) => const AuthCheck(),
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
        '/form': (context) => const FormPage(),
        '/inicial': (context) => const InicialPage(),
        '/lgpd': (context) => const ColetaDadosPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/edit_profile': (context) => const EditProfileScreen(),
        'verify_email': (context) => const VerifyEmailScreen()
      },
    );
  }
}
