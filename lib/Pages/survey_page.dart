import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:projeto_agricultura_familiar/Models/mascaras_formatacao.dart';
import 'package:projeto_agricultura_familiar/Pages/home_page.dart';
import 'package:projeto_agricultura_familiar/Repository/atividades_produtivas_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/pessoa_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/processados_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/unidades_familiares_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/vegetais_repository.dart';

import '../Models/meses.dart';
import '../Repository/animais_repository.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final nameEntrevistadoController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final quantidadeFamilia = TextEditingController();
  final controllerLatitude = TextEditingController();
  final controllerLongitude = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final mascara = MascaraFormatacao();
  final tabelaUnidadeFamiliar = UnidadeFamiliarRepository.tabela;
  final tabelaAtividades = AtividadeRepository.tabela;
  bool _showValidationError = false;

  List<TextEditingController> areaPuraControllers = [];
  List<TextEditingController> areaConsorciadaControllers = [];
  List<TextEditingController> quantidadeColhidaControllers = [];
  List<TextEditingController> quantidadeVendidaControllers = [];
  List<TextEditingController> precoUnitarioControllers = [];
  List<TextEditingController> parcelaCosumoControllers = [];
  List<TextEditingController> quantidadePerdidadeVegetaisControllers = [];
  List<MonthData> _selectedMonthsVegetal = List.generate(
    12,
        (index) => MonthData(),
  );
  List<bool> _allMonthsSelectedVegetal = List.generate(12, (index) => false);
  List<bool> _selectedVegetaisOrganicos = List.generate(10, (index) => true);
  List<bool> _selectedVegetaisComercializados =
      List.generate(10, (index) => false);

  List<TextEditingController> areaAnimalControllers = [];
  List<TextEditingController> volumeAnimalControllers = [];
  List<TextEditingController> quantidadeAnimalCriadoControllers = [];
  List<TextEditingController> quantidadeAnimalVendidoControllers = [];
  List<TextEditingController> precoAnimalUnitarioControllers = [];
  List<TextEditingController> parcelaAnimalCosumoControllers = [];
  List<TextEditingController> quantidadePerdidadeAnimaisControllers = [];
  List<bool> _selectedAnimaisComercializados =
      List.generate(10, (index) => false);
  List<MonthData> _selectedMonthsAnimal = List.generate(
    12,
        (index) => MonthData(),
  );
  List<bool> _allMonthsSelectedAnimal = List.generate(12, (index) => false);

  List<TextEditingController> areaProcessadosVegetalControllers = [];
  List<TextEditingController> volumeProcessadosVegetalControllers = [];
  List<TextEditingController> quantidadeProduzidaProcessadosVegetalControllers =
      [];
  List<TextEditingController> quantidadeVendidaProcessadosVegetalControllers =
      [];
  List<TextEditingController> precoProcessadosVegetalUnitarioControllers = [];
  List<TextEditingController> parcelaProcessadosVegetalCosumoControllers = [];
  List<TextEditingController>
      quantidadePerdidadeProcessadosVegetaisControllers = [];

  List<bool> _selectedProcessadosVegetaisComercializados =
      List.generate(10, (index) => false);
  List<MonthData> _selectedMonthsProcessadoVegetal = List.generate(
    12,
        (index) => MonthData(),
  );
  List<bool> _allMonthsSelectedProcessadoVegetal =
      List.generate(12, (index) => false);

  List<TextEditingController> areaProcessadosAnimalControllers = [];
  List<TextEditingController> volumeProcessadosAnimalControllers = [];
  List<TextEditingController> quantidadeProduzidaProcessadosAnimalControllers =
      [];
  List<TextEditingController> quantidadeVendidaProcessadosAnimalControllers =
      [];
  List<TextEditingController> precoProcessadosAnimalUnitarioControllers = [];
  List<TextEditingController> parcelaProcessadosAnimalCosumoControllers = [];
  List<TextEditingController>
      quantidadePerdidadeProcessadosAnimaissControllers = [];
  List<bool> _selectedProcessadosAnimalComercializados =
      List.generate(10, (index) => false);
  List<MonthData> _selectedMonthsProcessadoAnimal = List.generate(
    12,
        (index) => MonthData(),
  );
  List<bool> _allMonthsSelectedProcessadoAnimal =
      List.generate(12, (index) => false);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    WidgetsFlutterBinding.ensureInitialized();
  }

  List<bool> expanded = [false, false];

  String? _selectedUnidade;
  String? _selectedProducao;
  bool usaAgrotoxico = false;
  bool _visitedInstitutions = false;
  bool _possuiSelos = false;
  bool _possuiCertificacao = false;
  bool _possuiDAP = false;
  bool _possuiCAR = false;
  bool _produziuVegetais = false;
  bool _produziuOrganicos = false;
  bool _produziuProcessadosVegetais = false;
  bool _produziuProcessadosAnimais = false;
  bool _criouAnimais = false;
  final List<String> _selectedInstitutions = [];
  final List<String> _selectedSelos = [];
  final List<String> _selectedCanais = [];
  final List<String> _selectedCertificacao = [];
  final List<String> _selectedDAP = [];
  final List<String> _selectedVegetais = [];
  final List<String> _selectedProcessadosVegetais = [];
  final List<String> _selectedProcessadosAnimais = [];
  final List<String> _selectedAnimais = [];
  int _quantidadeVegetaisProduzidos = 1;
  int _quantidadeProcessadosVegetaisProduzidos = 1;
  int _quantidadeProcessadosAnimaisProduzidos = 1;
  int _quantidadeAnimaisCriados = 1;


  saveAll() async {
    // Criar uma instância do Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Criar um documento no Firestore
    DocumentReference docRef = firestore.collection('dados').doc();

    // Crie uma variável para armazenar os valores do cônjuge
    // Map<String, dynamic> conjugeData;
    //
    // if (_selectedMaritalStatus == 'Casado(a)') {
    //   // Se for "Casado(a)", defina os valores do cônjuge
    //   conjugeData = {
    //     'nomeConjuge': nameConjugeController.text,
    //     'cpfConjuge': cpfConjugeController.text,
    //     'NISConjuge': nisConjugeController.text,
    //     'telefoneConjuge': telefoneConjugeController.text,
    //   };
    // } else {
    //   // Se for diferente de "Casado(a)", defina os valores do cônjuge como nulos
    //   conjugeData = {
    //     'nomeConjuge': null,
    //     'cpfConjuge': null,
    //     'NISConjuge': null,
    //     'telefoneConjuge': null,
    //   };
    // }

    // // Obtenha a posição atual do dispositivo
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Obtenha as coordenadas de latitude e longitude
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Crie uma lista para armazenar os itensVegetais
    List<Map<String, dynamic>> itensVegetais = [];
    for (var i = 0; i < _selectedVegetais.length; i++) {
      final areaPuraController = areaPuraControllers[i];
      final quantidadeColhidaController = quantidadeColhidaControllers[i];
      final parcelaConsumo = parcelaCosumoControllers[i];
      final parcelaPerdida = quantidadePerdidadeVegetaisControllers[i];
      final quantidadeVendidaController = quantidadeVendidaControllers[i];
      final precoUnitarioController = precoUnitarioControllers[i];

      // Converter as strings para inteiros
      final areaPuraValue = int.parse(areaPuraController.text);
      final quantidadeColhidaValue =
      int.parse(quantidadeColhidaController.text);
      final quantidadeVendidaValue =
      int.parse(quantidadeVendidaController.text);
      final precoUnitarioValue = double.parse(precoUnitarioController.text);
      final parcelaConsumoValue = int.parse(parcelaConsumo.text);
      final parcelaPerdidaValue = int.parse(parcelaPerdida.text);

      // Criar um mapa com as informações do item
      Map<String, dynamic> itemDataVegetal = {
        '01 - NomeItem': _selectedVegetais[i],
        '02 - AreaProducao': areaPuraValue,
        '03 - VolumeProduzido': quantidadeColhidaValue,
        '04 - VolumeAutoConsumo': parcelaConsumoValue,
        '05 - VolumePerdido': parcelaPerdidaValue,
        '06 - Organico': usaAgrotoxico ? 'Não' : 'Sim',
        '07 - VolumeComercializado': quantidadeVendidaValue,
        '08 - PrecoUnitario': precoUnitarioValue,
        '09 - ValorTotalVendas': quantidadeVendidaValue * precoUnitarioValue,
        '10 - MesesComercializado': _selectedMonthsVegetal[i].months,
      };

      // Adicionar o item à lista de itensVegetais
      itensVegetais.add(itemDataVegetal);
    }

    List<Map<String, dynamic>> itensProcessadosVegetais = [];
    for (var i = 0; i < _selectedProcessadosVegetais.length; i++) {
      final areaProcessadosVegetaisController = areaProcessadosVegetalControllers[i];
      final quantidadeProduzidaProcessadosVegetalController = quantidadeProduzidaProcessadosVegetalControllers[i];
      final quantidadeVendidaProcessadosVegetalController = quantidadeVendidaProcessadosVegetalControllers[i];
      final precoProcessadosVegetalUnitarioController = precoProcessadosVegetalUnitarioControllers[i];
      final parcelaProcessadosVegetalCosumoController = parcelaProcessadosVegetalCosumoControllers[i];
      final quantidadePerdidaProcessadosVegetaisController = quantidadePerdidadeProcessadosVegetaisControllers[i];

      // Converter as strings para inteiros
      final areaPuraValue = int.parse(areaProcessadosVegetaisController.text);
      final quantidadeProduzidaValue =
      int.parse(quantidadeProduzidaProcessadosVegetalController.text);
      final quantidadeVendidaValue =
      int.parse(quantidadeVendidaProcessadosVegetalController.text);
      final precoUnitarioValue = double.parse(precoProcessadosVegetalUnitarioController.text);
      final parcelaConsumoValue = int.parse(parcelaProcessadosVegetalCosumoController.text);
      final parcelaPerdidaValue = int.parse(quantidadePerdidaProcessadosVegetaisController.text);


      // Criar um mapa com as informações do item
      Map<String, dynamic> itemDataProcessadoVegetal = {
        '01 - NomeItem': _selectedProcessadosVegetais[i],
        '02 - AreaProducao': areaPuraValue,
        '03 - VolumeProduzido': quantidadeProduzidaValue,
        '04 - VolumeAutoConsumo': parcelaConsumoValue,
        '05 - VolumePerdido':parcelaPerdidaValue,
        '06 - VolumeComercializado': quantidadeVendidaValue,
        '07 - PrecoUnitario': precoUnitarioValue,
        '08 - ValorTotalVendas': quantidadeVendidaValue * precoUnitarioValue,
        '09 - MesesComercializado': _selectedMonthsProcessadoVegetal[i].months
      };

      // Adicionar o item à lista de itensVegetais
      itensProcessadosVegetais.add(itemDataProcessadoVegetal);
    }

    List<Map<String, dynamic>> itensAnimais = [];
    for (var i = 0; i < _selectedAnimais.length; i++) {
      final areaPuraController = areaAnimalControllers[i];
      final volumeProduzidoController = volumeAnimalControllers[i];
      final quantidadeVendidaController = quantidadeAnimalVendidoControllers[i];
      final precoUnitarioController = precoAnimalUnitarioControllers[i];
      final parcelaConsumo = parcelaAnimalCosumoControllers[i];
      final parcelaPerdida = quantidadePerdidadeAnimaisControllers[i];

      // Converter as strings para inteiros
      final areaPuraValue = int.parse(areaPuraController.text);
      final volumeProduzidoValue =
      int.parse(volumeProduzidoController.text);
      final quantidadeVendidaValue =
      int.parse(quantidadeVendidaController.text);
      final precoUnitarioValue = double.parse(precoUnitarioController.text);
      final parcelaConsumoValue = int.parse(parcelaConsumo.text);
      final parcelaPerdidaValue = int.parse(parcelaPerdida.text);


      // Criar um mapa com as informações do item
      Map<String, dynamic> itemDataAnimal = {
        '01 - NomeItem': _selectedAnimais[i],
        '02 - AreaProducao': areaPuraValue,
        '03 - VolumeProduzido': volumeProduzidoValue,
        '04 - VolumeAutoConsumo': parcelaConsumoValue,
        '05 - VolumePerdido': parcelaPerdidaValue,
        '06 - Volumevendido': quantidadeVendidaValue,
        '07 - PrecoUnitario': precoUnitarioValue,
        '08 - ValorTotalVendas': quantidadeVendidaValue * precoUnitarioValue,
        '09 - MesesComercializado': _selectedMonthsAnimal[i].months
      };

      // Adicionar o item à lista de itensVegetais
      itensAnimais.add(itemDataAnimal);
    }

    List<Map<String, dynamic>> itensProcessadosAnimais = [];
    for (var i = 0; i < _selectedProcessadosAnimais.length; i++) {
      final areaPuraController = areaProcessadosAnimalControllers[i];
      final volumeProduzidoController = quantidadeProduzidaProcessadosAnimalControllers[i];
      final quantidadeVendidaController = quantidadeVendidaProcessadosAnimalControllers[i];
      final precoUnitarioController = precoProcessadosAnimalUnitarioControllers[i];
      final parcelaConsumo = parcelaProcessadosAnimalCosumoControllers[i];
      final parcelaPerdida = quantidadePerdidadeProcessadosAnimaissControllers[i];

      // Converter as strings para inteiros
      final areaPuraValue = int.parse(areaPuraController.text);
      final quantidadeColhidaValue =
      int.parse(volumeProduzidoController.text);
      final quantidadeVendidaValue =
      int.parse(quantidadeVendidaController.text);
      final precoUnitarioValue = double.parse(precoUnitarioController.text);
      final parcelaConsumoValue = int.parse(parcelaConsumo.text);
      final parcelaPeriddaValue = int.parse(parcelaPerdida.text);


      // Criar um mapa com as informações do item
      Map<String, dynamic> itemDataProcessadoAnimal = {
        '01 - NomeItem': _selectedProcessadosAnimais[i],
        '02 - AreaProducao': areaPuraValue,
        '03 - VolumeProduzido': quantidadeColhidaValue,
        '04 - VolumeAutoConsumo': parcelaConsumoValue,
        '05 - VolumePerdido': parcelaPeriddaValue,
        '06 - QuantidadeVendida': quantidadeVendidaValue,
        '07 - PrecoUnitario': precoUnitarioValue,
        '08 - ValorTotalVendas': quantidadeVendidaValue * precoUnitarioValue,
        '09 - MesesComercializado': _selectedMonthsProcessadoAnimal[i].months
      };

      // Adicionar o item à lista de itensVegetais
      itensProcessadosAnimais.add(itemDataProcessadoAnimal);
    }

    late DateTime selectedDate = DateTime.now();
    // Obter a data atual com hora zero
    DateTime dateWithoutTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Formatar a data
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateWithoutTime);
    // Formatar a hora
    String formattedTime = DateFormat('HH:mm').format(selectedDate);

    // Definir os dados a serem salvos
    Map<String, dynamic> data = {
      '01 - DataEntrevista': formattedDate,
      '02 - HoraEntrevista': formattedTime,
      '03 - location': 'Lat: $latitude | Long: $longitude',
      '04 - Entrevistador': user.email,
      '05 - NomeEntrevistado': nameEntrevistadoController.text,
      '06 - CPFentrevistado': cpfController.text,
      '07 - TelefoneEntrevistado': telefoneController.text,
      '08 - QntPessoasFamilia': quantidadeFamilia.text,
      '09 - InstituicoesVisita': _visitedInstitutions? _selectedInstitutions : 'Não recebeu visitas',
      '10 - PossuiDAP/CAF': _possuiDAP ? _selectedDAP : 'Não possui DAP',
      '11 - PossuiCAR': _possuiCAR ? 'Sim' : 'Não',
      '12 - SelosPropriedade': _possuiSelos ? _selectedSelos : 'Não possui Selos',
      '13 - CategoriaFamilia': _selectedUnidade,
      '14 - TipoProducao': _selectedProducao,
      '15 - CNPO': _possuiCertificacao ? _selectedCertificacao : 'Não possui Certificação',
      '16 - ItensVegetais': _produziuVegetais ? itensVegetais : 'Não produziu Vegetais',
      '17 - ItensProcessadosVegetais': _produziuProcessadosVegetais ? itensProcessadosVegetais : 'Não produziu processados vegetal',
      '18 - ItensAnimais': _criouAnimais ? itensAnimais : 'Não criou animais',
      '19 - ItensProcessadosAnimais': _produziuProcessadosAnimais ? itensProcessadosAnimais : 'Não produziu processados animal',
      '20 - CanaisComercializacao': _selectedCanais,
      // Adicione outros campos aqui com os respectivos valores
    };

    // Salvar os dados no Firestore
    try {
      await docRef.set(data);
      //print('Dados salvos com sucesso!');
    } catch (e) {
      //print('Erro ao salvar os dados: $e');
    }
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'jan';
      case 2:
        return 'fev';
      case 3:
        return 'mar';
      case 4:
        return 'abr';
      case 5:
        return 'mai';
      case 6:
        return 'jun';
      case 7:
        return 'jul';
      case 8:
        return 'ago';
      case 9:
        return 'set';
      case 10:
        return 'out';
      case 11:
        return 'nov';
      case 12:
        return 'dez';
      default:
        return '';
    }
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Define a expressão regular para validar o formato do número de telefone
    const pattern = r'^\(\d{2}\)\d{5}-\d{4}$';

    // Cria uma instância de RegExp com a expressão regular
    final regExp = RegExp(pattern);

    // Verifica se o número de telefone corresponde ao padrão
    return regExp.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (context, _) => [
            const SliverAppBar(
              title: Text('Formulário'),
              snap: true,
              floating: true,
            )
          ],
          body: SingleChildScrollView(
            child: Container(
              color: Colors.grey[200],
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(
                            width: double.infinity,
                            child: Text(
                              '1- Dados da família',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            )),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Entrevistado',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            controller: nameEntrevistadoController,
                            validator: (value) => value != null && value.isEmpty
                                ? 'Digite o Nome do Entrevistado'
                                : null,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.5, color: Colors.red),
                              ),
                              hintText: 'Nome do Entrevistado',
                              labelText: 'Nome do Entrevistado',
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'CPF do entrevistado',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            controller: cpfController,
                            inputFormatters: [MascaraFormatacao.formatadorCPF],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Informe o CPF';
                              } else if (!CPFValidator.isValid(value)) {
                                return 'CPF inválido';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.5, color: Colors.red),
                              ),
                              hintText: 'CPF',
                              labelText: 'CPF',
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Telefone do entrevistado',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            controller: telefoneController,
                            inputFormatters: [
                              MascaraFormatacao.formatadorTelefone
                            ],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Informe o número de telefone';
                              } else if (!_isValidPhoneNumber(value)) {
                                return 'Número de telefone inválido';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.5, color: Colors.red),
                              ),
                              hintText: 'Telefone do entrevistado',
                              labelText: 'Telefone do entrevistado',
                            ),
                          ),
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Quantas pessoas da família \nvivem na Unidade Familiar?',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: TextFormField(
                            controller: quantidadeFamilia,
                            inputFormatters: [],
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Informe a quantidade';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.8, color: Colors.white),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                    width: 0.5, color: Colors.red),
                              ),
                              hintText: 'Quantidade de pessoas',
                              labelText: 'Quantidade de pessoas',
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'A unidade familiar recebeu a visita de alguma instituição prestadora de assistência, exceto a prefeitura, no último ano?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _visitedInstitutions,
                              onChanged: (value) {
                                setState(() {
                                  _visitedInstitutions = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _visitedInstitutions,
                              onChanged: (value) {
                                setState(() {
                                  _visitedInstitutions = value!;
                                  _selectedInstitutions.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_visitedInstitutions)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.tabela
                                .map<Widget>((institution) {
                              return CheckboxListTile(
                                title: Text(institution.nome),
                                value: _selectedInstitutions
                                    .contains(institution.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedInstitutions
                                          .add(institution.nome);
                                    } else {
                                      _selectedInstitutions
                                          .remove(institution.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        /////////////////////////
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(
                            width: double.infinity,
                            child: Text(
                              '2- Unidade Familiar de Produção Agrária (UFPA)',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            )),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Possui Declaração de Aptidão ao \n'
                                'PRONAF (DAP) e/ou Cadastro Nacional \n'
                                'da Agricultura Familiar (CAF)?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _possuiDAP,
                              onChanged: (value) {
                                setState(() {
                                  _possuiDAP = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _possuiDAP,
                              onChanged: (value) {
                                setState(() {
                                  _possuiDAP = value!;
                                  _selectedDAP.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_possuiDAP)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.dap
                                .map<Widget>((dap) {
                              return CheckboxListTile(
                                title: Text(dap.nome),
                                value: _selectedDAP.contains(dap.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedDAP.add(dap.nome);
                                    } else {
                                      _selectedDAP.remove(dap.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Possui Cadastro Ambiental Rural (CAR)?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _possuiCAR,
                              onChanged: (value) {
                                setState(() {
                                  _possuiCAR = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _possuiCAR,
                              onChanged: (value) {
                                setState(() {
                                  _possuiCAR = value!;
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Possui selos da propriedade?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _possuiSelos,
                              onChanged: (value) {
                                setState(() {
                                  _possuiSelos = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _possuiSelos,
                              onChanged: (value) {
                                setState(() {
                                  _possuiSelos = value!;
                                  _selectedSelos.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_possuiSelos)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.selos
                                .map<Widget>((selos) {
                              return CheckboxListTile(
                                title: Text(selos.nome),
                                value: _selectedSelos.contains(selos.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedSelos.add(selos.nome);
                                    } else {
                                      _selectedSelos.remove(selos.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Qual a categoria fundiária da unidade familiar?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.dialog(
                                fit: FlexFit.tight,
                                showSelectedItems: true,
                                showSearchBox: true,
                                scrollbarProps: ScrollbarProps()),
                            items: PessoaRepository.identificacaoComunidade,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.8, color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.8, color: Colors.white),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.5, color: Colors.red),
                                ),
                                hintText: 'Unidade familiar',
                                labelText: 'Unidade familiar',
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecione a unidade';
                              }
                              return null; // Retorna null se o campo estiver preenchido corretamente
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedUnidade = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(
                            width: double.infinity,
                            child: Text(
                              '3- Produção e Comercialização',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            )),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'Quanto ao tipo de produção geral da unidade familiar, marque a opção que se aplica:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: DropdownSearch<String>(
                            popupProps: PopupProps.dialog(
                                fit: FlexFit.tight,
                                showSelectedItems: true,
                                showSearchBox: true,
                                scrollbarProps: ScrollbarProps()),
                            items: PessoaRepository.producaoGeral,
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.8, color: Colors.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.8, color: Colors.white),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                      width: 0.5, color: Colors.red),
                                ),
                                hintText: 'Tipo de Produção',
                                labelText: 'Tipo de Produção',
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Selecione o tipo de produção';
                              }
                              return null; // Retorna null se o campo estiver preenchido corretamente
                            },
                            onChanged: (value) {
                              setState(() {
                                _selectedProducao = value;
                              });
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A unidade familiar está no Cadastro Nacional \nde Produtores Orgânicos?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _possuiCertificacao,
                              onChanged: (value) {
                                setState(() {
                                  _possuiCertificacao = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _possuiCertificacao,
                              onChanged: (value) {
                                setState(() {
                                  _possuiCertificacao = value!;
                                  _selectedCertificacao.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_possuiCertificacao)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.prodOrganica
                                .map<Widget>((selos) {
                              return CheckboxListTile(
                                title: Text(selos.nome),
                                value:
                                    _selectedCertificacao.contains(selos.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedCertificacao.add(selos.nome);
                                    } else {
                                      _selectedCertificacao.remove(selos.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A unidade familiar produziu vegetais?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _produziuVegetais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuVegetais = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _produziuVegetais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuVegetais = value!;
                                  _selectedVegetais.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_produziuVegetais)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantidade de itens produzidos:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: DropdownButton<int>(
                                  elevation: 0,
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  value: _quantidadeVegetaisProduzidos,
                                  onChanged: (value) {
                                    setState(() {
                                      _quantidadeVegetaisProduzidos = value!;
                                      _selectedVegetais.clear();
                                    });
                                  },
                                  items: List.generate(10, (index) {
                                    final quantidade = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: quantidade,
                                      child: Text('$quantidade'),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        if (_produziuVegetais &&
                            _quantidadeVegetaisProduzidos > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.all(20.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Selecionar vegetais:',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Column(
                                children: List.generate(
                                    _quantidadeVegetaisProduzidos, (index) {
                                  final selectedVegetal =
                                      _selectedVegetais.length > index
                                          ? _selectedVegetais[index]
                                          : null;
                                  final areaController =
                                      areaPuraControllers.length > index
                                          ? areaPuraControllers[index]
                                          : null;
                                  final quantidadeColhidaController =
                                      quantidadeColhidaControllers.length >
                                              index
                                          ? quantidadeColhidaControllers[index]
                                          : null;
                                  final quantidadeVendidaController =
                                      quantidadeVendidaControllers.length >
                                              index
                                          ? quantidadeVendidaControllers[index]
                                          : null;
                                  final precoUnitarioController =
                                      precoUnitarioControllers.length > index
                                          ? precoUnitarioControllers[index]
                                          : null;
                                  final parcelaConsumoController =
                                      parcelaCosumoControllers.length > index
                                          ? parcelaCosumoControllers[index]
                                          : null;
                                  final quantidadePerdidaVegetalController =
                                      quantidadePerdidadeVegetaisControllers
                                                  .length >
                                              index
                                          ? quantidadePerdidadeVegetaisControllers[
                                              index]
                                          : null;
                                  // Novo estado para armazenar se o vegetal é orgânico ou não
                                  return Column(
                                    children: [
                                      ExpansionTile(
                                          title: Text(
                                            'Selecionar vegetais',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: DropdownSearch<String>(
                                                popupProps: PopupProps.dialog(
                                                    fit: FlexFit.tight,
                                                    showSelectedItems: true,
                                                    showSearchBox: true,
                                                    scrollbarProps:
                                                        ScrollbarProps()),
                                                items: VegetaisRepository
                                                    .listVegetais,
                                                dropdownDecoratorProps:
                                                    DropDownDecoratorProps(
                                                  dropdownSearchDecoration:
                                                      InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 0.8,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 0.8,
                                                              color:
                                                                  Colors.white),
                                                    ),
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                      borderSide:
                                                          const BorderSide(
                                                              width: 0.5,
                                                              color:
                                                                  Colors.red),
                                                    ),
                                                    hintText:
                                                        'Selecione o Vegetal',
                                                    labelText:
                                                        'Selecione o Vegetal',
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Selecione o Vegetal';
                                                  }
                                                  return null; // Retorna null se o campo estiver preenchido corretamente
                                                },
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (value != null &&
                                                        !_selectedVegetais
                                                            .contains(value)) {
                                                      _selectedVegetais
                                                          .add(value);
                                                      areaPuraControllers.add(
                                                          TextEditingController());
                                                      areaConsorciadaControllers
                                                          .add(
                                                              TextEditingController());
                                                      quantidadeColhidaControllers
                                                          .add(
                                                              TextEditingController());
                                                      quantidadeVendidaControllers
                                                          .add(
                                                              TextEditingController());
                                                      precoUnitarioControllers.add(
                                                          TextEditingController());
                                                      parcelaCosumoControllers.add(
                                                          TextEditingController());
                                                      quantidadePerdidadeVegetaisControllers
                                                          .add(
                                                              TextEditingController());
                                                    } else {
                                                      int index =
                                                          _selectedVegetais
                                                              .indexOf(value!);
                                                      if (index != -1) {
                                                        _selectedVegetais
                                                            .removeAt(index);
                                                        areaPuraControllers
                                                            .removeAt(index);
                                                        areaConsorciadaControllers
                                                            .removeAt(index);
                                                        quantidadeColhidaControllers
                                                            .removeAt(index);
                                                        quantidadeVendidaControllers
                                                            .removeAt(index);
                                                        precoUnitarioControllers
                                                            .removeAt(index);
                                                        parcelaCosumoControllers
                                                            .removeAt(index);
                                                        quantidadePerdidadeVegetaisControllers
                                                            .removeAt(index);
                                                      }
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            if (selectedVegetal != null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 10,
                                                          bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Total de área destinada à produção - (Hectares)',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          areaController,
                                                      validator: (value) =>
                                                          value != null &&
                                                                  value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        labelText:
                                                            'Área destinada à produção',
                                                        suffixText: 'hectares',
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 20,
                                                          bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Volume produzido '
                                                            '\n(Utilize a unidade do item)',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      validator: (value) =>
                                                          value != null &&
                                                                  value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          quantidadeColhidaController,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        labelText:
                                                            'Volume produzido',
                                                        suffixText: 'quilos',
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 20,
                                                          bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Qual volume foi autoconsumido, '
                                                            '\ndoado ou trocado?',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      validator: (value) =>
                                                          value != null &&
                                                                  value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          parcelaConsumoController,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        labelText:
                                                            'Qual volume foi autoconsumido,doado ou trocado?',
                                                        suffixText: 'quilos',
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0,
                                                          top: 20,
                                                          bottom: 10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Quanto da produção foi perdida?',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    TextFormField(
                                                      validator: (value) =>
                                                          value != null &&
                                                                  value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      controller:
                                                          quantidadePerdidaVegetalController,
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        errorBorder:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                        ),
                                                        labelText:
                                                            'Quanto foi perdido?',
                                                        suffixText: 'quilos',
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Esse item, \nfoi produzido de forma ORGÂNICA?',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              _selectedVegetaisOrganicos[
                                                                  index],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedVegetaisOrganicos[
                                                                      index] =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        const Text('Sim'),
                                                        Radio<bool>(
                                                          value: false,
                                                          groupValue:
                                                              _selectedVegetaisOrganicos[
                                                                  index],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedVegetaisOrganicos[
                                                                      index] =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        const Text('Não'),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _selectedVegetaisOrganicos[
                                                                  index] ==
                                                              false,
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(
                                                            10.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Utiliza agrotóxicos/químico?',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _selectedVegetaisOrganicos[
                                                                  index] ==
                                                              false,
                                                      child: Row(
                                                        children: [
                                                          Radio<bool>(
                                                            value: true,
                                                            groupValue:
                                                                usaAgrotoxico,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                usaAgrotoxico =
                                                                    value!;
                                                              });
                                                            },
                                                          ),
                                                          const Text('Sim'),
                                                          Radio<bool>(
                                                            value: false,
                                                            groupValue:
                                                                usaAgrotoxico,
                                                            onChanged: (value) {
                                                              setState(() {
                                                                usaAgrotoxico =
                                                                    value!;
                                                              });
                                                            },
                                                          ),
                                                          const Text('Não'),
                                                        ],
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Esse item foi comercializado??',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Radio<bool>(
                                                          value: true,
                                                          groupValue:
                                                              _selectedVegetaisComercializados[
                                                                  index],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedVegetaisComercializados[
                                                                      index] =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        const Text('Sim'),
                                                        Radio<bool>(
                                                          value: false,
                                                          groupValue:
                                                              _selectedVegetaisComercializados[
                                                                  index],
                                                          onChanged: (value) {
                                                            setState(() {
                                                              _selectedVegetaisComercializados[
                                                                      index] =
                                                                  value!;
                                                            });
                                                          },
                                                        ),
                                                        const Text('Não'),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          _selectedVegetaisComercializados[
                                                                  index] ==
                                                              true,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10.0,
                                                                    top: 20,
                                                                    bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Volume comercializado'
                                                                  '\n(Utilize a unidade do item)',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Preencha o Campo';
                                                              }

                                                              int?
                                                                  quantidadeColhida =
                                                                  int.tryParse(
                                                                      quantidadeColhidaController!
                                                                          .text);
                                                              int?
                                                                  quantidadeVendida =
                                                                  int.tryParse(
                                                                      value);

                                                              if (quantidadeVendida! >
                                                                  quantidadeColhida!) {
                                                                return 'A quantidade vendida não pode ser maior\n que a quantidade colhida';
                                                              }

                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                quantidadeVendidaController,
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide: const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide: const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        width:
                                                                            0.5,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Volume comercializado',
                                                              suffixText:
                                                                  'quilos',
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10.0,
                                                                    top: 20,
                                                                    bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Preço Unitário',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            validator: (value) =>
                                                                value != null &&
                                                                        value
                                                                            .isEmpty
                                                                    ? 'Preencha o Campo'
                                                                    : null,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            controller:
                                                                precoUnitarioController,
                                                            decoration:
                                                                InputDecoration(
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide: const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide: const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                borderSide:
                                                                    const BorderSide(
                                                                        width:
                                                                            0.5,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Preço unitário (R\$)',
                                                              suffixText:
                                                                  'reais',
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10.0,
                                                                    top: 20,
                                                                    bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  'Em quais meses do ano o produto \nestá disponível para comercialização?',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          ExpansionTile(
                                                            title: Text(
                                                              'Meses de Comercialização',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                            ),
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: _allMonthsSelectedVegetal[index],
                                                                        onChanged: (value) {
                                                                          setState(
                                                                                () {
                                                                              _allMonthsSelectedVegetal[index] = value!;
                                                                              final allSelected = _allMonthsSelectedVegetal[index];
                                                                              _selectedMonthsVegetal[index].months.forEach((month, _) {
                                                                                _selectedMonthsVegetal[index].months[month] = allSelected;
                                                                              });
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                      Text('Todos os Meses'),
                                                                    ],
                                                                  ),
                                                                  for (final month in _selectedMonthsVegetal[index].months.keys)
                                                                    Row(
                                                                      children: [
                                                                        Checkbox(
                                                                          value: _selectedMonthsVegetal[index].months[month],
                                                                          onChanged: (value) {
                                                                            setState(
                                                                                  () {
                                                                                _selectedMonthsVegetal[index].months[month] = value!;
                                                                                if (value && _allMonthsSelectedVegetal[index]) {
                                                                                  _allMonthsSelectedVegetal[index] = false;
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                        Text(month),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Visibility(
                                                              visible:
                                                                  _selectedVegetaisComercializados[
                                                                          index] ==
                                                                      true,
                                                              child: Divider(
                                                                thickness: 1,
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ]),
                                      Divider(
                                        thickness: 1,
                                      )
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A unidade familiar produziu \nprocessados/beneficiados de origem vegetal?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _produziuProcessadosVegetais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuProcessadosVegetais = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _produziuProcessadosVegetais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuProcessadosVegetais = value!;
                                  _selectedProcessadosVegetais.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_produziuProcessadosVegetais)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantidade de itens produzidos:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: DropdownButton<int>(
                                  elevation: 3,
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  value:
                                      _quantidadeProcessadosVegetaisProduzidos,
                                  onChanged: (value) {
                                    setState(() {
                                      _quantidadeProcessadosVegetaisProduzidos =
                                          value!;
                                      _selectedProcessadosVegetais.clear();
                                    });
                                  },
                                  items: List.generate(10, (index) {
                                    final quantidade = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: quantidade,
                                      child: Text('$quantidade'),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        if (_produziuProcessadosVegetais &&
                            _quantidadeProcessadosVegetaisProduzidos > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.all(20.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Selecionar processados vegetais:',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Column(
                                children: List.generate(
                                    _quantidadeProcessadosVegetaisProduzidos,
                                    (index) {
                                  final selectedProcessadoVegetal =
                                      _selectedProcessadosVegetais.length >
                                              index
                                          ? _selectedProcessadosVegetais[index]
                                          : null;
                                  final areaProcessadosVegetaisController =
                                      areaProcessadosVegetalControllers.length >
                                              index
                                          ? areaProcessadosVegetalControllers[
                                              index]
                                          : null;
                                  final quantidadeProduzidaProcessadosVegetalController =
                                      quantidadeProduzidaProcessadosVegetalControllers
                                                  .length >
                                              index
                                          ? quantidadeProduzidaProcessadosVegetalControllers[
                                              index]
                                          : null;
                                  final quantidadeVendidaProcessadosVegetalController =
                                      quantidadeVendidaProcessadosVegetalControllers
                                                  .length >
                                              index
                                          ? quantidadeVendidaProcessadosVegetalControllers[
                                              index]
                                          : null;
                                  final precoProcessadosVegetalUnitarioController =
                                      precoProcessadosVegetalUnitarioControllers
                                                  .length >
                                              index
                                          ? precoProcessadosVegetalUnitarioControllers[
                                              index]
                                          : null;
                                  final parcelaProcessadosVegetalCosumoController =
                                      parcelaProcessadosVegetalCosumoControllers
                                                  .length >
                                              index
                                          ? parcelaProcessadosVegetalCosumoControllers[
                                              index]
                                          : null;
                                  final quantidadePerdidaProcessadosVegetaisController =
                                      quantidadePerdidadeProcessadosVegetaisControllers
                                                  .length >
                                              index
                                          ? quantidadePerdidadeProcessadosVegetaisControllers[
                                              index]
                                          : null;
                                  return Column(
                                    children: [
                                      ExpansionTile(
                                        title: Text('Selecionar processados vegetais',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),),
                                        children: [
                                          Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: DropdownSearch<String>(
                                            popupProps: PopupProps.dialog(
                                                fit: FlexFit.tight,
                                                showSelectedItems: true,
                                                showSearchBox: true,
                                                scrollbarProps: ScrollbarProps()),
                                            items: ProcessadosRepository
                                                .listProcessadosVegetais,
                                            dropdownDecoratorProps:
                                            DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                              InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.5,
                                                      color: Colors.red),
                                                ),
                                                hintText:
                                                'Selecione o Processado Vegetal',
                                                labelText:
                                                'Selecione o Processado Vegetal',
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Selecione o Processado Vegetal';
                                              }
                                              return null; // Retorna null se o campo estiver preenchido corretamente
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                if (value != null &&
                                                    !_selectedProcessadosVegetais
                                                        .contains(value)) {
                                                  _selectedProcessadosVegetais
                                                      .add(value);
                                                  areaProcessadosVegetalControllers
                                                      .add(
                                                      TextEditingController());
                                                  quantidadeProduzidaProcessadosVegetalControllers
                                                      .add(
                                                      TextEditingController());
                                                  quantidadeVendidaProcessadosVegetalControllers
                                                      .add(
                                                      TextEditingController());
                                                  precoProcessadosVegetalUnitarioControllers
                                                      .add(
                                                      TextEditingController());
                                                  parcelaProcessadosVegetalCosumoControllers
                                                      .add(
                                                      TextEditingController());
                                                  quantidadePerdidadeProcessadosVegetaisControllers
                                                      .add(
                                                      TextEditingController());
                                                } else {
                                                  int index =
                                                  _selectedProcessadosVegetais
                                                      .indexOf(value!);
                                                  if (index != -1) {
                                                    _selectedProcessadosVegetais
                                                        .removeAt(index);
                                                    areaProcessadosVegetalControllers
                                                        .removeAt(index);
                                                    volumeProcessadosVegetalControllers
                                                        .removeAt(index);
                                                    quantidadeProduzidaProcessadosVegetalControllers
                                                        .removeAt(index);
                                                    quantidadeVendidaProcessadosVegetalControllers
                                                        .removeAt(index);
                                                    precoProcessadosVegetalUnitarioControllers
                                                        .removeAt(index);
                                                    parcelaProcessadosVegetalCosumoControllers
                                                        .removeAt(index);
                                                    quantidadePerdidadeProcessadosVegetaisControllers
                                                        .removeAt(index);
                                                  }
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                          if (selectedProcessadoVegetal != null)
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 10,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Total de área destinada à produção - (Hectares)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    areaProcessadosVegetaisController,
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Área destinada à produção',
                                                      suffixText: 'hectares',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Volume produzido '
                                                              '\n(Utilize a unidade do item)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    quantidadeProduzidaProcessadosVegetalController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText: 'Volume produzido',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Qual volume foi autoconsumido, '
                                                              '\ndoado ou trocado?',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    parcelaProcessadosVegetalCosumoController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Qual volume foi autoconsumido, doado ou trocado?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Quanto da produção foi perdida?',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    quantidadePerdidaProcessadosVegetaisController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Quanto foi perdido?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Esse item foi comercializado??',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Radio<bool>(
                                                        value: true,
                                                        groupValue:
                                                        _selectedProcessadosVegetaisComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedProcessadosVegetaisComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Sim'),
                                                      Radio<bool>(
                                                        value: false,
                                                        groupValue:
                                                        _selectedProcessadosVegetaisComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedProcessadosVegetaisComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Não'),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible:
                                                    _selectedProcessadosVegetaisComercializados[
                                                    index] ==
                                                        true,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Volume comercializado'
                                                                    '\n(Utilize a unidade do item)',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Preencha o Campo';
                                                            }

                                                            int? quantidadeColhida =
                                                            int.tryParse(
                                                                quantidadeProduzidaProcessadosVegetalController!
                                                                    .text);
                                                            int? quantidadeVendida =
                                                            int.tryParse(value);

                                                            if (quantidadeVendida! >
                                                                quantidadeColhida!) {
                                                              return 'A quantidade vendida não pode ser maior\n que a quantidade colhida';
                                                            }

                                                            return null;
                                                          },
                                                          keyboardType:
                                                          TextInputType.number,
                                                          controller:
                                                          quantidadeVendidaProcessadosVegetalController,
                                                          decoration:
                                                          InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            labelText:
                                                            'Volume comercializado',
                                                            suffixText: 'quilos',
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Preço Unitário',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          validator: (value) =>
                                                          value != null &&
                                                              value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                          keyboardType:
                                                          TextInputType.number,
                                                          controller:
                                                          precoProcessadosVegetalUnitarioController,
                                                          decoration:
                                                          InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            labelText:
                                                            'Preço unitário (R\$)',
                                                            suffixText: 'reais',
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Em quais meses do ano o produto \nestá disponível para comercialização?',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ExpansionTile(
                                                          title: Text(
                                                            'Meses de Comercialização',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                          ),
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Checkbox(
                                                                      value: _allMonthsSelectedProcessadoVegetal[index],
                                                                      onChanged: (value) {
                                                                        setState(
                                                                              () {
                                                                                _allMonthsSelectedProcessadoVegetal[index] = value!;
                                                                            final allSelected = _allMonthsSelectedProcessadoVegetal[index];
                                                                            _selectedMonthsProcessadoVegetal[index].months.forEach((month, _) {
                                                                              _selectedMonthsProcessadoVegetal[index].months[month] = allSelected;
                                                                            });
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                    Text('Todos os Meses'),
                                                                  ],
                                                                ),
                                                                for (final month in _selectedMonthsProcessadoVegetal[index].months.keys)
                                                                  Row(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: _selectedMonthsProcessadoVegetal[index].months[month],
                                                                        onChanged: (value) {
                                                                          setState(
                                                                                () {
                                                                                  _selectedMonthsProcessadoVegetal[index].months[month] = value!;
                                                                              if (value && _allMonthsSelectedProcessadoVegetal[index]) {
                                                                                _allMonthsSelectedProcessadoVegetal[index] = false;
                                                                              }
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                      Text(month),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Visibility(
                                                      visible:
                                                      _quantidadeProcessadosVegetaisProduzidos! >
                                                          1,
                                                      child: Divider(
                                                        thickness: 1,
                                                      )),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      Divider(
                                          thickness: 1,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A unidade familiar criou Animais?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _criouAnimais,
                              onChanged: (value) {
                                setState(() {
                                  _criouAnimais = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _criouAnimais,
                              onChanged: (value) {
                                setState(() {
                                  _criouAnimais = value!;
                                  _selectedAnimais.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_criouAnimais)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantidade de Animais criados:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: DropdownButton<int>(
                                  elevation: 3,
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  value: _quantidadeAnimaisCriados,
                                  onChanged: (value) {
                                    setState(() {
                                      _quantidadeAnimaisCriados = value!;
                                      _selectedAnimais.clear();
                                    });
                                  },
                                  items: List.generate(10, (index) {
                                    final quantidade = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: quantidade,
                                      child: Text('$quantidade'),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        if (_criouAnimais && _quantidadeAnimaisCriados > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.all(20.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Selecionar Animais:',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Column(
                                children: List.generate(
                                    _quantidadeAnimaisCriados, (index) {
                                  final selectedAnimal =
                                      _selectedAnimais.length > index
                                          ? _selectedAnimais[index]
                                          : null;
                                  final areaAnimalController =
                                      areaAnimalControllers.length > index
                                          ? areaAnimalControllers[index]
                                          : null;
                                  final volumeController =
                                      volumeAnimalControllers.length > index
                                          ? volumeAnimalControllers[index]
                                          : null;
                                  final quantidadeVendidaAnimalController =
                                      quantidadeAnimalVendidoControllers
                                                  .length >
                                              index
                                          ? quantidadeAnimalVendidoControllers[
                                              index]
                                          : null;
                                  final precoUnitarioAnimalController =
                                      precoAnimalUnitarioControllers.length >
                                              index
                                          ? precoAnimalUnitarioControllers[
                                              index]
                                          : null;
                                  final parcelaAnimalConsumoController =
                                      parcelaAnimalCosumoControllers.length >
                                              index
                                          ? parcelaAnimalCosumoControllers[
                                              index]
                                          : null;
                                  final quantidadePerdidaAnimaisController =
                                      quantidadePerdidadeAnimaisControllers
                                                  .length >
                                              index
                                          ? quantidadePerdidadeAnimaisControllers[
                                              index]
                                          : null;
                                  return Column(
                                    children: [
                                      ExpansionTile(
                                        title: Text('Selecionar animais',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: DropdownSearch<String>(
                                              popupProps: PopupProps.dialog(
                                                  fit: FlexFit.tight,
                                                  showSelectedItems: true,
                                                  showSearchBox: true,
                                                  scrollbarProps: ScrollbarProps()),
                                              items: AnimaisRepository.listAnimais,
                                              dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                                dropdownSearchDecoration:
                                                InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.8,
                                                        color: Colors.white),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.8,
                                                        color: Colors.white),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.5,
                                                        color: Colors.red),
                                                  ),
                                                  hintText: 'Selecione o Animal',
                                                  labelText: 'Selecione o Animal',
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Selecione o Animal';
                                                }
                                                return null; // Retorna null se o campo estiver preenchido corretamente
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value != null &&
                                                      !_selectedAnimais
                                                          .contains(value)) {
                                                    _selectedAnimais.add(value);
                                                    areaAnimalControllers.add(
                                                        TextEditingController());
                                                    volumeAnimalControllers.add(
                                                        TextEditingController());
                                                    quantidadeAnimalVendidoControllers
                                                        .add(
                                                        TextEditingController());
                                                    precoAnimalUnitarioControllers
                                                        .add(
                                                        TextEditingController());
                                                    parcelaAnimalCosumoControllers
                                                        .add(
                                                        TextEditingController());
                                                    quantidadePerdidadeAnimaisControllers
                                                        .add(
                                                        TextEditingController());
                                                  } else {
                                                    int index = _selectedAnimais
                                                        .indexOf(value!);
                                                    if (index != -1) {
                                                      _selectedAnimais
                                                          .removeAt(index);
                                                      areaAnimalControllers
                                                          .removeAt(index);
                                                      volumeAnimalControllers
                                                          .removeAt(index);
                                                      quantidadeAnimalVendidoControllers
                                                          .removeAt(index);
                                                      precoAnimalUnitarioControllers
                                                          .removeAt(index);
                                                      parcelaAnimalCosumoControllers
                                                          .removeAt(index);
                                                      quantidadePerdidadeAnimaisControllers
                                                          .removeAt(index);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          if (selectedAnimal != null)
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 10,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Área de animais criados - Hectares',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    areaAnimalController,
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Área de animais criados',
                                                      suffixText: 'hectares',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Volume produzido\n'
                                                              '(Quilogramas)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller: volumeController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText: 'Volume produzido',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Qual volume foi autoconsumido,'
                                                              '\ndoado ou trocado?'
                                                              '\n(Quilogramas)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    parcelaAnimalConsumoController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Qual volume foi autoconsumido, doado ou trocado?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Quanto da produção foi perdida?',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    quantidadePerdidaAnimaisController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Quanto foi perdido?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Esse item foi comercializado??',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Radio<bool>(
                                                        value: true,
                                                        groupValue:
                                                        _selectedAnimaisComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedAnimaisComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Sim'),
                                                      Radio<bool>(
                                                        value: false,
                                                        groupValue:
                                                        _selectedAnimaisComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedAnimaisComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Não'),
                                                    ],
                                                  ),
                                                  Visibility(
                                                    visible:
                                                    _selectedAnimaisComercializados[
                                                    index] ==
                                                        true,
                                                    child: Column(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Volume Comercializado'
                                                                    '\n(Quilogramas)',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Preencha o Campo';
                                                            }

                                                            int? quantidadeColhida =
                                                            int.tryParse(
                                                                quantidadeVendidaAnimalController!
                                                                    .text);
                                                            int? quantidadeVendida =
                                                            int.tryParse(value);

                                                            if (quantidadeVendida! >
                                                                quantidadeColhida!) {
                                                              return 'A quantidade vendida não pode ser maior\n que a quantidade colhida';
                                                            }

                                                            return null;
                                                          },
                                                          keyboardType:
                                                          TextInputType.number,
                                                          controller:
                                                          quantidadeVendidaAnimalController,
                                                          decoration:
                                                          InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            labelText:
                                                            'Volume comercializado',
                                                            suffixText: 'quilos',
                                                          ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Preço Unitário',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 15),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TextFormField(
                                                          validator: (value) =>
                                                          value != null &&
                                                              value.isEmpty
                                                              ? 'Preencha o Campo'
                                                              : null,
                                                          keyboardType:
                                                          TextInputType.number,
                                                          controller:
                                                          precoUnitarioAnimalController,
                                                          decoration:
                                                          InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            border:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.8,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            errorBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                              borderSide:
                                                              const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            labelText:
                                                            'Preço unitário',
                                                            suffixText: 'reais',
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0,
                                                              top: 20,
                                                              bottom: 10),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              Text(
                                                                'Em quais meses do ano o produto \nestá disponível para comercialização?',
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                  fontSize: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ExpansionTile(
                                                          title: Text(
                                                            'Meses de Comercialização',
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                          ),
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Checkbox(
                                                                      value: _allMonthsSelectedAnimal[index],
                                                                      onChanged: (value) {
                                                                        setState(
                                                                              () {
                                                                                _allMonthsSelectedAnimal[index] = value!;
                                                                            final allSelected = _allMonthsSelectedAnimal[index];
                                                                            _selectedMonthsAnimal[index].months.forEach((month, _) {
                                                                              _selectedMonthsAnimal[index].months[month] = allSelected;
                                                                            });
                                                                          },
                                                                        );
                                                                      },
                                                                    ),
                                                                    Text('Todos os Meses'),
                                                                  ],
                                                                ),
                                                                for (final month in _selectedMonthsAnimal[index].months.keys)
                                                                  Row(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: _selectedMonthsAnimal[index].months[month],
                                                                        onChanged: (value) {
                                                                          setState(
                                                                                () {
                                                                                  _selectedMonthsAnimal[index].months[month] = value!;
                                                                              if (value && _allMonthsSelectedAnimal[index]) {
                                                                                _allMonthsSelectedAnimal[index] = false;
                                                                              }
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                      Text(month),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Visibility(
                                                    visible:
                                                    _quantidadeAnimaisCriados >
                                                        1,
                                                    child: const Divider(
                                                      thickness: 1,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                        ]
                                      ),
                                      Divider(
                                        thickness: 1,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A unidade familiar produziu \nprocessados/beneficiados de origem animal?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _produziuProcessadosAnimais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuProcessadosAnimais = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _produziuProcessadosAnimais,
                              onChanged: (value) {
                                setState(() {
                                  _produziuProcessadosAnimais = value!;
                                  _selectedProcessadosAnimais.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_produziuProcessadosAnimais)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantidade de itens produzidos:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: DropdownButton<int>(
                                  elevation: 3,
                                  isDense: true,
                                  dropdownColor: Colors.white,
                                  focusColor: Colors.white,
                                  value:
                                      _quantidadeProcessadosAnimaisProduzidos,
                                  onChanged: (value) {
                                    setState(() {
                                      _quantidadeProcessadosAnimaisProduzidos =
                                          value!;
                                      _selectedProcessadosAnimais.clear();
                                    });
                                  },
                                  items: List.generate(10, (index) {
                                    final quantidade = index + 1;
                                    return DropdownMenuItem<int>(
                                      value: quantidade,
                                      child: Text('$quantidade'),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        if (_produziuProcessadosAnimais &&
                            _quantidadeProcessadosAnimaisProduzidos > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // const Padding(
                              //   padding: EdgeInsets.all(20.0),
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.start,
                              //     children: [
                              //       Text(
                              //         'Selecionar processados animais:',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.bold,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Column(
                                children: List.generate(
                                    _quantidadeProcessadosAnimaisProduzidos,
                                    (index) {
                                  final selectedProcessadoAnimal =
                                      _selectedProcessadosAnimais.length > index
                                          ? _selectedProcessadosAnimais[index]
                                          : null;
                                  final areaProcessadosAnimaisController =
                                      areaProcessadosAnimalControllers.length >
                                              index
                                          ? areaProcessadosAnimalControllers[
                                              index]
                                          : null;
                                  final quantidadeProduzidaProcessadosAnimalController =
                                      quantidadeProduzidaProcessadosAnimalControllers
                                                  .length >
                                              index
                                          ? quantidadeProduzidaProcessadosAnimalControllers[
                                              index]
                                          : null;
                                  final quantidadeVendidaProcessadosAnimalController =
                                      quantidadeVendidaProcessadosAnimalControllers
                                                  .length >
                                              index
                                          ? quantidadeVendidaProcessadosAnimalControllers[
                                              index]
                                          : null;
                                  final precoProcessadosAnimalUnitarioController =
                                      precoProcessadosAnimalUnitarioControllers
                                                  .length >
                                              index
                                          ? precoProcessadosAnimalUnitarioControllers[
                                              index]
                                          : null;
                                  final parcelaProcessadosAnimalCosumoController =
                                      parcelaProcessadosAnimalCosumoControllers
                                                  .length >
                                              index
                                          ? parcelaProcessadosAnimalCosumoControllers[
                                              index]
                                          : null;
                                  final quantidadePerdidadeProcessadosAnimaissController =
                                      quantidadePerdidadeProcessadosAnimaissControllers
                                                  .length >
                                              index
                                          ? quantidadePerdidadeProcessadosAnimaissControllers[
                                              index]
                                          : null;
                                  return Column(
                                    children: [
                                      ExpansionTile(
                                        title: Text('Selecionar processados animais') ,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: DropdownSearch<String>(
                                              popupProps: PopupProps.dialog(
                                                  fit: FlexFit.tight,
                                                  showSelectedItems: true,
                                                  showSearchBox: true,
                                                  scrollbarProps: ScrollbarProps()),
                                              items: ProcessadosRepository
                                                  .listProcessadosAnimal,
                                              dropdownDecoratorProps:
                                              DropDownDecoratorProps(
                                                dropdownSearchDecoration:
                                                InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.8,
                                                        color: Colors.white),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.8,
                                                        color: Colors.white),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(30),
                                                    borderSide: const BorderSide(
                                                        width: 0.5,
                                                        color: Colors.red),
                                                  ),
                                                  hintText:
                                                  'Selecione o Processado Animal',
                                                  labelText:
                                                  'Selecione o Processado Animal',
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Selecione o Processado Animal';
                                                }
                                                return null; // Retorna null se o campo estiver preenchido corretamente
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value != null &&
                                                      !_selectedProcessadosAnimais
                                                          .contains(value)) {
                                                    _selectedProcessadosAnimais
                                                        .add(value);
                                                    areaProcessadosAnimalControllers
                                                        .add(
                                                        TextEditingController());
                                                    volumeProcessadosAnimalControllers
                                                        .add(
                                                        TextEditingController());
                                                    quantidadeProduzidaProcessadosAnimalControllers
                                                        .add(
                                                        TextEditingController());
                                                    quantidadeVendidaProcessadosAnimalControllers
                                                        .add(
                                                        TextEditingController());
                                                    precoProcessadosAnimalUnitarioControllers
                                                        .add(
                                                        TextEditingController());
                                                    parcelaProcessadosAnimalCosumoControllers
                                                        .add(
                                                        TextEditingController());
                                                    quantidadePerdidadeProcessadosAnimaissControllers
                                                        .add(
                                                        TextEditingController());
                                                  } else {
                                                    int index =
                                                    _selectedProcessadosAnimais
                                                        .indexOf(value!);
                                                    if (index != -1) {
                                                      _selectedProcessadosAnimais
                                                          .removeAt(index);
                                                      areaProcessadosAnimalControllers
                                                          .removeAt(index);
                                                      volumeProcessadosAnimalControllers
                                                          .removeAt(index);
                                                      quantidadeProduzidaProcessadosAnimalControllers
                                                          .removeAt(index);
                                                      quantidadeVendidaProcessadosAnimalControllers
                                                          .removeAt(index);
                                                      precoProcessadosAnimalUnitarioControllers
                                                          .removeAt(index);
                                                      parcelaProcessadosAnimalCosumoControllers
                                                          .removeAt(index);
                                                      quantidadePerdidadeProcessadosAnimaissControllers
                                                          .removeAt(index);
                                                    }
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          if (selectedProcessadoAnimal != null)
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 10,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Total de área destinada à produção - (Hectares)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    areaProcessadosAnimaisController,
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Área destinada à produção',
                                                      suffixText: 'hectares',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Volume produzido'
                                                              '\n(Utilize a unidade do item)',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    quantidadeProduzidaProcessadosAnimalController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText: 'Volume produzido',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Qual volume foi autoconsumido, '
                                                              '\ndoado ou trocado?',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    parcelaProcessadosAnimalCosumoController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Qual volume foi autoconsumido, doado ou trocado?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 10.0,
                                                        top: 20,
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Quanto da produção foi perdida?',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight.w500,
                                                              fontSize: 15),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  TextFormField(
                                                    validator: (value) =>
                                                    value != null &&
                                                        value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    controller:
                                                    quantidadePerdidadeProcessadosAnimaissController,
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.8,
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      errorBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                        borderSide:
                                                        const BorderSide(
                                                            width: 0.5,
                                                            color: Colors.red),
                                                      ),
                                                      labelText:
                                                      'Quanto foi perdido?',
                                                      suffixText: 'quilos',
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Esse item foi comercializado??',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Radio<bool>(
                                                        value: true,
                                                        groupValue:
                                                        _selectedProcessadosAnimalComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedProcessadosAnimalComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Sim'),
                                                      Radio<bool>(
                                                        value: false,
                                                        groupValue:
                                                        _selectedProcessadosAnimalComercializados[
                                                        index],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _selectedProcessadosAnimalComercializados[
                                                            index] = value!;
                                                          });
                                                        },
                                                      ),
                                                      const Text('Não'),
                                                    ],
                                                  ),
                                                  Visibility(
                                                      visible:
                                                      _selectedProcessadosAnimalComercializados[
                                                      index] ==
                                                          true,
                                                      child: Column(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                left: 10.0,
                                                                top: 20,
                                                                bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  'Volume comercializado'
                                                                      '\n(Utilize a unidade do item)',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                      fontSize: 15),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            validator: (value) {
                                                              if (value == null ||
                                                                  value.isEmpty) {
                                                                return 'Preencha o Campo';
                                                              }

                                                              int?
                                                              quantidadeColhida =
                                                              int.tryParse(
                                                                  quantidadeProduzidaProcessadosAnimalController!
                                                                      .text);
                                                              int?
                                                              quantidadeVendida =
                                                              int.tryParse(
                                                                  value);

                                                              if (quantidadeVendida! >
                                                                  quantidadeColhida!) {
                                                                return 'A quantidade vendida não pode ser maior\n que a quantidade colhida';
                                                              }

                                                              return null;
                                                            },
                                                            keyboardType:
                                                            TextInputType
                                                                .number,
                                                            controller:
                                                            quantidadeVendidaProcessadosAnimalController,
                                                            decoration:
                                                            InputDecoration(
                                                              filled: true,
                                                              fillColor:
                                                              Colors.white,
                                                              border:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              enabledBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              errorBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.5,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              labelText:
                                                              'Volume comercializado',
                                                              suffixText: 'quilos',
                                                            ),
                                                          ),
                                                          const Padding(
                                                            padding:
                                                            EdgeInsets.only(
                                                                left: 10.0,
                                                                top: 20,
                                                                bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  'Preço Unitário',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                      fontSize: 15),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          TextFormField(
                                                            validator: (value) =>
                                                            value != null &&
                                                                value
                                                                    .isEmpty
                                                                ? 'Preencha o Campo'
                                                                : null,
                                                            keyboardType:
                                                            TextInputType
                                                                .number,
                                                            controller:
                                                            precoProcessadosAnimalUnitarioController,
                                                            decoration:
                                                            InputDecoration(
                                                              filled: true,
                                                              fillColor:
                                                              Colors.white,
                                                              border:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              enabledBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.8,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              errorBorder:
                                                              OutlineInputBorder(
                                                                borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                    30),
                                                                borderSide:
                                                                const BorderSide(
                                                                    width: 0.5,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                              labelText:
                                                              'Preço unitário (R\$)',
                                                              suffixText: 'reais',
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10.0,
                                                                top: 20,
                                                                bottom: 10),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                  'Em quais meses do ano o produto \nestá disponível para comercialização?',
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          ExpansionTile(
                                                            title: Text(
                                                              'Meses de Comercialização',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w300),
                                                            ),
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Checkbox(
                                                                        value: _allMonthsSelectedProcessadoAnimal[index],
                                                                        onChanged: (value) {
                                                                          setState(
                                                                                () {
                                                                                  _allMonthsSelectedProcessadoAnimal[index] = value!;
                                                                              final allSelected = _allMonthsSelectedProcessadoAnimal[index];
                                                                              _selectedMonthsProcessadoAnimal[index].months.forEach((month, _) {
                                                                                _selectedMonthsProcessadoAnimal[index].months[month] = allSelected;
                                                                              });
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                      Text('Todos os Meses'),
                                                                    ],
                                                                  ),
                                                                  for (final month in _selectedMonthsProcessadoAnimal[index].months.keys)
                                                                    Row(
                                                                      children: [
                                                                        Checkbox(
                                                                          value: _selectedMonthsProcessadoAnimal[index].months[month],
                                                                          onChanged: (value) {
                                                                            setState(
                                                                                  () {
                                                                                    _selectedMonthsProcessadoAnimal[index].months[month] = value!;
                                                                                if (value && _allMonthsSelectedProcessadoAnimal[index]) {
                                                                                  _allMonthsSelectedProcessadoAnimal[index] = false;
                                                                                }
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                        Text(month),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )),
                                                  Visibility(
                                                    visible:
                                                    _quantidadeProcessadosAnimaisProduzidos >
                                                        1,
                                                    child: const Divider(
                                                      thickness: 2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ]
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        const Divider(
                          thickness: 1,
                        ),
                        const Padding(
                          padding:
                              EdgeInsets.only(left: 20.0, top: 20, bottom: 10),
                          child: SizedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Assinale todos os canais de comercialização da \n'
                                  'produção na unidade familiar.',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ExpansionTile(
                        //   title: Text(
                        //     'Canais de comercialização',
                        //     style: TextStyle(
                        //         fontWeight: FontWeight.w300, fontSize: 16),
                        //   ),
                        //   children: [
                        //     SizedBox(
                        //       width: MediaQuery.of(context).size.width,
                        //       height: MediaQuery.of(context).size.height * .5,
                        //       child: ListView.separated(
                        //         separatorBuilder: (_, __) => const Divider(
                        //           thickness: 1.0,
                        //         ),
                        //         itemCount: UnidadeFamiliarRepository
                        //             .canaisComercializacao.length,
                        //         itemBuilder: (BuildContext context, int moeda) {
                        //           return ListTile(
                        //             title: Text(
                        //               UnidadeFamiliarRepository
                        //                   .canaisComercializacao[moeda].nome,
                        //               style: TextStyle(
                        //                   fontSize: 14,
                        //                   fontWeight: FontWeight.bold),
                        //             ),
                        //             trailing: Row(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 Text("Importância:"),
                        //                 SizedBox(width: 8),
                        //                 Container(
                        //                   width: 50,
                        //                   child: TextField(
                        //                     keyboardType: TextInputType.number,
                        //                     onChanged: (value) {
                        //                       int importance =
                        //                           int.tryParse(value) ?? 0;
                        //                       setState(() {
                        //                         importances[moeda] = importance;
                        //                       });
                        //                     },
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             leading: Checkbox(
                        //               value: importances[moeda] > 0,
                        //               onChanged: (value) {
                        //                 setState(() {
                        //                   importances[moeda] = value as int;
                        //                 });
                        //               },
                        //             ),
                        //           );
                        //         },
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        ExpansionTile(
                            title: Text(
                              'Canais de comercialização',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 18),
                            ),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: UnidadeFamiliarRepository
                                    .canaisComercializacao
                                    .map<Widget>((canais) {
                                  return CheckboxListTile(
                                    title: Text(
                                      canais.nome,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    value:
                                        _selectedCanais.contains(canais.nome),
                                    onChanged: (value) {
                                      setState(() {
                                        if (value != null && value) {
                                          _selectedCanais.add(canais.nome);
                                        } else {
                                          _selectedCanais.remove(canais.nome);
                                        }
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  );
                                }).toList(),
                              ),
                            ]),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _showValidationError = true;
                          });
                          if (_formKey.currentState!.validate()) {
                            saveAll();
                            _formKey.currentState!.save();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pesquisa salva com Sucesso.'),
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Enviar Formulário'),
                      ),
                    ),
                  ),
                  if (_showValidationError)
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 20),
                      child: Text(
                        'Preencha todos os campos para enviar a pesquisa',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
