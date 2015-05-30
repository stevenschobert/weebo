defmodule Weebo.Call do
  defstruct method: nil, params: []
end

defimpl Weebo.Formattable, for: Weebo.Call do
  def format(%Weebo.Call{method: name, params: params}) do
    formatted_params = Enum.map params, fn(param) ->
      {:param, [{:value, [Weebo.Formattable.format(param)]}]}
    end
    {:methodCall, [{:methodName, [name]}, {:params, formatted_params}]}
  end
end
