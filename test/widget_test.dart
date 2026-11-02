import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gasto_certo/main.dart';

void main() {
  testWidgets('Tela inicial abre e mostra o estado vazio', (tester) async {
    await tester.pumpWidget(const GastoCertoApp());

    // Título da AppBar
    expect(find.text('GastoCerto'), findsOneWidget);

    // Total começa zerado
    expect(find.text('R\$ 0,00'), findsOneWidget);

    // Mensagem de estado vazio
    expect(find.text('Nenhum gasto cadastrado ainda'), findsOneWidget);

    // Botão para adicionar gasto
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
