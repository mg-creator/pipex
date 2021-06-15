defmodule Pipeline do
  @moduledoc false

  defdelegate add_event(event), to: Pipeline.Producer

  def add_events(amount) do
    for x <- 0..amount do
      x
      |> Integer.to_string()
      |> add_event()
    end
  end
end
