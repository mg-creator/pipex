defmodule Pipeline.Processor do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(_args), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def init(_state) do
    Logger.info("Pipeline.Processor init")
    {:ok, []}
  end

  def async_process(event), do: GenServer.cast(__MODULE__, {:event, event})

  def handle_cast({:event, event}, state) do
    Logger.info("Start of event #{event} processing.")

    latency = Enum.random(50..300)
    Process.sleep(latency)

    Logger.info("Processing of event #{event} took #{latency}ms")

    Pipeline.Consumer.pull()

    {:noreply, state}
  end
end
