defmodule BankingCoreTest do
  use ExUnit.Case
  doctest BankingCore

  test "greets the world" do
    assert BankingCore.hello() == :world
  end
end
