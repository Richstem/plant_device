defmodule PlantDeviceTest do
  use ExUnit.Case
  doctest PlantDevice

  test "greets the world" do
    assert PlantDevice.hello() == :world
  end
end
