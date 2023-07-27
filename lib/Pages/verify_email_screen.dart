import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_agricultura_familiar/Pages/home_page.dart';
import 'package:projeto_agricultura_familiar/Utils/utils.dart';
import 'package:projeto_agricultura_familiar/Wigets/block_button.dart';
import 'package:provider/provider.dart';

import '../Services/auth_services.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();

    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? HomePage()
      : Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Verificar E-mail'),
          ),
          body: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 80,
                ),
                const Icon(Icons.email, size: 40),
                const Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text('Por favor, verifique seu Email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22)),
                ),
                BlockButton(
                  label: isEmailVerified
                      ? 'Aguarde...'
                      : 'Enviar e-mail de verificação',
                  onPressed: () {
                    sendVerificationEmail();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'E-mail de verificação enviado.',
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<AuthService>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Colors.red,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sair do App',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

}
