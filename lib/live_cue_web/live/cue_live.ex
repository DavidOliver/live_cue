defmodule LiveCueWeb.CueLive do
  use LiveCueWeb, :live_view
  alias LiveCue.Collection

  @impl true
  def mount(_params, _session, socket) do
    index = Collection.get_index()
    {:ok, assign(socket, :index, index)}
  end
end
