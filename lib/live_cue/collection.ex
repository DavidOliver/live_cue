defmodule LiveCue.Collection do
  @starting_map %{single: %{}, various: %{}}
  # @extensions ["flac", "mp3", "m4a",]
  @extensions ["flac"]
  @flac %{
    read_bytes: 1024 * 512,
  }

  def get_index() do
    CubDB.get(LiveCue.DB, :collection_index, @starting_map)
  end

  def get_album(type, id) when is_binary(type) and is_binary(id) do
    type_key =
      case type do
        t when t in ["single", "various"] -> String.to_atom(t)
        _ -> nil
      end

    CubDB.get(LiveCue.DB, {:collection, type_key, id})
  end

  def process_collection() do
    :ok = parse_collection_files()
    :ok = store_collection_data()

    :ok
  end

  def parse_collection_files() do
    files_parsed = process_dir(Application.fetch_env!(:live_cue, :collection_directory))

    :ok = CubDB.put(LiveCue.DB, :collection_files_parsed, files_parsed)
  end

  def store_collection_data() do
    case CubDB.get(LiveCue.DB, :collection_files_parsed, nil) do
      x when is_list(x) ->
        store_collection_data(x)
      _ ->
        raise "No file data"
    end
  end

  defp store_collection_data(files_parsed) when is_list(files_parsed) do
    collection_data =
      files_parsed
      |> Enum.reduce(@starting_map, &restructure_with_tracks/2)
      |> Enum.map(&reorder/1)
      |> Enum.reduce([], &key_for_storage/2)
      |> List.flatten()
      |> Enum.into(%{})

    index =
      files_parsed
      |> Enum.reduce(@starting_map, &restructure_for_index/2)
      |> Enum.map(&reorder/1)
      |> Enum.into(%{})

    :ok = CubDB.put_multi(LiveCue.DB, collection_data)
    :ok = CubDB.put(LiveCue.DB, :collection_index, index)

    :ok
  end

  defp process_dir(dir) when is_binary(dir) do
    IO.puts "Processing: #{trim_collection_base_dir(dir)}"

    {:ok, files_and_dirs} = File.ls(dir)

    files_and_dirs
    |> Enum.reject(&String.starts_with?(&1, "."))
    |> Enum.sort_by(&(&1))
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
    with \
      true <- is_accepted_file_ext(path, @extensions),
      relative_path <- trim_collection_base_dir(path),
      {:ok, meta} <- read_file_meta(path)
    do
      Map.new()
      |> Map.put(:relative_path, relative_path)
      |> Map.merge(meta)
    else
      {:error, reason} ->
        IO.puts "PARSING ERROR: #{trim_collection_base_dir(path)}:"
        IO.inspect reason
      x ->
        if is_accepted_file_ext(path, @extensions) do
          IO.puts "PARSING FAILURE: #{trim_collection_base_dir(path)}:"
          IO.inspect x
        end
        []
    end
  end

  defp trim_collection_base_dir(path) when is_binary(path) do
    collection_directory = Application.fetch_env!(:live_cue, :collection_directory)

    String.trim_leading(path, collection_directory <> "/")
  end

  defp is_accepted_file_ext(path, extensions) when is_binary(path) and is_list(extensions) do
    path
    |> file_ext()
    |> Kernel.in(extensions)
  end

  defp read_file_meta(path) when is_binary(path) do
    read_file_meta(path, file_ext(path))
  end
  defp read_file_meta(path, "flac") when is_binary(path) do
    relative_path = trim_collection_base_dir(path)

    {:ok, file} = :file.open(path, [:read, :binary])
    {:ok, data} = :file.read(file, @flac.read_bytes)
    :file.close(file)

    try do
      parse_flac(data, relative_path)
    rescue
      _ ->
        case File.read(path) do
          {:ok, data} -> parse_flac(data, relative_path)
          x -> x
        end
    end
  end
  defp parse_flac(data, relative_path) do
    case FlacParser.parse(data) do
      {:ok, meta} ->
        clean_meta =
          meta
          |> clean_album(relative_path)
          |> clean_track_number(relative_path)
        {:ok, clean_meta}
      {:error, _reason} ->
        # @TODO: Log issue
        nil
    end
  end
  defp clean_album(meta, relative_path) do
    Map.update(meta, :album, "", fn existing ->
      case existing do
        a when is_list(a) ->
          IO.puts "MULTIPLE ALBUM TAGS (joining with ' - '): #{relative_path}"
          Enum.join(a, " - ")
        a when is_binary(a) ->
          a
        _ ->
          IO.puts "INVALID ALBUM TAG DATA (defaulting to ''): #{relative_path}"
          ""
      end
    end)
  end
  defp clean_track_number(meta, relative_path) do
    Map.update(meta, :tracknumber, nil, fn existing ->
      case existing do
        "" ->
          IO.puts "MISSING TRACK NUMBER (deriving from filename): #{relative_path}"
          relative_path |> String.split("/") |> List.last() |> String.split(";") |> List.first() |> String.to_integer()
        t when is_binary(t) ->
          t |> String.split("/") |> List.first() |> String.to_integer()
        t ->
          IO.puts "UNEXPECTED TRACK NUMBER: #{relative_path}"
          IO.inspect t
          nil
      end
    end)
  end
  # defp read_file_meta(path, "mp3") when is_binary(path) do
  #   case File.read(path) do
  #     {:ok, file_content} ->
  #       # @TODO: deal with ID3v2 failure
  #       ID3v2.frames(file_content)
  #     {:error, _reason} ->
  #       # @TODO: Log issue
  #       nil
  #   end
  # end
  # defp read_file_meta(path, "m4a") when is_binary(path) do
  # end

  defp file_ext(path) when is_binary(path), do: path |> String.split(".") |> List.last()

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
            # IO.inspect(track, [label: "Adding artist"])
            Kernel.update_in(acc, [artist_key_prefix(track)], fn x ->
              Map.put_new(x, artist_key(track), %{})
            end)
          _ ->
            acc
        end
    end
  end

  defp add_album_meta(acc, track) do
    # IO.inspect(track, [label: "Adding album meta"])
    # @TODO: set meta based on all album’s tracks rather than album’s first track?
    artist =
      case album_is_various_artists(track) do
        true -> nil
        _ -> track[:albumartist] || track[:artist]
      end
    type =
      case album_is_various_artists(track) do
        true -> "various"
        _ -> "single"
      end
    hash_source = "#{artist} #{track[:album]} #{track[:date]} #{track[:genre]}"
    hash =
      :crypto.hash(:sha256, hash_source)
      |> Base.encode16()
      |> String.downcase()
    album_info = %{
      type: type,
      id: hash,
      title: track[:album],
      artist: artist,
      date: track[:date],
      genre: track[:genre],
      tracks: []
    }
    keys = album_key_path(track)

    if !get_in(acc, keys), do: put_in(acc, keys, album_info), else: acc
  end

  defp add_track(acc, track) do
    track_info = %{
      artist: track[:artist],
      number: track[:tracknumber],
      title: track[:title],
      date: track[:date],
      genre: track[:genre],
      relative_path: track[:relative_path],
    }

    Kernel.update_in(acc, tracks_key_path(track), fn tracks ->
      tracks ++ [track_info]
    end)
  end

  defp album_is_various_artists(track), do: String.starts_with?(track.relative_path, "Various/")

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
    album_key =
      case track[:album] do
        k when is_list(k) ->
          IO.puts "#{track.relative_path}: multiple album tags; joining with ' - '"
          Enum.join(k, " - ")
        k when is_binary(k) ->
          k
        _ ->
          []
      end

    artist_key_path(track) ++ [album_key] |> List.flatten()
  end

  defp tracks_key_path(track) do
    album_key_path(track) ++ [:tracks]
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

    %{artist_name => artist_albums_sorted}
  end

  defp sort_tracks({_album_name, album_info}) do
    album_info
    |> get_and_update_in([:tracks], fn tracks -> {tracks, Enum.sort_by(tracks, &Map.get(&1, :number))} end)
    |> elem(1)
  end

  defp key_for_storage(type, acc) do
    case elem(type, 0) do
      :various ->
        for album <- elem(type, 1) do
          album_key = {:collection, :various, album.id}
          [{album_key, album}] ++ acc
        end
      :single ->
        for artist <- elem(type, 1) do
          for album <- artist |> Map.to_list() |> List.first() |> elem(1) do
            album_key = {:collection, :single, album.id}
            [{album_key, album}] ++ acc
          end
        end
    end
  end
end
