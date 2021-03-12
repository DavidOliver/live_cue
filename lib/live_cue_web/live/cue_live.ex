defmodule LiveCueWeb.CueLive do
  use LiveCueWeb, :live_view
  alias LiveCue.Collection
  alias LiveCueWeb.AlbumComponent

  @impl true
  def mount(_params, _session, socket) do
    index = Collection.get_index()
    {:ok, assign(socket, :index, index)}
  end
end
