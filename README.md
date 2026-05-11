# Agenda CLI em Elixir


Divulgação de Uso de IA
Durante a implementação, utilizei GitHub Copilot como assistência para:

- Sugestões de sintaxe Elixir
- Completação de trechos de código

Todos os requisitos do enunciado foram implementados por mim, testados e validados. O código foi revisado para garantir conformidade com os requisitos técnicos.



Requisitos Técnicos Cumpridos

Requisito — Implementação — Arquivo
- CLI executável via Mix — `mix run` — `mix.exs`
- Serialização JSON (Jason) — `Jason` — `lib/agenda_cli/store.ex`
- Loop recursivo (cauda) — `fazer_loop/1` — `lib/agenda_cli.ex`
- Pattern matching no parser — `processar_comando/2` — `lib/agenda_cli.ex`
- CRUD (add, edit, del, show, list) — funções puras — `lib/agenda_cli/contacts.ex`
- Busca parcial case-insensitive — `buscar/2` — `lib/agenda_cli/contacts.ex`

Arquitetura

AgendaCli (entrada)
├── `AgendaCli` — loop interativo e parsing (`lib/agenda_cli.ex`)
├── `AgendaCli.Contacts` — operações de manipulação da lista (`lib/agenda_cli/contacts.ex`)
└── `AgendaCli.Store` — leitura e escrita em `contacts.json` (`lib/agenda_cli/store.ex`)

Como Executar

Pré-requisitos
- Elixir 1.19+

Passos
```powershell

mix deps.get
mix compile
mix run --no-start -e "AgendaCli.main([])"
```

Exemplos de uso (no prompt `agenda>`)

- Adicionar com flags:
	add --name "Ana Lima" --company "Acme" --phone 85912345678 --email ana@acme.com
- Adicionar interativo:
	add
- Listar:
	list
- Mostrar detalhes:
	show <id>
- Editar com flags:
	edit <id> --phone 85900000000
- Buscar:
	search --name Ana
- Deletar:
	del <id>
- Sair:
	exit


Estrutura de Arquivos

```
agenda-cli-elixir-master/
├── lib/
│   ├── agenda_cli.ex
│   ├── agenda_cli/
│   │   ├── contacts.ex
│   │   └── store.ex
├── mix.exs
├── README.md
└── .gitignore
```



Compilação

```powershell
mix compile
```

Resultado esperado:

Compiling 3 files (.ex)
Generated agenda_cli app
