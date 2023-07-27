import 'package:projeto_agricultura_familiar/Models/unidade_familiar.dart';

class UnidadeFamiliarRepository {
  static List<UnidadeFamiliar> tabela = [
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
    UnidadeFamiliar(nome: 'Principal'),
    UnidadeFamiliar(nome: 'Assessoria Mulher'),
    UnidadeFamiliar(nome: 'Assessória Jovem'),
    UnidadeFamiliar(nome: 'Especial'),
  ];
}
