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

  static List<UnidadeFamiliar> canaisComercializacao = [
    UnidadeFamiliar(nome: 'Cooperativas da agricultura familiar'),
    UnidadeFamiliar(nome: 'Agroindústrias da agricultura familiar'),
    UnidadeFamiliar(nome: 'Cooperativas não enquadradas como de agricultura familiar'),
    UnidadeFamiliar(nome: 'Agroindústrias ou indústrias não enquadradas como de agricultura familiar'),
    UnidadeFamiliar(nome: 'Bares, restaurantes, lanchonetes e hotéis'),
    UnidadeFamiliar(nome: 'Exportação ou empresas exportadoras (comercialização para outros países)'),
    UnidadeFamiliar(nome: 'Feiras'),
    UnidadeFamiliar(nome: 'Mercados/ supermercados de outros Estados'),
    UnidadeFamiliar(nome: 'Mercados/ supermercados de outros municípios de Mato Grosso'),
    UnidadeFamiliar(nome: 'Mercados/ supermercados/quitandas do município'),
    UnidadeFamiliar(nome: 'Programa de Aquisição de Alimentos - PAA'),
    UnidadeFamiliar(nome: 'Programa Nacional de Alimentação Escolar - PNAE'),
    UnidadeFamiliar(nome: 'Revendedores/ atravessadores/ intermediários'),
    UnidadeFamiliar(nome: 'Venda direta para o consumidor final'),
    UnidadeFamiliar(nome: 'Vendas para órgãos públicos em geral (compras governamentais)'),
  ];


}
