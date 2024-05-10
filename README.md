# Glass

Glass is a small library which provides a way to _transparently_ proxy function calls
in a pluggable fashion.

## Installation

Add `:glass` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:glass, "~> 0.1.0"}
  ]
end
```

## About

This is immediately useful if you're working with multiple applications potentially deployed
in different releases/environments but need to call functions between them.

Usually, you could do this via the built-in `:rpc` or `:erpc` modules (amongst others), but
this requires ceremony and boilerplate to set up and maintain.

Glass aims to live up to its name, and the idea that the BEAM is network-transparent, by
completely hiding the fact that you're _not just calling a local function_.

## Usage

Once installed, you can use `Glass` as simply as adding the following to your code:

```elixir
# 1) Setup and initialize `Glass`
use Glass

# 2) Define a `GlassProxy` for the target module, which for this example, we can
#    imagine is in another Elixir application which is bundled in the same umbrella
#    project as the current application, but is *released separately* in a production
#    environment so *we can't directly call functions in it*.
defglass ReportService, via: Glass.Methods.RPC

# 3) Be blown away by `Glass` letting you call these functions directly...
def accounts_receivable_report do
  current_user()
  |> MyApp.Accounting.accounts_receivable()
  |> ReportService.to_excel!()
end
```

## Configuration

Glass is designed to be pluggable and extensible, and comes with a few built-in methods
for proxying function calls between modules.

### Built-in Methods

- `Glass.Methods.Apply` (default): Useful for prototyping locally, this method simply
  calls the target function directly in the target module via `Kernel.apply/3`.
- `Glass.Methods.RPC`: This method uses `:rpc` to call the target function in the target
  module. The node the rpc call is executed on is currently limited to a random node in
  the cluster (`:erlang.nodes()`), but this may be configurable in the future.

### Custom Methods

You can also define your own method for proxying function calls by implementing the
`Glass.Method` behaviour. If you want to customize the way `Glass` proxies function calls,
you can define your own module and pass it as the `:via` option to `defglass`.

```elixir
defmodule MyApp.Tupleize do
  @behaviour Glass.Method

  @impl Glass.Method
  def handle_proxy(module, function, args) do
    {module, function, args}
  end
end

defmodule MyApp.Users do
  use Glass

  defglass ReportService, via: MyApp.Tupleize

  ...

  def users_report do
    current_org()
    |> list_users()
    |> Enum.map(&build_report_rows/1)
    |> ReportService.to_csv!()
  end
end

iex(1)> MyApp.Users.users_report()
{ReportService, :to_csv!, [ ... ]}
```

### Additional Configuration

- `:private` (default: `true`): Whether or not to generate the proxy module as private.
  This is useful if you want to prevent direct access to the proxy module and force all
  calls to go through `Glass`. Mainly affects tab-completion in IEx.

- `:debug` (default: `false`): Whether or not to generate debug information when proxying
  function calls. This is useful for debugging and tracing calls between modules.

## Caveats

- **Magic**: This is a _very_ magical library and should be used with caution. It's designed
  to be a _transparent_ proxy, but this means that it can be difficult to debug when things
  go wrong. Use with caution and test thoroughly.

- **Performance**: The easier it is to write network-transparent code, the easier it is to
  write _slow_ network-transparent code.

  Be mindful of the performance implications of calling functions between modules in this way
  as depending on the `:via` method used, there may be a non-trivial serialization-deserialization
  overhead, or limitations on how much data can be sent between nodes before issues arise.

- **Security**: This library is designed to be used in a trusted environment where you have
  control over the nodes in the cluster.

  It's not designed to be used in a hostile environment where you need to worry about malicious
  actors. Be mindful of the security implications of calling functions between modules in this way.

  You can mitigate some of these concerns by using the `:via` option to define your own
  method for proxying function calls with additional security checks, but this is left as
  an exercise to the reader.

## Future Work

- **Anonymous via functions**: Allow for anonymous functions to be passed as the `:via` option
  to `defglass` to allow for more flexible proxying of function calls.

- **Customizable debug output**: Allow for custom debug output to be generated when proxying
  function calls.

- **Customizable error handling**: Allow for custom error handling to be defined when proxying
  function calls.

- **Telemetry integration**: Allow for `Telemetry` events to be emitted when proxying function
  calls to allow for better observability of function calls between modules.

- **Testing utilities**: Allow for easier testing of `Glass`-proxied functions by providing
  utilities to mock out the `Glass` proxying mechanism.

## License

`Glass` is released under the MIT License. See the [LICENSE](LICENSE) file for more information.
