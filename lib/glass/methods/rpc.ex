defmodule Glass.Methods.RPC do
  @moduledoc """
  This module is a `Glass.Method` implementation that uses `:rpc` to call functions.

  This is useful for calling functions on remote nodes transparently via `Glass` proxies.

  Note that the node to call the function on is chosen randomly from the list of nodes available
  in your Erlang cluster. If you need more control over which node to call, you should implement
  your own `Glass.Method` module based on this one and use that instead.

  > #### Warning {: .warning}
  > By default, `:rpc` calls allow for remote calling of *any* function, in *any* module, > on the
  > remote node. This can be a security risk if you are not careful.
  >
  > If you need to restrict the functions that can be called remotely, you should implement your own
  > `Glass.Method` module based on this one and use that instead, making sure to implement your own
  > security checks as needed.
  """

  @behaviour Glass.Method

  @impl Glass.Method
  def handle_proxy(module, function, args) do
    :erlang.nodes()
    |> Enum.concat([node()])
    |> Enum.random()
    |> :rpc.call(module, function, args)
  end
end
