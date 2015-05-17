defmodule Weebo do
  def cast(string) when is_bitstring(string) do
    parsed = Exml.parse(string)

    case get_type(parsed) do
      {:boolean, x} ->
        cast_boolean(x)
      {:integer, x} ->
        cast_integer(x)
      _ ->
        {:unknown_type, string}
    end
  end

  defp get_type(doc) do
    cond do
      Exml.get(doc, "/boolean")|>is_bitstring ->
        {:boolean, Exml.get(doc, "/boolean")}
      Exml.get(doc, "/int")|>is_bitstring ->
        {:integer, Exml.get(doc, "/int")}
      Exml.get(doc, "/i4")|>is_bitstring ->
        {:integer, Exml.get(doc, "/i4")}
      true -> :unknown
    end
  end

  defp cast_boolean("1"), do: true
  defp cast_boolean("0"), do: false

  defp cast_integer(int), do: String.to_integer(int)
end
