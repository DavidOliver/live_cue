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
  def handle_event("play_album", %{"album-type" => album_type, "album-id" => album_id}, socket) do
    payload = %{
      album_id: album_id,
      album_type: album_type
    }
    Endpoint.broadcast("player", "album_play_request", payload)

    {:noreply, socket}
  end

  @impl true
  def handle_event("play_track", %{"album-type" => album_type, "album-id" => album_id, "track-number" => track_number}, socket) do
    payload = %{
      album_id: album_id,
      album_type: album_type,
      track_number: String.to_integer(track_number)
    }
    Endpoint.broadcast("player", "track_play_request", payload)

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
  def handle_info(%{topic: "player", event: "album_play_request", payload: payload}, socket) do
    Player.play_album(payload)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "track_play_request", payload: payload}, socket) do
    Player.play_track(payload)

    {:noreply, socket}
  end
end
