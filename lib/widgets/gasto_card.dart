import 'package:flutter/material.dart';

import '../models/gasto.dart';

/// Card que mostra um gasto da lista.
/// É StatelessWidget porque só exibe os dados que recebe; quem guarda o
/// estado (a lista) é a tela principal. As ações de tocar e excluir chegam
/// por callback, assim o card não precisa saber como a lista é alterada.
class GastoCard extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback onTap;
  final VoidCallback onExcluir;

  const GastoCard({
    super.key,
    required this.gasto,
    required this.onTap,
    required this.onExcluir,
  });

  /// Escolhe um ícone diferente para cada categoria.
  IconData _iconeDaCategoria(String categoria) {
    switch (categoria) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_bus;
      case 'Lazer':
        return Icons.sports_esports;
      case 'Moradia':
        return Icons.home;
      case 'Educação':
        return Icons.school;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: cores.primaryContainer,
          child: Icon(
            _iconeDaCategoria(gasto.categoria),
            color: cores.onPrimaryContainer,
          ),
        ),
        title: Text(
          gasto.descricao,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${gasto.categoria} • ${formatarData(gasto.data)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatarReais(gasto.valor),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Excluir gasto',
              onPressed: onExcluir,
            ),
          ],
        ),
      ),
    );
  }
}
