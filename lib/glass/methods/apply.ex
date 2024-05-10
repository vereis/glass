defmodule Glass.Methods.Apply do
  @moduledoc """
  This module is a `Glass.Method` implementation that simply calls the function directly via `Kernel.apply/3`.

  > #### Note {: .info}
  > Note that this module is just a simple example. `Kernel.apply/3` cannot be used to call > functions on
  > remote nodes, so this module is only useful for local development and testing of `Glass` itself.
  """

  @behaviour Glass.Method

  @impl Glass.Method
  def handle_proxy(module, function, args) do
    apply(module, function, args)
  end
end
