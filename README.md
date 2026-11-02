# GastoCerto – Controle de Gastos Pessoais

**Aluno:** Matheus Peres – RM567300
**Disciplina:** Mobile Application Development
**Professor:** Pietro Rischi Nunes
**Entrega:** CheckPoint 3 – FIAP, Análise e Desenvolvimento de Sistemas (3º semestre)

---

## 1. Proposta do App

### O que é

O **GastoCerto** é um app simples para anotar os gastos do dia a dia. A ideia é ser rápido: abriu, cadastrou o gasto e já viu quanto gastou no total. Nada de planilha nem cadastro complicado.

### Para quem é

Para quem quer ter uma noção de para onde o dinheiro está indo (por exemplo, um estudante que quer ver quanto gasta com transporte e alimentação no mês) sem precisar de um app de finanças completo.

### Funcionalidades

- Cadastrar um gasto com **descrição**, **valor** e **categoria** (Alimentação, Transporte, Lazer, Moradia, Educação ou Outros). A data é registrada automaticamente.
- Ver a **lista de gastos**, com descrição, categoria, data e valor em reais (R$ 0,00).
- Ver o **total gasto** num card no topo da tela, junto com a quantidade de gastos.
- **Filtrar por categoria**. O total do topo também respeita o filtro.
- **Editar** um gasto tocando nele.
- **Excluir** um gasto, com confirmação antes e opção de **desfazer** logo depois.
- Mensagens de erro nos campos do formulário e mensagens de sucesso depois de cada ação.

> Os dados ficam só em memória (numa `List` dentro do `State`). Se o app for fechado, os gastos são perdidos. Foi uma decisão do escopo do trabalho, que pede para não usar banco de dados nem API.

### Fluxo de uso passo a passo

1. Ao abrir o app, a tela principal mostra o total **R$ 0,00** e a mensagem *"Nenhum gasto cadastrado ainda"*.
2. O usuário toca no botão **+** e abre a tela **Novo gasto**.
3. Ele preenche descrição, valor e categoria e toca em **Cadastrar gasto**.
   - Se algum campo estiver errado, aparece a mensagem de erro embaixo do campo e o gasto não é salvo.
   - Se ele voltar sem salvar, nada muda na lista.
4. Ao salvar, o app volta para a lista, o gasto aparece no topo, o total é atualizado e aparece a mensagem *"Gasto cadastrado com sucesso!"*.
5. O usuário pode tocar num chip de categoria (ex.: **Transporte**) para ver só os gastos dela. O card do topo passa a mostrar *"Total em Transporte"*. Se não tiver nenhum gasto nessa categoria, aparece uma mensagem avisando.
6. Tocando num gasto, abre a tela **Editar gasto** com os campos já preenchidos. Ao salvar, o gasto é atualizado na mesma posição e aparece *"Gasto atualizado com sucesso!"*.
7. Tocando no ícone de lixeira, aparece um diálogo perguntando se ele quer mesmo excluir. Se cancelar, nada acontece. Se confirmar, o gasto sai da lista e aparece a mensagem *"Gasto excluído"* com o botão **Desfazer**, que devolve o gasto para a mesma posição.

---

## Como executar o projeto

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (o projeto foi feito com o Flutter 3.47, canal stable)
- Um emulador Android, um celular conectado ou o navegador Chrome

### Comandos

```bash
# clonar o repositório
git clone https://github.com/MaThPMJ/CP3-MOBILE.git
cd CP3-MOBILE

# baixar as dependências (só o SDK do Flutter, sem pacotes externos)
flutter pub get

# rodar o app (escolha o dispositivo quando ele perguntar)
flutter run

# rodar no navegador, se não tiver emulador
flutter run -d chrome

# rodar a análise de código e os testes
flutter analyze
flutter test
```

---

## Estrutura de pastas

```
lib/
├── main.dart                        # Inicia o app, define o título "GastoCerto", o tema e a tela inicial
├── models/
│   └── gasto.dart                   # Classe Gasto, lista de categorias e funções para formatar R$ e data
├── screens/
│   ├── lista_gastos_screen.dart     # Tela principal: total, filtro, lista, exclusão e desfazer
│   └── form_gasto_screen.dart       # Tela de formulário, usada para cadastrar e para editar
└── widgets/
    ├── gasto_card.dart              # Card de cada gasto da lista
    └── resumo_card.dart             # Card do topo com o total gasto
test/
└── widget_test.dart                 # Teste que confere se a tela inicial abre com o estado vazio
```

Separei assim para cada arquivo ter uma responsabilidade só: o **model** guarda o formato dos dados, as **screens** são as telas que têm estado e os **widgets** são pedaços de tela que só exibem o que recebem.

---

## 3. Conceitos Utilizados

### StatelessWidget x StatefulWidget

- **StatelessWidget** é um widget que não muda depois de criado. Ele só desenha o que recebe.
- **StatefulWidget** tem um objeto `State` junto, que guarda dados que podem mudar. Quando esses dados mudam, a tela é redesenhada.

No projeto:

| Widget | Tipo | Por quê |
|---|---|---|
| `GastoCertoApp` ([main.dart](lib/main.dart)) | Stateless | Só configura título, tema e tela inicial |
| `GastoCard` ([gasto_card.dart](lib/widgets/gasto_card.dart)) | Stateless | Só mostra um gasto; as ações chegam por callback (`onTap`, `onExcluir`) |
| `ResumoCard` ([resumo_card.dart](lib/widgets/resumo_card.dart)) | Stateless | Recebe o total já calculado e só exibe |
| `ListaGastosScreen` ([lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart)) | **Stateful** | Guarda a lista de gastos (`_gastos`) e a categoria do filtro (`_categoriaSelecionada`) |
| `FormGastoScreen` ([form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)) | **Stateful** | Guarda os controllers, a categoria escolhida e o modo de validação |

Um ponto que achei importante: os cards são Stateless, mas mesmo assim mudam na tela. Isso acontece porque quem tem o estado é a tela "mãe". Quando ela chama `setState`, ela reconstrói os filhos com os dados novos.

### Ciclo de vida: `initState` e `dispose`

Arquivo: [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)

- **`initState()`** roda uma única vez, quando o `State` é criado. Usei ele para preencher os campos quando a tela abre em modo de edição (descrição, valor com vírgula e categoria do gasto recebido).
- **`dispose()`** roda quando a tela é removida da pilha de navegação. Nele eu chamo `dispose()` nos dois `TextEditingController`, porque eles ocupam memória e ficam ligados ao campo. Se não liberar, pode dar vazamento de memória.

Nos dois métodos é preciso chamar o `super` (`super.initState()` no começo e `super.dispose()` no final).

### `setState`

O `setState` avisa o Flutter que algum dado do `State` mudou e que o método `build` precisa rodar de novo. Se eu só alterasse a lista sem `setState`, o dado mudaria, mas a tela continuaria igual.

Onde aparece:

- [lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart):
  - `_abrirCadastro()` – adiciona o gasto novo na lista (`_gastos.insert(0, novoGasto)`)
  - `_abrirEdicao()` – troca o gasto antigo pelo editado
  - `_confirmarExclusao()` – remove o gasto
  - `_desfazerExclusao()` – coloca o gasto de volta na mesma posição
  - `_construirFiltro()` – troca a categoria selecionada no `ChoiceChip`
- [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart):
  - `onChanged` do `DropdownButtonFormField` – guarda a categoria escolhida
  - `_salvar()` – liga a validação automática depois da primeira tentativa com erro

O total e a lista filtrada não são guardados em variável: eles são calculados pelos getters `_gastosFiltrados` e `_total`. Como o `build` roda a cada `setState`, eles sempre ficam certos, e não tem como o total ficar "desatualizado" em relação à lista.

### Form e validação

Arquivo: [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)

- O formulário usa um widget **`Form`** com uma **`GlobalKey<FormState>`** (`_formKey`). A chave dá acesso ao estado do formulário para chamar `_formKey.currentState!.validate()`.
- Cada campo é um **`TextFormField`** (ou `DropdownButtonFormField`) com um **`validator`**. O validator recebe o texto e retorna `null` se estiver tudo certo ou uma `String` com a mensagem de erro.
- O `validate()` roda todos os validators de uma vez. Se algum falhar, as mensagens aparecem embaixo dos campos e o gasto não é salvo.

Regras de validação:

| Campo | Regra | Mensagem |
|---|---|---|
| Descrição | obrigatória | "Informe a descrição do gasto" |
| Descrição | mínimo de 3 caracteres (ignorando espaços nas pontas) | "A descrição precisa ter pelo menos 3 caracteres" |
| Valor | obrigatório | "Informe o valor do gasto" |
| Valor | precisa ser número (aceita `25,90` e `25.90`) | "Digite um valor válido, ex.: 25,90" |
| Valor | maior que zero | "O valor precisa ser maior que zero" |
| Valor | até R$ 1.000.000,00 | "O valor máximo é R$ 1.000.000,00" |
| Categoria | obrigatória | "Escolha uma categoria" |

Detalhes que coloquei:

- O campo valor usa `FilteringTextInputFormatter` para deixar digitar só números, vírgula e ponto.
- No começo o `autovalidateMode` fica desligado, para não aparecer erro antes do usuário tentar salvar. Depois da primeira tentativa com erro, eu mudo para `AutovalidateMode.onUserInteraction` (com `setState`), e aí as mensagens somem conforme o usuário corrige.
- O valor é arredondado para centavos antes de salvar.

### TextEditingController

Arquivo: [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)

O `TextEditingController` é o objeto que guarda o texto de um campo. Usei dois: `_descricaoController` e `_valorController`. Com eles eu consigo:

- **escrever** no campo pelo código (no `initState`, para preencher na edição);
- **ler** o que o usuário digitou (no `_salvar()`, para montar o objeto `Gasto`).

Como falado acima, eles são liberados no `dispose()`.

### Navigator: `push` e `pop` com retorno de dados

Arquivos: [lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart) e [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)

- A tela principal abre o formulário com `await Navigator.push<Gasto>(...)` (métodos `_abrirCadastro()` e `_abrirEdicao()`). O `push` devolve um `Future`, então a tela fica "esperando" o formulário fechar.
- O formulário fecha com `Navigator.pop(context, gasto)` no `_salvar()`, devolvendo o gasto para quem abriu.
- Se o usuário volta pela seta ou pelo botão voltar do celular, o `pop` acontece sem valor e o retorno é `null`. Por isso tem o teste `if (novoGasto == null || !mounted) return;`, que faz o app simplesmente não fazer nada nesse caso.
- O `mounted` confere se a tela ainda existe depois do `await`, antes de usar o `context` ou chamar `setState`.
- Na edição, o gasto é passado pelo construtor: `FormGastoScreen(gasto: gasto)`. Se vier `null`, é cadastro; se vier preenchido, é edição. O mesmo formulário serve para os dois casos, mudando o título da AppBar ("Novo gasto" / "Editar gasto") e o texto do botão.
- O `AlertDialog` também usa `Navigator.pop(context, true/false)` para devolver a resposta do usuário.

### ListView.builder

Arquivo: [lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart), no método `build`

O `ListView.builder` monta a lista sob demanda: ele só cria os itens que estão aparecendo na tela, usando o `itemCount` e o `itemBuilder`. Isso é melhor que montar todos os itens de uma vez quando a lista fica grande. Cada item é um `GastoCard` com uma `ValueKey(gasto.id)`, para o Flutter saber qual item é qual quando a lista muda (exclusão, desfazer, filtro).

Quando a lista filtrada está vazia, no lugar do `ListView` aparece o método `_construirEstadoVazio()`, com uma mensagem diferente para "nenhum gasto cadastrado" e "nenhum gasto nesta categoria".

Obs.: no formulário eu **não** usei `ListView`, e sim `SingleChildScrollView` com `Column`. Como o `ListView` só monta o que está visível, um campo fora da tela poderia não ser validado pelo `Form`. Com `Column` todos os campos ficam montados.

### SnackBar

Arquivo: [lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart), método `_mostrarMensagem()`

A `SnackBar` é a mensagem que aparece rapidinho na parte de baixo da tela. Usei para avisar sucesso ao cadastrar, editar e excluir. Ela é mostrada com `ScaffoldMessenger.of(context).showSnackBar(...)`.

- Antes de mostrar uma nova, chamo `hideCurrentSnackBar()` para as mensagens não ficarem numa fila.
- Na exclusão, a SnackBar tem uma **`SnackBarAction`** chamada **Desfazer**. Antes de remover eu guardo o índice do gasto, e o desfazer insere ele de volta nesse mesmo índice (`_desfazerExclusao()`).
- Descobri que, na versão atual do Flutter, uma SnackBar com ação fica aberta até o usuário tocar nela. Por isso coloquei `persist: false`, para ela sumir sozinha depois de 4 segundos como as outras.

### AlertDialog

Arquivo: [lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart), método `_confirmarExclusao()`

Antes de excluir, o app mostra um `AlertDialog` com `showDialog<bool>`, perguntando *Deseja excluir "nome do gasto"?*, com os botões **Cancelar** e **Excluir**. O `showDialog` devolve `true` (excluir), `false` (cancelar) ou `null` (se o usuário tocar fora do diálogo). Só excluo quando o resultado é exatamente `true`.

### Scaffold, AppBar e FloatingActionButton

- **`Scaffold`** é a estrutura base de uma tela do Material Design. As duas telas usam ([lista_gastos_screen.dart](lib/screens/lista_gastos_screen.dart) e [form_gasto_screen.dart](lib/screens/form_gasto_screen.dart)).
- **`AppBar`** é a barra do topo. Na tela principal mostra "GastoCerto"; no formulário mostra "Novo gasto" ou "Editar gasto" e já vem com a seta de voltar automaticamente.
- **`FloatingActionButton`** é o botão redondo **+** da tela principal, que chama `_abrirCadastro()`. Coloquei um espaço no final da lista (`padding` de 88) para o botão não ficar em cima do último gasto.

### Outros widgets usados

- **`ChoiceChip`** no filtro por categoria (`_construirFiltro()`), dentro de um `SingleChildScrollView` horizontal para caber em telas pequenas.
- **`DropdownButtonFormField`** para escolher a categoria no formulário, com validator.
- **`Card`** e **`ListTile`** no `GastoCard` e no `ResumoCard`.
- **`ThemeData` com `ColorScheme.fromSeed`** no [main.dart](lib/main.dart) para gerar as cores do app a partir de uma cor base (teal).

### Formatação de valor sem pacote externo

Arquivo: [gasto.dart](lib/models/gasto.dart)

Como o trabalho não permite pacotes como o `intl`, fiz duas funções simples:

- `formatarReais(double)` – usa `toStringAsFixed(2)` para ter duas casas e coloca o ponto de milhar na mão. Ex.: `1234.5` vira `R$ 1.234,50`.
- `formatarData(DateTime)` – usa `padLeft` para montar `dd/mm/aaaa`.

---

## Cenários de erro e sucesso tratados

| Cenário | O que acontece |
|---|---|
| Abrir o app sem gastos | Total R$ 0,00 e mensagem "Nenhum gasto cadastrado ainda" |
| Salvar com campos vazios | Mensagem de erro embaixo de cada campo, nada é salvo |
| Descrição com menos de 3 caracteres (ou só espaços) | Erro no campo descrição |
| Valor zero, inválido ou acima de R$ 1.000.000,00 | Erro no campo valor |
| Letras no campo valor | Não deixa digitar (só números, vírgula e ponto) |
| Categoria não escolhida | Erro no campo categoria |
| Cadastro válido | Volta para a lista, gasto aparece no topo, total atualizado, SnackBar "Gasto cadastrado com sucesso!" |
| Edição válida | Gasto atualizado na mesma posição, SnackBar "Gasto atualizado com sucesso!" |
| Voltar do formulário sem salvar | Retorno `null`, lista continua igual, sem erro |
| Filtro sem resultados | Total R$ 0,00 e mensagem "Nenhum gasto em [categoria]" |
| Tocar na lixeira e cancelar (ou tocar fora do diálogo) | Nada é excluído |
| Confirmar exclusão | Gasto removido, total atualizado, SnackBar "Gasto excluído" com "Desfazer" |
| Tocar em "Desfazer" | Gasto volta para a mesma posição da lista |
| Várias ações seguidas | A SnackBar anterior é fechada antes de mostrar a nova |

---

## Prints das telas

[INSERIR_PRINTS_DAS_TELAS]
