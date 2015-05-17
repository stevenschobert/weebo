defmodule Weebo do
  alias Weebo.XMLInterface, as: XML

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
  def cast(val) do
    {:unknown_type, val}
  end
 end
