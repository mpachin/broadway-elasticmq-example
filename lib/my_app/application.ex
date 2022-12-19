defmodule MyApp.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      :my_app
      |> Application.fetch_env(:broadway_module)
      |> case do
        {_, _} = broadway_module -> [{broadway_module, []}]
        _ -> []
      end

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
