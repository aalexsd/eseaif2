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
  bool _showConjugeFields = false;
  String? _selectedMunicipio;
  bool _visitedInstitutions = false;
  final List<String> _selectedInstitutions = [];
  bool _possuiDAP = false;
  final List<String> _selectedDAP = [];
  bool _listaBeneficios = false;
  final List<String> _selectedBeneficios = [];
  bool _listaServicosPublicos = false;
  final List<String> _selectedServicosPublicos = [];
  bool _atividadesProduzidas = false;
  final List<String> _selectedActivities = [];
  bool _produziuVegetais = false;
  int _quantidadeItensProduzidos = 1;
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
        appBar: AppBar(
          title: const Text("Formulário"),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black12,
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
                            '1- Identificação do Questionário',
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
                              'Grupo Amostral',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedGroup,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGroup = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o Municipio';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          items: PessoaRepository.grupoAmostral
                              .map<DropdownMenuItem<String>>((String grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo,
                              child: Text(grupo),
                            );
                          }).toList(),
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
                            hintText: 'Grupo Amostral',
                            labelText: 'Selecione o Grupo Amostral',
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
                              'Município',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: DropdownSearch<String>(
                          popupProps: PopupProps.dialog(
                            showSelectedItems: true,
                            showSearchBox: true,
                          ),
                          items: MunicipiosRepository.municipiosMatoGrosso,
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
                              hintText: 'Município',
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o Municipio';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMunicipio = newValue;
                            });
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 20, left: 20),
                      //   child: DropdownButtonFormField<String>(
                      //     value: _selectedMunicipio,
                      //     onChanged: (newValue) {
                      //       setState(() {
                      //         _selectedMunicipio = newValue;
                      //       });
                      //     },
                      //     validator: (value) {
                      //       if (value == null || value.isEmpty) {
                      //         return 'Selecione o Municipio';
                      //       }
                      //       return null; // Retorna null se o campo estiver preenchido corretamente
                      //     },
                      //     items: MunicipiosRepository.municipiosMatoGrosso
                      //         .map<DropdownMenuItem<String>>(
                      //             (String comunidade) {
                      //       return DropdownMenuItem<String>(
                      //         value: comunidade,
                      //         child: Text(
                      //           comunidade,
                      //           style: const TextStyle(fontSize: 14),
                      //         ),
                      //       );
                      //     }).toList(),
                      //     decoration: InputDecoration(
                      //       filled: true,
                      //       fillColor: Colors.white,
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(30),
                      //         borderSide: const BorderSide(
                      //             width: 0.8, color: Colors.white),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(30),
                      //         borderSide: const BorderSide(
                      //             width: 0.8, color: Colors.white),
                      //       ),
                      //       errorBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(30),
                      //         borderSide: const BorderSide(
                      //             width: 0.5, color: Colors.red),
                      //       ),
                      //       hintText: 'Município',
                      //     ),
                      //   ),
                      // ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, top: 20, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Comunidade',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: comunidadeController,
                          validator: (value) => value != null && value.isEmpty
                              ? 'Digite a Comunidade'
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
                            hintText: 'Comunidade',
                            labelText: 'Comunidade',
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
                              'Identificação Sociocultural',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedComunity,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedComunity = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione a identificação sociocultural';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          items: PessoaRepository.identificacaoComunidade
                              .map<DropdownMenuItem<String>>(
                                  (String comunidade) {
                            return DropdownMenuItem<String>(
                              value: comunidade,
                              child: Text(
                                comunidade,
                                style: const TextStyle(
                                    fontSize: 13,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            );
                          }).toList(),
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
                            hintText: 'Identificação sociocultural',
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
                              'Tipo de Moradia',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedMoradias,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMoradias = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione o tipo de Moradia';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          items: PessoaRepository.moradias
                              .map<DropdownMenuItem<String>>((String moradias) {
                            return DropdownMenuItem<String>(
                              value: moradias,
                              child: Text(moradias),
                            );
                          }).toList(),
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
                            hintText: 'Caracterização das Moradias',
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
                              'A unidade familiar realiza \natividades produtivas?',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: _atividadesProduzidas,
                            onChanged: (value) {
                              setState(() {
                                _atividadesProduzidas = value!;
                              });
                            },
                          ),
                          const Text('Sim'),
                          Radio<bool>(
                            value: false,
                            groupValue: _atividadesProduzidas,
                            onChanged: (value) {
                              setState(() {
                                _atividadesProduzidas = value!;
                                _selectedActivities.clear();
                              });
                            },
                          ),
                          const Text('Não'),
                        ],
                      ),
                      if (_atividadesProduzidas)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: AtividadeRepository.tabela
                              .map<Widget>((institution) {
                            return CheckboxListTile(
                              title: Text(institution.nome),
                              value: _selectedActivities
                                  .contains(institution.nome),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && value) {
                                    _selectedActivities.add(institution.nome);
                                  } else {
                                    _selectedActivities
                                        .remove(institution.nome);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
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
                            '2- Dados da Família',
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
                              'Nome do Entrevistado',
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
                              'Nome do Chefe da Família',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: nameChefeFamiliaController,
                          validator: (value) => value != null && value.isEmpty
                              ? 'Digite o Nome do Chefe da Família'
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
                            hintText: 'Nome do Chefe da Família',
                            labelText: 'Nome Chefe da Família',
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
                              'CPF do Chefe da Família',
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
                              'NIS/CadUnico do Chefe da Família',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: nisController,
                          keyboardType: TextInputType.number,
                          validator: (value) => value != null && value.isEmpty
                              ? 'Digite o NIS/CadUnico'
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
                            hintText: 'NIS/CadUnico',
                            labelText: 'NIS/CadUnico',
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
                            hintText: 'Telefone do Chefe da Família',
                            labelText: 'Telefone do Chefe da Família',
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
                              'Genero do Chefe da Família',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20, left: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um gênero';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          items: PessoaRepository.genders
                              .map<DropdownMenuItem<String>>(
                            (String gender) {
                              return DropdownMenuItem<String>(
                                value: gender,
                                child: Text(gender),
                              );
                            },
                          ).toList(),
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
                            hintText: 'Gênero',
                            labelText: 'Selecione o Gênero',
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
                              'Estado Civil Chefe da Família',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedMaritalStatus,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedMaritalStatus = newValue;
                              _showConjugeFields = newValue ==
                                  'Casado(a)'; // Mostrar campos se a opção for "casado"
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Selecione um Estado Civil';
                            }
                            return null; // Retorna null se o campo estiver preenchido corretamente
                          },
                          items: PessoaRepository.maritalStatuses
                              .map<DropdownMenuItem<String>>(
                            (String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            },
                          ).toList(),
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
                            hintText: 'Estado Civil',
                            labelText: 'Estado Civil',
                          ),
                        ),
                      ),
                      if (_showConjugeFields)
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, top: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nome do Cônjuge',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                controller: nameConjugeController,
                                validator: (value) =>
                                    value != null && value.isEmpty
                                        ? 'Digite o Nome do Cônjuge'
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
                                  hintText: 'Nome do Cônjuge',
                                  labelText: 'Nome Cônjuge',
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, top: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'CPF do Cônjuge',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                controller: cpfConjugeController,
                                inputFormatters: [
                                  MascaraFormatacao.formatadorCPF
                                ],
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
                                  hintText: 'CPF do Cônjuge',
                                  labelText: 'CPF do Cônjuge',
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, top: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'NIS/CadUnico do Cônjuge',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                controller: nisConjugeController,
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    value != null && value.isEmpty
                                        ? 'Digite o NIS/CadUnico do Cônjuge'
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
                                  hintText: 'NIS/CadUnico do Cônjuge',
                                  labelText: 'NIS/CadUnico do Cônjuge',
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25.0, top: 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Telefone do Cônjuge',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: TextFormField(
                                controller: telefoneConjugeController,
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
                                  hintText: 'Telefone do Cônjuge',
                                  labelText: 'Telefone do Cônjuge',
                                ),
                              ),
                            ),
                          ],
                        ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Possui DAP?',
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
                          children:
                              UnidadeFamiliarRepository.dap.map<Widget>((dap) {
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
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
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
                                    _selectedInstitutions.add(institution.nome);
                                  } else {
                                    _selectedInstitutions
                                        .remove(institution.nome);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'O(A) Sr(a) ou integrante de sua família alguma vez já acessou os benefícios a seguir? (resposta múltipla)',
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
                            groupValue: _listaBeneficios,
                            onChanged: (value) {
                              setState(() {
                                _listaBeneficios = value!;
                              });
                            },
                          ),
                          const Text('Sim'),
                          Radio<bool>(
                            value: false,
                            groupValue: _listaBeneficios,
                            onChanged: (value) {
                              setState(() {
                                _listaBeneficios = value!;
                                _selectedBeneficios.clear();
                              });
                            },
                          ),
                          const Text('Não'),
                        ],
                      ),
                      if (_listaBeneficios)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: BeneficioRepository.tabela
                              .map<Widget>((beneficio) {
                            return CheckboxListTile(
                              title: Text(beneficio.nome),
                              value:
                                  _selectedBeneficios.contains(beneficio.nome),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && value) {
                                    _selectedBeneficios.add(beneficio.nome);
                                  } else {
                                    _selectedBeneficios.remove(beneficio.nome);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
                        ),
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'A sua família se beneficia dos seguintes serviços públicos? (resposta múltipla):',
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
                            groupValue: _listaServicosPublicos,
                            onChanged: (value) {
                              setState(() {
                                _listaServicosPublicos = value!;
                              });
                            },
                          ),
                          const Text('Sim'),
                          Radio<bool>(
                            value: false,
                            groupValue: _listaServicosPublicos,
                            onChanged: (value) {
                              setState(() {
                                _listaServicosPublicos = value!;
                                _selectedServicosPublicos.clear();
                              });
                            },
                          ),
                          const Text('Não'),
                        ],
                      ),
                      if (_listaServicosPublicos)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: BeneficioRepository.servicosPublicos
                              .map<Widget>((servico) {
                            return CheckboxListTile(
                              title: Text(servico.nome),
                              value: _selectedServicosPublicos
                                  .contains(servico.nome),
                              onChanged: (value) {
                                setState(() {
                                  if (value != null && value) {
                                    _selectedServicosPublicos.add(servico.nome);
                                  } else {
                                    _selectedServicosPublicos
                                        .remove(servico.nome);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          }).toList(),
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
                            '3- Produção Vegetal e Extrativismo',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )),
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
                                value: _quantidadeItensProduzidos,
                                onChanged: (value) {
                                  setState(() {
                                    _quantidadeItensProduzidos = value!;
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
                      if (_produziuVegetais && _quantidadeItensProduzidos > 0)
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
                                  _quantidadeItensProduzidos, (index) {
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
                                    quantidadeColhidaControllers.length > index
                                        ? quantidadeColhidaControllers[index]
                                        : null;
                                final quantidadeVendidaController =
                                    quantidadeVendidaControllers.length > index
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
                                        ? parcelaOutrosEstadosControllers[index]
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
                                          scrollbarProps: ScrollbarProps(
                                          )
                                        ),
                                        items: VegetaisRepository.listVegetais,
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
                                            hintText: 'Selecione o Vegetal',
                                            labelText: 'Selecione o Vegetal',
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Selecione o Municipio';
                                          }
                                          return null; // Retorna null se o campo estiver preenchido corretamente
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            if (value != null &&
                                                !_selectedVegetais
                                                    .contains(value)) {
                                              _selectedVegetais.add(value);
                                              areaPuraControllers
                                                  .add(TextEditingController());
                                              areaConsorciadaControllers
                                                  .add(TextEditingController());
                                              quantidadeColhidaControllers
                                                  .add(TextEditingController());
                                              quantidadeVendidaControllers
                                                  .add(TextEditingController());
                                              precoUnitarioControllers
                                                  .add(TextEditingController());
                                              parcelaPAAControllers
                                                  .add(TextEditingController());
                                              parcelaMercadosLocaisControllers
                                                  .add(TextEditingController());
                                              parcelaOutrosEstadosControllers
                                                  .add(TextEditingController());
                                              parcelaCosumoControllers
                                                  .add(TextEditingController());
                                              valorCosumoControllers
                                                  .add(TextEditingController());
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
                                                  value != null && value.isEmpty
                                                      ? 'Preencha o Campo'
                                                      : null,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                labelText: 'Quantidade colhida',
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                labelText: 'Quantidade vendida',
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                          overflow: TextOverflow
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
                                                  value != null && value.isEmpty
                                                      ? 'Preencha o Campo'
                                                      : null,
                                              keyboardType:
                                                  TextInputType.number,
                                              controller: parcelaPAAController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                                  value != null && value.isEmpty
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
                                                      BorderRadius.circular(30),
                                                  borderSide: const BorderSide(
                                                      width: 0.8,
                                                      color: Colors.white),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
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
                                builder: (context) =>  HomePage()),
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
    );
  }
}
