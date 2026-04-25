defmodule PlantDeviceTest do
  use ExUnit.Case
  doctest PlantDevice

  test "greets the world" do
    assert PlantDevice.hello() == :world
  end

  test "get the integer temp" do
    assert is_integer(PlantDevice.get_temp())
  end
end
