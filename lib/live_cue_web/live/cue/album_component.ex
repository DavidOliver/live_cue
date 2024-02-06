defmodule LiveCueWeb.AlbumComponent do
  use LiveCueWeb, :live_component
  alias LiveCue.Collection

  @impl true
  def handle_event("expand", %{"type" => type, "id" => id}, socket) do
    album = case socket.assigns.album do
      %{tracks: tracks} when tracks == [] -> Collection.get_album(type, id)
      _ -> socket.assigns.album |> Map.replace(:tracks, [])
    end

    {:noreply, assign(socket, :album, album)}
  end
end
