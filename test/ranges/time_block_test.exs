defmodule Ranges.TimeBlockTest do
  use Ranges.DataCase

  import Ranges.RangeQuery

  alias Ranges.TimeBlock

  def time_block_factory(attrs \\ %{}) do
    {:ok, time_block} =
      %TimeBlock{}
      |> TimeBlock.changeset(attrs)
      |> Repo.insert()

    time_block
  end

  describe "tstzrange" do
    test "inserting a tztsrange with DateTimes" do
      # Inputs are DateTimes
      {:ok, start, 0} = DateTime.from_iso8601("2018-11-04T09:00:00Z")
      {:ok, finish, 0} = DateTime.from_iso8601("2018-11-04T10:00:00Z")

      attrs = %{
        tz_time_range: {start, finish}
      }

      time_block = time_block_factory(attrs)

      # When returned from DB, tz_time_range should be a `{%DateTime{}, %DateTime{}}
      assert {%DateTime{} = s, %DateTime{} = f} = time_block.tz_time_range
      assert s == start
      assert f == finish
    end

    test "inserting a tztsrange with NaiveDateTimes" do
      # Inputs are NaiveDateTimes
      start = ~N[2018-11-04 09:00:00]
      finish = ~N[2018-11-04 10:00:00]

      attrs = %{
        tz_time_range: {start, finish}
      }

      time_block = time_block_factory(attrs)

      # When returned from DB, tz_time_range should be a `{%DateTime{}, %DateTime{}}`
      assert {%DateTime{} = s, %DateTime{} = f} = time_block.tz_time_range
      assert s == DateTime.from_naive!(start, "Etc/UTC")
      assert f == DateTime.from_naive!(finish, "Etc/UTC")
    end

    test "respecting Timezone <-> UTC conversion within :tz_time_range" do
      # Set up a start and end time that won't depend on when in the day this test is run.
      start =
        Timex.now("US/Central")
        |> Timex.beginning_of_day()
        |> Timex.shift(hours: 5)

      finish = Timex.shift(start, hours: 3)

      # Now create a time_block
      attrs = %{
        tz_time_range: {start, finish}
      }

      # Create the time_block
      %{id: id} = time_block_factory(attrs)

      # Get time_block fresh from DB
      time_block = Repo.get(TimeBlock, id)

      {block_start, block_finish} = time_block.tz_time_range

      assert block_start.time_zone == "Etc/UTC"
      assert block_finish.time_zone == "Etc/UTC"

      # Convert the start/finish to our time zone
      block_start = Timex.Timezone.convert(block_start, "US/Central")
      block_finish = Timex.Timezone.convert(block_finish, "US/Central")

      # Expect the time in our time zone to have been preserved
      assert Timex.equal?(block_start, start)
      assert Timex.equal?(block_finish, finish)
      assert block_start.time_zone == "US/Central"
      assert block_finish.time_zone == "US/Central"
    end

    test "querying for overlapping ranges with a window of DateTimes" do
      # Block1: 9:00 UTC to 10:00 UTC
      {:ok, start, 0} = DateTime.from_iso8601("2018-11-04T09:00:00Z")
      {:ok, finish, 0} = DateTime.from_iso8601("2018-11-04T10:00:00Z")
      time_block1 = time_block_factory(%{tz_time_range: {start, finish}})

      # Block2: 12:00 UTC to 13:00 UTC
      {:ok, start, 0} = DateTime.from_iso8601("2018-11-04T12:00:00Z")
      {:ok, finish, 0} = DateTime.from_iso8601("2018-11-04T13:00:00Z")
      time_block2 = time_block_factory(%{tz_time_range: {start, finish}})

      # 9:30 UTC to 10:30 UTC (2:30 -7:00 to 3:30 -7:00) as the overlap query window
      {:ok, s, _} = DateTime.from_iso8601("2018-11-04T02:30:00-07:00")
      {:ok, f, _} = DateTime.from_iso8601("2018-11-04T03:30:00-07:00")

      # Get time_blocks where :time_range overlaps query_window_range
      q = from(tb in TimeBlock, where: overlaps(tstzrange(^s, ^f), tb.tz_time_range))
      results = Repo.all(q)

      # Only time_block1 should be returned
      assert Enum.map(results, & &1.id) == [time_block1.id]
    end
  end

  describe "tsrange" do
    test "inserting a tsrange with NaiveDateTimes" do
      start = ~N[2018-11-04 09:00:00]
      finish = ~N[2018-11-04 10:00:00]

      attrs = %{
        time_range: {start, finish}
      }

      time_block = time_block_factory(attrs)

      # When returned from DB, time_range should be a `{%NaiveDateTime{}, %NaiveDateTime{}}`
      {%NaiveDateTime{} = s, %NaiveDateTime{} = f} = time_block.time_range
      assert s == start
      assert f == finish
    end

    test "inserting a tsrange with DateTime" do
      {:ok, start, 0} = DateTime.from_iso8601("2018-11-04T09:00:00Z")
      {:ok, finish, 0} = DateTime.from_iso8601("2018-11-04T10:00:00Z")

      attrs = %{
        time_range: {start, finish}
      }

      time_block = time_block_factory(attrs)

      # When returned from DB, time_range should be a `{%NaiveDateTime{}, %NaiveDateTime{}}`
      {%NaiveDateTime{} = s, %NaiveDateTime{} = f} = time_block.time_range
      assert s == DateTime.to_naive(start)
      assert f == DateTime.to_naive(finish)
    end

    test "querying for overlapping ranges with a window of NaiveDateTimes" do
      # Block1: 9:00 UTC to 10:00 UTC
      time_block1 =
        time_block_factory(%{
          time_range: {~N[2018-11-04 09:00:00], ~N[2018-11-04 10:00:00]}
        })

      # Block2: 12:00 UTC to 13:00 UTC
      time_block2 =
        time_block_factory(%{
          time_range: {~N[2018-11-04 12:00:00], ~N[2018-11-04 13:00:00]}
        })

      # 9:30 UTC to 10:30 UTC as the overlap query window
      query_window_range = {~N[2018-11-04 09:30:00], ~N[2018-11-04 10:30:00]}
      {s, f} = query_window_range

      # Get time_blocks where :time_range overlaps query_window_range
      q = from(tb in TimeBlock, where: overlaps(tsrange(^s, ^f), tb.time_range))
      results = Repo.all(q)

      # Only time_block1 should be returned
      assert Enum.map(results, & &1.id) == [time_block1.id]
    end

    test "querying for overlapping ranges with a window of DateTimes" do
      # Block1: 9:00 UTC to 10:00 UTC
      time_block1 =
        time_block_factory(%{
          time_range: {~N[2018-11-04 09:00:00], ~N[2018-11-04 10:00:00]}
        })

      # Block2: 12:00 UTC to 13:00 UTC
      time_block2 =
        time_block_factory(%{
          time_range: {~N[2018-11-04 12:00:00], ~N[2018-11-04 13:00:00]}
        })

      # 9:30 UTC to 10:30 UTC (2:30 -7:00 to 3:30 -7:00) as the overlap query window
      {:ok, s, _} = DateTime.from_iso8601("2018-11-04T02:30:00-07:00")
      {:ok, f, _} = DateTime.from_iso8601("2018-11-04T03:30:00-07:00")

      # Get time_blocks where :time_range overlaps query_window_range
      q = from(tb in TimeBlock, where: overlaps(tsrange(^s, ^f), tb.time_range))
      results = Repo.all(q)

      # Only time_block1 should be returned
      assert Enum.map(results, & &1.id) == [time_block1.id]
    end
  end
end
