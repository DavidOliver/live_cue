defmodule LiveCueWeb.AlbumComponent do
  use LiveCueWeb, :live_component
  alias LiveCue.Collection

  @impl true
  def handle_event("expand", %{"type" => type, "id" => id}, socket) do
    album =
      case socket.assigns.album do
        nil -> Collection.get_album(type, id)
        _ -> nil
      end

    {:noreply, assign(socket, :album, album)}
  end
end
