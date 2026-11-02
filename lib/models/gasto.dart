/// Lista fixa de categorias que o usuário pode escolher.
/// Fica aqui no model porque é usada tanto no formulário quanto no filtro.
const List<String> categoriasGasto = [
  'Alimentação',
  'Transporte',
  'Lazer',
  'Moradia',
  'Educação',
  'Outros',
];

/// Representa um gasto cadastrado pelo usuário.
/// Os campos são `final` porque um gasto não muda depois de criado:
/// quando o usuário edita, a gente cria um novo objeto com o mesmo id.
class Gasto {
  final String id;
  final String descricao;
  final double valor;
  final String categoria;
  final DateTime data;

  const Gasto({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.categoria,
    required this.data,
  });
}

/// Formata um número no padrão de moeda brasileiro, ex.: 1234.5 -> "R$ 1.234,50".
/// Fiz na mão para não precisar do pacote intl.
String formatarReais(double valor) {
  // toStringAsFixed(2) garante sempre duas casas decimais: "1234.50"
  final partes = valor.toStringAsFixed(2).split('.');
  final inteiro = partes[0];
  final centavos = partes[1];

  // Coloca um ponto a cada 3 dígitos, contando da direita para a esquerda
  final buffer = StringBuffer();
  for (int i = 0; i < inteiro.length; i++) {
    final digitosRestantes = inteiro.length - i;
    if (i > 0 && digitosRestantes % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(inteiro[i]);
  }

  return 'R\$ $buffer,$centavos';
}

/// Formata a data no padrão dd/mm/aaaa.
String formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}
