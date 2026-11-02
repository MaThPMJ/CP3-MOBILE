import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/gasto.dart';

/// Tela usada tanto para cadastrar quanto para editar um gasto.
/// Se receber um [gasto], ela entra em modo de edição; se vier null,
/// é um cadastro novo.
class FormGastoScreen extends StatefulWidget {
  final Gasto? gasto;

  const FormGastoScreen({super.key, this.gasto});

  @override
  State<FormGastoScreen> createState() => _FormGastoScreenState();
}

class _FormGastoScreenState extends State<FormGastoScreen> {
  // A GlobalKey dá acesso ao estado do Form, para chamar validate()
  final _formKey = GlobalKey<FormState>();

  // Os controllers guardam o texto digitado nos campos
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  String? _categoria;

  // Começa desligado para não mostrar erro antes do usuário tentar salvar.
  // Depois da primeira tentativa, os erros passam a sumir enquanto ele corrige.
  AutovalidateMode _modoValidacao = AutovalidateMode.disabled;

  bool get _editando => widget.gasto != null;

  @override
  void initState() {
    super.initState();
    // initState roda uma vez só, quando a tela é criada.
    // É o lugar certo para preencher os campos no modo de edição.
    final gasto = widget.gasto;
    if (gasto != null) {
      _descricaoController.text = gasto.descricao;
      // Mostra o valor com vírgula, que é o que o usuário brasileiro espera
      _valorController.text = gasto.valor
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      _categoria = gasto.categoria;
    }
  }

  @override
  void dispose() {
    // Os controllers ocupam memória e ficam "escutando" o campo.
    // Quando a tela sai da pilha, liberamos eles para não vazar memória.
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  /// Converte o texto do campo valor para double.
  /// Aceita tanto "12,50" quanto "12.50". Retorna null se não for número.
  double? _converterValor(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  String? _validarDescricao(String? texto) {
    final descricao = texto?.trim() ?? '';
    if (descricao.isEmpty) {
      return 'Informe a descrição do gasto';
    }
    if (descricao.length < 3) {
      return 'A descrição precisa ter pelo menos 3 caracteres';
    }
    return null; // null = campo válido
  }

  String? _validarValor(String? texto) {
    if (texto == null || texto.trim().isEmpty) {
      return 'Informe o valor do gasto';
    }
    final valor = _converterValor(texto);
    if (valor == null) {
      return 'Digite um valor válido, ex.: 25,90';
    }
    if (valor < 0.01) {
      return 'O valor precisa ser maior que zero';
    }
    if (valor > 1000000) {
      return 'O valor máximo é R\$ 1.000.000,00';
    }
    return null;
  }

  void _salvar() {
    // validate() chama o validator de todos os campos do Form.
    // Se algum retornar mensagem de erro, ele aparece embaixo do campo.
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _modoValidacao = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final valor = _converterValor(_valorController.text)!;

    final gasto = Gasto(
      // Na edição mantém o mesmo id e a mesma data; no cadastro gera novos
      id: widget.gasto?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      descricao: _descricaoController.text.trim(),
      // Arredonda para centavos (ex.: 10,999 vira 11,00)
      valor: (valor * 100).round() / 100,
      categoria: _categoria!,
      data: widget.gasto?.data ?? DateTime.now(),
    );

    // Fecha a tela e devolve o gasto para quem abriu (a tela da lista)
    Navigator.pop(context, gasto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar gasto' : 'Novo gasto')),
      body: Form(
        key: _formKey,
        autovalidateMode: _modoValidacao,
        // SingleChildScrollView deixa a tela rolar quando o teclado abre.
        // Usei Column (e não ListView) para todos os campos ficarem
        // sempre montados e serem validados pelo Form.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: Almoço no restaurante',
                  border: OutlineInputBorder(),
                ),
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: _validarDescricao,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valorController,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  hintText: 'Ex.: 25,90',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                // Deixa digitar só números, vírgula e ponto
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: _validarValor,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: categoriasGasto
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (valor) {
                  setState(() {
                    _categoria = valor;
                  });
                },
                validator: (valor) =>
                    valor == null ? 'Escolha uma categoria' : null,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvar,
                icon: const Icon(Icons.check),
                label: Text(
                  _editando ? 'Salvar alterações' : 'Cadastrar gasto',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
