import 'package:projeto_agricultura_familiar/Models/beneficios.dart';

class BeneficioRepository {
  static List<Beneficios> tabela = [
    Beneficios(nome: 'Aposentadoria, Previdência social'),
    Beneficios(nome: 'Seguro desemprego'),
    Beneficios(
        nome:
            'Bolsa família, bolsa escola, cartão alimentação, auxílio gás, cesta básica'),
    Beneficios(
        nome: 'Bolsa de educação, Educa mais Brasil, Inglês sem fronteiras'),
    Beneficios(
        nome:
            'Jovem aprendiz, Pronatec, Sisutec, Sisu, Prouni, FIES Pós-graduação'),
    Beneficios(nome: 'Passe livre, cartão do idoso, CNH Social'),
    Beneficios(nome: 'Viver sem limites, Saúde não tem preço, Rede cegonha'),
    Beneficios(nome: 'Tarifa social de energia elétrica'),
    Beneficios(nome: 'Minha casa minha vida, Minha casa melhor'),
    Beneficios(nome: 'Luz no campo'),
    Beneficios(nome: 'Luz para todos'),
    Beneficios(nome: 'Cisterna para consumo humano - 1ª água'),
    Beneficios(nome: 'Cisterna para produção humano - 2ª água'),
    Beneficios(nome: 'Assistência técnica e extensão rural (ATER)'),
    Beneficios(nome: 'Financiamento agrícola'),
    Beneficios(nome: 'Pronaf'),
    Beneficios(nome: 'PAA'),
    Beneficios(nome: 'PNAE'),
    Beneficios(nome: 'Garantia Safra'),
    Beneficios(nome: 'Plano Brasil sem Miséria (PBSM)'),
    Beneficios(nome: 'Seguro rural'),
    Beneficios(nome: 'Seguro da Agricultura Familiar – SEAF (antigo Proagro)'),
    Beneficios(nome: 'Programa de reforma agrária, crédito fundiário'),
    Beneficios(nome: 'Programa de combate à pobreza rural'),
    Beneficios(
        nome: 'Microempreendedor individual (MEI), Refis ou Programa SEBRAE'),
    Beneficios(nome: 'Auxílios emergenciais em calamidades – Bolsa Estiagem'),
    Beneficios(nome: 'Programa de Saúde da Família (PSF)'),
    Beneficios(nome: 'Seguro Defeso'),
    Beneficios(nome: 'Sistema de Abastecimento de Água pelo Estado'),
    Beneficios(nome: 'Água para Consumo Humano em Carro-Pipa')
  ];

  static List<Beneficios> servicosPublicos = [
    Beneficios(nome: 'Agente de saúde'),
    Beneficios(nome: 'PSF/presença de médico na comunidade/ distrito '),
    Beneficios(nome: 'Transporte escolar'),
    Beneficios(nome: 'Transporte público'),
    Beneficios(nome: 'Segurança pública'),
  ];
}
