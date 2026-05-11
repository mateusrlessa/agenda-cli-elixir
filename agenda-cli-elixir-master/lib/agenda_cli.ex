defmodule AgendaCli do
  @moduledoc """
  Módulo principal da aplicação CLI de agenda de contatos.
  """

  alias AgendaCli.Contacts
  alias AgendaCli.Store

  def main(_args) do
    contatos = Store.carregar_contatos()
    IO.puts("Bem-vindo à Agenda CLI!")
    IO.puts("Comandos: add, show, edit, del, list, search, exit")
    fazer_loop(contatos)
  end

  # Loop recursivo principal
  defp fazer_loop(contatos) do
    entrada = IO.gets("agenda> ")

    case entrada do
      nil ->
        System.halt(0)

      input ->
        input
        |> String.trim()
        |> processar_comando(contatos)
    end
  end

  # Processador de comando
  defp processar_comando(entrada, contatos) do
    cond do
      entrada == "exit" ->
        IO.puts("Até logo!")
        System.halt(0)

      String.starts_with?(entrada, "list") ->
        exibir_todos(contatos)
        fazer_loop(contatos)

      String.starts_with?(entrada, "show ") ->
        [_, id_texto] = String.split(entrada, " ", parts: 2)
        id = String.to_integer(id_texto)
        contato = Contacts.encontrar(contatos, id)

        case contato do
          nil -> IO.puts("Contato não encontrado")
          _ -> exibir_contato(contato)
        end

        fazer_loop(contatos)

      String.starts_with?(entrada, "add") ->
        rest = String.replace_prefix(entrada, "add", "") |> String.trim()

        flags = parse_flags(rest)

        novo_contato =
          if map_size(flags) > 0 do
            criar_contato_com_flags(flags)
          else
            criar_contato_interativo()
          end

        contatos_atualizados = contatos ++ [novo_contato]
        Store.salvar_contatos(contatos_atualizados)
        IO.puts("Contato adicionado com sucesso!")
        fazer_loop(contatos_atualizados)

      String.starts_with?(entrada, "edit ") ->
        [_, resto] = String.split(entrada, " ", parts: 2)
        [id_texto | tail] = String.split(resto, " ", parts: 2)
        id = String.to_integer(id_texto)
        flag_str = if tail == [], do: "", else: List.first(tail)

        flags = parse_flags(flag_str)

        contatos_atualizados = Contacts.editar(contatos, id, flags)
        Store.salvar_contatos(contatos_atualizados)
        IO.puts("Contato atualizado!")
        fazer_loop(contatos_atualizados)

      String.starts_with?(entrada, "del ") ->
        [_, id_texto] = String.split(entrada, " ", parts: 2)
        id = String.to_integer(id_texto)
        contatos_atualizados = Contacts.deletar(contatos, id)
        Store.salvar_contatos(contatos_atualizados)
        IO.puts("Contato deletado!")
        fazer_loop(contatos_atualizados)

      String.starts_with?(entrada, "search") ->
        rest = String.replace_prefix(entrada, "search", "") |> String.trim()
        case parse_search(rest) do
          {:ok, parse_tuple} ->
            resultados = Contacts.buscar(contatos, parse_tuple)
            exibir_resultados(resultados)

          :no_flags ->
            # busca por termo simples (sem flags)
            resultados = Contacts.buscar(contatos, rest)
            exibir_resultados(resultados)
        end

        fazer_loop(contatos)

      true ->
        IO.puts("Comando inválido!")
        fazer_loop(contatos)
    end
  end

  # Funções auxiliares para criar contato
  defp criar_contato_interativo do
    nome = IO.gets("Nome: ") |> String.trim()
    empresa = IO.gets("Empresa: ") |> String.trim()
    telefone = IO.gets("Telefone: ") |> String.trim()
    email = IO.gets("Email: ") |> String.trim()

    %{
      "id" => System.system_time(:millisecond),
      "name" => nome,
      "company" => empresa,
      "phone" => telefone,
      "email" => email
    }
  end

  defp criar_contato_com_flags(flags) do
    %{
      "id" => System.system_time(:millisecond),
      "name" => Map.get(flags, "name", ""),
      "company" => Map.get(flags, "company", ""),
      "phone" => Map.get(flags, "phone", ""),
      "email" => Map.get(flags, "email", "")
    }
  end

  # Exibir um contato
  defp exibir_contato(contato) do
    IO.puts("")
    IO.puts("ID: #{contato["id"]}")
    IO.puts("Nome: #{contato["name"]}")
    IO.puts("Empresa: #{contato["company"]}")
    IO.puts("Telefone: #{contato["phone"]}")
    IO.puts("Email: #{contato["email"]}")
    # metadata não exibida (removida por segurança)
    IO.puts("")
  end

  # Parse flags simples no formato --key value
  defp parse_flags(""), do: %{}

  defp parse_flags(str) do
    regex = ~r/--(\w+)\s+"([^"]+)"|--(\w+)\s+(\S+)/

    Regex.scan(regex, str)
    |> Enum.reduce(%{}, fn
      [_, key, val, _, _], acc when key != nil -> Map.put(acc, key, val)
      [_, _, _, key2, val2], acc -> Map.put(acc, key2, val2)
      _, acc -> acc
    end)
  end

  # parse_search retorna uma tupla com tipo e valor sem gravar arquivos
  defp parse_search(rest) do
    flags = parse_flags(rest)

    cond do
      Map.has_key?(flags, "name") -> {:ok, {:name, flags["name"]}}
      Map.has_key?(flags, "phone") -> {:ok, {:phone, flags["phone"]}}
      Map.has_key?(flags, "email") -> {:ok, {:email, flags["email"]}}
      true -> :no_flags
    end
  end

  # Exibir todos os contatos
  defp exibir_todos([]) do
    IO.puts("Nenhum contato cadastrado")
  end

  defp exibir_todos(contatos) do
    IO.puts("")
    IO.puts("=== LISTA DE CONTATOS ===")

    Enum.each(contatos, fn contato ->
      IO.puts("#{contato["id"]} - #{contato["nome"]} (#{contato["empresa"]})")
    end)

    IO.puts("")
  end

  # Exibir resultados de busca
  defp exibir_resultados([]) do
    IO.puts("Nenhum resultado encontrado")
  end

  defp exibir_resultados(resultados) do
    IO.puts("")
    IO.puts("=== RESULTADOS ===")

    Enum.each(resultados, fn contato ->
      IO.puts("#{contato["id"]} - #{contato["nome"]} (#{contato["email"]})")
    end)

    IO.puts("")
  end
end