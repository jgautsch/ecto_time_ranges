defmodule Postgrex.Extension.TSTZRange do
  @behaviour Ecto.Type

  def type, do: :tstzrange

  def cast({lower, upper}) do
    require IEx
    IEx.pry()

    case apply_func({lower, upper}, &Ecto.Type.cast(:utc_datetime, &1)) do
      {:ok, {lower, upper}} ->
        {:ok, {lower, upper}}

      :error ->
        :error
    end
  end

  def cast(_), do: :error

  def load(%Postgrex.Range{lower: lower, upper: upper}) do
    apply_func({lower, upper}, &Ecto.Type.load(:utc_datetime, &1))
  end

  def load(_), do: :error

  def dump({lower, upper}) do
    case apply_func({lower, upper}, &Ecto.Type.dump(:utc_datetime, &1)) do
      {:ok, {lower, upper}} ->
        {:ok, %Postgrex.Range{lower: lower, upper: upper, upper_inclusive: false}}

      :error ->
        :error
    end
  end

  def dump(_), do: :error

  def apply_func({lower, upper}, fun) do
    lower = do_apply_func(lower, fun)

    upper = do_apply_func(upper, fun)

    if lower != :error and upper != :error do
      {:ok, {lower, upper}}
    else
      :error
    end
  end

  def do_apply_func(target, fun) do
    case fun.(target) do
      {:ok, target} -> target
      :error -> :error
    end
  end
end
