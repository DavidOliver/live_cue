defmodule LiveCue.Player do
  alias LiveCue.Collection

  def cue_album(%{album_type: album_type, album_id: album_id, action: action}) do
    album_relative_path =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> List.first()
      |> Map.get(:relative_path)
      |> String.reverse()
      |> String.split("/", [parts: 2])
      |> List.last()
      |> String.reverse()

    :ok = cue(album_relative_path, action)
  end

  def cue_track(%{album_type: album_type, album_id: album_id, track_number: track_number, action: action}) do
    track_relative_path =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> Enum.find(&(&1.number == track_number))
      |> Map.get(:relative_path)

    :ok = cue(track_relative_path, action)
  end

  def stop(), do: :ok = cmus_remote([["--stop"]])

  def pause_resume(), do: :ok = cmus_remote([["--pause"]])

  defp cue(relative_path, "play") do
    :ok = cmus_remote([
      ["--stop"],
      ["--queue", "--clear"],
      ["--queue", get_absolute_path(relative_path)]
    ])

    # Give cmus some time to add track(s)
    Process.sleep(500)

    :ok = cmus_remote([["--next"], ["--play"]])
  end

  defp cue(relative_path, "append") do
    :ok = cmus_remote([
      ["--queue", get_absolute_path(relative_path)]
    ])
  end

  defp get_absolute_path(relative_path) do
    :live_cue
    |> Application.fetch_env!(:collection_directory)
    |> Path.join(relative_path)
  end

  defp cmus_remote(commands) when is_list(commands) do
    Enum.each(commands, fn cmd_args ->
      {_, 0} = System.cmd("cmus-remote", cmd_args)
    end)

    :ok
  end
end
