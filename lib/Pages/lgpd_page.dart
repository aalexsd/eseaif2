import 'package:flutter/material.dart';

class ColetaDadosPage extends StatefulWidget {
  const ColetaDadosPage({super.key});

  @override
  State<ColetaDadosPage> createState() => _ColetaDadosPageState();
}

class _ColetaDadosPageState extends State<ColetaDadosPage> {
  bool _isAuthorized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autorização Coleta de Dados'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Você autoriza a coleta dos seus dados?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ao responder esta pesquisa, você autoriza expressamente a coleta, uso, armazenamento e tratamento dos seus dados pessoais, conforme estabelecido pela Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018) e demais legislações aplicáveis. Os dados pessoais fornecidos ou coletados durante o uso do aplicativo serão utilizados exclusivamente para os fins descritos em nossa política de privacidade.',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Sim'),
                leading: Radio(
                  value: true,
                  groupValue: _isAuthorized,
                  onChanged: (value) {
                    setState(() {
                      _isAuthorized = value as bool;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Não'),
                leading: Radio(
                  value: false,
                  groupValue: _isAuthorized,
                  onChanged: (value) {
                    setState(() {
                      _isAuthorized = value as bool;
                    });
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .2,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      if (_isAuthorized) {
                        Navigator.pushNamed(context, '/form');
                      } else {
                        Navigator.popAndPushNamed(context, '/home');
                        // Exibir Snackbar informando que é necessária a autorização
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'É necessário autorizar a coleta de dados para continuar a pesquisa.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
