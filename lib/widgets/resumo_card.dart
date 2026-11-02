import 'package:flutter/material.dart';

import '../models/gasto.dart';

/// Card do topo da tela que mostra o total gasto.
/// Também é StatelessWidget: recebe o total já calculado pela tela principal
/// e só desenha. Quando a tela chama setState, ele é reconstruído com o
/// valor novo.
class ResumoCard extends StatelessWidget {
  final String titulo;
  final double total;
  final int quantidade;

  const ResumoCard({
    super.key,
    required this.titulo,
    required this.total,
    required this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final textoQuantidade = quantidade == 1 ? '1 gasto' : '$quantidade gastos';

    return Card(
      color: cores.primary,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(color: cores.onPrimary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              formatarReais(total),
              style: TextStyle(
                color: cores.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(textoQuantidade, style: TextStyle(color: cores.onPrimary)),
          ],
        ),
      ),
    );
  }
}
