import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../Services/auth_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmNewPasswordController;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmNewPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Informe sua senha atual';
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      // Adicione lógica para validar a senha atual com o banco de dados aqui.
      // Por exemplo:
      // if (!isValidCurrentPassword(email, value)) {
      //   return 'Senha atual incorreta';
      // }
    } else {
      return 'Usuário não autenticado';
    }

    return null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Validar as senhas antes de fazer as alterações
      final currentPassword = currentPasswordController.text;
      final error = validateCurrentPassword(currentPassword);
      if (error != null) {
        _showErrorSnackBar(error);
        return;
      }

      // Lógica para atualizar a senha no banco de dados aqui.
      // Por exemplo:
      // if (senhasCoincidem()) {
      //   atualizarSenha();
      // } else {
      //   _showErrorSnackBar('As senhas não coincidem');
      // }
    }
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite a nova senha';
    }

    return null;
  }

  String? validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirme a nova senha';
    }

    final newPassword = newPasswordController.text;
    if (newPassword != value) {
      return 'As senhas não coincidem';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                // Validar as senhas antes de fazer as alterações
                final user = FirebaseAuth.instance.currentUser!;
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                await _updatePassword(user, currentPassword, newPassword);
                context.read<AuthService>().logout();
                signOutGoogle();

                Navigator.pop(context);
              } else {
                _handleSubmit();
              }
            },
            child: const Text(
              'Salvar',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Alterar Senha',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Informe sua senha atual',
                  labelText: 'Senha Atual',
                ),
                obscureText: true,
                validator: validateCurrentPassword,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Digite a nova senha',
                  labelText: 'Nova Senha',
                ),
                obscureText: true,
                validator: validateNewPassword,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: confirmNewPasswordController,
                decoration: const InputDecoration(
                  hintText: 'Confirme a nova senha',
                  labelText: 'Confirmar Nova Senha',
                ),
                obscureText: true,
                validator: validateCurrentPassword,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePassword(
      User user, String currentPassword, String newPassword) async {
    try {
      // Autentica novamente o usuário com a senha atual antes de atualizar a senha
      final credential = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(credential);

      // Atualiza a senha
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Senha atualizada com sucesso.\n'
            'Faca Login novamente para continuar.'),
      ));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? 'Erro ao atualizar a senha.'),
      ));
    }
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
