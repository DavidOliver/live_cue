defmodule LiveCueWeb.CueLive do
  use LiveCueWeb, :live_view
  alias LiveCue.{Collection, Player}
  alias LiveCueWeb.{Endpoint, AlbumComponent}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Endpoint.subscribe("player")

    socket =
      socket
      |> assign(:index, Collection.get_index())
      |> assign(:track_started_playing, nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("index_collection", _params, socket) do
    Task.start(Collection, :store_collection_data, [])

    {:noreply, socket}
  end

  @impl true
  def handle_event("cue_album", params, socket) do
    Endpoint.broadcast("player", "request_album_cue", %{
      album_id: Map.fetch!(params, "album-id"),
      album_type: Map.fetch!(params, "album-type"),
      action: Map.fetch!(params, "action"),
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("cue_track", params, socket) do
    Endpoint.broadcast("player", "request_track_cue", %{
      album_id: Map.fetch!(params, "album-id"),
      album_type: Map.fetch!(params, "album-type"),
      track_number: params |> Map.fetch!("track-number") |> String.to_integer(),
      action: Map.fetch!(params, "action"),
    })

    {:noreply, socket}
  end

  @impl true
  def handle_event("stop", _params, socket) do
    Endpoint.broadcast("player", "request_stop", nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("pause_resume", _params, socket) do
    Endpoint.broadcast("player", "request_pause_resume", nil)

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "request_album_cue", payload: payload}, socket) do
    Task.start(Player, :cue_album, [payload])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "request_track_cue", payload: payload}, socket) do
    Task.start(Player, :cue_track, [payload])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "request_stop"}, socket) do
    Task.start(Player, :stop, [])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{topic: "player", event: "request_pause_resume"}, socket) do
    Task.start(Player, :pause_resume, [])

    {:noreply, socket}
  end
end
