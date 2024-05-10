defmodule GlassTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  describe "defglass/2" do
    test "will proxy the specified module" do
      Code.eval_string("""
        defmodule MyApp.Users1 do
          use Glass

          defglass Enum, via: Glass.Methods.RPC, private: false

          def display_name(%{first_name: first_name, last_name: last_name}) do
            Enum.join([first_name, last_name], " ")
          end
        end
      """)

      # A proxy was created
      assert Code.loaded?(MyApp.Users1.Glasses.Enum)

      # Proxy was successfully executed
      assert apply(MyApp.Users1, :display_name, [%{first_name: "John", last_name: "Doe"}]) ==
               "John Doe"
    end

    test "emits debug information when debug is enabled" do
      Code.eval_string("""
        defmodule MyApp.Users2 do
          use Glass

          defglass Enum, via: Glass.Methods.RPC, private: false, debug: true

          def display_name(%{first_name: first_name, last_name: last_name}) do
            Enum.join([first_name, last_name], " ")
          end
        end
      """)

      # A proxy was created
      assert Code.loaded?(MyApp.Users2.Glasses.Enum)

      # Proxy was successfully executed
      assert log =
               capture_log([level: :debug], fn ->
                 apply(MyApp.Users2, :display_name, [%{first_name: "John", last_name: "Doe"}])
               end)

      # Contains call being proxied
      assert log =~ "Proxying call to `Enum.join/2`"

      # Contains arguments being passed
      assert log =~ "[\"John\", \"Doe\"]"

      # Contains the proxy module created
      assert log =~ "`MyApp.Users2.Glasses.Enum`"

      # Contains the method being used for proxying
      assert log =~ "`Glass.Methods.RPC`"
    end
  end
end
