defmodule LiveCue.Player do
  alias LiveCue.Collection

  def play_track(%{album_id: album_id, album_type: album_type, track_number: track_number}) do
    collection_directory = Application.fetch_env!(:live_cue, :collection_directory)
    track =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> Enum.find(&(&1.number == track_number))

    track_path = Path.join(collection_directory, Map.get(track, :relative_path))

    System.cmd("cmus-remote", ["--stop"])
    System.cmd("cmus-remote", ["--clear", "--queue"])
    System.cmd("cmus-remote", ["--queue", track_path])
    System.cmd("cmus-remote", ["--next"])
    System.cmd("cmus-remote", ["--play"])

    {:ok, Map.get(track, :title)}
  end
end
