defmodule LiveCueWeb.ViewHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  def artist_map_name(artist) when is_map(artist) do
    artist |> Map.keys() |> List.first()
  end

  def artist_map_albums(artist) when is_map(artist) do
    artist |> Map.values() |> List.first()
  end
end
