import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:projeto_agricultura_familiar/Wigets/block_button.dart';
import 'package:provider/provider.dart';
import '../Services/auth_services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String displayName =
      FirebaseAuth.instance.currentUser?.displayName ?? '';

  void updateDisplayName(String newName) {
    setState(() {
      displayName = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    displayName = user.displayName ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 20),
              child: Text(
                'Olá, $displayName',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0, top: 20),
              child: Text(
                'Informações Pessoais',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Nome completo:',
                        style: TextStyle(fontSize: 15)),
                    trailing: Text(user.displayName ?? ''),
                    // onTap: () {
                    //   Navigator.of(context).push(MaterialPageRoute(
                    //       builder: (context) => EditProfileScreen(
                    //             updateDisplayName: updateDisplayName,
                    //             displayName: displayName,
                    //           )));
                    // },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text(
                      'E-mail:',
                      style: TextStyle(fontSize: 15),
                    ),
                    trailing: Text(user.email!),
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
            // Center(
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
            //     child: SizedBox(
            //       width: double.infinity,
            //       height: mediaquery.size.height * .07,
            //       child: ElevatedButton(
            //         onPressed: () {
            //           Navigator.of(context).push(MaterialPageRoute(
            //               builder: (context) => EditProfileScreen(
            //                   updateDisplayName: updateDisplayName,
            //                   displayName: displayName)));
            //         },
            //         style: OutlinedButton.styleFrom(
            //           backgroundColor: Colors.black,
            //         ),
            //         child: const Text('Editar Perfil'),
            //       ),
            //     ),
            //   ),
            // ),
            BlockButton(
                label: 'Editar Perfil',
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_profile');
                }),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, right: 20, left: 20),
              child: OutlinedButton(
                onPressed: () {
                  context.read<AuthService>().logout();
                  signOutGoogle();
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

  Future<void> signOutGoogle() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logout realizado com sucesso')),
    );
  }
}
