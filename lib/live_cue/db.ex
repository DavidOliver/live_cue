defmodule LiveCue.DB do
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {CubDB, :start_link, [
        Application.get_env(:live_cue, :db_location, "/tmp/live_cue"),
        [
          auto_file_sync: true,
          auto_compact: true,
          name: __MODULE__,
        ]
      ]}
    }
  end
end
