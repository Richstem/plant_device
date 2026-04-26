defmodule PlantDevice.SoilStats do
  alias Circuits.{I2C}


  def get_soil_temp_f() do
    with {:ok, i2c} <- I2C.open("i2c-1"),
    :ok <- I2C.write(i2c, 0x36, <<0x00, 0x04>>),  #0x00 is status module, 0x04 is Temp function
    _ <- Process.sleep(2),
    {:ok, <<soil_temp::signed-big-size(32)>>} <- I2C.read(i2c, 0x36, 4) do
      tempf = Float.round((soil_temp / 65536 * (9/5) + 32), 1)
      tempf
      |> Float.to_string()
      |> Kernel.<>(" F")
    else
      _error -> "Failed to get soil temp. Check wiring."
    end
  end

  def get_moisture_reading() do
    with {:ok, i2c} <- I2C.open("i2c-1"),

    #we have to write to the bus first and wait to read.
    #binary 0x0F is touch base (bc it's capacitive device)
    #binary 0x10 is the function to prep for te return data
    :ok <- I2C.write(i2c, 0x36, <<0x0F, 0x10>>),

    #sleep to give device time to respond
    _ <- Process.sleep(5),

    #convert binary response to moisture reading
    {:ok, <<moisture::unsigned-big-size(16)>>} <- I2C.read(i2c, 0x36, 2) do
      moisture

    else
      _error -> "Moisture sensor reading failed. Check wiring."
    end
  end
end
