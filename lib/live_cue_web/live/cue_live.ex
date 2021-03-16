defmodule LiveCueWeb.CueLive do
  use LiveCueWeb, :live_view
  alias LiveCue.{Collection, Player}
  alias LiveCueWeb.{Endpoint, AlbumComponent}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Endpoint.subscribe("player")
    end

    index = Collection.get_index()

    socket =
      socket
      |> assign(:index, index)
      |> assign(:track_started_playing, nil)
    {:ok, socket}
  end

  @impl true
  def handle_event("index_collection", _params, socket) do
    Task.start(Collection, :store_collection_data, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("play", %{"album-id" => album_id, "album-type" => album_type, "track-number" => track_number}, socket) do
    payload = %{
      album_id: album_id,
      album_type: album_type,
      track_number: String.to_integer(track_number)
    }
    Endpoint.broadcast("player", "start_playing_track", payload)

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _params, socket) do
    System.cmd("cmus-remote", ["--stop"])

    {:noreply, socket}
  end

  @impl true
  def handle_event("pause_resume", _params, socket) do
    System.cmd("cmus-remote", ["--pause"])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "start_playing_track", payload: payload}, socket) do
    {:ok, title} = Player.play_track(payload)

    {:noreply, assign(socket, :track_started_playing, title)}
  end
end
