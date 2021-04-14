defmodule LiveCue.Player do
  alias LiveCue.Collection

  def play_album(%{album_type: album_type, album_id: album_id}) do
    album_relative_path =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> List.first()
      |> Map.get(:relative_path)
      |> String.reverse()
      |> String.split("/", [parts: 2])
      |> List.last()
      |> String.reverse()

    :ok = play(album_relative_path)
  end

  def play_track(%{album_type: album_type, album_id: album_id, track_number: track_number}) do
    track_relative_path =
      Collection.get_album(album_type, album_id)
      |> Map.get(:tracks)
      |> Enum.find(&(&1.number == track_number))
      |> Map.get(:relative_path)

    :ok = play(track_relative_path)
  end

  def stop(), do: :ok = cmus_remote([["--stop"]])

  def pause_resume(), do: :ok = cmus_remote([["--pause"]])

  defp play(relative_path) when is_binary(relative_path) do
    absolute_path =
      Application.fetch_env!(:live_cue, :collection_directory)
      |> Path.join(relative_path)

    :ok = cmus_remote([["--stop"], ["--clear"], [absolute_path]])

    # Give cmus some time to add track(s) to its playlist
    Process.sleep(100)

    :ok = cmus_remote([["--next"], ["--play"]])
  end

  defp cmus_remote(commands) when is_list(commands) do
    Enum.each(commands, fn cmd_args ->
      {_, 0} = System.cmd("cmus-remote", cmd_args)
    end)

    :ok
  end
end
