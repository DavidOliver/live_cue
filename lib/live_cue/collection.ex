defmodule LiveCue.Collection do
  # @extensions ["flac", "mp3"]
  @extensions ["flac"]
  @starting_map [single: %{}, various: %{}]

  def store_collection_data() do
    files_processed = process_dir(Application.fetch_env!(:live_cue, :collection_directory))

    collection_data =
      files_processed
      |> Enum.reduce(@starting_map, &restructure_with_tracks/2)
      |> Enum.map(&reorder/1)
      |> Enum.reduce([], &key_for_storage/2)
      |> List.flatten()

    index =
      files_processed
      |> Enum.reduce(@starting_map, &restructure_for_index/2)
      |> Enum.map(&reorder/1)

    :ok = CubDB.put_multi(LiveCue.DB, collection_data)
    :ok = CubDB.put(LiveCue.DB, :collection_index, index)

    :ok
  end

  defp reorder({:single, artists}) do
    artists_sorted =
      artists
      |> Enum.sort_by(&(elem(&1, 0)))
      |> Enum.map(&sort_single_artist_albums/1)

    {:single, artists_sorted}
  end

  defp reorder({:various, albums}) do
    albums_sorted =
      albums
      |> Enum.sort_by(&(&1 |> elem(1) |> Map.get(:date)))
      |> Enum.map(&sort_tracks/1)

    {:various, albums_sorted}
  end

  defp sort_single_artist_albums({artist_name, artist_albums}) do
    artist_albums_sorted =
      artist_albums
      |> Enum.sort_by(&{&1 |> elem(1) |> Map.get(:date), &1 |> elem(1) |> Map.get(:name)})
      |> Enum.map(&sort_tracks/1)

    {artist_name, artist_albums_sorted}
  end

  defp sort_tracks({album_name, album_info}) do
    album_info_sorted =
      album_info
      |> get_and_update_in([:tracks], fn tracks -> {tracks, Enum.sort_by(tracks, &elem(&1, 0))} end)
      |> elem(1)

    {album_name, album_info_sorted}
  end

  defp process_dir(dir) when is_binary(dir) do
    {:ok, files_and_dirs} = File.ls(dir)

    files_and_dirs
    |> reject_hidden()
    |> Enum.map(&process_file_or_dir(&1, dir))
    |> List.flatten()
  end

  defp process_file_or_dir(file_or_dir, parent_dir) when is_binary(file_or_dir) and is_binary(parent_dir) do
    path = Path.join(parent_dir, file_or_dir)

    cond do
      File.regular?(path) -> process_file(path)
      File.dir?(path) -> process_dir(path)
      true -> []
    end
  end

  defp process_file(path) when is_binary(path) do
    collection_directory = Application.fetch_env!(:live_cue, :collection_directory)

    with \
      true <- is_accepted_file_ext(path, @extensions),
      relative_path <- String.trim_leading(path, collection_directory <> "/"),
      meta <- read_file_meta(path)
    do
      Map.new()
      |> Map.put(:relative_path, relative_path)
      |> Map.merge(meta)
    else
      _ -> []
    end
  end

  defp read_file_meta(path) when is_binary(path) do
    read_file_meta(path, file_ext(path))
  end
  defp read_file_meta(path, "flac") do
    case FlacParser.parse(path) do
      {:ok, meta} ->
        meta
      {:error, _reason} ->
        # @TODO: Log issue
        nil
    end
  end
  defp read_file_meta(path, "mp3") when is_binary(path) do
    case File.read(path) do
      {:ok, file_content} ->
        # @TODO: deal with ID3v2 failure
        ID3v2.frames(file_content)
      {:error, _reason} ->
        # @TODO: Log issue
        nil
    end
  end

  defp is_accepted_file_ext(path, extensions) when is_binary(path) and is_list(extensions) do
    path
    |> file_ext()
    |> Kernel.in(extensions)
  end

  defp file_ext(path) when is_binary(path) do
    path
    |> String.split(".")
    |> List.last()
  end

  defp reject_hidden(files_and_dirs) when is_list(files_and_dirs) do
    Enum.reject(files_and_dirs, fn name -> String.starts_with?(name, ".") end)
  end

  defp restructure_for_index(track, acc) do
    acc
    |> add_artist(track)
    |> add_album_meta(track)
  end

  defp restructure_with_tracks(track, acc) do
    acc
    |> add_artist(track)
    |> add_album_meta(track)
    |> add_track(track)
  end

  defp add_artist(acc, track) do
    cond do
      album_is_various_artists(track) ->
        acc
      true ->
        case Kernel.get_in(acc, artist_key_path(track)) do
          nil ->
            Kernel.update_in(acc, [artist_key_prefix(track)], fn x ->
              Map.put_new(x, artist_key(track), %{})
            end)
          _ ->
            acc
        end
    end
  end

  defp add_album_meta(acc, track) do
    # @TODO: set meta based on all album’s tracks rather than album’s first track?
    artist =
      case album_is_various_artists(track) do
        true -> nil
        _ -> track[:albumartist] || track[:artist]
      end
    album_info = %{
      title: track[:album],
      artist: artist,
      date: track[:date],
      genre: track[:genre],
      tracks: []
    }
    keys = album_key_path(track)

    if !get_in(acc, keys) do
      put_in(acc, keys, album_info)
    else
      acc
    end
  end

  defp add_track(acc, track) do
    track_number =
      track[:tracknumber]
      |> String.split("/")
      |> List.first()
      |> String.to_integer()
    track_info = %{
      artist: track[:artist],
      title: track[:title],
      date: track[:date],
      genre: track[:genre],
      relative_path: track[:relative_path],
    }

    Kernel.update_in(acc, tracks_key_path(track), fn tracks ->
      tracks ++ [{track_number, track_info}]
    end)
  end

  defp album_is_various_artists(track) do
    String.starts_with?(track.relative_path, "Various/")
  end

  defp artist_key_prefix(track) do
    cond do
      album_is_various_artists(track) -> :various
      true -> :single
    end
  end

  defp artist_key(track) do
    cond do
      album_is_various_artists(track) -> []
      true -> track[:albumartist] || track[:artist]
    end
  end

  defp artist_key_path(track) do
    [artist_key_prefix(track)] ++ [artist_key(track)] |> List.flatten()
  end

  defp album_key_path(track) do
    artist_key_path(track) ++ [track[:album]] |> List.flatten()
  end

  defp tracks_key_path(track) do
    album_key_path(track) ++ [:tracks]
  end

  defp key_for_storage(type, acc) do
    # @TODO: improve comprehensions?
    # @TODO: use x_key functions?
    case elem(type, 0) do
      :various ->
        for album <- elem(type, 1) do
          album_key = {:collection, :various, elem(album, 0)}
          acc ++ [{album_key, elem(album, 1)}]
        end
      :single ->
        for artist <- elem(type, 1) do
          for album <- elem(artist, 1) do
            album_key = {:collection, :single, elem(artist, 0), elem(album, 0)}
            acc ++ [{album_key, elem(album, 1)}]
          end
        end
    end
  end
end
