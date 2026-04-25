defmodule PlantDevice.TempReporter  do
  use GenServer
  alias PhoenixClient.{Socket, Channel}

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
  socket_opts = [url: "ws://192.168.1.134:4000/socket/websocket"]
  {:ok, socket} = Socket.start_link(socket_opts)

  # Check if we can join now, otherwise retry in 5s
  case Channel.join(socket, "device:temp") do
    {:ok, _resp, channel} ->
      send(self(), :report)
      {:ok, %{channel: channel, socket: socket}}

    _error ->
      # Server or WiFi isn't ready. Wait 5s and try again.
      Process.send_after(self(), :retry_join, 5000)
      {:ok, %{channel: nil, socket: socket}}
  end
end

# Add this handler to perform the retry
def handle_info(:retry_join, state) do
  case Channel.join(state.socket, "device:temp") do
    {:ok, _resp, channel} ->
      send(self(), :report) # Start the reporting loop now
      {:noreply, %{state | channel: channel}}
    _error ->
      Process.send_after(self(), :retry_join, 5000)
      {:noreply, state}
  end
end
  # def init(_) do
  #   socket_opts = [
  #      url: "ws://192.168.1.134:4000/socket/websocket",
  #      reconnect: true
  #   ]

  #   #Connecting here
  #   {:ok, socket} = Socket.start_link(socket_opts)

  #   #Joining device:temp channel
  #   {:ok, _response, channel} = Channel.join(socket, "device:temp")

  #   #Begin reporting loop
  #   send(self(), :report)
  #   {:ok, %{channel: channel}}
  # end

  def handle_info(:report, state) do
    #processing self-sent report, sending new temp
    current_temp = PlantDevice.get_temp_f()
    Channel.push_async(state.channel, "report_temp", %{temp: current_temp})

    #wait 5 seconds and send again
    Process.send_after(self(), :report, 5000)
    {:noreply, state}
  end
end
