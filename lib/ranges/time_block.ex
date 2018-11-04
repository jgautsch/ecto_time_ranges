defmodule Ranges.TimeBlock do
  use Ecto.Schema
  import Ecto.Changeset

  schema "time_blocks" do
    field(:tz_time_range, Postgrex.Extension.TSTZRange)
    field(:time_range, Postgrex.Extension.TSRange)
  end

  def changeset(time_block, attrs) do
    time_block
    |> cast(attrs, [:tz_time_range, :time_range])
  end
end
