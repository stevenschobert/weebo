defmodule WeeboTest do
  use ExUnit.Case

  def unknown_type() do
    "<foo>bar</foo>"
  end

  def string_type(string) do
    "<string>#{string}</string>"
  end

  def boolean_type(true) do
    "<boolean>1</boolean>"
  end
  def boolean_type(false) do
    "<boolean>0</boolean>"
  end

  def int_type(num) do
    "<int>#{num}</int>"
  end

  def int_type_alt(num) do
    "<i4>#{num}</i4>"
  end

  def double_type(num) do
    "<double>#{num}</double>"
  end

  def base64_type(string) do
    "<base64>#{Base.encode64(string)}</base64>"
  end

  def member_type(name: name, type: type, value: val) do
    typed_value = apply(__MODULE__, String.to_atom("#{type}_type"), [val])
    "<member><name>#{name}</name><value>#{typed_value}</value></member>"
  end

  def array_type(list) when is_list(list) do
    {_, typed} = Enum.map_reduce list, "<array><data>", fn({type, value}, acc) ->
      typed_value = apply(__MODULE__, String.to_atom("#{type}_type"), [value])
      {{type, value}, "#{acc}<value>#{typed_value}</value>"}
    end
    "#{typed}</data></array>"
  end

  def struct_type(list) when is_list(list) do
    {_, typed} = Enum.map_reduce list, "<struct>", fn({name, type, value}, acc) ->
      member = member_type(name: name, type: type, value: value)
      {{name, type, value}, "#{acc}#{member}"}
    end
    "#{typed}</struct>"
  end

  test "#cast" do
    assert string_type("xmlrpc")|>Weebo.cast == "xmlrpc"
    assert base64_type("xmlrpc")|>Weebo.cast == "xmlrpc"

    assert boolean_type(true)|>Weebo.cast == true
    assert boolean_type(false)|>Weebo.cast == false

    assert int_type(5)|>Weebo.cast == 5
    assert int_type_alt(5)|>Weebo.cast == 5

    assert double_type(12.5)|>Weebo.cast == 12.5

    assert member_type(name: "foo", type: :string, value: "bar")|>Weebo.cast == {:foo, "bar"}

    assert array_type([{:boolean, true}, {:string, "hello"}, {:int, 40}])|>Weebo.cast == [true, "hello", 40]

    assert struct_type([{:foo, :string, "bar"}, {:number, :int, 40}, {:online, :boolean, false}])|>Weebo.cast == %{foo: "bar", number: 40, online: false}
  end
end
