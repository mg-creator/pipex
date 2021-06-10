defmodule Pipeline do
  @moduledoc false

  defdelegate add_event(event), to: Pipeline.Producer
end
