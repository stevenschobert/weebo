defmodule Weebo.Response do
  defstruct error: nil, params: []
end

defimpl Weebo.Formattable, for: Weebo.Response do
  def format(response) do
    case response do
      %Weebo.Response{error: nil, params: params} ->
        mapped_params = Enum.map params, fn(param) ->
          {:param, [{:value, [Weebo.Formattable.format(param)]}]}
        end
        {:methodResponse, [{:params, mapped_params}]}
      %Weebo.Response{error: error, params: []} ->
        {:methodResponse, [{:fault, [{:value, [Weebo.Formattable.format(error)]}]}]}
    end
  end
end
