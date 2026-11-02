import 'package:flutter/material.dart';

import '../models/gasto.dart';
import '../widgets/gasto_card.dart';
import '../widgets/resumo_card.dart';
import 'form_gasto_screen.dart';

/// Tela principal: mostra o total, o filtro e a lista de gastos.
/// É StatefulWidget porque a lista e o filtro mudam enquanto o app roda,
/// e a tela precisa se redesenhar quando isso acontece.
class ListaGastosScreen extends StatefulWidget {
  const ListaGastosScreen({super.key});

  @override
  State<ListaGastosScreen> createState() => _ListaGastosScreenState();
}

class _ListaGastosScreenState extends State<ListaGastosScreen> {
  // Estado da tela: os dados ficam só em memória, dentro do State.
  // Se fechar o app, os gastos somem (não usamos banco de dados).
  final List<Gasto> _gastos = [];

  // Categoria escolhida no filtro. 'Todas' mostra tudo.
  static const String _todas = 'Todas';
  String _categoriaSelecionada = _todas;

  /// Lista que aparece na tela, já respeitando o filtro.
  List<Gasto> get _gastosFiltrados {
    if (_categoriaSelecionada == _todas) {
      return _gastos;
    }
    return _gastos.where((g) => g.categoria == _categoriaSelecionada).toList();
  }

  /// Soma dos valores da lista filtrada.
  double get _total {
    double soma = 0;
    for (final gasto in _gastosFiltrados) {
      soma += gasto.valor;
    }
    return soma;
  }

  /// Mostra uma SnackBar, fechando antes a que estiver aberta
  /// (assim as mensagens não ficam empilhadas).
  void _mostrarMensagem(String texto, {SnackBarAction? acao}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(texto),
        action: acao,
        duration: const Duration(seconds: 4),
        // Nesta versão do Flutter, SnackBar com ação fica aberta até o
        // usuário tocar. Com persist: false ela some sozinha após 4 segundos.
        persist: false,
      ),
    );
  }

  Future<void> _abrirCadastro() async {
    // push devolve um Future com o valor passado no Navigator.pop do formulário
    final novoGasto = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(builder: (context) => const FormGastoScreen()),
    );

    // Se o usuário voltou sem salvar, o retorno é null e não fazemos nada.
    // O mounted confere se a tela ainda existe depois do await.
    if (novoGasto == null || !mounted) return;

    // setState avisa o Flutter que o estado mudou e a tela precisa ser
    // reconstruída. Sem ele a lista mudaria, mas a tela não.
    setState(() {
      _gastos.insert(0, novoGasto); // mais recente fica no topo
    });
    _mostrarMensagem('Gasto cadastrado com sucesso!');
  }

  Future<void> _abrirEdicao(Gasto gasto) async {
    final gastoEditado = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(builder: (context) => FormGastoScreen(gasto: gasto)),
    );

    if (gastoEditado == null || !mounted) return;

    // Procura pelo id para trocar o gasto antigo pelo editado na mesma posição
    final indice = _gastos.indexWhere((g) => g.id == gastoEditado.id);
    if (indice == -1) return;

    setState(() {
      _gastos[indice] = gastoEditado;
    });
    _mostrarMensagem('Gasto atualizado com sucesso!');
  }

  Future<void> _confirmarExclusao(Gasto gasto) async {
    // showDialog também devolve um Future: true se confirmou,
    // false se cancelou e null se tocou fora do diálogo.
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir gasto'),
        content: Text('Deseja excluir "${gasto.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmou != true || !mounted) return;

    // Guarda a posição antes de remover, para o "Desfazer" devolver
    // o gasto exatamente no mesmo lugar
    final indice = _gastos.indexWhere((g) => g.id == gasto.id);
    if (indice == -1) return;

    setState(() {
      _gastos.removeAt(indice);
    });

    _mostrarMensagem(
      'Gasto excluído',
      acao: SnackBarAction(
        label: 'Desfazer',
        onPressed: () => _desfazerExclusao(gasto, indice),
      ),
    );
  }

  void _desfazerExclusao(Gasto gasto, int indice) {
    if (!mounted) return;
    setState(() {
      // Se a lista mudou de tamanho nesse meio tempo, evita índice inválido
      final posicao = indice > _gastos.length ? _gastos.length : indice;
      _gastos.insert(posicao, gasto);
    });
  }

  /// Linha de chips para filtrar por categoria.
  Widget _construirFiltro() {
    final opcoes = [_todas, ...categoriasGasto];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: opcoes.map((categoria) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categoria),
              selected: _categoriaSelecionada == categoria,
              onSelected: (_) {
                // Trocar o filtro também é mudança de estado
                setState(() {
                  _categoriaSelecionada = categoria;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Mensagem mostrada quando não tem nada para exibir.
  Widget _construirEstadoVazio() {
    final semNenhumGasto = _gastos.isEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              semNenhumGasto ? Icons.savings_outlined : Icons.filter_alt_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              semNenhumGasto
                  ? 'Nenhum gasto cadastrado ainda'
                  : 'Nenhum gasto em $_categoriaSelecionada',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              semNenhumGasto
                  ? 'Toque no botão + para adicionar o seu primeiro gasto.'
                  : 'Escolha outra categoria ou cadastre um gasto nesta.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build roda de novo a cada setState, então os valores abaixo
    // são sempre recalculados com o estado atual
    final gastosVisiveis = _gastosFiltrados;

    return Scaffold(
      appBar: AppBar(title: const Text('GastoCerto')),
      body: Column(
        children: [
          ResumoCard(
            titulo: _categoriaSelecionada == _todas
                ? 'Total gasto'
                : 'Total em $_categoriaSelecionada',
            total: _total,
            quantidade: gastosVisiveis.length,
          ),
          _construirFiltro(),
          Expanded(
            child: gastosVisiveis.isEmpty
                ? _construirEstadoVazio()
                // ListView.builder só cria os itens que aparecem na tela
                : ListView.builder(
                    // Espaço no final para o botão + não cobrir o último item
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: gastosVisiveis.length,
                    itemBuilder: (context, index) {
                      final gasto = gastosVisiveis[index];
                      return GastoCard(
                        key: ValueKey(gasto.id),
                        gasto: gasto,
                        onTap: () => _abrirEdicao(gasto),
                        onExcluir: () => _confirmarExclusao(gasto),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        tooltip: 'Adicionar gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
