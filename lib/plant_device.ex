defmodule PlantDevice do
  @moduledoc """
  Documentation for `PlantDevice`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> PlantDevice.hello()
      :world

  """
  def hello do
    :world
  end

  def get_temp do
    case File.read("/sys/devices/virtual/thermal/thermal_zone0/temp") do
    {:ok, content} ->
      content
      |> String.trim()
      |> String.to_integer()
      |> Kernel.div(1000)

    {:error, reason} ->
      {:error, reason}
    end
  end

  def get_temp_f do
    case get_temp() do
      temp_c when is_integer(temp_c) ->
        (temp_c * 9/5 + 32)
        |> Float.round(2)
        |> Float.to_string()
        |> Kernel.<>(" F")
      {:error, _} = error -> error    #pass the error along if it errors out.
    end
  end
end
