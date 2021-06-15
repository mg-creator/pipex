defmodule Pipeline.RateLimiter do
  @moduledoc false

  use GenStage

  require Logger

  def start_link(_args) do
    initial_state = %{}
    GenStage.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    Logger.info("Pipeline.RateLimiter init")
    sub_opts = [{Pipeline.Producer, min_demand: 0, max_demand: 3}]
    {:consumer, initial_state, subscribe_to: sub_opts}
  end

  def pull(), do: GenStage.cast(__MODULE__, :ask)

  def handle_subscribe(:producer, opts, from, producers) do
    pending = opts[:max_demand] || 1000
    interval = opts[:interval] || 5000

    # Register the producer in the state
    producers = Map.put(producers, from, {pending, interval})
    # Ask for the pending events and schedule the next time around
    producers = ask_and_schedule(producers, from)

    # Returns manual as we want control over the demand
    {:manual, producers}
  end

  def handle_cancel(_, from, producers) do
    # Remove the producers from the map on unsubscribe
    {:noreply, [], Map.delete(producers, from)}
  end

  def handle_events(events, from, producers) do
    Logger.info("Pipeline.RateLimiter received: #{events}")

    # Bump the amount of pending events for the given producer
    producers =
      Map.update!(producers, from, fn {pending, interval} ->
        {pending + length(events), interval}
      end)

    # Consume the events.
    Pipeline.Processor.async_process(events)

    {:noreply, [], producers}
  end

  def handle_info({:ask, from}, producers), do: {:noreply, [], ask_and_schedule(producers, from)}

  defp ask_and_schedule(producers, from) do
    Logger.info("Pipeline.RateLimiter is asking for new events")

    case producers do
      %{^from => {pending, interval}} ->
        # Ask for any pending events
        GenStage.ask(from, pending)
        # And let's check again after interval
        Process.send_after(self(), {:ask, from}, interval)
        # Finally, reset pending events to 0
        Map.put(producers, from, {0, interval})

      %{} ->
        producers
    end
  end
end
