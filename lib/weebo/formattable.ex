defprotocol Weebo.Formattable do
  @fallback_to_any true

  @doc "Returns an Weebo XMLInterface tree ready for serialization."
  def format(data)
end

defimpl Weebo.Formattable, for: BitString do
  def format(string), do: {:string, [string]}
end

defimpl Weebo.Formattable, for: Integer do
  def format(int), do: {:int, [Integer.to_string(int)]}
end

defimpl Weebo.Formattable, for: Float do
  def format(float), do: {:double, ["#{float}"]}
end

defimpl Weebo.Formattable, for: List do
  def format(list) do
    values = Enum.map list, fn(item) -> {:value, [Weebo.Formattable.format(item)]} end
    {:array, [{:data, values}]}
  end
end

defimpl Weebo.Formattable, for: Map do
  def format(map) do
    entries = Enum.map map, fn({k, v}) ->
      {:member, [{:name, ["#{k}"]}, {:value, [Weebo.Formattable.format(v)]}]}
    end
    {:struct, entries}
  end
end

defimpl Weebo.Formattable, for: Any do
  def format(nil), do: {:nil, []}
  def format(true), do: {:boolean, ["1"]}
  def format(false), do: {:boolean, ["0"]}
  def format({{_,_,_}, {_,_,_}} = time), do: {:"dateTime.iso8601", [:iso8601.format(time)]}
end
