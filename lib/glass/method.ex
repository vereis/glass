defmodule Glass.Method do
  @moduledoc """
  Behavior for implementing custom handling of proxying of functions in `Glass` proxies.

  Currently, only the `handle_proxy/3` callback is required to be implemented.
  No other callbacks can be implemented at this time.

  When a function on a `Glass` proxy is called, the proxied module name, function being executed,
  and arguments provided are passed to the `handle_proxy/3` callback.

  Any return value from the callback will be returned as the result of the function call on the proxy.

  For more concrete examples, see the provided modules under the `Glass.Methods` namespace.
  """

  @callback handle_proxy(module :: module(), function :: atom(), args :: [any()] | []) :: any()
end
