import 'package:flutter/material.dart';

import 'screens/lista_gastos_screen.dart';

void main() {
  runApp(const GastoCertoApp());
}

/// Widget raiz do app. É StatelessWidget porque só configura o título,
/// o tema e a tela inicial; nada aqui muda enquanto o app roda.
class GastoCertoApp extends StatelessWidget {
  const GastoCertoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GastoCerto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const ListaGastosScreen(),
    );
  }
}
