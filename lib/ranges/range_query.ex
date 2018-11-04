defmodule Ranges.RangeQuery do
  defmacro tsrange(lower, upper) do
    quote(do: fragment("tsrange(?, ?)", unquote(lower), unquote(upper)))
  end

  defmacro tstzrange(lower, upper) do
    quote(do: fragment("tstzrange(?, ?)", unquote(lower), unquote(upper)))
  end

  defmacro overlaps(range, value) do
    quote(do: fragment("? && ?", unquote(range), unquote(value)))
  end
end
