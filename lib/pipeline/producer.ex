defmodule Pipeline.Producer do
  @moduledoc false

  use GenStage
  require Logger

  def start_link(_args) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("Pipeline.Producer init")
    {:producer, initial_state}
  end

  def add_event(event), do: GenStage.cast(__MODULE__, {:add_event, event})

  def handle_demand(demand, state) do
    Logger.info("Pipeline.Producer received demand for #{demand}")
    events = []
    {:noreply, events, state}
  end

  def handle_cast({:add_event, event}, state) do
    {:noreply, [event], state}
  end
end
