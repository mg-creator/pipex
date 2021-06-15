defmodule Pipeline.Processor do
  @moduledoc false

  use GenServer

  require Logger

  def start_link(_args), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  @impl true
  def init(state) do
    Logger.info("Pipeline.Processor init")
    {:ok, state}
  end

  def async_process(events), do: GenServer.cast(__MODULE__, {:process, events})

  @impl true
  def handle_cast({:process, events}, state) when is_list(events) do
    new_tasks =
      Enum.map(events, fn event ->
        %Task{ref: ref} = Task.async(fn -> process(event) end)
        {ref, event}
      end)
      |> Enum.into(%{})

    {:noreply, Map.merge(state, new_tasks)}
  end

  @impl true
  def handle_cast({:process, event}, state) do
    %Task{ref: ref} = Task.async(fn -> process(event) end)

    {:noreply, Map.put(state, ref, event)}
  end

  @impl true
  def handle_info({ref, _res}, state), do: {:noreply, Map.delete(state, ref)}

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, :normal}, state),
    do: {:noreply, Map.delete(state, ref)}

  defp process(event) do
    Logger.info("Subtask is processing event #{event}")

    latency = Enum.random(50..300)
    Process.sleep(latency)

    Logger.info("Subtask took #{latency}ms to process #{event}")
  end
end
