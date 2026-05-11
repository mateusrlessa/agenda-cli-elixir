defmodule AgendaCli.Store do
  @moduledoc """
  Persistência de contatos em JSON.
  """

  @arquivo "contacts.json"

  # Carrega contatos do arquivo JSON
  def carregar_contatos do
    case File.read(@arquivo) do
      {:ok, conteudo} ->
        case Jason.decode(conteudo) do
          {:ok, dados} -> dados
          _ -> []
        end

      {:error, :enoent} ->
        []
    end
  end

  # Salva contatos no arquivo JSON
  def salvar_contatos(contatos) do
    case Jason.encode(contatos, pretty: true) do
      {:ok, json} ->
        File.write(@arquivo, json)

      {:error, _} ->
        :erro
    end
  end

  # Aliases para nomes esperados (load/save)
  def load(), do: carregar_contatos()
  def save(contatos), do: salvar_contatos(contatos)
end