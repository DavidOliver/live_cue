defmodule LiveCueWeb.CueLive do
  use LiveCueWeb, :live_view
  alias LiveCue.Collection
  alias LiveCueWeb.AlbumComponent

  @impl true
  def mount(_params, _session, socket) do
    index = Collection.get_index()
    {:ok, assign(socket, :index, index)}
  end

  @impl true
  def handle_event("index_collection", _params, socket) do
    Task.start(Collection, :store_collection_data, [])

    {:noreply, socket}
  end
end
