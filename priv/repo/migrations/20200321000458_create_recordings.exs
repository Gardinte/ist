defmodule Ist.Repo.Migrations.CreateRecordings do
  use Ist, :migration

  def change do
    if prefix = prefix() do
      do_change(prefix)
    else
      for prefix <- account_prefixes(), do: do_change(prefix)
    end
  end

  defp do_change(prefix) do
    create table(:recordings, prefix: prefix) do
      add :uuid, :string, null: false
      add :file, :string, null: false
      add :content_type, :string, null: false
      add :size, :bigint, null: false
      add :generation, :bigint, null: false
      add :started_at, :utc_datetime, null: false
      add :ended_at, :utc_datetime, null: false
      add :device_id, references(:devices, on_delete: :nilify_all)

      timestamps type: :utc_datetime
    end

    create unique_index(:recordings, [:uuid], prefix: prefix)
    create index(:recordings, [:started_at], prefix: prefix)
    create index(:recordings, [:device_id], prefix: prefix)
  end
end
