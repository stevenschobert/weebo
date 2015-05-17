defmodule Weebo do
  def cast(string) when is_bitstring(string) do
    parsed = Exml.parse(string)

    case get_type(parsed) do
      {:boolean, x} ->
        cast_boolean(x)
      {:integer, x} ->
        cast_integer(x)
      {:double, x} ->
        cast_double(x)
      {:base64, x} ->
        cast_base64(x)
      {:string, x} ->
        x
      _ ->
        {:unknown_type, string}
    end
  end

  defp get_type(doc) do
    cond do
      Exml.get(doc, "/string")|>is_bitstring ->
        {:string, Exml.get(doc, "/string")}
      Exml.get(doc, "/boolean")|>is_bitstring ->
        {:boolean, Exml.get(doc, "/boolean")}
      Exml.get(doc, "/int")|>is_bitstring ->
        {:integer, Exml.get(doc, "/int")}
      Exml.get(doc, "/i4")|>is_bitstring ->
        {:integer, Exml.get(doc, "/i4")}
      Exml.get(doc, "/double")|>is_bitstring ->
        {:double, Exml.get(doc, "/double")}
      Exml.get(doc, "/base64")|>is_bitstring ->
        {:base64, Exml.get(doc, "/base64")}
      true -> :unknown
    end
  end

  defp cast_boolean("1"), do: true
  defp cast_boolean("0"), do: false

  defp cast_integer(int), do: String.to_integer(int)
  defp cast_double(double), do: String.to_float(double)

  defp cast_base64(string), do: Base.decode64!(string)
end
