defmodule AgendaCli.Application do
  @moduledoc """
  Configuração da aplicação OTP - apenas inicialização básica
  """
  use Application

  def start(_type, _args) do
    children = []
    Supervisor.start_link(children, strategy: :one_for_one, name: AgendaCli.Supervisor)
  end
end
