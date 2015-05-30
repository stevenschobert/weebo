defmodule Weebo do
  alias Weebo.XMLInterface, as: XML
  alias Weebo.Formattable

  def format(object) do
    Formattable.format(object)|>XML.from_tree|>XML.export
  end

  def parse(string) when is_bitstring(string) do
    parsed = XML.parse(string)|>XML.to_tree
    case parsed do
      {:methodCall, [{:methodName, [name]}, {:params, params}]} ->
        %Weebo.Call{method: name, params: Enum.map(params, &cast/1)}
      {:methodResponse, [{:params, params}]} ->
        %Weebo.Response{error: nil, params: Enum.map(params, &cast/1)}
      {:methodResponse, [{:fault, [error]}]} ->
        %Weebo.Response{error: cast(error)}
    end
  end

  def cast(string) when is_bitstring(string) do
    XML.parse(string)|>XML.to_tree|>cast
  end

  def cast({:string, [string]}), do: string
  def cast({:boolean, ["1"]}), do: true
  def cast({:boolean, ["0"]}), do: false
  def cast({:int, [int]}), do: String.to_integer(int)
  def cast({:i4, [int]}), do: String.to_integer(int)
  def cast({:double, [double]}), do: String.to_float(double)
  def cast({:base64, [string]}), do: Base.decode64!(string)
  def cast({:"dateTime.iso8601", [value]}), do: :iso8601.parse(value)
  def cast({:array, [{:data, items}]}), do: Enum.map(items, &cast/1)
  def cast({:member, [{:name, [name]}, value]}), do: {String.to_atom(name), cast(value)}
  def cast({:struct, members}) do
    {_, casted} = Enum.map_reduce members, %{}, fn(member, acc) ->
      {name, value} = cast(member)
      {member, Map.put(acc, name, value)}
    end
    casted
  end
  def cast({:value, [value]}), do: cast(value)
  def cast({:param, [value]}), do: cast(value)
  def cast({:nil, []}), do: nil
  def cast(val) do
    {:unknown_type, val}
  end
 end
