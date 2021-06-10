defmodule Pipeline.Consumer do
  @moduledoc false

  use GenStage

  require Logger

  def start_link(_args) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("Pipeline.Consumer init")
    sub_opts = [{Pipeline.Producer, min_demand: 0, max_demand: 1}]
    {:consumer, initial_state, subscribe_to: sub_opts}
  end

  def pull(), do: GenStage.cast(__MODULE__, :ask)

  def handle_subscribe(:producer, _opts, subscription, _state) do
    GenStage.ask(subscription, 1)
    {:manual, %{subscription: subscription}}
  end

  def handle_cancel(_, _subscription, _state) do
    {:noreply, [], []}
  end

  def handle_events(event, _from, state) do
    Logger.info("Pipeline.Consumer received #{inspect(event)}")
    Pipeline.Processor.async_process(event)
    {:noreply, [], state}
  end

  def handle_cast(:ask, state) do
    GenStage.ask(state.subscription, 1)
    {:noreply, [], state}
  end
end
