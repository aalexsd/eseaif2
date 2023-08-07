import 'package:projeto_agricultura_familiar/Models/unidade_familiar.dart';

class UnidadeFamiliarRepository {
  static List<UnidadeFamiliar> tabela = [
    UnidadeFamiliar(nome: 'EMATER/RN'),
    UnidadeFamiliar(nome: 'Empaer'),
    UnidadeFamiliar(nome: 'Cooperativas'),
    UnidadeFamiliar(nome: 'Embrapa'),
    UnidadeFamiliar(nome: 'Empresas privadas'),
    UnidadeFamiliar(nome: 'IFMT'),
    UnidadeFamiliar(nome: 'Incra'),
    UnidadeFamiliar(nome: 'ONGs'),
    UnidadeFamiliar(nome: 'Sebrae'),
    UnidadeFamiliar(nome: 'Senar'),
    UnidadeFamiliar(nome: 'Universidades privadas'),
    UnidadeFamiliar(nome: 'Universidades públicas'),
  ];

  static List<UnidadeFamiliar> dap = [
    UnidadeFamiliar(nome: 'SIM, ambos'),
    UnidadeFamiliar(nome: 'SIM, apenas DAP'),
    UnidadeFamiliar(nome: 'SIM, apenas CAF'),
  ];

  static List<UnidadeFamiliar> prodOrganica = [
    UnidadeFamiliar(nome: 'Certificadora por Auditoria'),
    UnidadeFamiliar(nome: 'Organismo Participativo de Avaliação da Conformidade - OPAC'),
    UnidadeFamiliar(nome: 'Organização de Controle Social – OCS'),
  ];


  static List<UnidadeFamiliar> selos = [
    UnidadeFamiliar(nome: 'Selo arte'),
    UnidadeFamiliar(nome: 'Selo da agricultura familiar'),
    UnidadeFamiliar(nome: 'Selo da agroecologia'),
    UnidadeFamiliar(nome: 'Selos distintos'),
  ];


}
