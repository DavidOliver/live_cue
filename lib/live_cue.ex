defmodule LiveCue do
  @moduledoc """
  LiveCue keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias LiveCue.{Collection}

  defdelegate(store_collection_data(), [to: Collection])
end
