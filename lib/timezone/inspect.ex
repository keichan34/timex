defimpl Inspect, for: Timex.TimezoneInfo do

  def inspect(date, %{:structs => false} = opts) do
    Inspect.Algebra.to_doc(date, opts)
  end
  def inspect(tzinfo, _) do
    offset = format_offset(tzinfo.offset_std, tzinfo.offset_utc)
    "#<Timezone(#{tzinfo.full_name} - #{tzinfo.abbreviation} (#{offset}))>"
  end

  defp format_offset(offset_std, offset_utc) do
    offset_hours = div(offset_std + offset_utc, 60)
    offset_mins  = rem(offset_std + offset_utc, 60)
    hour  = "#{pad_numeric(offset_hours)}"
    min   = "#{pad_numeric(offset_mins)}"
    cond do
      (offset_hours + offset_mins) >= 0 -> "+#{hour}:#{min}"
      true -> "#{hour}:#{min}"
    end
  end

  defp pad_numeric(number) when is_integer(number), do: pad_numeric("#{number}")
  defp pad_numeric(<<?-, number_str::binary>>) do
    res = pad_numeric(number_str)
    <<?-, res::binary>>
  end
  defp pad_numeric(number_str) do
    min_width = 2
    len = String.length(number_str)
    cond do
      len < min_width -> String.duplicate("0", min_width - len) <> number_str
      true -> number_str
    end
  end
end

defimpl Inspect, for: Timex.AmbiguousTimezoneInfo do
  alias Timex.AmbiguousTimezoneInfo

  def inspect(date, %{:structs => false} = opts) do
    Inspect.Algebra.to_doc(date, opts)
  end
  def inspect(%AmbiguousTimezoneInfo{:before => before, :after => aft}, _opts) do
    "#<Ambiguous(#{inspect before} ~ #{inspect aft})>"
  end
end
