defmodule GlassTest do
  use ExUnit.Case
  doctest Glass

  test "greets the world" do
    assert Glass.hello() == :world
  end
end
