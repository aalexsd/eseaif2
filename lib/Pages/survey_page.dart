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
import 'package:projeto_agricultura_familiar/Repository/beneficio_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/municipios_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/pessoa_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/unidades_familiares_repository.dart';
import 'package:projeto_agricultura_familiar/Repository/vegetais_repository.dart';

import '../Repository/animais_repository.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final municipioController = TextEditingController();
  final comunidadeController = TextEditingController();
  final nameEntrevistadoController = TextEditingController();
  final nameChefeFamiliaController = TextEditingController();
  final cpfController = TextEditingController();
  final nisController = TextEditingController();
  final telefoneController = TextEditingController();
  final nameConjugeController = TextEditingController();
  final cpfConjugeController = TextEditingController();
  final nisConjugeController = TextEditingController();
  final telefoneConjugeController = TextEditingController();
  final controllerLatitude = TextEditingController();
  final controllerLongitude = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final mascara = MascaraFormatacao();

  //late DateTime selectedDate = DateTime.now();
  final tabelaUnidadeFamiliar = UnidadeFamiliarRepository.tabela;
  final tabelaAtividades = AtividadeRepository.tabela;
  bool _showValidationError = false;
  List<TextEditingController> areaPuraControllers = [];
  List<TextEditingController> areaConsorciadaControllers = [];
  List<TextEditingController> quantidadeColhidaControllers = [];
  List<TextEditingController> quantidadeVendidaControllers = [];
  List<TextEditingController> precoUnitarioControllers = [];
  List<TextEditingController> parcelaPAAControllers = [];
  List<TextEditingController> parcelaMercadosLocaisControllers = [];
  List<TextEditingController> parcelaOutrosEstadosControllers = [];
  List<TextEditingController> parcelaCosumoControllers = [];
  List<TextEditingController> valorCosumoControllers = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    WidgetsFlutterBinding.ensureInitialized();
  }

  List<bool> expanded = [false, false];
  String? _selectedGender;
  String? _selectedGroup;
  String? _selectedComunity;
  String? _selectedMoradias;
  String? _selectedMaritalStatus;
  String? _selectedMunicipio;
  String? _selectedUnidade;
  String? _selectedProducao;
  bool _visitedInstitutions = false;
  bool _selos = false;
  bool _certificacao = false;
  final List<String> _selectedInstitutions = [];
  final List<String> _selectedSelos = [];
  final List<String> _selectedCertificacao = [];
  bool _possuiDAP = false;
  bool _possuiCAR = false;
  final List<String> _selectedDAP = [];
  final List<String> _selectedBeneficios = [];
  bool _listaServicosPublicos = false;
  final List<String> _selectedServicosPublicos = [];
  final List<String> _selectedActivities = [];
  bool _produziuVegetais = false;
  bool _criouAnimais = false;
  int _quantidadeVegetaisProduzidos = 1;
  int _quantidadeAnimaisCriados = 1;
  final List<String> _selectedVegetais = [];

  saveAll() async {
    // Criar uma instância do Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Criar um documento no Firestore
    DocumentReference docRef = firestore.collection('dados').doc();

    // Crie uma variável para armazenar os valores do cônjuge
    Map<String, dynamic> conjugeData;

    if (_selectedMaritalStatus == 'Casado(a)') {
      // Se for "Casado(a)", defina os valores do cônjuge
      conjugeData = {
        'nomeConjuge': nameConjugeController.text,
        'cpfConjuge': cpfConjugeController.text,
        'NISConjuge': nisConjugeController.text,
        'telefoneConjuge': telefoneConjugeController.text,
      };
    } else {
      // Se for diferente de "Casado(a)", defina os valores do cônjuge como nulos
      conjugeData = {
        'nomeConjuge': null,
        'cpfConjuge': null,
        'NISConjuge': null,
        'telefoneConjuge': null,
      };
    }

    // // Obtenha a posição atual do dispositivo
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Obtenha as coordenadas de latitude e longitude
    double latitude = position.latitude;
    double longitude = position.longitude;

    // Crie uma lista para armazenar os itens
    List<Map<String, dynamic>> itens = [];

    for (var i = 0; i < _selectedVegetais.length; i++) {
      final areaPuraController = areaPuraControllers[i];
      final areaConsorciadaController = areaConsorciadaControllers[i];
      final quantidadeColhidaController = quantidadeColhidaControllers[i];
      final quantidadeVendidaController = quantidadeVendidaControllers[i];
      final precoUnitarioController = precoUnitarioControllers[i];
      final parcelaPAA = parcelaPAAControllers[i];
      final parcelaMercadosLocais = parcelaMercadosLocaisControllers[i];
      final parcelaOutrosEstados = parcelaOutrosEstadosControllers[i];
      final parcelaConsumo = parcelaCosumoControllers[i];
      final valorConsumo = valorCosumoControllers[i];

      // Converter as strings para inteiros
      final areaPuraValue = int.parse(areaPuraController.text);
      final areaConsorciadaValue = int.parse(areaConsorciadaController.text);
      final quantidadeColhidaValue =
          int.parse(quantidadeColhidaController.text);
      final quantidadeVendidaValue =
          int.parse(quantidadeVendidaController.text);
      final precoUnitarioValue = double.parse(precoUnitarioController.text);
      final parcelaPAAValue = int.parse(parcelaPAA.text);
      final parcelaMercadosLocaisValue = int.parse(parcelaMercadosLocais.text);
      final parcelaOutrosEstadosValue = int.parse(parcelaOutrosEstados.text);
      final parcelaConsumoValue = int.parse(parcelaConsumo.text);
      final valorConsumoValue = int.parse(valorConsumo.text);

      // Criar um mapa com as informações do item
      Map<String, dynamic> itemData = {
        'NomeItem': _selectedVegetais[i],
        'AreaPura': areaPuraValue,
        'AreaConsorciada': areaConsorciadaValue,
        'QuantidadeColhida': quantidadeColhidaValue,
        'QuantidadeVendida': quantidadeVendidaValue,
        'PrecoUnitario': precoUnitarioValue,
        'ValorTotalVendas': quantidadeVendidaValue * precoUnitarioValue,
        'ParcelaPAA': parcelaPAAValue,
        'ParcelaMercadosLocais': parcelaMercadosLocaisValue,
        'ParcelaOutrosEstados': parcelaOutrosEstadosValue,
        'ParcelaConsumo': parcelaConsumoValue,
        'ValorConsumo': valorConsumoValue,
      };

      // Adicionar o item à lista de itens
      itens.add(itemData);
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
      'Entrevistador': user.email,
      'DataEntrevista': formattedDate,
      'HoraEntrevista': formattedTime,
      'GrupoAmostral': _selectedGroup,
      'Municipio': _selectedMunicipio,
      'Comunidade': comunidadeController.text,
      'IdentificacaoSociocultural': _selectedComunity,
      'CaracteristicaMoradias': _selectedMoradias,
      'AtividadesProdutivas': _selectedActivities,
      'NomeEntrevistado': nameEntrevistadoController.text,
      'NomeChefeFamilia': nameChefeFamiliaController.text,
      'CPFChefe': cpfController.text,
      'NIS/CADUnicoChefe': nisController.text,
      'TelefoneChefe': telefoneController.text,
      'GeneroChefe': _selectedGender,
      'EstadoCivilChefe': _selectedMaritalStatus,
      'conjuge': conjugeData,
      'possuiDAP': _selectedDAP,
      'unidadesFamiliares': _selectedInstitutions,
      'recebeuBeneficios': _selectedBeneficios,
      'servicosPublicos': _selectedServicosPublicos,
      'location': 'Lat: $latitude | Long: $longitude',
      'Itens': itens,
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
                                'CPF do Chefe entrevistado',
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
                                'Telefone do Chefe da Família',
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
                            controller: telefoneController,
                            inputFormatters: [
                              MascaraFormatacao.formatadorTelefone
                            ],
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
                              groupValue: _selos,
                              onChanged: (value) {
                                setState(() {
                                  _selos = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _selos,
                              onChanged: (value) {
                                setState(() {
                                  _selos = value!;
                                  _selectedSelos.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_selos)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.selos
                                .map<Widget>((selos) {
                              return CheckboxListTile(
                                title: Text(selos.nome),
                                value: _selectedSelos
                                    .contains(selos.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedSelos
                                          .add(selos.nome);
                                    } else {
                                      _selectedSelos
                                          .remove(selos.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              );
                            }).toList(),
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
                            items:
                            PessoaRepository.identificacaoComunidade,
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
                                hintText: 'Unidade familiar',
                                labelText: 'Unidade familiar',
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
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
                            items:
                            PessoaRepository.producaoGeral,
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
                                hintText: 'Tipo de Produção',
                                labelText: 'Tipo de Produção',
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty) {
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
                                'A unidade familiar possui certificação de \nprodução orgânica?',
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
                              groupValue: _certificacao,
                              onChanged: (value) {
                                setState(() {
                                  _certificacao = value!;
                                });
                              },
                            ),
                            const Text('Sim'),
                            Radio<bool>(
                              value: false,
                              groupValue: _certificacao,
                              onChanged: (value) {
                                setState(() {
                                  _certificacao = value!;
                                  _selectedCertificacao.clear();
                                });
                              },
                            ),
                            const Text('Não'),
                          ],
                        ),
                        if (_certificacao)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: UnidadeFamiliarRepository.prodOrganica
                                .map<Widget>((selos) {
                              return CheckboxListTile(
                                title: Text(selos.nome),
                                value: _selectedCertificacao
                                    .contains(selos.nome),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null && value) {
                                      _selectedCertificacao
                                          .add(selos.nome);
                                    } else {
                                      _selectedCertificacao
                                          .remove(selos.nome);
                                    }
                                  });
                                },
                                controlAffinity:
                                ListTileControlAffinity.leading,
                              );
                            }).toList(),
                          ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A sua família produziu vegetais?',
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
                                  elevation: 3,
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
                        if (_produziuVegetais && _quantidadeVegetaisProduzidos > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selecionar vegetais:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                                  final area2Controller =
                                      areaConsorciadaControllers.length > index
                                          ? areaConsorciadaControllers[index]
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
                                  final parcelaPAAController =
                                      parcelaPAAControllers.length > index
                                          ? parcelaPAAControllers[index]
                                          : null;
                                  final parcelaMercadosLocaisController =
                                      parcelaMercadosLocaisControllers.length >
                                              index
                                          ? parcelaMercadosLocaisControllers[
                                              index]
                                          : null;
                                  final parcelaOutrosEstadosController =
                                      parcelaOutrosEstadosControllers.length >
                                              index
                                          ? parcelaOutrosEstadosControllers[
                                              index]
                                          : null;
                                  final parcelaConsumoController =
                                      parcelaCosumoControllers.length > index
                                          ? parcelaCosumoControllers[index]
                                          : null;
                                  final valorConsumoController =
                                      valorCosumoControllers.length > index
                                          ? valorCosumoControllers[index]
                                          : null;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: DropdownSearch<String>(
                                          popupProps: PopupProps.dialog(
                                              fit: FlexFit.tight,
                                              showSelectedItems: true,
                                              showSearchBox: true,
                                              scrollbarProps: ScrollbarProps()),
                                          items:
                                              VegetaisRepository.listVegetais,
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
                                              hintText: 'Selecione o Vegetal',
                                              labelText: 'Selecione o Vegetal',
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
                                                _selectedVegetais.add(value);
                                                areaPuraControllers.add(
                                                    TextEditingController());
                                                areaConsorciadaControllers.add(
                                                    TextEditingController());
                                                quantidadeColhidaControllers.add(
                                                    TextEditingController());
                                                quantidadeVendidaControllers.add(
                                                    TextEditingController());
                                                precoUnitarioControllers.add(
                                                    TextEditingController());
                                                parcelaPAAControllers.add(
                                                    TextEditingController());
                                                parcelaMercadosLocaisControllers
                                                    .add(
                                                        TextEditingController());
                                                parcelaOutrosEstadosControllers
                                                    .add(
                                                        TextEditingController());
                                                parcelaCosumoControllers.add(
                                                    TextEditingController());
                                                valorCosumoControllers.add(
                                                    TextEditingController());
                                              } else {
                                                int index = _selectedVegetais
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
                                                  parcelaPAAControllers
                                                      .removeAt(index);
                                                  parcelaMercadosLocaisControllers
                                                      .removeAt(index);
                                                  parcelaOutrosEstadosControllers
                                                      .removeAt(index);
                                                  parcelaCosumoControllers
                                                      .removeAt(index);
                                                  valorCosumoControllers
                                                      .removeAt(index);
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(10.0),
                                      //   child: DropdownButtonFormField<String>(
                                      //     menuMaxHeight: 500,
                                      //     decoration: InputDecoration(
                                      //       filled: true,
                                      //       fillColor: Colors.white,
                                      //       border: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.8,
                                      //             color: Colors.white),
                                      //       ),
                                      //       enabledBorder: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.8,
                                      //             color: Colors.white),
                                      //       ),
                                      //       errorBorder: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.5, color: Colors.red),
                                      //       ),
                                      //       hintText: 'Selecione o Vegetal',
                                      //       labelText: 'Selecione o Vegetal',
                                      //     ),
                                      //     isExpanded: true,
                                      //     value: selectedVegetal,
                                      //     onChanged: (value) {
                                      //       setState(() {
                                      //         if (value != null &&
                                      //             !_selectedVegetais
                                      //                 .contains(value)) {
                                      //           _selectedVegetais.add(value);
                                      //           areaPuraControllers
                                      //               .add(TextEditingController());
                                      //           areaConsorciadaControllers
                                      //               .add(TextEditingController());
                                      //           quantidadeColhidaControllers
                                      //               .add(TextEditingController());
                                      //           quantidadeVendidaControllers
                                      //               .add(TextEditingController());
                                      //           precoUnitarioControllers
                                      //               .add(TextEditingController());
                                      //           parcelaPAAControllers
                                      //               .add(TextEditingController());
                                      //           parcelaMercadosLocaisControllers
                                      //               .add(TextEditingController());
                                      //           parcelaOutrosEstadosControllers
                                      //               .add(TextEditingController());
                                      //           parcelaCosumoControllers
                                      //               .add(TextEditingController());
                                      //           valorCosumoControllers
                                      //               .add(TextEditingController());
                                      //         } else {
                                      //           int index = _selectedVegetais
                                      //               .indexOf(value!);
                                      //           if (index != -1) {
                                      //             _selectedVegetais
                                      //                 .removeAt(index);
                                      //             areaPuraControllers
                                      //                 .removeAt(index);
                                      //             areaConsorciadaControllers
                                      //                 .removeAt(index);
                                      //             quantidadeColhidaControllers
                                      //                 .removeAt(index);
                                      //             quantidadeVendidaControllers
                                      //                 .removeAt(index);
                                      //             precoUnitarioControllers
                                      //                 .removeAt(index);
                                      //             parcelaPAAControllers
                                      //                 .removeAt(index);
                                      //             parcelaMercadosLocaisControllers
                                      //                 .removeAt(index);
                                      //             parcelaOutrosEstadosControllers
                                      //                 .removeAt(index);
                                      //             parcelaCosumoControllers
                                      //                 .removeAt(index);
                                      //             valorCosumoControllers
                                      //                 .removeAt(index);
                                      //           }
                                      //         }
                                      //       });
                                      //     },
                                      //     items: VegetaisRepository.listVegetais
                                      //         .map((vegetal) {
                                      //       return DropdownMenuItem<String>(
                                      //         value: vegetal.nome,
                                      //         child: Text(
                                      //           vegetal.nome,
                                      //           style:
                                      //               const TextStyle(fontSize: 14),
                                      //         ),
                                      //       );
                                      //     }).toList(),
                                      //   ),
                                      // ),
                                      if (selectedVegetal != null)
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
                                                      'Total de área destinada à produção (Hectares)',
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
                                                controller: areaController,
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
                                                      'Área destinada à produção (ha)',
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
                                                      'Quantidade Colhida (Quilogramas)',
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
                                                    quantidadeColhidaController,
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
                                                      'Quantidade colhida (Kg)',
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
                                                      'Quantidade Vendida (Quilogramas)',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                          quantidadeColhidaController!
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
                                                    quantidadeVendidaController,
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
                                                      'Quantidade vendida (Kg)',
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
                                                      'Preço Unitário',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // TextFormField(
                                              //   decoration: InputDecoration(
                                              //     filled: true,
                                              //     fillColor: Colors.white,
                                              //     border: OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     enabledBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     errorBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.5,
                                              //               color: Colors.red),
                                              //     ),
                                              //     labelText:
                                              //         'Unidade da quantidade (Chave 2)',
                                              //   ),
                                              // ),
                                              // const SizedBox(
                                              //   height: 20,
                                              // ),
                                              TextFormField(
                                                validator: (value) =>
                                                    value != null &&
                                                            value.isEmpty
                                                        ? 'Preencha o Campo'
                                                        : null,
                                                keyboardType:
                                                    TextInputType.number,
                                                controller:
                                                    precoUnitarioController,
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
                                                      'Preço unitário (R\$)',
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
                                                      'Parcela da Produção destinada \nao consumo próprio (Quilogramas)',
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
                                                    parcelaConsumoController,
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
                                                      'Parcela da produção destinada ao consumo familiar (Kg)',
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const Divider(
                                                thickness: 2,
                                              )
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'A sua família criou Animais?',
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
                                  _selectedVegetais.clear();
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
                        if (_produziuVegetais && _quantidadeAnimaisCriados > 0)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selecionar Animais:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: List.generate(
                                    _quantidadeAnimaisCriados, (index) {
                                  final selectedVegetal =
                                  _selectedVegetais.length > index
                                      ? _selectedVegetais[index]
                                      : null;
                                  final areaController =
                                  areaPuraControllers.length > index
                                      ? areaPuraControllers[index]
                                      : null;
                                  final area2Controller =
                                  areaConsorciadaControllers.length > index
                                      ? areaConsorciadaControllers[index]
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
                                  final parcelaPAAController =
                                  parcelaPAAControllers.length > index
                                      ? parcelaPAAControllers[index]
                                      : null;
                                  final parcelaMercadosLocaisController =
                                  parcelaMercadosLocaisControllers.length >
                                      index
                                      ? parcelaMercadosLocaisControllers[
                                  index]
                                      : null;
                                  final parcelaOutrosEstadosController =
                                  parcelaOutrosEstadosControllers.length >
                                      index
                                      ? parcelaOutrosEstadosControllers[
                                  index]
                                      : null;
                                  final parcelaConsumoController =
                                  parcelaCosumoControllers.length > index
                                      ? parcelaCosumoControllers[index]
                                      : null;
                                  final valorConsumoController =
                                  valorCosumoControllers.length > index
                                      ? valorCosumoControllers[index]
                                      : null;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: DropdownSearch<String>(
                                          popupProps: PopupProps.dialog(
                                              fit: FlexFit.tight,
                                              showSelectedItems: true,
                                              showSearchBox: true,
                                              scrollbarProps: ScrollbarProps()),
                                          items:
                                          AnimaisRepository.listAnimais,
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
                                                  !_selectedVegetais
                                                      .contains(value)) {
                                                _selectedVegetais.add(value);
                                                areaPuraControllers.add(
                                                    TextEditingController());
                                                areaConsorciadaControllers.add(
                                                    TextEditingController());
                                                quantidadeColhidaControllers.add(
                                                    TextEditingController());
                                                quantidadeVendidaControllers.add(
                                                    TextEditingController());
                                                precoUnitarioControllers.add(
                                                    TextEditingController());
                                                parcelaPAAControllers.add(
                                                    TextEditingController());
                                                parcelaMercadosLocaisControllers
                                                    .add(
                                                    TextEditingController());
                                                parcelaOutrosEstadosControllers
                                                    .add(
                                                    TextEditingController());
                                                parcelaCosumoControllers.add(
                                                    TextEditingController());
                                                valorCosumoControllers.add(
                                                    TextEditingController());
                                              } else {
                                                int index = _selectedVegetais
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
                                                  parcelaPAAControllers
                                                      .removeAt(index);
                                                  parcelaMercadosLocaisControllers
                                                      .removeAt(index);
                                                  parcelaOutrosEstadosControllers
                                                      .removeAt(index);
                                                  parcelaCosumoControllers
                                                      .removeAt(index);
                                                  valorCosumoControllers
                                                      .removeAt(index);
                                                }
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.all(10.0),
                                      //   child: DropdownButtonFormField<String>(
                                      //     menuMaxHeight: 500,
                                      //     decoration: InputDecoration(
                                      //       filled: true,
                                      //       fillColor: Colors.white,
                                      //       border: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.8,
                                      //             color: Colors.white),
                                      //       ),
                                      //       enabledBorder: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.8,
                                      //             color: Colors.white),
                                      //       ),
                                      //       errorBorder: OutlineInputBorder(
                                      //         borderRadius:
                                      //             BorderRadius.circular(30),
                                      //         borderSide: const BorderSide(
                                      //             width: 0.5, color: Colors.red),
                                      //       ),
                                      //       hintText: 'Selecione o Vegetal',
                                      //       labelText: 'Selecione o Vegetal',
                                      //     ),
                                      //     isExpanded: true,
                                      //     value: selectedVegetal,
                                      //     onChanged: (value) {
                                      //       setState(() {
                                      //         if (value != null &&
                                      //             !_selectedVegetais
                                      //                 .contains(value)) {
                                      //           _selectedVegetais.add(value);
                                      //           areaPuraControllers
                                      //               .add(TextEditingController());
                                      //           areaConsorciadaControllers
                                      //               .add(TextEditingController());
                                      //           quantidadeColhidaControllers
                                      //               .add(TextEditingController());
                                      //           quantidadeVendidaControllers
                                      //               .add(TextEditingController());
                                      //           precoUnitarioControllers
                                      //               .add(TextEditingController());
                                      //           parcelaPAAControllers
                                      //               .add(TextEditingController());
                                      //           parcelaMercadosLocaisControllers
                                      //               .add(TextEditingController());
                                      //           parcelaOutrosEstadosControllers
                                      //               .add(TextEditingController());
                                      //           parcelaCosumoControllers
                                      //               .add(TextEditingController());
                                      //           valorCosumoControllers
                                      //               .add(TextEditingController());
                                      //         } else {
                                      //           int index = _selectedVegetais
                                      //               .indexOf(value!);
                                      //           if (index != -1) {
                                      //             _selectedVegetais
                                      //                 .removeAt(index);
                                      //             areaPuraControllers
                                      //                 .removeAt(index);
                                      //             areaConsorciadaControllers
                                      //                 .removeAt(index);
                                      //             quantidadeColhidaControllers
                                      //                 .removeAt(index);
                                      //             quantidadeVendidaControllers
                                      //                 .removeAt(index);
                                      //             precoUnitarioControllers
                                      //                 .removeAt(index);
                                      //             parcelaPAAControllers
                                      //                 .removeAt(index);
                                      //             parcelaMercadosLocaisControllers
                                      //                 .removeAt(index);
                                      //             parcelaOutrosEstadosControllers
                                      //                 .removeAt(index);
                                      //             parcelaCosumoControllers
                                      //                 .removeAt(index);
                                      //             valorCosumoControllers
                                      //                 .removeAt(index);
                                      //           }
                                      //         }
                                      //       });
                                      //     },
                                      //     items: VegetaisRepository.listVegetais
                                      //         .map((vegetal) {
                                      //       return DropdownMenuItem<String>(
                                      //         value: vegetal.nome,
                                      //         child: Text(
                                      //           vegetal.nome,
                                      //           style:
                                      //               const TextStyle(fontSize: 14),
                                      //         ),
                                      //       );
                                      //     }).toList(),
                                      //   ),
                                      // ),
                                      if (selectedVegetal != null)
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
                                                      'Área Pura Colhida em Hectares',
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
                                                controller: areaController,
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
                                                  'Área colhida produção pura (ha)',
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
                                                      'Área Consorciada Colhida em Hectares',
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
                                                controller: area2Controller,
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
                                                  'Área colhida produção consorciada (ha)',
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
                                                      'Quantidade Colhida',
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
                                                quantidadeColhidaController,
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
                                                  'Quantidade colhida',
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
                                                      'Quantidade Vendida',
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w500,
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
                                                      quantidadeColhidaController!
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
                                                quantidadeVendidaController,
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
                                                  'Quantidade vendida',
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
                                                      'Preço Unitário',
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // TextFormField(
                                              //   decoration: InputDecoration(
                                              //     filled: true,
                                              //     fillColor: Colors.white,
                                              //     border: OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     enabledBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     errorBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.5,
                                              //               color: Colors.red),
                                              //     ),
                                              //     labelText:
                                              //         'Unidade da quantidade (Chave 2)',
                                              //   ),
                                              // ),
                                              // const SizedBox(
                                              //   height: 20,
                                              // ),
                                              TextFormField(
                                                validator: (value) =>
                                                value != null &&
                                                    value.isEmpty
                                                    ? 'Preencha o Campo'
                                                    : null,
                                                keyboardType:
                                                TextInputType.number,
                                                controller:
                                                precoUnitarioController,
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
                                                  'Preço unitário (R\$)',
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10.0,
                                                    top: 20,
                                                    bottom: 10),
                                                child: SizedBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Parcela da Produção destinada ao \nPAA, PNAE',
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            fontSize: 15,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // TextFormField(
                                              //   decoration: InputDecoration(
                                              //     filled: true,
                                              //     fillColor: Colors.white,
                                              //     border: OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     enabledBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.8,
                                              //               color:
                                              //                   Colors.white),
                                              //     ),
                                              //     errorBorder:
                                              //         OutlineInputBorder(
                                              //       borderRadius:
                                              //           BorderRadius.circular(
                                              //               30),
                                              //       borderSide:
                                              //           const BorderSide(
                                              //               width: 0.5,
                                              //               color: Colors.red),
                                              //     ),
                                              //     labelText:
                                              //         'Valor total das vendas (R\$)',
                                              //   ),
                                              // ),
                                              // const SizedBox(
                                              //   height: 20,
                                              // ),
                                              TextFormField(
                                                validator: (value) =>
                                                value != null &&
                                                    value.isEmpty
                                                    ? 'Preencha o Campo'
                                                    : null,
                                                keyboardType:
                                                TextInputType.number,
                                                controller:
                                                parcelaPAAController,
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
                                                  'Parcela da produção destinada ao PAA, PNAE',
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0,
                                                    top: 20,
                                                    bottom: 10),
                                                child: SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Parcela da Produção destinada a \nMercados Locais no mesmo Estado',
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
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
                                                parcelaMercadosLocaisController,
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
                                                  'Parcela da produção destinada a mercados locais no mesmo estado ',
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
                                                      'Parcela da Produção destinada a \noutros Estados',
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
                                                parcelaOutrosEstadosController,
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
                                                  'Parcela da produção destinada a outros estados',
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
                                                      'Parcela da Produção destinada \nao Consumo',
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
                                                parcelaConsumoController,
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
                                                  'Parcela da produção destinada ao consumo familiar',
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
                                                      'Valor da Produção destinado \nao Consumo',
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
                                                valorConsumoController,
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
                                                  'Valor do consumo expresso em R\$',
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              const Divider(
                                                thickness: 2,
                                              )
                                            ],
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
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
