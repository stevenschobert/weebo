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

  test "#cast" do
    assert string_type("xmlrpc")|>Weebo.cast == "xmlrpc"

    assert boolean_type(true)|>Weebo.cast == true
    assert boolean_type(false)|>Weebo.cast == false

    assert int_type(5)|>Weebo.cast == 5
    assert int_type_alt(5)|>Weebo.cast == 5

    assert double_type(12.5)|>Weebo.cast == 12.5
  end
end
