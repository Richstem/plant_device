defmodule PlantDevice.PumpWater do
  alias Circuits.{GPIO}

  def pump_seconds(pin_number, duration) do
    {:ok, gpio} = GPIO.open(pin_number, :output, initial_value: 0) #start with it off
    GPIO.write(gpio, 1)                 # start pumping
    Process.sleep(duration * 1000)     # wait
    GPIO.write(gpio, 0)                 # stop
    GPIO.close(gpio)                     #let's close it here
    :ok
  end

end
