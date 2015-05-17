defmodule Weebo.XMLInterface do
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse(xml_string, options \\ [quiet: true]) when is_binary(xml_string) do
    {doc, []} = xml_string
                |> :binary.bin_to_list
                |> :xmerl_scan.string(options)
    doc
  end

  def to_tree(xml) do
    node = {element_name(xml), []}
    to_tree(element_value(xml), node)
  end
  def to_tree([], tree), do: tree
  def to_tree(string, {name, children}) when is_binary(string) do
    to_tree([], {name, children ++ [string]})
  end
  def to_tree([head|tail], {name, children}) do
    new_node = cond do
      Record.is_record(head, :xmlText) ->
        element_value(head)
      true ->
        to_tree(element_value(head), {element_name(head), []})
    end

    cond do
      is_binary(new_node) and String.strip(new_node)|>String.length == 0 ->
        to_tree(tail, {name, children})
      true ->
        to_tree(tail, {name, children ++ [new_node]})
    end
  end

  def element_name(xmlElement(name: name)), do: name

  def element_value(xmlElement(content: [xmlText(value: value)])), do: to_string(value)
  def element_value(xmlText(value: value)), do: to_string(value)
  def element_value(xmlElement(content: list)) when is_list(list), do: list
end
