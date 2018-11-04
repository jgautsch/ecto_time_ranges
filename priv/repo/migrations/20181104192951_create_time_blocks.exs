defmodule Ranges.Repo.Migrations.CreateTimeBlocks do
  use Ecto.Migration

  def change do
    create table(:time_blocks) do
      add(:tz_time_range, :tstzrange)
      add(:time_range, :tsrange)
    end

    create(index(:time_blocks, [:tz_time_range], using: :gist))
    create(index(:time_blocks, [:time_range], using: :gist))
  end
end
