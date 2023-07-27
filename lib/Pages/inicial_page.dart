import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:projeto_agricultura_familiar/Pages/lgpd_page.dart';

class InicialPage extends StatefulWidget {
  const InicialPage({super.key});

  @override
  State<InicialPage> createState() => _InicialPageState();
}

class _InicialPageState extends State<InicialPage> {
  @override
  Widget build(BuildContext context) {
    void openSearchScreen() async {
      // Verificar se a permissão de localização está concedida
      ph.PermissionStatus permissionStatus =
          await ph.Permission.location.status;
      if (permissionStatus.isGranted) {
        // Verificar se a localização está ativada
        Location location = Location();
        bool serviceEnabled = await location.serviceEnabled();
        if (serviceEnabled) {
          // Acesso à tela de pesquisa permitido
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ColetaDadosPage()));
        } else {
          // Solicitar ativação da localização
          bool serviceRequested = await location.requestService();
          if (serviceRequested) {
            // Acesso à tela de pesquisa permitido
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ColetaDadosPage()));
          } else {
            // Exibir mensagem para o usuário ativar a localização
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Ativar Localização'),
                content: const Text(
                    'Por favor, ative a localização para acessar a pesquisa.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      } else {
        // Exibir mensagem para o usuário conceder a permissão de localização
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissão de Localização'),
            content: const Text(
                'Por favor, conceda a permissão de localização para acessar a pesquisa.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }

    final mediaquery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home),
        title: const Text('Página Inicial'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              height: mediaquery.size.height * .15,
              width: mediaquery.size.width * .9,
              child: ElevatedButton(
                onPressed: () {
                  openSearchScreen();
                  //Navigator.pushNamed(context, '/lgpd');
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.indigo[500]),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(color: Colors.indigo),
                    ),
                  ),
                ),
                child: const Text(
                  'Preencher Novo Formulário',
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
