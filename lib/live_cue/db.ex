defmodule LiveCue.DB do
  def child_spec(_) do
    db_directory = Application.fetch_env!(:live_cue, :db_directory)

    %{
      id: __MODULE__,
      start: {CubDB, :start_link, [
        db_directory,
        [
          auto_file_sync: true,
          auto_compact: true,
          name: __MODULE__,
        ]
      ]}
    }
  end
end
