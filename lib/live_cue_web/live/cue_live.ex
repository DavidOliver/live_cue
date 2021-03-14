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

  @impl true
  def handle_event("play", %{"album-id" => album_id, "album-type" => album_type, "track-number" => track_number}, socket) do
    collection_directory = Application.fetch_env!(:live_cue, :collection_directory)
    track_relative_path =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> Enum.find(&(&1.number == String.to_integer(track_number)))
      |> Map.get(:relative_path)
    track_path = Path.join(collection_directory, track_relative_path)

    System.cmd("cmus-remote", ["--stop"])
    System.cmd("cmus-remote", ["--clear", "--queue"])
    System.cmd("cmus-remote", ["--queue", track_path])
    System.cmd("cmus-remote", ["--next"])
    System.cmd("cmus-remote", ["--play"])

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
end
