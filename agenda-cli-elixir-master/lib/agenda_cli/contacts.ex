defmodule AgendaCli.Contacts do
  @moduledoc """
  Funções para manipular contatos.
  """

  # Encontra um contato pelo ID
  def encontrar(contatos, id) do
    Enum.find(contatos, fn c -> c["id"] == id end)
  end

  # Busca contatos por termo
  def buscar(contatos, termo) when is_binary(termo) do
    termo_lower = String.downcase(termo)

    Enum.filter(contatos, fn contato ->
      nome_lower = String.downcase(contato["name"] || "")
      email_lower = String.downcase(contato["email"] || "")
      telefone_lower = String.downcase(contato["phone"] || "")

      String.contains?(nome_lower, termo_lower) or
        String.contains?(email_lower, termo_lower) or
        String.contains?(telefone_lower, termo_lower)
    end)
  end

  def buscar(contatos, {:name, valor}) do
    termo_lower = String.downcase(valor)

    Enum.filter(contatos, fn contato ->
      String.contains?(String.downcase(contato["name"] || ""), termo_lower)
    end)
  end

  def buscar(contatos, {:phone, valor}) do
    termo_lower = String.downcase(valor)

    Enum.filter(contatos, fn contato ->
      String.contains?(String.downcase(contato["phone"] || ""), termo_lower)
    end)
  end

  def buscar(contatos, {:email, valor}) do
    termo_lower = String.downcase(valor)

    Enum.filter(contatos, fn contato ->
      String.contains?(String.downcase(contato["email"] || ""), termo_lower)
    end)
  end

  # Edita um contato existente
  def editar(contatos, id, flags \\ %{}) do
    contato = encontrar(contatos, id)

    case contato do
      nil ->
        contatos

      _ ->
        # se vieram flags, aplicá-las; caso contrário, pedir interativo
        nome_final = if Map.has_key?(flags, "name"), do: flags["name"], else: IO.gets("Novo nome (#{contato["name"]}): ") |> String.trim()
        company_final = if Map.has_key?(flags, "company"), do: flags["company"], else: contato["company"]
        email_final = if Map.has_key?(flags, "email"), do: flags["email"], else: IO.gets("Novo email (#{contato["email"]}): ") |> String.trim()
        phone_final = if Map.has_key?(flags, "phone"), do: flags["phone"], else: IO.gets("Novo telefone (#{contato["phone"]}): ") |> String.trim()

        # se entradas vazias vindas do gets, manter original
        nome_final = if nome_final == "", do: contato["name"], else: nome_final
        email_final = if email_final == "", do: contato["email"], else: email_final
        phone_final = if phone_final == "", do: contato["phone"], else: phone_final

        contato_atualizado = %{
          "id" => contato["id"],
          "name" => nome_final,
          "company" => company_final || contato["company"],
          "phone" => phone_final,
          "email" => email_final
        }

        Enum.map(contatos, fn c ->
          if c["id"] == id, do: contato_atualizado, else: c
        end)
    end
  end

  # Deleta um contato
  def deletar(contatos, id) do
    Enum.filter(contatos, fn c -> c["id"] != id end)
  end
end